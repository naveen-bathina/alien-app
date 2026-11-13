import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myalien/metadata/models/metadata_option.dart';

/// Repository managing dynamic retrieval and creation of Activity Types and Looking For intentions.
class MetadataRepository {
  MetadataRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  FirebaseFirestore? get _fs {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  FirebaseAuth? get _fa {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  // --- Curated Standard Defaults (Fallback & Seeding) ---

  static const List<MetadataOption> defaultActivities = [
    MetadataOption(
      id: 'coffee-chat',
      title: 'Coffee & Chat',
      subtitle: 'Specialty cafe catchup, boba, and relaxed conversation',
      category: 'Food & Drink',
      iconName: 'local_cafe_rounded',
    ),
    MetadataOption(
      id: 'dinner-companion',
      title: 'Dinner Companion',
      subtitle: 'Fine dining, culinary exploration, and evening dinners',
      category: 'Food & Drink',
      iconName: 'restaurant_rounded',
    ),
    MetadataOption(
      id: 'live-music-art',
      title: 'Live Music & Art',
      subtitle: 'Concerts, indie gigs, gallery showcases, and comedy shows',
      category: 'Entertainment',
      iconName: 'palette_rounded',
    ),
    MetadataOption(
      id: 'city-explorer',
      title: 'City Explorer',
      subtitle: 'Local sightseeing, shopping tours, and hidden street gems',
      category: 'Social',
      iconName: 'explore_rounded',
    ),
    MetadataOption(
      id: 'movie-entertainment',
      title: 'Movie & Entertainment',
      subtitle: 'Cinema screenings, film festivals, and IMAX experiences',
      category: 'Entertainment',
      iconName: 'movie_rounded',
    ),
    MetadataOption(
      id: 'fitness-workout',
      title: 'Fitness / Workout',
      subtitle: 'Gym buddy, morning jog, badminton, or yoga session',
      category: 'Active',
      iconName: 'fitness_center_rounded',
    ),
    MetadataOption(
      id: 'study-coworking',
      title: 'Study & Co-working',
      subtitle: 'Quiet library focus, work sessions, or project collaboration',
      category: 'Work & Study',
      iconName: 'menu_book_rounded',
    ),
    MetadataOption(
      id: 'board-games',
      title: 'Board Games & Arcade',
      subtitle: 'Arcade gaming, tabletop strategy games, and trivia nights',
      category: 'Entertainment',
      iconName: 'sports_esports_rounded',
    ),
  ];

  static const List<MetadataOption> defaultIntentions = [
    MetadataOption(
      id: 'cafe-catchups',
      title: 'Cafe Catchups',
      subtitle: 'Casual coffee, boba, and quick catchups',
      iconName: 'local_cafe',
    ),
    MetadataOption(
      id: 'event-companion',
      title: 'Event Companion',
      subtitle: 'Weddings, concerts, galas, and social events',
      iconName: 'celebration',
    ),
    MetadataOption(
      id: 'activity-partner',
      title: 'Activity Partner',
      subtitle: 'Workouts, hiking, sports, and weekend hobbies',
      iconName: 'fitness_center_rounded',
    ),
    MetadataOption(
      id: 'long-term-relationship',
      title: 'Long-term relationship',
      subtitle: 'Dating with genuine long-term intent',
      iconName: 'favorite_outline_rounded',
    ),
    MetadataOption(
      id: 'something-casual',
      title: 'Something casual',
      subtitle: 'Relaxed, friendly hangouts without pressure',
      iconName: 'weekend_outlined',
    ),
    MetadataOption(
      id: 'new-friends',
      title: 'New friends',
      subtitle: 'Expanding social circle and meeting new minds',
      iconName: 'people_outline_rounded',
    ),
  ];

  // In-memory cache for dynamic additions when offline or during tests
  final List<MetadataOption> _inMemoryActivities = [];
  final List<MetadataOption> _inMemoryIntentions = [];

  final _activityStreamController = StreamController<List<MetadataOption>>.broadcast();
  final _intentionStreamController = StreamController<List<MetadataOption>>.broadcast();

  /// Watch available Activity Types in real-time from Firestore, falling back to defaults.
  Stream<List<MetadataOption>> watchActivityTypes() {
    final fs = _fs;
    if (fs == null) {
      return Stream.value([...defaultActivities, ..._inMemoryActivities]);
    }

    try {
      return fs.collection('activity_types').snapshots().map((snap) {
        final firestoreList = snap.docs
            .map((doc) => MetadataOption.fromMap(doc.data(), docId: doc.id))
            .toList();

        return _mergeOptions(defaultActivities, firestoreList, _inMemoryActivities);
      }).handleError((_) {
        return [...defaultActivities, ..._inMemoryActivities];
      });
    } on Object {
      return Stream.value([...defaultActivities, ..._inMemoryActivities]);
    }
  }

  /// Watch available 'Looking For' intentions in real-time from Firestore.
  Stream<List<MetadataOption>> watchLookingForIntentions() {
    final fs = _fs;
    if (fs == null) {
      return Stream.value([...defaultIntentions, ..._inMemoryIntentions]);
    }

    try {
      return fs.collection('looking_for_intentions').snapshots().map((snap) {
        final firestoreList = snap.docs
            .map((doc) => MetadataOption.fromMap(doc.data(), docId: doc.id))
            .toList();

        return _mergeOptions(defaultIntentions, firestoreList, _inMemoryIntentions);
      }).handleError((_) {
        return [...defaultIntentions, ..._inMemoryIntentions];
      });
    } on Object {
      return Stream.value([...defaultIntentions, ..._inMemoryIntentions]);
    }
  }

  /// Merges standard defaults, Firestore documents, and in-memory entries without duplicates.
  List<MetadataOption> _mergeOptions(
    List<MetadataOption> defaults,
    List<MetadataOption> firestore,
    List<MetadataOption> inMemory,
  ) {
    final map = <String, MetadataOption>{};

    for (final opt in defaults) {
      map[opt.title.toLowerCase().trim()] = opt;
    }
    for (final opt in firestore) {
      map[opt.title.toLowerCase().trim()] = opt;
    }
    for (final opt in inMemory) {
      map[opt.title.toLowerCase().trim()] = opt;
    }

    return map.values.toList();
  }

  /// Add a brand new custom activity type (e.g. `Netflix and Chill`) and persist to Firestore.
  Future<MetadataOption> addCustomActivityType({
    required String title,
    String? subtitle,
    String? category,
  }) async {
    final trimmedTitle = title.trim();
    final slug = trimmedTitle.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    final iconName = MetadataOption.resolveIconNameFromTitle(trimmedTitle);
    final user = _fa?.currentUser?.uid ?? 'guest';

    final newOption = MetadataOption(
      id: slug,
      title: trimmedTitle,
      subtitle: subtitle?.trim().isNotEmpty == true
          ? subtitle!.trim()
          : 'Relaxed hangout & activities',
      category: category ?? 'Entertainment',
      iconName: iconName,
      isCustom: true,
      createdBy: user,
    );

    _inMemoryActivities.add(newOption);

    final fs = _fs;
    if (fs != null) {
      try {
        await fs
            .collection('activity_types')
            .doc(slug)
            .set(newOption.toMap(), SetOptions(merge: true));
      } on Object {
        // Ignored if offline; in-memory copy ensures UI stays updated
      }
    }

    return newOption;
  }

  /// Add a brand new 'Looking For' intention (e.g. `Netflix and Chill`) and persist to Firestore.
  Future<MetadataOption> addCustomLookingFor({
    required String title,
    String? subtitle,
  }) async {
    final trimmedTitle = title.trim();
    final slug = trimmedTitle.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    final iconName = MetadataOption.resolveIconNameFromTitle(trimmedTitle);
    final user = _fa?.currentUser?.uid ?? 'guest';

    final newOption = MetadataOption(
      id: slug,
      title: trimmedTitle,
      subtitle: subtitle?.trim().isNotEmpty == true
          ? subtitle!.trim()
          : 'Connecting for shared hangouts',
      iconName: iconName,
      isCustom: true,
      createdBy: user,
    );

    _inMemoryIntentions.add(newOption);

    final fs = _fs;
    if (fs != null) {
      try {
        await fs
            .collection('looking_for_intentions')
            .doc(slug)
            .set(newOption.toMap(), SetOptions(merge: true));
      } on Object {
        // Ignored if offline; in-memory copy ensures UI stays updated
      }
    }

    return newOption;
  }
}

/// Global singleton instance
final metadataRepository = MetadataRepository();

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';
import 'package:myalien/matches/models/match_entry.dart';

class MatchesRepository {
  MatchesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _fs = firestore,
        _auth = auth {
    _initSeededEntries();
  }

  static final MatchesRepository instance = MatchesRepository();

  final FirebaseFirestore? _fs;
  final FirebaseAuth? _auth;

  final StreamController<List<MatchEntry>> _matchesController =
      StreamController<List<MatchEntry>>.broadcast();

  final List<MatchEntry> _entries = [];

  Stream<List<MatchEntry>> get matchesStream async* {
    yield List.unmodifiable(_entries);
    yield* _matchesController.stream;
  }

  List<MatchEntry> get currentEntries => List.unmodifiable(_entries);

  void _initSeededEntries() {
    final candidates = HomeProfileRepository.sampleCandidates();
    final profileMap = {for (final p in candidates) p.uid: p};

    final maya = profileMap['sample_maya_1'];
    final vikram = profileMap['sample_vikram_2'];
    final priya = profileMap['sample_priya_3'];
    final arjun = profileMap['sample_arjun_4'];
    final ananya = profileMap['sample_ananya_5'];

    final zoya = Profile(
      uid: 'sample_zoya_7',
      name: 'Zoya Akhtar',
      dob: DateTime(2002, 6, 14),
      gender: 'Woman',
      location: 'Jubilee Hills, Hyderabad',
      coinsPerHour: 150,
      tagline: 'Cinephile & Board Game Geek',
      rating: 4.97,
      reviewsCount: 38,
      bio: 'Loves foreign cinema, strategy board games, and exploring rooftop '
          'cafes. Looking for witty conversations, movie marathons, and fun '
          'events across town.',
      lookingFor: 'Board Games & Movie Buddies',
      photos: const [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
      ],
      availability: const ProfileAvailability(
        statusText: 'Available Tonight',
        availableDays: ['Fri', 'Sat', 'Sun'],
        timeWindow: '6:00 PM – 11:00 PM',
      ),
    );

    _entries.clear();

    // 1. Mutually Liked
    if (maya != null) {
      _entries.add(
        MatchEntry(
          profile: maya,
          relation: MatchRelationType.mutuallyLiked,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
    }

    // 2. Mutually Superliked
    _entries.add(
      MatchEntry(
        profile: zoya,
        relation: MatchRelationType.mutuallySuperliked,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    );

    // 3. Liked You (Received Like)
    if (priya != null) {
      _entries.add(
        MatchEntry(
          profile: priya,
          relation: MatchRelationType.receivedLike,
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      );
    }

    // 4. Superliked You (Received Superlike)
    if (ananya != null) {
      _entries.add(
        MatchEntry(
          profile: ananya,
          relation: MatchRelationType.receivedSuperlike,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
    }

    // 5. You Liked (Sent Like)
    if (vikram != null) {
      _entries.add(
        MatchEntry(
          profile: vikram,
          relation: MatchRelationType.sentLike,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );
    }

    // 6. You Superliked (Sent Superlike)
    if (arjun != null) {
      _entries.add(
        MatchEntry(
          profile: arjun,
          relation: MatchRelationType.sentSuperlike,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
      );
    }
  }

  /// Convert a received like or superlike into a mutual match by liking back.
  Future<void> likeBack(Profile profile) async {
    final index = _entries.indexWhere((e) => e.profile.uid == profile.uid);
    if (index >= 0) {
      final current = _entries[index];
      final newRelation =
          current.relation == MatchRelationType.receivedSuperlike
              ? MatchRelationType.mutuallySuperliked
              : MatchRelationType.mutuallyLiked;

      _entries[index] = current.copyWith(
        relation: newRelation,
        timestamp: DateTime.now(),
      );
    } else {
      _entries.insert(
        0,
        MatchEntry(
          profile: profile,
          relation: MatchRelationType.mutuallyLiked,
          timestamp: DateTime.now(),
        ),
      );
    }

    _notify();
    await _persistAction(profile.uid, 'like');
  }

  /// Convert a received like or superlike into a mutual superlike match.
  Future<void> superlikeBack(Profile profile) async {
    final index = _entries.indexWhere((e) => e.profile.uid == profile.uid);
    if (index >= 0) {
      final current = _entries[index];
      _entries[index] = current.copyWith(
        relation: MatchRelationType.mutuallySuperliked,
        timestamp: DateTime.now(),
      );
    } else {
      _entries.insert(
        0,
        MatchEntry(
          profile: profile,
          relation: MatchRelationType.mutuallySuperliked,
          timestamp: DateTime.now(),
        ),
      );
    }

    _notify();
    await _persistAction(profile.uid, 'superlike');
  }

  /// Record an outgoing action triggered from Discover or FullProfileScreen.
  Future<void> recordOutgoingAction(Profile profile, String type) async {
    final index = _entries.indexWhere((e) => e.profile.uid == profile.uid);
    if (index >= 0) {
      final existing = _entries[index];
      if (existing.isReceived) {
        if (type == 'superlike' ||
            existing.relation == MatchRelationType.receivedSuperlike) {
          _entries[index] = existing.copyWith(
            relation: MatchRelationType.mutuallySuperliked,
            timestamp: DateTime.now(),
          );
        } else {
          _entries[index] = existing.copyWith(
            relation: MatchRelationType.mutuallyLiked,
            timestamp: DateTime.now(),
          );
        }
        _notify();
        await _persistAction(profile.uid, type);
        return;
      }
    }

    // New outgoing action
    final relation = type == 'superlike'
        ? MatchRelationType.sentSuperlike
        : MatchRelationType.sentLike;

    if (index >= 0) {
      _entries[index] = _entries[index].copyWith(
        relation: relation,
        timestamp: DateTime.now(),
      );
    } else {
      _entries.insert(
        0,
        MatchEntry(
          profile: profile,
          relation: relation,
          timestamp: DateTime.now(),
        ),
      );
    }

    _notify();
    await _persistAction(profile.uid, type);
  }

  Future<void> _persistAction(String targetUid, String type) async {
    try {
      final auth = _auth ?? FirebaseAuth.instance;
      final fs = _fs ?? FirebaseFirestore.instance;
      final me = auth.currentUser;
      if (me == null) return;

      await fs
          .collection('users')
          .doc(me.uid)
          .collection('actions')
          .doc(targetUid)
          .set({
        'targetUid': targetUid,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also mark received action on target user for two-way mutual detection
      await fs
          .collection('users')
          .doc(targetUid)
          .collection('received_actions')
          .doc(me.uid)
          .set({
        'sourceUid': me.uid,
        'targetUid': targetUid,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on Object catch (e) {
      debugPrint('Firestore persistence notice: $e');
    }
  }

  void _notify() {
    if (!_matchesController.isClosed) {
      _matchesController.add(List.unmodifiable(_entries));
    }
  }

  /// Helper for unit tests to clear entries or reset state.
  void clearMemoryEntries() {
    _entries.clear();
    _notify();
  }

  /// Reset to standard sample seed
  void resetToSampleSeed() {
    _initSeededEntries();
    _notify();
  }

  void dispose() {
    _matchesController.close();
  }
}

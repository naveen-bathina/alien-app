import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myalien/home/models/profile_model.dart';

class HomeProfileRepository {
  HomeProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _fs = firestore ?? _safeFirestore,
        _auth = auth ?? _safeAuth;

  static FirebaseFirestore? get _safeFirestore {
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  static FirebaseAuth? get _safeAuth {
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  final FirebaseFirestore? _fs;
  final FirebaseAuth? _auth;

  Stream<List<Profile>> streamCandidates({int limit = 50}) {
    if (_fs == null) {
      return Stream.value(sampleCandidates());
    }
    final me = _auth?.currentUser;
    final q = _fs
        .collection('users')
        .where('uid', isNotEqualTo: me?.uid)
        .limit(limit);

    return q.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Profile.fromMap(d.data()))
          .where((p) => p.isDiscoveryActive)
          .toList();
      if (list.isEmpty) {
        return sampleCandidates();
      }
      return list;
    }).handleError((Object _) => sampleCandidates());
  }

  Future<void> recordAction({
    required String targetUid,
    required String type,
  }) async {
    if (_fs == null) return;
    final me = _auth?.currentUser;
    if (me == null) return;
    try {
      final actionRef = _fs
          .collection('users')
          .doc(me.uid)
          .collection('actions')
          .doc(targetUid);
      await actionRef.set({
        'targetUid': targetUid,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on Object {}
  }

  static List<Profile> sampleCandidates() {
    return [
      Profile(
        uid: 'sample_maya_1',
        name: 'Maya Rao',
        dob: DateTime(2001, 4, 18),
        gender: 'Woman',
        location: 'Roastery Coffee House, Jubilee Hills',
        isLocationFlexible: false,
        tagline: 'Coffee Connoisseur & Tech Enthusiast',
        rating: 4.95,
        reviewsCount: 28,
        bio: 'Passionate about specialty coffee, indie games, and long '
            'conversations about sci-fi films. Available as a friendly event '
            'companion, cafe buddy, and city guide around Hyderabad.',
        lookingFor: 'New friends & fun hangouts',
        photos: [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
          timeWindow: '5:00 PM – 10:00 PM',
        ),
      ),
      Profile(
        uid: 'sample_vikram_2',
        name: 'Vikram Mehta',
        dob: DateTime(1998, 9, 12),
        gender: 'Man',
        location: 'Madhapur, Hyderabad',
        role: 'Sponsor',
        coinsPerHour: null,
        tagline: 'Angel Investor & Foodie',
        rating: 4.88,
        reviewsCount: 19,
        bio: 'Love hosting group dinners, trying out new fine dining spots, '
            'and meeting creative minds. Always happy to sponsor a great table '
            'and share insightful conversations.',
        lookingFor: 'Dinner companions & interesting chats',
        photos: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          statusText: 'Hosting This Weekend',
          availableDays: ['Fri', 'Sat', 'Sun'],
          timeWindow: '7:00 PM – 11:30 PM',
        ),
      ),
      Profile(
        uid: 'sample_priya_3',
        name: 'Priya Sharma',
        dob: DateTime(2000, 2, 24),
        gender: 'Woman',
        location: 'Banjara Hills, Hyderabad',
        coinsPerHour: 120,
        tagline: 'Art Curator & Yoga Instructor',
        rating: 4.98,
        reviewsCount: 42,
        bio: 'Gallery curator by day, vinyl record collector by night. '
            'I bring lively positive vibes to gallery openings, art walks, '
            'wellness workshops, and quiet cafe work sessions.',
        lookingFor: 'Art enthusiasts & genuine connections',
        photos: [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&q=80',
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          statusText: 'Available Tomorrow',
          availableDays: ['Tue', 'Thu', 'Sat', 'Sun'],
          timeWindow: '4:00 PM – 9:00 PM',
        ),
      ),
      Profile(
        uid: 'sample_arjun_4',
        name: 'Arjun Verma',
        dob: DateTime(1999, 11, 5),
        gender: 'Man',
        location: 'Gachibowli, Hyderabad',
        coinsPerHour: 60,
        tagline: 'Fitness Coach & Adventure Trekker',
        rating: 4.91,
        reviewsCount: 22,
        bio: 'Into badminton, cross-country cycling, bouldering, and weekend '
            'treks. If you need a workout partner or an adventurous buddy to '
            'explore nature trails with, hit me up!',
        lookingFor: 'Activity partners & gym buddies',
        photos: [
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '6:00 AM – 11:00 AM & 5:00 PM – 9:00 PM',
        ),
      ),
      Profile(
        uid: 'sample_ananya_5',
        name: 'Ananya Roy',
        dob: DateTime(2003, 7, 19),
        gender: 'Woman',
        location: 'Indiranagar, Bangalore',
        coinsPerHour: 90,
        tagline: 'Indie Musician & Cafe Hopper',
        rating: 4.96,
        reviewsCount: 31,
        bio: 'Guitarist and singer-songwriter. Love acoustic cafe sets, '
            'vintage thrift hunting, and discovering local underground bands.',
        lookingFor: 'Live Music & Art',
        photos: const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '2:00 PM – 9:00 PM',
        ),
      ),
      Profile(
        uid: 'sample_rohit_6',
        name: 'Rohit Khanna',
        dob: DateTime(1994, 3, 10),
        gender: 'Man',
        location: 'Bandra West, Mumbai',
        role: 'Sponsor',
        tagline: 'Tech Founder & Gourmet Explorer',
        rating: 4.85,
        reviewsCount: 16,
        bio: 'Angel investor and food enthusiast. Always eager to sponsor '
            'dinner tables, talk technology, and explore new city rooftop venues.',
        lookingFor: 'Dinner Companion',
        photos: const [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          statusText: 'Hosting This Weekend',
          availableDays: ['Fri', 'Sat', 'Sun'],
          timeWindow: '7:00 PM – 11:00 PM',
        ),
      ),
    ];
  }
}

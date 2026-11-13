import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myalien/models/hangout_request.dart';
import 'package:myalien/models/profile_model.dart';

/// Service responsible for generating and seeding 10 diverse synthetic
/// profiles and test scenarios into Cloud Firestore.
class SyntheticDataSeeder {
  const SyntheticDataSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  /// 10 diverse synthetic profiles representing various roles, cities,
  /// gender preferences, rates, and availability scenarios.
  static List<Profile> get syntheticProfiles {
    return [
      // 1. Earner - Hyderabad - Coffee & Tech - Available Today
      Profile(
        uid: 'synthetic_earner_01',
        name: 'Maya Rao',
        dob: DateTime(2001, 4, 18),
        gender: 'Woman',
        location: 'Jubilee Hills, Hyderabad',
        isLocationFlexible: false,
        role: 'Earner',
        coinsPerHour: 80,
        tagline: 'Coffee Connoisseur & Tech Enthusiast',
        rating: 4.95,
        reviewsCount: 28,
        bio: 'Passionate about specialty coffee, indie games, and deep talks '
            'about sci-fi and tech. Available as a cafe companion, tech buddy, '
            'and friendly Hyderabad guide.',
        lookingFor: 'Cafe Catchups',
        photos: const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available Today',
          availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
          timeWindow: '5:00 PM – 11:00 PM',
        ),
      ),

      // 2. Sponsor - Hyderabad - Foodie Angel Investor - Weekend Host
      Profile(
        uid: 'synthetic_sponsor_02',
        name: 'Vikram Mehta',
        dob: DateTime(1996, 9, 12),
        gender: 'Man',
        location: 'Madhapur, Hyderabad',
        role: 'Sponsor',
        coinsPerHour: null,
        tagline: 'Angel Investor & Foodie Host',
        rating: 4.88,
        reviewsCount: 19,
        bio: 'Love hosting group dinners, exploring new fine dining spots, '
            'and meeting creative minds. Always excited to sponsor an inspiring '
            'dinner table and talk business & startups.',
        lookingFor: 'Dinner Companion',
        photos: const [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: false,
          statusText: 'Hosting This Weekend',
          availableDays: ['Fri', 'Sat', 'Sun'],
          timeWindow: '7:00 PM – 11:30 PM',
        ),
      ),

      // 3. Earner - Hyderabad - Art Curator & Yoga - High Rated
      Profile(
        uid: 'synthetic_earner_03',
        name: 'Priya Sharma',
        dob: DateTime(2000, 2, 24),
        gender: 'Woman',
        location: 'Banjara Hills, Hyderabad',
        role: 'Earner',
        coinsPerHour: 120,
        tagline: 'Art Curator & Vinyl Collector',
        rating: 4.98,
        reviewsCount: 44,
        bio: 'Gallery curator by day, vinyl record collector by night. '
            'I bring positive vibes to art walks, exhibitions, wellness sessions, '
            'and peaceful cafe coworking afternoons.',
        lookingFor: 'Live Music & Art',
        photos: const [
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available Tomorrow',
          availableDays: ['Tue', 'Thu', 'Sat', 'Sun'],
          timeWindow: '4:00 PM – 9:00 PM',
        ),
      ),

      // 4. Earner - Hyderabad - Fitness & Adventure - Split Windows
      Profile(
        uid: 'synthetic_earner_04',
        name: 'Arjun Verma',
        dob: DateTime(1999, 11, 5),
        gender: 'Man',
        location: 'Gachibowli, Hyderabad',
        role: 'Earner',
        coinsPerHour: 60,
        tagline: 'Fitness Coach & Adventure Trekker',
        rating: 4.91,
        reviewsCount: 22,
        bio: 'Cross-country cyclist, bouldering enthusiast, and certified coach. '
            'Looking for workout partners, cycling buddies, or someone to join '
            'weekend nature trails around Gandipet.',
        lookingFor: 'Fitness / Workout',
        photos: const [
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available Today',
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '6:00 AM – 10:00 AM & 5:00 PM – 9:00 PM',
        ),
      ),

      // 5. Earner - Bangalore - Indie Musician - Flexible Location
      Profile(
        uid: 'synthetic_earner_05',
        name: 'Ananya Roy',
        dob: DateTime(2003, 7, 19),
        gender: 'Woman',
        location: 'Indiranagar, Bangalore',
        isLocationFlexible: true,
        role: 'Earner',
        coinsPerHour: 90,
        tagline: 'Indie Musician & Cafe Hopper',
        rating: 4.96,
        reviewsCount: 31,
        bio: 'Acoustic singer-songwriter and vintage thrift lover. '
            'Catch me at local music open-mics, cozy bookstores, and third-wave '
            'coffee roasters across Indiranagar.',
        lookingFor: 'Live Music & Art',
        photos: const [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available Today',
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '2:00 PM – 9:00 PM',
        ),
      ),

      // 6. Sponsor - Mumbai - Tech Founder & Gourmet Explorer
      Profile(
        uid: 'synthetic_sponsor_06',
        name: 'Rohit Khanna',
        dob: DateTime(1994, 3, 10),
        gender: 'Man',
        location: 'Bandra West, Mumbai',
        role: 'Sponsor',
        coinsPerHour: null,
        tagline: 'Tech Founder & Gourmet Explorer',
        rating: 4.85,
        reviewsCount: 16,
        bio: 'Tech founder, architecture fan, and rooftop dining enthusiast. '
            'Always looking to sponsor dinner tables at Mumbai spots and have '
            'stimulating debates on AI, products, and culture.',
        lookingFor: 'Dinner Companion',
        photos: const [
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: false,
          statusText: 'Hosting This Weekend',
          availableDays: ['Fri', 'Sat', 'Sun'],
          timeWindow: '7:00 PM – 11:00 PM',
        ),
      ),

      // 7. Earner - Hyderabad - Cinephile & Board Game Geek - Premium Tier
      Profile(
        uid: 'synthetic_earner_07',
        name: 'Zoya Akhtar',
        dob: DateTime(2002, 6, 14),
        gender: 'Woman',
        location: 'Jubilee Hills, Hyderabad',
        role: 'Earner',
        coinsPerHour: 150,
        tagline: 'Cinephile & Strategy Gamer',
        rating: 4.97,
        reviewsCount: 38,
        bio: 'Foreign cinema aficionado and strategy board game enthusiast. '
            'Whether it is Catan game nights, indie film screenings, or late evening '
            'gelato runs, count me in!',
        lookingFor: 'Movie & Chill',
        photos: const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available Tonight',
          availableDays: ['Fri', 'Sat', 'Sun'],
          timeWindow: '6:00 PM – 11:30 PM',
        ),
      ),

      // 8. Earner - Bangalore - Non-Binary - Comedy & Barista
      Profile(
        uid: 'synthetic_earner_08',
        name: 'Kabir Sen',
        dob: DateTime(1998, 12, 1),
        gender: 'Non-binary',
        location: 'Koramangala, Bangalore',
        role: 'Earner',
        coinsPerHour: 75,
        tagline: 'Stand-up Comic & Artisan Barista',
        rating: 4.89,
        reviewsCount: 20,
        bio: 'Part-time barista, aspiring stand-up comic, and certified dog lover. '
            'I bring humor, witty banter, and great pour-over coffee knowledge '
            'to any casual meetup or social event.',
        lookingFor: 'Cafe Catchups',
        photos: const [
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available Today',
          availableDays: ['Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
          timeWindow: '3:00 PM – 8:00 PM',
        ),
      ),

      // 9. Earner - Goa - Travel, Yoga & Beach - Highest Rate Tier
      Profile(
        uid: 'synthetic_earner_09',
        name: 'Rhea D\'Souza',
        dob: DateTime(1997, 8, 22),
        gender: 'Woman',
        location: 'Panjim, Goa',
        isLocationFlexible: true,
        role: 'Earner',
        coinsPerHour: 200,
        tagline: 'Beach Yoga Instructor & Coastal Guide',
        rating: 4.99,
        reviewsCount: 52,
        bio: 'Certified Hatha Yoga guide and Goan heritage explorer. '
            'Perfect companion for sunset beach walks, boutique cafe discovery, '
            'and peaceful mindfulness retreats along the coast.',
        lookingFor: 'City Explorer',
        photos: const [
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: true,
          statusText: 'Available This Week',
          availableDays: ['Mon', 'Wed', 'Fri', 'Sat', 'Sun'],
          timeWindow: '7:00 AM – 11:00 AM & 4:00 PM – 8:00 PM',
        ),
      ),

      // 10. Earner - Delhi - Heritage Walks & Photography - Affordable Rate
      Profile(
        uid: 'synthetic_earner_10',
        name: 'Devansh Joshi',
        dob: DateTime(2001, 1, 15),
        gender: 'Man',
        location: 'Connaught Place, Delhi',
        role: 'Earner',
        coinsPerHour: 70,
        tagline: 'Street Photographer & Old Delhi Walker',
        rating: 4.92,
        reviewsCount: 26,
        bio: 'Street photographer with a deep love for Mughal architecture, '
            'monument tours, and culinary street walks. Let us explore the '
            'hidden alleys and historic nooks of Old Delhi together.',
        lookingFor: 'City Explorer',
        photos: const [
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
        ],
        availability: const ProfileAvailability(
          isAvailableToday: false,
          statusText: 'Available This Weekend',
          availableDays: ['Sat', 'Sun'],
          timeWindow: '8:00 AM – 2:00 PM & 4:00 PM – 7:00 PM',
        ),
      ),
    ];
  }

  /// Sample hangout bookings created to test booking conflicts, meetups view,
  /// and companion earnings transactions.
  static List<HangoutRequest> get syntheticHangouts {
    final now = DateTime.now();
    var upcomingDate = now.add(const Duration(days: 1));
    while (upcomingDate.weekday != DateTime.friday) {
      upcomingDate = upcomingDate.add(const Duration(days: 1));
    }

    return [
      // Confirmed upcoming slot with Maya (triggers conflict checking)
      HangoutRequest(
        id: 'synthetic_hangout_01',
        companionUid: 'synthetic_earner_01',
        companionName: 'Maya Rao',
        companionAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        requesterUid: 'synthetic_sponsor_02',
        requesterName: 'Vikram Mehta',
        date: DateTime(upcomingDate.year, upcomingDate.month, upcomingDate.day),
        startHour: 18,
        startMinute: 0,
        durationHours: 2,
        location: 'Roastery Coffee House, Jubilee Hills',
        activity: 'Cafe Catchups',
        coinsPerHour: 80,
        totalCoins: 160,
        status: 'confirmed',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),

      // Pending hangout review with Priya
      HangoutRequest(
        id: 'synthetic_hangout_02',
        companionUid: 'synthetic_earner_03',
        companionName: 'Priya Sharma',
        companionAvatar:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
        requesterUid: 'synthetic_earner_04',
        requesterName: 'Arjun Verma',
        date: upcomingDate.add(const Duration(days: 1)),
        startHour: 16,
        startMinute: 0,
        durationHours: 2,
        location: 'State Art Gallery, Madhapur',
        activity: 'Live Music & Art',
        coinsPerHour: 120,
        totalCoins: 240,
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),

      // Completed past meetup with Ananya
      HangoutRequest(
        id: 'synthetic_hangout_03',
        companionUid: 'synthetic_earner_05',
        companionName: 'Ananya Roy',
        companionAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
        requesterUid: 'synthetic_sponsor_06',
        requesterName: 'Rohit Khanna',
        date: now.subtract(const Duration(days: 3)),
        startHour: 15,
        startMinute: 0,
        durationHours: 3,
        location: 'Third Wave Coffee, Indiranagar',
        activity: 'Cafe Catchups',
        coinsPerHour: 90,
        totalCoins: 270,
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  /// Seeds all 10 profiles and sample hangout bookings into Cloud Firestore.
  /// Returns the number of seeded items.
  Future<int> seedAll() async {
    final fs = firestore;
    if (fs == null) {
      debugPrint('Firestore instance not available for seeding.');
      return 0;
    }

    final batch = fs.batch();
    var count = 0;

    // 1. Seed 10 Profiles
    for (final profile in syntheticProfiles) {
      final docRef = fs.collection('users').doc(profile.uid);
      batch.set(docRef, profile.toMap(), SetOptions(merge: true));
      count++;
    }

    // 2. Seed 3 Hangouts
    for (final hangout in syntheticHangouts) {
      final docRef = fs.collection('hangouts').doc(hangout.id);
      batch.set(docRef, hangout.toMap(), SetOptions(merge: true));
      count++;
    }

    // 3. Commit batch write
    await batch.commit();
    debugPrint('Successfully seeded $count synthetic records into Firestore.');
    return count;
  }

  /// Clears only synthetic data generated with `synthetic_` prefix.
  Future<int> clearSyntheticData() async {
    final fs = firestore;
    if (fs == null) return 0;

    var deletedCount = 0;
    final batch = fs.batch();

    // Delete synthetic users
    for (final profile in syntheticProfiles) {
      final docRef = fs.collection('users').doc(profile.uid);
      batch.delete(docRef);
      deletedCount++;
    }

    // Delete synthetic hangouts
    for (final hangout in syntheticHangouts) {
      final docRef = fs.collection('hangouts').doc(hangout.id);
      batch.delete(docRef);
      deletedCount++;
    }

    await batch.commit();
    debugPrint('Cleared $deletedCount synthetic records from Firestore.');
    return deletedCount;
  }
}

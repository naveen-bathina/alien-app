import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/profile/models/profile_model.dart';

void main() {
  group('Profile', () {
    test('round-trips dating profile details with onboarding fields', () {
      final dob = DateTime(1995, 6, 12);
      final profile = Profile(
        uid: 'user-1',
        name: 'Alex',
        fullName: 'Alexander Smith',
        displayName: 'Alex',
        dob: dob,
        gender: 'Non-binary',
        location: 'Toronto',
        lookingFor: 'Long-term relationship',
        bio: 'I spend weekends exploring new places.',
        photoUrl: 'https://example.com/profile.jpg',
        photos: const [
          'https://example.com/profile.jpg',
          'https://example.com/profile2.jpg',
        ],
      );

      final restored = Profile.fromMap(profile.toMap());

      expect(restored.uid, 'user-1');
      expect(restored.name, 'Alex');
      expect(restored.fullName, 'Alexander Smith');
      expect(restored.displayName, 'Alex');
      expect(restored.dob, dob);
      expect(restored.gender, 'Non-binary');
      expect(restored.location, 'Toronto');
      expect(restored.bio, profile.bio);
      expect(restored.photoUrl, 'https://example.com/profile.jpg');
      expect(restored.photos.length, 2);
      expect(restored.age, isNotNull);
    });

    test('reads older profiles without optional dating details', () {
      final profile = Profile.fromMap({
        'uid': 'user-2',
        'name': 'Sam',
        'gender': 'Woman',
        'location': 'Seattle',
        'lookingFor': 'New friends',
      });

      expect(profile.dob, isNull);
      expect(profile.bio, isEmpty);
      expect(profile.name, 'Sam');
    });

    test('round-trips role, coin economics, tagline, and working hours', () {
      final profile = Profile(
        uid: 'earner-101',
        name: 'Maya',
        dob: DateTime(1999, 3, 15),
        gender: 'Woman',
        location: 'Jubilee Hills, Hyderabad',
        coinsPerHour: 120,
        tagline: 'Specialty Coffee & Tech Enthusiast',
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
          timeWindow: '5:00 PM – 10:00 PM',
        ),
        photos: const ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      );

      final map = profile.toMap();
      final restored = Profile.fromMap(map);

      expect(restored.isEarner, isTrue);
      expect(restored.isSponsor, isFalse);
      expect(restored.coinsPerHour, 120);
      expect(restored.tagline, 'Specialty Coffee & Tech Enthusiast');
      expect(restored.isDiscoveryActive, isTrue);
      expect(restored.availability.isAvailableToday, isTrue);
      expect(restored.availability.availableDays,
          containsAll(['Mon', 'Wed', 'Fri', 'Sat']));
      expect(restored.availability.timeWindow, '5:00 PM – 10:00 PM');
    });

    test('supports sponsor role with hourly budget and snoozed discovery', () {
      final profile = Profile(
        uid: 'sponsor-202',
        name: 'Vikram',
        dob: DateTime(1992, 8, 20),
        gender: 'Man',
        location: 'Banjara Hills',
        role: 'Sponsor',
        coinsPerHour: 250,
        isDiscoveryActive: false,
      );

      final map = profile.toMap();
      final restored = Profile.fromMap(map);

      expect(restored.isSponsor, isTrue);
      expect(restored.isEarner, isFalse);
      expect(restored.coinsPerHour, 250);
      expect(restored.isDiscoveryActive, isFalse);
    });
  });
}

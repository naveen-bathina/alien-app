import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/profile/services/profile_service.dart';

void main() {
  group('ProfileService isComplete', () {
    final ps = ProfileService();

    test('returns true when all questionnaire fields are complete', () {
      final adultDob = DateTime.now().subtract(
        const Duration(days: 365 * 22),
      );
      final completeData = {
        'fullName': 'Alexander Smith',
        'displayName': 'Alex',
        'gender': 'Non-binary',
        'location': 'Toronto, ON',
        'dob': adultDob.toIso8601String(),
        'photoUrl': 'https://example.com/avatar.jpg',
      };

      expect(ps.isComplete(completeData), isTrue);
    });

    test('returns true when photos array has at least one photo', () {
      final adultDob = DateTime.now().subtract(
        const Duration(days: 365 * 25),
      );
      final dataWithPhotos = {
        'name': 'Sam',
        'gender': 'Woman',
        'location': 'Seattle',
        'dob': adultDob.toIso8601String(),
        'photos': ['https://example.com/photo1.jpg'],
      };

      expect(ps.isComplete(dataWithPhotos), isTrue);
    });

    test('returns false when under 18', () {
      final minorDob = DateTime.now().subtract(
        const Duration(days: 365 * 16),
      );
      final minorData = {
        'fullName': 'Young Person',
        'displayName': 'Young',
        'gender': 'Man',
        'location': 'Austin, TX',
        'dob': minorDob.toIso8601String(),
        'photoUrl': 'https://example.com/avatar.jpg',
      };

      expect(ps.isComplete(minorData), isFalse);
    });

    test('returns false when photo is missing', () {
      final adultDob = DateTime.now().subtract(
        const Duration(days: 365 * 20),
      );
      final missingPhoto = {
        'fullName': 'Jane Doe',
        'displayName': 'Jane',
        'gender': 'Woman',
        'location': 'Chicago',
        'dob': adultDob.toIso8601String(),
      };

      expect(ps.isComplete(missingPhoto), isFalse);
    });

    test('returns false when name is missing', () {
      final adultDob = DateTime.now().subtract(
        const Duration(days: 365 * 20),
      );
      final missingName = {
        'gender': 'Woman',
        'location': 'Chicago',
        'dob': adultDob.toIso8601String(),
        'photoUrl': 'https://example.com/photo.jpg',
      };

      expect(ps.isComplete(missingName), isFalse);
    });
  });
}

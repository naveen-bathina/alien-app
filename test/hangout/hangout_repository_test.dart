import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/hangout/repository/hangout_repository.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/models/hangout_request.dart';

void main() {
  group('HangoutRepository & Conflict Verification Engine', () {
    late HangoutRepository repo;
    late Profile testCompanion;

    setUp(() {
      repo = HangoutRepository();
      testCompanion = Profile(
        uid: 'maya_01',
        name: 'Maya Rao',
        dob: DateTime(1998, 5, 20),
        gender: 'Female',
        location: 'Hyderabad, India',
        photos: const ['https://example.com/maya.jpg'],
        lookingFor: 'Friendship & Activities',
        availability: const ProfileAvailability(
          availableDays: ['Fri', 'Sat'],
          timeWindow: '5:00 PM – 11:00 PM',
        ),
      );
    });

    test(
      'detects conflict when requested slot overlaps with existing booking',
      () {
        // Find next Friday (matching the seeded booking, at least tomorrow if Friday 18:00 already passed)
        var targetDate = DateTime.now();
        if (targetDate.weekday == DateTime.friday && targetDate.hour >= 18) {
          targetDate = targetDate.add(const Duration(days: 7));
        } else {
          while (targetDate.weekday != DateTime.friday) {
            targetDate = targetDate.add(const Duration(days: 1));
          }
        }
        final date =
            DateTime(targetDate.year, targetDate.month, targetDate.day);

        // Seed has Maya booked on Friday from 18:00 to 20:00 (2 hrs)
        final result = repo.checkConflict(
          companionUid: 'maya_01',
          requesterUid: 'user_naveen',
          date: date,
          startHour: 18,
          startMinute: 0,
          durationHours: 2,
          companionProfile: testCompanion,
        );

        expect(result.hasConflict, isTrue);
        expect(
          result.conflictReason,
          contains('Maya Rao already has a hangout'),
        );
        expect(
          result.conflictingHangout?.companionUid,
          equals('sample_maya_1'),
        );
      },
    );

    test(
      'detects conflict for partial overlap at the end of existing slot',
      () {
      final seeded = repo.currentBookings.firstWhere((b) => b.id == 'seed-maya-friday');
      final date = DateTime(seeded.date.year, seeded.date.month, seeded.date.day);

      // Existing booking is 18:00 - 20:00.
      // Requested slot is 19:00 - 21:00 (overlaps from 19:00 to 20:00)
      final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: date,
        startHour: 19,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isTrue);
    });

    test('allows non-conflicting adjacent slot after existing booking ends',
        () {
      final seeded = repo.currentBookings.firstWhere((b) => b.id == 'seed-maya-friday');
      final date = DateTime(seeded.date.year, seeded.date.month, seeded.date.day);

      // Existing booking is 18:00 - 20:00.
      // Requested slot starts at 20:00 (ends at 22:00, within 11:00 PM window)
      final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: date,
        startHour: 20,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isFalse);
      expect(result.conflictReason, isNull);
    });

    test('rejects slot outside companion available days', () {
      // Find a Monday (testCompanion is only available Fri, Sat)
      var mondayDate = DateTime.now();
      while (mondayDate.weekday != DateTime.monday) {
        mondayDate = mondayDate.add(const Duration(days: 1));
      }

      final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: mondayDate,
        startHour: 18,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isTrue);
      expect(result.isOutsideOperatingHours, isTrue);
      expect(result.conflictReason, contains('not available on Mondays'));
    });

    test('rejects slot outside companion operating time window', () {
      var fridayDate = DateTime.now().add(const Duration(days: 1));
      while (fridayDate.weekday != DateTime.friday) {
        fridayDate = fridayDate.add(const Duration(days: 1));
      }

      // Time window is 5:00 PM – 11:00 PM (17:00 - 23:00)
      // Requesting 14:00 (2:00 PM) on next upcoming Friday
      final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: fridayDate,
        startHour: 14,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isTrue);
      expect(result.isOutsideOperatingHours, isTrue);
      expect(result.conflictReason, contains('operating hours'));
    });

    test('detects conflict if requester already has another hangout booked',
        () async {
      var targetDate = DateTime.now().add(const Duration(days: 1));
      while (targetDate.weekday != DateTime.friday) {
        targetDate = targetDate.add(const Duration(days: 1));
      }

      // Add existing booking for requester with another companion
      await repo.createHangout(
        HangoutRequest(
          id: 'user_existing_hangout',
          companionUid: 'vikram_02',
          companionName: 'Vikram Rao',
          companionAvatar: 'https://example.com/vikram.jpg',
          requesterUid: 'user_naveen',
          requesterName: 'Naveen',
          date: DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
          ),
          startHour: 20,
          startMinute: 30,
          durationHours: 2,
          location: 'Starbucks',
          activity: 'Coffee & Chat',
          coinsPerHour: 50,
          totalCoins: 100,
        ),
      );

      // Now requester tries to book Maya at 21:00 (overlaps with Vikram)
      final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: targetDate,
        startHour: 21,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isTrue);
      expect(
        result.conflictReason,
        contains('You already have a hangout with'),
      );
    });

    test('supports multi-range operating windows like morning and evening', () {
      final multiWindowCompanion = Profile(
        uid: 'arjun_multi',
        name: 'Arjun Verma',
        dob: DateTime(1999, 11, 5),
        gender: 'Man',
        location: 'Gachibowli, Hyderabad',
        photos: const ['https://example.com/arjun.jpg'],
        lookingFor: 'Activity partners',
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '6:00 AM – 11:00 AM & 5:00 PM – 9:00 PM',
        ),
      );

      final nextWeekDate = DateTime.now().add(const Duration(days: 7));

      // 1. Morning slot 7:00 AM - 9:00 AM -> Should be allowed
      final morningResult = repo.checkConflict(
        companionUid: 'arjun_multi',
        requesterUid: 'user_naveen',
        date: nextWeekDate,
        startHour: 7,
        startMinute: 0,
        durationHours: 2,
        companionProfile: multiWindowCompanion,
      );
      expect(morningResult.hasConflict, isFalse);

      // 2. Evening slot 6:00 PM - 8:00 PM -> Should be allowed
      final eveningResult = repo.checkConflict(
        companionUid: 'arjun_multi',
        requesterUid: 'user_naveen',
        date: nextWeekDate,
        startHour: 18,
        startMinute: 0,
        durationHours: 2,
        companionProfile: multiWindowCompanion,
      );
      expect(eveningResult.hasConflict, isFalse);

      // 3. Afternoon slot 1:00 PM - 3:00 PM -> Should be rejected
      final afternoonResult = repo.checkConflict(
        companionUid: 'arjun_multi',
        requesterUid: 'user_naveen',
        date: nextWeekDate,
        startHour: 13,
        startMinute: 0,
        durationHours: 2,
        companionProfile: multiWindowCompanion,
      );
      expect(afternoonResult.hasConflict, isTrue);
      expect(
        afternoonResult.conflictReason,
        contains('outside Arjun Verma operating hours'),
      );
    });

    test(
      'rejects slot when duration extends beyond operating window closing time',
      () {
        var fridayDate = DateTime.now().add(const Duration(days: 7));
        while (fridayDate.weekday != DateTime.friday) {
          fridayDate = fridayDate.add(const Duration(days: 1));
        }
        // Maya Rao window is 5:00 PM - 11:00 PM
        // Request starts at 10:00 PM (22:00) with 2 hrs -> ends at 12:00 AM
        final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: fridayDate,
        startHour: 22,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isTrue);
      expect(result.conflictReason, contains('closes at 11:00 PM'));
    });

    test('rejects past-time booking on the current calendar day', () {
      final today = DateTime.now();
      // Pick a time from 2 hours ago today
      final pastHour = today.hour >= 2 ? today.hour - 2 : 0;

      final result = repo.checkConflict(
        companionUid: 'maya_01',
        requesterUid: 'user_naveen',
        date: DateTime(today.year, today.month, today.day),
        startHour: pastHour,
        startMinute: 0,
        durationHours: 2,
        companionProfile: testCompanion,
      );

      expect(result.hasConflict, isTrue);
      expect(result.conflictReason, contains('already passed today'));
    });
  });
}

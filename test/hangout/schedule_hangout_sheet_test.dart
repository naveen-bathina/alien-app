import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';

void main() {
  group('ScheduleHangoutSheet Widget Tests', () {
    late Profile flexibleEarner;
    late Profile fixedEarner;

    setUp(() {
      flexibleEarner = Profile(
        uid: 'test_priya',
        name: 'Priya Sharma',
        dob: DateTime(2000, 2, 24),
        gender: 'Woman',
        location: 'Banjara Hills, Hyderabad',
        coinsPerHour: 100,
        photos: const [],
        lookingFor: 'Coffee & Chat',
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '10:00 AM – 10:00 PM',
        ),
      );

      fixedEarner = Profile(
        uid: 'test_maya',
        name: 'Maya Rao',
        dob: DateTime(2001, 4, 18),
        gender: 'Woman',
        location: 'Roastery Coffee House, Jubilee Hills',
        isLocationFlexible: false,
        photos: const [],
        lookingFor: 'Coffee & Chat',
        availability: const ProfileAvailability(
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          timeWindow: '5:00 PM – 10:00 PM',
        ),
      );
    });

    testWidgets(
      'renders custom start time tile and does not render preset chips',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScheduleHangoutSheet(profile: flexibleEarner),
            ),
          ),
        );
        await tester.pump();

        // Check header
        expect(find.text('Request Priya Sharma'), findsOneWidget);

        // Verify preset time chips (e.g. 5:00 PM, 6:00 PM) are NOT present
        expect(find.byType(ChoiceChip), findsNothing);

        // Verify custom start time tile is present with 'Change' action
        expect(find.text('Start Time'), findsOneWidget);
        expect(find.text('Change'), findsOneWidget);
        expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      },
    );

    testWidgets('renders activity type navigation tile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleHangoutSheet(profile: flexibleEarner),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Hangout For'), findsOneWidget);
      expect(find.text('Coffee & Chat'), findsOneWidget);
      expect(
        find.text('Tap to choose what to hangout for'),
        findsOneWidget,
      );
    });

    testWidgets(
      'displays fixed venue card when earner location is not flexible',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScheduleHangoutSheet(profile: fixedEarner),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Fixed Venue'), findsOneWidget);
        expect(
          find.text('Roastery Coffee House, Jubilee Hills'),
          findsOneWidget,
        );
        expect(
          find.text('Maya Rao only meets at their designated venue.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays flexible location picker tile when earner is flexible',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScheduleHangoutSheet(profile: flexibleEarner),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Location'), findsOneWidget);
        expect(
          find.text('Earner is flexible • Tap to choose on Google Maps'),
          findsOneWidget,
        );
      },
    );
  });
}

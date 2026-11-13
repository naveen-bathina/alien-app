import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/discover/view/full_profile_screen.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';

void main() {
  group('FullProfileScreen Widget Tests', () {
    late Profile testProfile;

    setUp(() {
      testProfile = Profile(
        uid: 'test_maya_1',
        name: 'Maya Rao',
        dob: DateTime(2001, 4, 18),
        gender: 'Woman',
        location: 'Jubilee Hills, Hyderabad',
        coinsPerHour: 120,
        tagline: 'Coffee Connoisseur & Tech Enthusiast',
        rating: 4.95,
        reviewsCount: 28,
        bio: 'Passionate about specialty coffee and sci-fi films.',
        lookingFor: 'New friends & fun hangouts',
        photos: const [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
        ],
      );
    });

    Widget createWidget() {
      return MaterialApp(
        home: FullProfileScreen(
          profile: testProfile,
        ),
      );
    }

    testWidgets('renders companion name, bio, rating, rate, and looking for',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.textContaining('Maya Rao'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text(testProfile.bio), findsOneWidget);
      expect(find.text('Hangout For'), findsOneWidget);
      expect(find.text('New friends & fun hangouts'), findsOneWidget);
      expect(find.textContaining('4.95 (28)'), findsOneWidget);
      expect(find.textContaining('120'), findsWidgets);
    });

    testWidgets('does NOT render Availability Schedule or day chips',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Availability Schedule'), findsNothing);
      expect(find.text('Schedule / Request Hangout'), findsNothing);
      expect(find.text('Mon'), findsNothing);
      expect(find.text('Sun'), findsNothing);
    });

    testWidgets('does NOT render Posts & Moments section', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.textContaining('Posts & Moments'), findsNothing);
    });

    testWidgets('renders pinned bottom action bar with Book button',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.textContaining('Book • 120 C/hr'), findsOneWidget);

      await tester.tap(find.textContaining('Book • 120 C/hr'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ScheduleHangoutSheet), findsOneWidget);
    });
  });
}

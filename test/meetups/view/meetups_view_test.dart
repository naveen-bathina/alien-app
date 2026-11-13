import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/hangout/repository/hangout_repository.dart';
import 'package:myalien/meetups/view/meetups_view.dart';
import 'package:myalien/models/hangout_request.dart';

void main() {
  group('MeetupsView Widget Tests', () {
    testWidgets('does NOT render Community Meetups or Host Meetup dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetupsView(),
        ),
      );
      await tester.pump();

      // Verify community meetups tabs and host dialog are gone
      expect(find.text('Community Meetups'), findsNothing);
      expect(find.text('Host Meetup'), findsNothing);
      expect(find.text('Explore Hangouts & Activities'), findsNothing);
    });

    testWidgets('renders AppEmptyState when no hangouts are scheduled', (tester) async {
      // Clear bookings
      hangoutRepository.clearMemoryBookings();

      var exploreTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MeetupsView(
            onExploreTapped: () => exploreTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('No Hangouts Scheduled Yet'), findsOneWidget);
      expect(find.text('Explore Companions'), findsOneWidget);

      await tester.tap(find.text('Explore Companions'));
      expect(exploreTapped, isTrue);
    });

    testWidgets('renders booked hangouts when present', (tester) async {
      hangoutRepository.clearMemoryBookings();
      await hangoutRepository.createHangout(
        HangoutRequest(
          id: 'test_1',
          companionUid: 'c1',
          companionName: 'Priya Sharma',
          companionAvatar: '',
          companionRole: 'Earner',
          requesterUid: 'u1',
          requesterName: 'Alex',
          date: DateTime(2026, 11, 20),
          startHour: 18,
          startMinute: 0,
          durationHours: 2,
          location: 'Roastery Coffee House',
          activity: 'Coffee & Chat',
          coinsPerHour: 100,
          totalCoins: 200,
          status: 'confirmed',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetupsView(),
        ),
      );
      await tester.pump();

      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Coffee & Chat'), findsOneWidget);
      expect(find.text('Roastery Coffee House'), findsOneWidget);
      expect(find.text('🪙 200 Coins'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('renders Accept and Reject buttons for pending hangout and updates status', (tester) async {
      hangoutRepository.clearMemoryBookings();
      await hangoutRepository.createHangout(
        HangoutRequest(
          id: 'test_pending_1',
          companionUid: 'c2',
          companionName: 'Rahul Verma',
          companionAvatar: '',
          companionRole: 'Earner',
          requesterUid: 'u2',
          requesterName: 'Alex',
          date: DateTime(2026, 11, 22),
          startHour: 19,
          startMinute: 0,
          durationHours: 2,
          location: 'Gallery Cafe',
          activity: 'Live Music',
          coinsPerHour: 90,
          totalCoins: 180,
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetupsView(),
        ),
      );
      await tester.pump();

      expect(find.text('Rahul Verma'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Message'), findsNothing);

      // Tap Accept
      await tester.tap(find.text('Accept'));
      await tester.pump();

      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('rejects pending hangout on tapping Reject', (tester) async {
      hangoutRepository.clearMemoryBookings();
      await hangoutRepository.createHangout(
        HangoutRequest(
          id: 'test_pending_2',
          companionUid: 'c3',
          companionName: 'Ananya Roy',
          companionAvatar: '',
          companionRole: 'Earner',
          requesterUid: 'u3',
          requesterName: 'Alex',
          date: DateTime(2026, 11, 23),
          startHour: 17,
          startMinute: 0,
          durationHours: 1,
          location: 'Starbucks',
          activity: 'Coffee & Chat',
          coinsPerHour: 80,
          totalCoins: 80,
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MeetupsView(),
        ),
      );
      await tester.pump();

      expect(find.text('Ananya Roy'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      // Tap Reject
      await tester.tap(find.text('Reject'));
      await tester.pump();

      expect(find.text('DECLINED'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Reject'), findsNothing);
    });
  });
}

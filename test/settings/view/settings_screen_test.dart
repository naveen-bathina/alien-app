import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/settings/models/notification_item.dart';
import 'package:myalien/settings/repository/notification_repository.dart';
import 'package:myalien/settings/view/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late NotificationRepository repo;

    setUp(() {
      repo = NotificationRepository();
    });

    testWidgets('renders SettingsScreen with notifications and filter chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Realtime Notifications'), findsOneWidget);

      // Verify filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.textContaining('Unread'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Hangouts'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);

      // Verify seeded notifications render
      expect(find.text('Welcome Alien Bonus! 🪙'), findsOneWidget);
      expect(find.text('New Mutual Match! ❤️'), findsOneWidget);
    });

    testWidgets('filtering by Matches shows only match notifications', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Matches'));
      await tester.pumpAndSettle();

      expect(find.text('New Mutual Match! ❤️'), findsOneWidget);
      expect(find.text('Welcome Alien Bonus! 🪙'), findsNothing);
    });

    testWidgets('mark all as read marks items as read', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      final markAllFinder = find.text('Mark all as read');
      expect(markAllFinder, findsOneWidget);

      await tester.tap(markAllFinder);
      await tester.pumpAndSettle();

      // Button should disappear when unreadCount is 0
      expect(find.text('Mark all as read'), findsNothing);
    });

    testWidgets('renders Notification Preferences expansion tile and toggles switch', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      final expansionTile = find.text('Notification Preferences');
      expect(expansionTile, findsOneWidget);

      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Match & Like Alerts'), findsOneWidget);
      expect(find.text('Hangout & Meetup Reminders'), findsOneWidget);
      expect(find.text('Wallet & Coin Rewards'), findsOneWidget);
    });

    testWidgets('renders BackButton and allows popping back to previous route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(repository: repo),
                    ),
                  );
                },
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      // BackButton must be present on SettingsScreen
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);

      // Tapping back should pop SettingsScreen and reveal origin screen
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}

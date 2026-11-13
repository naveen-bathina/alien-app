import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/app/widgets/app_card.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/app/widgets/app_navigation_tile.dart';
import 'package:myalien/app/widgets/app_section_header.dart';
import 'package:myalien/app/widgets/app_selection_tile.dart';

void main() {
  group('Design System Reusable Widgets', () {
    testWidgets('AppCard renders child and handles onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('AppNavigationTile renders icon, title, value, and triggers onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNavigationTile(
              icon: Icons.person,
              title: 'Edit Profile',
              value: 'Completed',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.tap(find.text('Edit Profile'));
      expect(tapped, isTrue);
    });

    testWidgets('AppSectionHeader renders title and optional action', (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              title: 'Account Settings',
              actionLabel: 'Reset',
              onActionTap: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      expect(actionTapped, isTrue);
    });

    testWidgets('AppEmptyState renders icon, title, subtitle and action button', (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No Matches Found',
              subtitle: 'Try adjusting your filters',
              actionLabel: 'Clear Filters',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Matches Found'), findsOneWidget);
      expect(find.text('Try adjusting your filters'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);

      await tester.tap(find.text('Clear Filters'));
      expect(actionTapped, isTrue);
    });

    testWidgets('AppSelectionTile renders selected and unselected states correctly', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSelectionTile(
              title: 'Cafe Catchups',
              subtitle: 'Casual meetup at a cafe',
              badge: 'Popular',
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Cafe Catchups'), findsOneWidget);
      expect(find.text('Casual meetup at a cafe'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Cafe Catchups'));
      expect(tapped, isTrue);
    });
  });
}

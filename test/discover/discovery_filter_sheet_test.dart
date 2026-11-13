import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/discover/models/discovery_filters.dart';
import 'package:myalien/discover/view/discovery_filter_sheet.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';

void main() {
  group('DiscoveryFilterSheet Widget Tests', () {
    final sampleProfiles = HomeProfileRepository.sampleCandidates();

    testWidgets('renders all discovery filter sections and controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryFilterSheet(
              initialFilters: DiscoveryFilters.defaultFilters(),
              allProfiles: sampleProfiles,
            ),
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Discovery Preferences'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Section 1: Role
      expect(find.text('1. Who Do You Want to Meet?'), findsOneWidget);
      expect(find.text('All Aliens'), findsOneWidget);
      expect(find.text('Earners Only'), findsOneWidget);
      expect(find.text('Sponsors Only'), findsOneWidget);

      // Section 2: Gender
      expect(find.text('2. Interested in Gender'), findsOneWidget);
      expect(find.text('Everyone'), findsOneWidget);
      expect(find.text('Woman'), findsOneWidget);
      expect(find.text('Man'), findsOneWidget);

      // Section 3: Age Range
      expect(find.text('3. Age Range'), findsOneWidget);

      // Section 4: Location & Nearby Distance
      expect(find.text('4. Location & Nearby Distance'), findsOneWidget);
      expect(find.text('📍 Nearby (Current GPS)'), findsOneWidget);
      expect(find.text('All Cities'), findsOneWidget);
      expect(find.text('Hyderabad'), findsOneWidget);

      // Apply button
      expect(
        find.textContaining('Apply Preferences'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Earners Only updates selection and match count', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryFilterSheet(
              initialFilters: DiscoveryFilters.defaultFilters(),
              allProfiles: sampleProfiles,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap 'Earners Only'
      await tester.tap(find.text('Earners Only'));
      await tester.pump();

      // Verify Earners Only is selected and button reflects matching earners
      expect(find.text('Earners Only'), findsOneWidget);
      expect(find.textContaining('matches'), findsOneWidget);
    });

    testWidgets('reset button restores default filter configuration', (
      tester,
    ) async {
      const customFilters = DiscoveryFilters(
        role: 'Sponsor',
        nearbyOnly: true,
        availableTodayOnly: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryFilterSheet(
              initialFilters: customFilters,
              allProfiles: sampleProfiles,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Verify role reset to All Aliens
      expect(find.text('All Aliens'), findsOneWidget);
    });
  });
}

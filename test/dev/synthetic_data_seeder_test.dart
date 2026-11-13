import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/dev/synthetic_data_seeder.dart';
import 'package:myalien/home/cubit/home_cubit.dart';
import 'package:myalien/discover/models/discovery_filters.dart';
import 'package:myalien/models/profile_model.dart';
import 'package:myalien/settings/view/settings_screen.dart';

void main() {
  group('SyntheticDataSeeder Tests', () {
    test('provides exactly 10 diverse synthetic profiles', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;
      expect(profiles.length, equals(10));

      // Validate all IDs follow synthetic prefix
      for (final p in profiles) {
        expect(p.uid.startsWith('synthetic_'), isTrue);
        expect(p.name.isNotEmpty, isTrue);
        expect(p.photos.isNotEmpty, isTrue);
        expect(p.location.isNotEmpty, isTrue);
        expect(p.bio.isNotEmpty, isTrue);
      }
    });

    test('profile roles cover both Earners and Sponsors', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;
      final earners = profiles.where((p) => p.isEarner).toList();
      final sponsors = profiles.where((p) => p.isSponsor).toList();

      expect(earners.length, equals(8));
      expect(sponsors.length, equals(2));
      expect(sponsors.map((s) => s.name), containsAll(['Vikram Mehta', 'Rohit Khanna']));
    });

    test('profile cities cover Hyderabad, Bangalore, Mumbai, Goa, and Delhi', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;
      final locations = profiles.map((p) => p.location.toLowerCase()).toList();

      expect(locations.any((l) => l.contains('hyderabad')), isTrue);
      expect(locations.any((l) => l.contains('bangalore')), isTrue);
      expect(locations.any((l) => l.contains('mumbai')), isTrue);
      expect(locations.any((l) => l.contains('goa')), isTrue);
      expect(locations.any((l) => l.contains('delhi')), isTrue);
    });

    test('profile genders cover Woman, Man, and Non-binary', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;
      final genders = profiles.map((p) => p.gender).toSet();

      expect(genders, containsAll(['Woman', 'Man', 'Non-binary']));
    });

    test('earner rates span multiple budget tiers (60 to 200 coins/hr)', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;
      final earnerRates = profiles
          .where((p) => p.isEarner && p.coinsPerHour != null)
          .map((p) => p.coinsPerHour!)
          .toList();

      expect(earnerRates.reduce((a, b) => a < b ? a : b), lessThanOrEqualTo(60));
      expect(earnerRates.reduce((a, b) => a > b ? a : b), greaterThanOrEqualTo(200));
    });

    test('all profiles serialize and deserialize via toMap/fromMap cleanly', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;

      for (final original in profiles) {
        final map = original.toMap();
        final reconstructed = Profile.fromMap(map);

        expect(reconstructed.uid, equals(original.uid));
        expect(reconstructed.name, equals(original.name));
        expect(reconstructed.gender, equals(original.gender));
        expect(reconstructed.role, equals(original.role));
        expect(reconstructed.coinsPerHour, equals(original.coinsPerHour));
      }
    });

    test('synthetic hangouts cover confirmed, pending, and completed scenarios', () {
      final hangouts = SyntheticDataSeeder.syntheticHangouts;
      expect(hangouts.length, equals(3));

      final statuses = hangouts.map((h) => h.status).toSet();
      expect(statuses, containsAll(['confirmed', 'pending', 'completed']));

      // All hangouts have companionUid & requesterUid from synthetic profiles
      for (final h in hangouts) {
        expect(h.id.startsWith('synthetic_hangout_'), isTrue);
        expect(h.companionUid.startsWith('synthetic_'), isTrue);
        expect(h.requesterUid.startsWith('synthetic_'), isTrue);
      }
    });

    test('HomeCubit filters work seamlessly with synthetic profiles', () {
      final profiles = SyntheticDataSeeder.syntheticProfiles;

      // 1. Role filter: Sponsor
      final sponsors = HomeCubit.filterProfiles(
        profiles,
        const DiscoveryFilters(role: 'Sponsor'),
      );
      expect(sponsors.length, equals(2));

      // 2. City filter: Bangalore
      final bangalore = HomeCubit.filterProfiles(
        profiles,
        const DiscoveryFilters(city: 'Bangalore'),
      );
      expect(bangalore.length, equals(2));
      expect(bangalore.map((p) => p.name), containsAll(['Ananya Roy', 'Kabir Sen']));

      // 3. Gender filter: Non-binary
      final nonBinary = HomeCubit.filterProfiles(
        profiles,
        const DiscoveryFilters(genders: ['Non-binary']),
      );
      expect(nonBinary.length, equals(1));
      expect(nonBinary.first.name, equals('Kabir Sen'));

      // 4. Rate filter: > 100 coins/hr
      final premium = HomeCubit.filterProfiles(
        profiles,
        const DiscoveryFilters(role: 'Earner', minCoinsPerHour: 100, maxCoinsPerHour: 200),
      );
      expect(premium.map((p) => p.name), containsAll(['Priya Sharma', 'Zoya Akhtar', 'Rhea D\'Souza']));
    });
  });

  group('Developer Seeder Widget Controls in SettingsScreen', () {
    testWidgets('renders Developer & Testing Tools card and expansion tile',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Developer & Testing Tools'), findsOneWidget);
      expect(find.text('Seed synthetic companion & sponsor scenarios'), findsOneWidget);

      // Tap expansion tile to reveal buttons
      await tester.tap(find.text('Developer & Testing Tools'));
      await tester.pumpAndSettle();

      expect(find.text('Seed 10 Profiles'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
  });
}

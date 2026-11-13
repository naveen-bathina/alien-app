import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/discover/models/discovery_filters.dart';
import 'package:myalien/home/cubit/home_cubit.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';

void main() {
  group('DiscoveryFilters Model Tests', () {
    test('default filters have isDefault true and activeFilterCount 0', () {
      final filters = DiscoveryFilters.defaultFilters();
      expect(filters.isDefault, isTrue);
      expect(filters.activeFilterCount, equals(0));
      expect(filters.role, equals('All'));
      expect(filters.city, equals('All Cities'));
      expect(filters.nearbyOnly, isFalse);
      expect(filters.minAge, equals(18));
      expect(filters.maxAge, equals(50));
      expect(filters.sortBy, equals('Recommended'));
    });

    test('activeFilterCount increments when filters deviate from default', () {
      var filters = DiscoveryFilters.defaultFilters();
      expect(filters.activeFilterCount, equals(0));

      filters = filters.copyWith(role: 'Earner');
      expect(filters.activeFilterCount, equals(1));

      filters = filters.copyWith(nearbyOnly: true);
      expect(filters.activeFilterCount, equals(2));

      filters = filters.copyWith(minAge: 21, maxAge: 35);
      expect(filters.activeFilterCount, equals(3));

      filters = filters.copyWith(intentions: ['Dinner Companion']);
      expect(filters.activeFilterCount, equals(4));

      filters = filters.copyWith(availableTodayOnly: true);
      expect(filters.activeFilterCount, equals(5));

      filters = filters.copyWith(verifiedOnly: true);
      expect(filters.activeFilterCount, equals(6));

      filters = filters.copyWith(sortBy: 'Highest Rated');
      expect(filters.activeFilterCount, equals(7));

      expect(filters.isDefault, isFalse);
    });

    test('toMap and fromMap serialize and deserialize accurately', () {
      const original = DiscoveryFilters(
        role: 'Sponsor',
        genders: ['Man'],
        minAge: 25,
        maxAge: 40,
        city: 'Mumbai',
        nearbyOnly: true,
        maxDistanceKm: 30,
        intentions: ['Dinner Companion'],
        minCoinsPerHour: 50,
        maxCoinsPerHour: 150,
        availableTodayOnly: true,
        verifiedOnly: true,
        flexibleLocationOnly: true,
        sortBy: 'Highest Rated',
      );

      final map = original.toMap();
      final restored = DiscoveryFilters.fromMap(map);

      expect(restored, equals(original));
      expect(restored.role, equals('Sponsor'));
      expect(restored.city, equals('Mumbai'));
      expect(restored.nearbyOnly, isTrue);
      expect(restored.maxDistanceKm, equals(30.0));
      expect(restored.sortBy, equals('Highest Rated'));
    });
  });

  group('HomeCubit Filtering Engine Tests', () {
    final candidates = HomeProfileRepository.sampleCandidates();

    test('filters by Role: Earner', () {
      const filters = DiscoveryFilters(role: 'Earner');
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((p) => p.isEarner), isTrue);
      expect(filtered.any((p) => p.isSponsor), isFalse);
    });

    test('filters by Role: Sponsor', () {
      const filters = DiscoveryFilters(role: 'Sponsor');
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((p) => p.isSponsor), isTrue);
      expect(filtered.any((p) => p.isEarner), isFalse);
    });

    test('filters by GPS Nearby (Hyderabad local area)', () {
      const filters = DiscoveryFilters(nearbyOnly: true);
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.isNotEmpty, isTrue);
      // Indiranagar Bangalore should NOT be in nearby
      expect(filtered.any((p) => p.location.contains('Bangalore')), isFalse);
      // Bandra West Mumbai should NOT be in nearby
      expect(filtered.any((p) => p.location.contains('Mumbai')), isFalse);
      // Hyderabad profiles should be present
      expect(filtered.any((p) => p.location.contains('Hyderabad')), isTrue);
    });

    test('filters by specific City: Bangalore', () {
      const filters = DiscoveryFilters(city: 'Bangalore');
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.length, equals(1));
      expect(filtered.first.name, equals('Ananya Roy'));
      expect(filtered.first.location, contains('Bangalore'));
    });

    test('filters by Intentions: Live Music & Art', () {
      const filters = DiscoveryFilters(intentions: ['Live Music & Art']);
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.isNotEmpty, isTrue);
      expect(
        filtered.every((p) =>
            (p.lookingFor ?? '').contains('Live Music & Art') ||
            (p.lookingFor ?? '').contains('Art')),
        isTrue,
      );
    });

    test('filters by Earner Coins Budget Range: 50 to 80 coins/hr', () {
      const filters = DiscoveryFilters(
        role: 'Earner',
        minCoinsPerHour: 50,
        maxCoinsPerHour: 80,
      );
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.isNotEmpty, isTrue);
      expect(
        filtered.every((p) => p.coinsPerHour != null && p.coinsPerHour! >= 50 && p.coinsPerHour! <= 80),
        isTrue,
      );
    });

    test('filters by Available Today Only', () {
      const filters = DiscoveryFilters(availableTodayOnly: true);
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((p) => p.availability.isAvailableToday), isTrue);
    });

    test('sorts by Highest Rated', () {
      const filters = DiscoveryFilters(sortBy: 'Highest Rated');
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      for (var i = 0; i < filtered.length - 1; i++) {
        expect(filtered[i].rating >= filtered[i + 1].rating, isTrue);
      }
    });

    test('sorts by Rate: Low to High for Earners', () {
      const filters = DiscoveryFilters(
        role: 'Earner',
        sortBy: 'Rate: Low to High',
      );
      final filtered = HomeCubit.filterProfiles(candidates, filters);

      for (var i = 0; i < filtered.length - 1; i++) {
        expect(
          (filtered[i].coinsPerHour ?? 0) <= (filtered[i + 1].coinsPerHour ?? 0),
          isTrue,
        );
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/matches/cubit/matches_cubit.dart';
import 'package:myalien/matches/models/match_entry.dart';
import 'package:myalien/matches/repository/matches_repository.dart';

void main() {
  group('MatchesCubit', () {
    late MatchesRepository repo;
    late MatchesCubit cubit;

    setUp(() {
      repo = MatchesRepository();
      cubit = MatchesCubit(repository: repo);
    });

    tearDown(() {
      cubit.close();
      repo.dispose();
    });

    test('initial state loads entries and calculates category counts', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.status, equals(MatchesStatus.loaded));
      expect(cubit.state.entries, isNotEmpty);
      expect(cubit.state.mutuallyLikedCount, greaterThanOrEqualTo(1));
      expect(cubit.state.mutuallySuperlikedCount, greaterThanOrEqualTo(1));
      expect(cubit.state.likedYouCount, greaterThanOrEqualTo(1));
      expect(cubit.state.superlikedYouCount, greaterThanOrEqualTo(1));
      expect(cubit.state.youLikedCount, greaterThanOrEqualTo(1));
      expect(cubit.state.youSuperlikedCount, greaterThanOrEqualTo(1));
    });

    test('selectFilter updates selectedFilter and visibleEntries', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.selectFilter(MatchFilter.likedYou);
      expect(cubit.state.selectedFilter, equals(MatchFilter.likedYou));
      expect(cubit.state.visibleEntries, equals(cubit.state.likedYouMatches));

      cubit.selectFilter(MatchFilter.superlikedYou);
      expect(cubit.state.selectedFilter, equals(MatchFilter.superlikedYou));
      expect(cubit.state.visibleEntries,
          equals(cubit.state.superlikedYouMatches));

      cubit.selectFilter(MatchFilter.mutuallySuperliked);
      expect(cubit.state.selectedFilter, equals(MatchFilter.mutuallySuperliked));
      expect(cubit.state.visibleEntries,
          equals(cubit.state.mutuallySuperlikedMatches));
    });

    test('setSearchQuery filters visibleEntries by name or location', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.selectFilter(MatchFilter.likedYou);
      final initialCount = cubit.state.visibleEntries.length;
      expect(initialCount, greaterThanOrEqualTo(1));

      cubit.setSearchQuery('NonExistentCompanionXYZ');
      expect(cubit.state.visibleEntries, isEmpty);

      final firstName = cubit.state.likedYouMatches.first.profile.name;
      cubit.setSearchQuery(firstName.substring(0, 3));
      expect(cubit.state.visibleEntries, isNotEmpty);
    });

    test('likeBack delegates to repository and updates state', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final target = cubit.state.likedYouMatches.first.profile;
      await cubit.likeBack(target);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final isNowMutual = cubit.state.mutuallyLikedMatches
          .any((e) => e.profile.uid == target.uid);
      expect(isNowMutual, isTrue);
    });
  });
}

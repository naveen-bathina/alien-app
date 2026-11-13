import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/matches/models/match_entry.dart';
import 'package:myalien/matches/repository/matches_repository.dart';

void main() {
  group('MatchesRepository', () {
    late MatchesRepository repo;

    setUp(() {
      repo = MatchesRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('initial seeded entries contains all 6 categories', () async {
      final entries = await repo.matchesStream.first;

      expect(entries, isNotEmpty);

      final hasMutuallyLiked =
          entries.any((e) => e.relation == MatchRelationType.mutuallyLiked);
      final hasMutuallySuperliked =
          entries.any((e) => e.relation == MatchRelationType.mutuallySuperliked);
      final hasReceivedLike =
          entries.any((e) => e.relation == MatchRelationType.receivedLike);
      final hasReceivedSuperlike =
          entries.any((e) => e.relation == MatchRelationType.receivedSuperlike);
      final hasSentLike =
          entries.any((e) => e.relation == MatchRelationType.sentLike);
      final hasSentSuperlike =
          entries.any((e) => e.relation == MatchRelationType.sentSuperlike);

      expect(hasMutuallyLiked, isTrue);
      expect(hasMutuallySuperliked, isTrue);
      expect(hasReceivedLike, isTrue);
      expect(hasReceivedSuperlike, isTrue);
      expect(hasSentLike, isTrue);
      expect(hasSentSuperlike, isTrue);
    });

    test('likeBack converts receivedLike into mutuallyLiked', () async {
      final initial = await repo.matchesStream.first;
      final receivedLikeEntry = initial.firstWhere(
        (e) => e.relation == MatchRelationType.receivedLike,
      );

      await repo.likeBack(receivedLikeEntry.profile);

      final updated = await repo.matchesStream.first;
      final upgraded = updated.firstWhere(
        (e) => e.profile.uid == receivedLikeEntry.profile.uid,
      );

      expect(upgraded.relation, equals(MatchRelationType.mutuallyLiked));
    });

    test('likeBack on receivedSuperlike converts into mutuallySuperliked',
        () async {
      final initial = await repo.matchesStream.first;
      final receivedSuperlikeEntry = initial.firstWhere(
        (e) => e.relation == MatchRelationType.receivedSuperlike,
      );

      await repo.likeBack(receivedSuperlikeEntry.profile);

      final updated = await repo.matchesStream.first;
      final upgraded = updated.firstWhere(
        (e) => e.profile.uid == receivedSuperlikeEntry.profile.uid,
      );

      expect(upgraded.relation, equals(MatchRelationType.mutuallySuperliked));
    });

    test('superlikeBack converts receivedLike into mutuallySuperliked',
        () async {
      final initial = await repo.matchesStream.first;
      final receivedLikeEntry = initial.firstWhere(
        (e) => e.relation == MatchRelationType.receivedLike,
      );

      await repo.superlikeBack(receivedLikeEntry.profile);

      final updated = await repo.matchesStream.first;
      final upgraded = updated.firstWhere(
        (e) => e.profile.uid == receivedLikeEntry.profile.uid,
      );

      expect(upgraded.relation, equals(MatchRelationType.mutuallySuperliked));
    });

    test('recordOutgoingAction adds sentLike for a brand new profile', () async {
      final newProfile = Profile(
        uid: 'brand_new_user_123',
        name: 'Brand New User',
      );

      await repo.recordOutgoingAction(newProfile, 'like');

      final updated = await repo.matchesStream.first;
      final match = updated.firstWhere(
        (e) => e.profile.uid == newProfile.uid,
      );

      expect(match.relation, equals(MatchRelationType.sentLike));
    });

    test('recordOutgoingAction adds sentSuperlike for a brand new profile',
        () async {
      final newProfile = Profile(
        uid: 'brand_new_user_super_456',
        name: 'Super User',
      );

      await repo.recordOutgoingAction(newProfile, 'superlike');

      final updated = await repo.matchesStream.first;
      final match = updated.firstWhere(
        (e) => e.profile.uid == newProfile.uid,
      );

      expect(match.relation, equals(MatchRelationType.sentSuperlike));
    });

    test('clearMemoryEntries clears all entries and notifies stream', () async {
      repo.clearMemoryEntries();
      final updated = await repo.matchesStream.first;
      expect(updated, isEmpty);
    });
  });
}

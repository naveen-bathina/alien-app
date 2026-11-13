import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/matches/cubit/matches_cubit.dart';
import 'package:myalien/matches/models/match_entry.dart';
import 'package:myalien/matches/repository/matches_repository.dart';
import 'package:myalien/matches/view/matches_view.dart';

void main() {
  testWidgets('MatchesView does not have overflow on narrow mobile screens (320px)', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = MatchesRepository();
    final cubit = MatchesCubit(repository: repo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchesView(cubit: cubit),
        ),
      ),
    );
    await tester.pump();

    // Check all filters
    for (final filter in MatchFilter.values) {
      cubit.selectFilter(filter);
      await tester.pump();
    }
  });

  testWidgets('MatchesView does not have overflow on desktop screen (1200px)', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = MatchesRepository();
    final cubit = MatchesCubit(repository: repo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchesView(cubit: cubit),
        ),
      ),
    );
    await tester.pump();

    // Select first entry to open desktop chat & companion banner
    final matchCard = find.textContaining('Maya Rao');
    if (matchCard.evaluate().isNotEmpty) {
      await tester.tap(matchCard.first);
      await tester.pump();
    }
  });
}

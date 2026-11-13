import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/discover/view/full_profile_screen.dart';
import 'package:myalien/matches/cubit/matches_cubit.dart';
import 'package:myalien/matches/repository/matches_repository.dart';
import 'package:myalien/matches/view/matches_view.dart';

void main() {
  group('MatchesView Widget Tests', () {
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

    Widget createWidget({VoidCallback? onExploreTapped}) {
      return MaterialApp(
        home: Scaffold(
          body: MatchesView(
            cubit: cubit,
            onExploreTapped: onExploreTapped,
          ),
        ),
      );
    }

    testWidgets('renders all 6 category choice chips', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.widgetWithText(ChoiceChip, 'Mutually Liked'), findsOneWidget);
      expect(
        find.widgetWithText(ChoiceChip, 'Mutually Superliked'),
        findsOneWidget,
      );

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'Liked You'),
        100,
        scrollable: scrollable,
      );
      expect(find.widgetWithText(ChoiceChip, 'Liked You'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'Superliked You'),
        100,
        scrollable: scrollable,
      );
      expect(find.widgetWithText(ChoiceChip, 'Superliked You'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'You Liked'),
        100,
        scrollable: scrollable,
      );
      expect(find.widgetWithText(ChoiceChip, 'You Liked'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'You Superliked'),
        100,
        scrollable: scrollable,
      );
      expect(find.widgetWithText(ChoiceChip, 'You Superliked'), findsOneWidget);
    });

    testWidgets('verifies NO "Message" button is rendered', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Ensure no "Message" button is present in the UI
      expect(find.text('Message'), findsNothing);
    });

    testWidgets('switching to Liked You displays received like cards',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap on 'Liked You' chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Liked You'));
      await tester.pump();

      expect(find.textContaining('Priya Sharma'), findsOneWidget);
      expect(find.text('Like Back'), findsOneWidget);
      expect(find.text('Liked You'), findsWidgets);
    });

    testWidgets('tapping Like Back triggers likeBack and shows SnackBar',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Switch to Liked You
      await tester.tap(find.widgetWithText(ChoiceChip, 'Liked You'));
      await tester.pump();

      // Tap Like Back
      await tester.tap(find.text('Like Back'));
      await tester.pump();

      expect(find.textContaining("It's a Mutual Match with Priya Sharma!"),
          findsOneWidget);
    });

    testWidgets('tapping companion card navigates to FullProfileScreen',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Default tab is Mutually Liked with Maya Rao
      expect(find.textContaining('Maya Rao'), findsOneWidget);

      // Tap on Maya Rao's match card
      await tester.tap(find.textContaining('Maya Rao'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Verify FullProfileScreen is pushed
      expect(find.byType(FullProfileScreen), findsOneWidget);
    });

    testWidgets('shows empty state and triggers onExploreTapped when empty',
        (tester) async {
      var exploreTapped = false;
      repo.clearMemoryEntries();

      await tester.pumpWidget(
        createWidget(onExploreTapped: () => exploreTapped = true),
      );
      await tester.pump();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('No Mutually Liked Matches Yet'), findsOneWidget);
      expect(find.text('Explore Companions'), findsOneWidget);

      await tester.tap(find.text('Explore Companions'));
      await tester.pump();

      expect(exploreTapped, isTrue);
    });
  });
}

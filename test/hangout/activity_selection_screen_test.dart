import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/hangout/view/activity_selection_screen.dart';
import 'package:myalien/metadata/repository/metadata_repository.dart';

void main() {
  group('ActivitySelectionScreen Widget Tests', () {
    late MetadataRepository repo;

    setUp(() {
      repo = MetadataRepository();
    });

    testWidgets('renders activity categories and list of activities', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitySelectionScreen(
            repo: repo,
            selectedActivity: 'Coffee & Chat',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Select Hangout For'), findsOneWidget);

      // Check categories
      expect(find.text('All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Food & Drink'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Entertainment'), findsOneWidget);

      // Check activity item
      expect(find.text('Coffee & Chat'), findsOneWidget);
      expect(find.text('Dinner Companion'), findsOneWidget);
    });

    testWidgets('allows user to add custom activity like Netflix and Chill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitySelectionScreen(
            repo: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ListView down to reveal the custom input card
      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Add Custom Activity'),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      final customInputFinder = find.byType(TextField).last;
      await tester.enterText(customInputFinder, 'Netflix and Chill');
      await tester.pumpAndSettle();

      // Tap 'Add & Use' button
      final addBtnFinder = find.widgetWithText(ElevatedButton, 'Add & Use');
      await tester.tap(addBtnFinder);
      await tester.pumpAndSettle();

      // Confirm 'Netflix and Chill' now exists in the repository
      final stream = repo.watchActivityTypes();
      final list = await stream.first;
      expect(list.any((a) => a.title == 'Netflix and Chill'), isTrue);
    });
  });
}

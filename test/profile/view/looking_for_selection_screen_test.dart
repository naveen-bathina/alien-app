import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/metadata/repository/metadata_repository.dart';
import 'package:myalien/profile/view/looking_for_selection_screen.dart';

void main() {
  group('LookingForSelectionScreen Widget Tests', () {
    late MetadataRepository repo;

    setUp(() {
      repo = MetadataRepository();
    });

    testWidgets('renders list of intentions and allows selecting one', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LookingForSelectionScreen(
            repo: repo,
            currentIntention: 'Cafe Catchups',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Hangout For'), findsOneWidget);
      expect(find.text('Cafe Catchups'), findsOneWidget);
      expect(find.text('Event Companion'), findsOneWidget);
      expect(find.text('Activity Partner'), findsOneWidget);
    });

    testWidgets('allows user to add new custom intention like Netflix and Chill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LookingForSelectionScreen(
            repo: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to custom input
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Add Custom Goal'),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      // Enter custom text
      final inputFinder = find.widgetWithText(TextField, 'e.g. Netflix and Chill');
      await tester.enterText(inputFinder, 'Netflix and Chill');
      await tester.pumpAndSettle();

      // Tap 'Add & Use'
      final addBtnFinder = find.widgetWithText(ElevatedButton, 'Add & Use');
      await tester.tap(addBtnFinder);
      await tester.pumpAndSettle();

      // Confirm 'Netflix and Chill' now exists in the intentions stream
      final stream = repo.watchLookingForIntentions();
      final list = await stream.first;
      expect(list.any((i) => i.title == 'Netflix and Chill'), isTrue);
    });
  });
}

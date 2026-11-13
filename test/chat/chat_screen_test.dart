import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/chat/view/chat_screen.dart';

void main() {
  group('ChatScreen', () {
    testWidgets('renders companion name, online status, and sends a new message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(
            userName: 'Maya',
            isOnline: true,
          ),
        ),
      );

      // Verify app bar info
      expect(find.text('Maya'), findsOneWidget);
      expect(find.text('Active now'), findsOneWidget);

      // Verify initial pre-populated messages
      expect(find.textContaining('Nice to connect with you on MyAlien'), findsOneWidget);

      // Type and send a new message
      await tester.enterText(find.byType(TextField), 'See you at the cafe!');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('See you at the cafe!'), findsOneWidget);
    });
  });
}

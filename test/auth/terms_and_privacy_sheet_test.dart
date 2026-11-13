import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myalien/auth/cubit/auth_cubit.dart';
import 'package:myalien/auth/cubit/auth_state.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:myalien/auth/view/terms_and_privacy_sheet.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('LoginScreen Terms & Privacy Tests', () {
    testWidgets('tapping Terms of Service opens TermsAndPrivacySheet',
        (tester) async {
      final authCubit = MockAuthCubit();
      when(() => authCubit.state).thenReturn(AuthInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final richTextFinder = find.byWidgetPredicate((w) {
        if (w is RichText) {
          return w.text.toPlainText().contains('Terms of Service');
        }
        return false;
      });
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final plainText = richText.text.toPlainText();
      final termsIndex = plainText.indexOf('Terms of Service');

      // Tap on Terms of Service span
      final textPosition = (richText.text as TextSpan)
          .getSpanForPosition(TextPosition(offset: termsIndex + 2));
      expect(textPosition, isNotNull);
      final recognizer = (textPosition! as TextSpan).recognizer;
      expect(recognizer, isA<TapGestureRecognizer>());
      (recognizer! as TapGestureRecognizer).onTap!();

      await tester.pumpAndSettle();

      expect(find.byType(TermsAndPrivacySheet), findsOneWidget);
      expect(find.text('Terms of Service'), findsWidgets);
      expect(find.text('Age Eligibility & Community Purpose'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('I Understand & Close'));
      await tester.pumpAndSettle();
      expect(find.byType(TermsAndPrivacySheet), findsNothing);
    });

    testWidgets('tapping Privacy Policy opens TermsAndPrivacySheet with privacy content',
        (tester) async {
      final authCubit = MockAuthCubit();
      when(() => authCubit.state).thenReturn(AuthInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final richTextFinder = find.byWidgetPredicate((w) {
        if (w is RichText) {
          return w.text.toPlainText().contains('Privacy Policy');
        }
        return false;
      });
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final plainText = richText.text.toPlainText();
      final privacyIndex = plainText.indexOf('Privacy Policy');

      final textPosition = (richText.text as TextSpan)
          .getSpanForPosition(TextPosition(offset: privacyIndex + 2));
      expect(textPosition, isNotNull);
      final recognizer = (textPosition! as TextSpan).recognizer;
      expect(recognizer, isA<TapGestureRecognizer>());
      (recognizer! as TapGestureRecognizer).onTap!();

      await tester.pumpAndSettle();

      expect(find.byType(TermsAndPrivacySheet), findsOneWidget);
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.text('Information We Collect'), findsOneWidget);
    });
  });
}

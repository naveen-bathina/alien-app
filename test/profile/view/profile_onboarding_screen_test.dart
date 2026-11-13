import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myalien/l10n/l10n.dart';
import 'package:myalien/profile/cubit/profile_cubit.dart';
import 'package:myalien/profile/cubit/profile_state.dart';
import 'package:myalien/profile/view/profile_onboarding_screen.dart';

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  group('ProfileOnboardingScreen', () {
    late MockProfileCubit profileCubit;

    setUp(() {
      profileCubit = MockProfileCubit();
      when(() => profileCubit.state).thenReturn(ProfileInitial());
    });

    Widget buildSubject() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ProfileCubit>.value(
          value: profileCubit,
          child: const ProfileOnboardingScreen(),
        ),
      );
    }

    testWidgets('renders Step 1 (Single Name field)', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text("What's your name?"), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('validates name and advances to Step 2 (About You)', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Enter empty name and tap Continue -> shows validation error
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter your name (at least 2 letters)'),
        findsOneWidget,
      );

      // Enter valid name
      await tester.enterText(find.byType(TextField), 'Alex Sharma');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should now be on Step 2 (About you - Gender & Birthday)
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('A little about you'), findsOneWidget);
      expect(find.text('Gender Identity'), findsOneWidget);
    });

    testWidgets('advances to Step 3 (City & Photo) and back button works', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Advance to Step 2
      await tester.enterText(find.byType(TextField), 'Alex Sharma');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);

      // Advance to Step 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('City & Photo'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('A little about you'), findsOneWidget);
    });
  });
}

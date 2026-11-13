import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_theme.dart';
import 'package:myalien/app/view/auth_gate.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:myalien/home/view/home_screen.dart';
import 'package:myalien/l10n/l10n.dart';
import 'package:myalien/profile/view/profile_onboarding_screen.dart';
import 'package:myalien/profile/view/profile_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const ProfileOnboardingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/theme/app_theme.dart';
import 'package:myalien/app/theme/theme_cubit.dart';
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
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: mediaQuery.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.35,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AuthGate(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/onboarding': (context) => const ProfileOnboardingScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}

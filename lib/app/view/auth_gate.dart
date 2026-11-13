import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:myalien/home/view/home_screen.dart';
import 'package:myalien/profile/services/profile_service.dart';
import 'package:myalien/profile/view/profile_onboarding_screen.dart';

/// Gatekeeper widget that handles app startup / cold starts.
/// Determines whether the user should see:
/// 1. LoginScreen (if unauthenticated or Firebase not ready)
/// 2. ProfileOnboardingScreen (if authenticated but profile is incomplete)
/// 3. HomeScreen (if authenticated and profile is complete)
class AuthGate extends StatelessWidget {
  const AuthGate({
    this.auth,
    this.profileService,
    super.key,
  });

  final FirebaseAuth? auth;
  final ProfileService? profileService;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth? firebaseAuth;
    try {
      firebaseAuth = auth ?? FirebaseAuth.instance;
    } on Object {
      firebaseAuth = null;
    }

    if (firebaseAuth == null) {
      return const LoginScreen();
    }

    final ps = profileService ?? ProfileService();

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      initialData: firebaseAuth.currentUser,
      builder: (context, userSnap) {
        final user = userSnap.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: ps.profileExists(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BrandLogo(size: 80),
                      SizedBox(height: 24),
                      CircularProgressIndicator.adaptive(),
                    ],
                  ),
                ),
              );
            }

            final isComplete = snapshot.data ?? false;
            if (isComplete) {
              return const HomeScreen();
            } else {
              return const ProfileOnboardingScreen();
            }
          },
        );
      },
    );
  }
}

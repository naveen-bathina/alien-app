import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:myalien/home/view/home_screen.dart';
import 'package:myalien/profile/services/profile_service.dart';
import 'package:myalien/profile/view/profile_onboarding_screen.dart';

Future<void> checkProfileCompleteAndNavigate(
  BuildContext context, {
  ProfileService? profileService,
  FirebaseAuth? auth,
}) async {
  final firebaseAuth = auth ?? FirebaseAuth.instance;
  final user = firebaseAuth.currentUser;

  if (user == null) {
    if (!context.mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    return;
  }

  final ps = profileService ?? ProfileService();
  try {
    final exists = await ps.profileExists(user.uid);
    if (!context.mounted) return;

    if (exists) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const ProfileOnboardingScreen(),
        ),
        (route) => false,
      );
    }
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Failed to verify profile status. Please check your connection.',
        ),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => checkProfileCompleteAndNavigate(
            context,
            profileService: ps,
            auth: firebaseAuth,
          ),
        ),
      ),
    );
  }
}

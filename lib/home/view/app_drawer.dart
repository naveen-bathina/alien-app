import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:myalien/discover/view/discovery_filter_sheet.dart';
import 'package:myalien/home/cubit/home_cubit.dart';
import 'package:myalien/home/view/community_safety_sheet.dart';
import 'package:myalien/home/view/home_screen.dart';
import 'package:myalien/models/profile_model.dart';
import 'package:myalien/profile/repository/profile_repository.dart';
import 'package:myalien/profile/view/profile_screen.dart';
import 'package:myalien/settings/view/settings_screen.dart';
import 'package:myalien/wallet/view/wallet_screen.dart';

/// Navigation drawer items for explicit active-selection tracking.
enum AppDrawerItem {
  discover,
  hangouts,
  matches,
  profile,
  wallet,
  settings,
  safety,
}

/// Navigation drawer displaying the live logged-in user profile and essential shortcuts.
class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
    this.onSelectTab,
    this.onOpenFilters,
    this.currentTabIndex,
    this.activeItem,
    this.profileRepo,
    this.initialProfile,
  });

  final ValueChanged<int>? onSelectTab;
  final VoidCallback? onOpenFilters;
  final int? currentTabIndex;
  final AppDrawerItem? activeItem;
  final ProfileRepository? profileRepo;
  final Profile? initialProfile;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Profile? _cachedProfile;

  late final ProfileRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = widget.profileRepo ?? ProfileRepository();
    _cachedProfile = widget.initialProfile;
    if (_cachedProfile == null) {
      _fetchLoggedInProfile();
    }
  }

  User? get _currentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } on Object {
      return null;
    }
  }

  Future<void> _fetchLoggedInProfile() async {
    final user = _currentUser;
    if (user == null) return;

    try {
      final p = await _repo.fetchProfile(user.uid);
      if (mounted) {
        setState(() {
          _cachedProfile = p;
        });
      }
    } on Object {}
  }

  void _handleTabTap(BuildContext context, int index) {
    final nav = Navigator.of(context);
    nav.pop();
    if (widget.onSelectTab != null) {
      widget.onSelectTab!(index);
    } else {
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(initialIndex: index),
        ),
        (route) => false,
      );
    }
  }

  void _handleFiltersTap(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    if (widget.onOpenFilters != null) {
      widget.onOpenFilters!();
    } else {
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(
            initialIndex: 0,
            openFilterSheet: true,
          ),
        ),
        (route) => false,
      );
    }
  }

  void _openProfile(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    if (widget.activeItem == AppDrawerItem.profile) return;
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfileScreen(),
      ),
    ).then((_) {
      if (mounted) _fetchLoggedInProfile();
    });
  }

  void _openWallet(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    if (widget.activeItem == AppDrawerItem.wallet) return;
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => const WalletScreen(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    if (widget.activeItem == AppDrawerItem.settings) return;
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(AppStrings.logoutDialogTitle),
          content: const Text(
            AppStrings.logoutDialogContent,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await FirebaseAuth.instance.signOut();
                } on Object {}
                if (!context.mounted) return;
                await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text(AppStrings.logOut),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    // Resolve live profile info
    final profile = _cachedProfile;
    final photoUrl = profile?.photoUrl ??
        (profile?.photos.isNotEmpty == true ? profile!.photos.first : null);

    final displayName = profile?.displayName ??
        profile?.name ??
        user?.displayName ??
        'Alien Explorer';

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';
    final role = profile?.role ?? 'Earner';
    final location = profile?.location.isNotEmpty == true
        ? profile!.location
        : (user?.phoneNumber ?? 'Connected');

    final effectiveActiveItem = widget.activeItem ??
        (widget.currentTabIndex == 0
            ? AppDrawerItem.discover
            : widget.currentTabIndex == 1
                ? AppDrawerItem.hangouts
                : widget.currentTabIndex == 2
                    ? AppDrawerItem.matches
                    : null);

    final isProfileActive = effectiveActiveItem == AppDrawerItem.profile;
    final isWalletActive = effectiveActiveItem == AppDrawerItem.wallet;
    final isDiscoverActive = effectiveActiveItem == AppDrawerItem.discover;
    final isHangoutsActive = effectiveActiveItem == AppDrawerItem.hangouts;
    final isMatchesActive = effectiveActiveItem == AppDrawerItem.matches;
    final isSettingsActive = effectiveActiveItem == AppDrawerItem.settings;
    final isSafetyActive = effectiveActiveItem == AppDrawerItem.safety;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header - Tappable to open Profile
                  InkWell(
                    onTap: () => _openProfile(context),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: photoUrl != null && photoUrl.isNotEmpty
                                      ? AppImage(
                                          source: photoUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: AppColors.primary,
                                          alignment: Alignment.center,
                                          child: Text(
                                            initial,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                        border:
                                            Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        role,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  AppStrings.navEditProfile,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Profile Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isProfileActive
                            ? AppColors.primaryLight
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProfileActive
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        color: isProfileActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      AppStrings.navProfile,
                      style: TextStyle(
                        fontWeight: isProfileActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                        color: isProfileActive ? AppColors.primary : null,
                      ),
                    ),
                    selected: isProfileActive,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _openProfile(context),
                  ),

                  // Wallet
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isWalletActive
                            ? AppColors.primaryLight
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWalletActive
                            ? Icons.account_balance_wallet_rounded
                            : Icons.account_balance_wallet_outlined,
                        color: isWalletActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      AppStrings.navWallet,
                      style: TextStyle(
                        fontWeight: isWalletActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                        color: isWalletActive ? AppColors.primary : null,
                      ),
                    ),
                    selected: isWalletActive,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _openWallet(context),
                  ),

                  // Alien VIP Pass Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Alien VIP Pass (Save 66%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E1E2D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: const Text(
                      '5% platform fee • Unlimited rewinds',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _openWallet(context),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.border),
                  ),

                  // Main Tabs Navigation
                  ListTile(
                    leading: Icon(
                      isDiscoverActive
                          ? Icons.explore_rounded
                          : Icons.explore_outlined,
                      color: isDiscoverActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      AppStrings.navDiscover,
                      style: TextStyle(
                        fontWeight: isDiscoverActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isDiscoverActive
                            ? AppColors.primary
                            : null,
                        fontSize: 14,
                      ),
                    ),
                    selected: isDiscoverActive,
                    onTap: () => _handleTabTap(context, 0),
                  ),

                  ListTile(
                    leading: Icon(
                      isHangoutsActive
                          ? Icons.calendar_month_rounded
                          : Icons.calendar_month_outlined,
                      color: isHangoutsActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      AppStrings.navHangouts,
                      style: TextStyle(
                        fontWeight: isHangoutsActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isHangoutsActive
                            ? AppColors.primary
                            : null,
                        fontSize: 14,
                      ),
                    ),
                    selected: isHangoutsActive,
                    onTap: () => _handleTabTap(context, 1),
                  ),

                  ListTile(
                    leading: Icon(
                      isMatchesActive
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isMatchesActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      AppStrings.navMatches,
                      style: TextStyle(
                        fontWeight: isMatchesActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isMatchesActive
                            ? AppColors.primary
                            : null,
                        fontSize: 14,
                      ),
                    ),
                    selected: isMatchesActive,
                    onTap: () => _handleTabTap(context, 2),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.border),
                  ),

                  // Discovery Filters / Preferences
                  ListTile(
                    leading: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      AppStrings.navFilters,
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _handleFiltersTap(context),
                  ),

                  // Settings Tile
                  ListTile(
                    leading: Icon(
                      isSettingsActive
                          ? Icons.settings_rounded
                          : Icons.settings_outlined,
                      color: isSettingsActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      AppStrings.navSettings,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSettingsActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSettingsActive ? AppColors.primary : null,
                      ),
                    ),
                    selected: isSettingsActive,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _openSettings(context),
                  ),

                  // Safety & Help
                  ListTile(
                    leading: Icon(
                      isSafetyActive
                          ? Icons.shield_rounded
                          : Icons.shield_outlined,
                      color: isSafetyActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      AppStrings.navSafetyHelp,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSafetyActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSafetyActive ? AppColors.primary : null,
                      ),
                    ),
                    selected: isSafetyActive,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      CommunitySafetySheet.show(context);
                    },
                  ),
                ],
              ),
            ),

            // Logout
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
              ),
              title: const Text(
                AppStrings.logOut,
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

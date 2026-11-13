// home_screen.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/app/view/responsive_breakpoints.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/app/widgets/app_sidebar.dart';
import 'package:myalien/app/widgets/app_top_bar.dart';
import 'package:myalien/app/widgets/command_palette_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myalien/discover/view/companion_bento_panel.dart';
import 'package:myalien/discover/view/discovery_filter_sheet.dart';
import 'package:myalien/discover/view/full_profile_screen.dart';
import 'package:myalien/home/cubit/home_cubit.dart';
import 'package:myalien/home/cubit/home_state.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';
import 'package:myalien/home/view/app_drawer.dart';
import 'package:myalien/home/widgets/action_stamps.dart';
import 'package:myalien/home/widgets/profile_card.dart';
import 'package:myalien/matches/matches.dart';
import 'package:myalien/meetups/view/meetups_view.dart';
import 'package:myalien/profile/view/profile_screen.dart';
import 'package:myalien/settings/models/notification_item.dart';
import 'package:myalien/settings/repository/notification_repository.dart';
import 'package:myalien/settings/view/settings_screen.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';
import 'package:myalien/wallet/view/buy_coins_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.openFilterSheet = false,
    this.homeCubit,
  });

  final int initialIndex;
  final bool openFilterSheet;
  final HomeCubit? homeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          homeCubit ??
          (HomeCubit(repo: HomeProfileRepository())..loadProfiles()),
      child: _HomeView(
        initialIndex: initialIndex,
        openFilterSheet: openFilterSheet,
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({
    this.initialIndex = 0,
    this.openFilterSheet = false,
  });

  final int initialIndex;
  final bool openFilterSheet;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late int _currentIndex;
  bool _sidebarCollapsed = false;

  void _openCommandPalette() {
    CommandPaletteModal.show(
      context,
      actions: [
        CommandPaletteAction(
          title: 'Discover Companions',
          icon: Icons.explore_rounded,
          shortcut: '⌘1',
          onSelect: () => setState(() => _currentIndex = 0),
        ),
        CommandPaletteAction(
          title: 'Hangouts & Meetups',
          icon: Icons.calendar_month_rounded,
          shortcut: '⌘2',
          onSelect: () => setState(() => _currentIndex = 1),
        ),
        CommandPaletteAction(
          title: 'Matches & Chat',
          icon: Icons.favorite_rounded,
          shortcut: '⌘3',
          onSelect: () => setState(() => _currentIndex = 2),
        ),
        CommandPaletteAction(
          title: 'Filter Companions',
          icon: Icons.tune_rounded,
          shortcut: 'F',
          onSelect: () {
            setState(() => _currentIndex = 0);
            _openFilterSheet(context);
          },
        ),
        CommandPaletteAction(
          title: 'Buy Alien Coins',
          icon: Icons.monetization_on_rounded,
          category: 'Wallet',
          onSelect: () => BuyCoinsSheet.show(context),
        ),
        CommandPaletteAction(
          title: 'Notification Settings',
          icon: Icons.notifications_rounded,
          category: 'Settings',
          onSelect: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  String get _currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? 'current_user';
    } on Object {
      return 'current_user';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (widget.openFilterSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openFilterSheet(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = kIsWeb && !WebBreakpoints.isCompact(context);
    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
        titleSpacing: 0,
        title: BrandAppBarTitle(
          _currentIndex == 0
              ? AppStrings.navDiscover
              : _currentIndex == 1
              ? AppStrings.navHangouts
              : AppStrings.navMatches,
        ),
        centerTitle: false,
        actions: [
          // Live Coin Balance Pill (Tap opens quick top-up)
          StreamBuilder<WalletStateData>(
            stream: walletRepository.walletStream,
            initialData: walletRepository.currentState,
            builder: (context, snapshot) {
              final balance = snapshot.data?.availableBalance ?? 0;
              final tokens = AppColorTokens.of(context);
              return Semantics(
                button: true,
                label: 'Alien Coins balance: $balance. Tap to buy coins',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => BuyCoinsSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.brandAccentSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: tokens.brandAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '$balance',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tokens.brandAccent,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.add_circle,
                              size: 13,
                              color: tokens.brandAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),


          // Realtime Notification Bell Icon with Badge / Overflow Menu
          StreamBuilder<List<NotificationItem>>(
            stream: NotificationRepository.instance.notificationsStream(
              _currentUserId,
            ),
            builder: (context, snapshot) {
              final unreadCount = snapshot.hasData
                  ? snapshot.data!.where((n) => !n.isRead).length
                  : 0;
              return IconButton(
                tooltip: AppStrings.notifications,
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              );
            },
          ),

          // Refresh Icon Button
          IconButton(
            tooltip: 'Refresh Profiles',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<HomeCubit>().loadProfiles();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: AppDrawer(
        currentTabIndex: _currentIndex,
        activeItem: _currentIndex == 0
            ? AppDrawerItem.discover
            : _currentIndex == 1
            ? AppDrawerItem.hangouts
            : AppDrawerItem.matches,
        onSelectTab: (index) {
          setState(() => _currentIndex = index);
        },
        onOpenFilters: () {
          setState(() => _currentIndex = 0);
          _openFilterSheet(context);
        },
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: AppStrings.navDiscover,
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: AppStrings.navHangouts,
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: AppStrings.navMatches,
                ),
              ],
            ),
      body: isWide
          ? Row(
              children: [
                AppSidebar(
                  selectedIndex: _currentIndex,
                  isCollapsed: _sidebarCollapsed,
                  onToggleCollapsed: () {
                    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                  },
                  onSelectIndex: (index) {
                    setState(() => _currentIndex = index);
                  },
                  items: const [
                    AppSidebarItem(
                      title: AppStrings.navDiscover,
                      icon: Icons.explore_rounded,
                    ),
                    AppSidebarItem(
                      title: AppStrings.navHangouts,
                      icon: Icons.calendar_month_rounded,
                    ),
                    AppSidebarItem(
                      title: AppStrings.navMatches,
                      icon: Icons.favorite_rounded,
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: _currentIndex == 0
                            ? AppStrings.navDiscover
                            : _currentIndex == 1
                            ? AppStrings.navHangouts
                            : AppStrings.navMatches,
                        onOpenCommandPalette: _openCommandPalette,
                        onOpenNotifications: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: [
                            _buildDiscoverTab(context),
                            MeetupsView(
                              onExploreTapped: () =>
                                  setState(() => _currentIndex = 0),
                            ),
                            MatchesView(
                              onExploreTapped: () =>
                                  setState(() => _currentIndex = 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildDiscoverTab(context),
                MeetupsView(
                  onExploreTapped: () => setState(() => _currentIndex = 0),
                ),
                MatchesView(
                  onExploreTapped: () => setState(() => _currentIndex = 0),
                ),
              ],
            ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final updated = await DiscoveryFilterSheet.show(
      context,
      initialFilters: cubit.state.filters,
      allProfiles: cubit.state.allProfiles,
    );
    if (updated != null) {
      cubit.applyFilters(updated);
    }
  }

  Widget _buildDiscoverTab(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          } else if (state is NavigateToProfileScreen) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HomeStatus.loading ||
              state.status == HomeStatus.initial) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          final profiles = state.profiles;
          final index = state.index;

          return Column(
            children: [
              // 1-Tap Quick Filter Chips Bar
              _buildQuickFilterBar(context, state),

              // Swiper / Empty State
              Expanded(
                child: profiles.isEmpty
                    ? _emptyState(context, state)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final showInspector =
                              constraints.maxWidth >= WebBreakpoints.desktopLarge;

                          final swiperStack = Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: WebBreakpoints.maxContentWidth,
                              ),
                              child: Stack(
                                children: [
                                  // Full Screen Tinder Swiping Cards
                                  Positioned.fill(
                                    child: SwipeCardStack(
                                      profiles:
                                          profiles.skip(index).take(3).toList(),
                                      onAction: (profile, action) {
                                        context.read<HomeCubit>().takeAction(
                                          profile.uid,
                                          action,
                                        );
                                        if (action == 'like' ||
                                            action == 'superlike') {
                                          MatchesRepository.instance
                                              .recordOutgoingAction(
                                            profile,
                                            action,
                                          );
                                        }
                                      },
                                      onOpenDetails: (profile) {
                                        _openFullProfile(context, profile);
                                      },
                                      onNoMore: () {},
                                    ),
                                  ),

                                  // Floating Tinder Action Buttons Bar
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 12,
                                    child: _buildFloatingControls(
                                      context,
                                      profiles[index],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (showInspector) {
                            return Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: swiperStack,
                                ),
                                const VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Color(0xFFE2DDF4),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: CompanionBentoPanel(
                                    profile: profiles[index],
                                    onAction: (action) {
                                      context.read<HomeCubit>().takeAction(
                                        profiles[index].uid,
                                        action,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }

                          return swiperStack;
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickFilterBar(BuildContext context, HomeState state) {
    final filters = state.filters;
    final cubit = context.read<HomeCubit>();
    final tokens = AppColorTokens.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: WebBreakpoints.maxContentWidth,
        ),
        child: Container(
          height: 56,
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            children: [
          // Filter Tune Button with Badge
          ActionChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            avatar: Badge(
              isLabelVisible: filters.activeFilterCount > 0,
              label: Text(
                '${filters.activeFilterCount}',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: tokens.brandAccent,
              child: Icon(
                Icons.tune_rounded,
                size: 16,
                color: filters.activeFilterCount > 0
                    ? tokens.brandAccent
                    : tokens.textPrimary,
              ),
            ),
            label: Text(
              filters.activeFilterCount > 0
                  ? '${AppStrings.navFilters} (${filters.activeFilterCount})'
                  : AppStrings.navFilters,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: filters.activeFilterCount > 0
                    ? tokens.brandAccent
                    : tokens.textPrimary,
              ),
            ),
            backgroundColor: filters.activeFilterCount > 0
                ? tokens.brandAccentSubtle
                : tokens.bgSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.activeFilterCount > 0
                    ? tokens.brandAccent
                    : tokens.borderLow,
              ),
            ),
            onPressed: () => _openFilterSheet(context),
          ),
          const SizedBox(width: 8),

          // Role quick toggles
          ChoiceChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            label: const Text('Earners'),
            selected: filters.role == 'Earner',
            selectedColor: tokens.brandAccent,
            backgroundColor: tokens.bgSubtle,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filters.role == 'Earner'
                  ? Colors.white
                  : tokens.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.role == 'Earner'
                    ? tokens.brandAccent
                    : tokens.borderLow,
              ),
            ),
            onSelected: (_) => cubit.toggleRole('Earner'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            label: const Text('Sponsors'),
            selected: filters.role == 'Sponsor',
            selectedColor: tokens.brandAccent,
            backgroundColor: tokens.bgSubtle,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filters.role == 'Sponsor'
                  ? Colors.white
                  : tokens.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.role == 'Sponsor'
                    ? tokens.brandAccent
                    : tokens.borderLow,
              ),
            ),
            onSelected: (_) => cubit.toggleRole('Sponsor'),
          ),
          const SizedBox(width: 8),

          // Nearby GPS Quick Chip
          FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            avatar: Icon(
              Icons.my_location_rounded,
              size: 14,
              color: filters.nearbyOnly
                  ? Colors.white
                  : tokens.brandAccent,
            ),
            label: const Text('📍 Nearby'),
            selected: filters.nearbyOnly,
            selectedColor: tokens.brandAccent,
            backgroundColor: tokens.bgSubtle,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filters.nearbyOnly
                  ? Colors.white
                  : tokens.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.nearbyOnly
                    ? tokens.brandAccent
                    : tokens.borderLow,
              ),
            ),
            onSelected: (_) => cubit.toggleNearby(),
          ),
          const SizedBox(width: 8),

          // Available Today
          FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            avatar: Icon(
              Icons.bolt_rounded,
              size: 16,
              color: filters.availableTodayOnly
                  ? Colors.white
                  : tokens.success,
            ),
            label: const Text('Available Today'),
            selected: filters.availableTodayOnly,
            selectedColor: tokens.success,
            backgroundColor: tokens.successBg,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filters.availableTodayOnly
                  ? Colors.white
                  : tokens.success,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.availableTodayOnly
                    ? tokens.success
                    : tokens.success.withValues(alpha: 0.3),
              ),
            ),
            onSelected: (_) => cubit.toggleAvailableToday(),
          ),
          const SizedBox(width: 8),

          // Verified Only
          FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            avatar: Icon(
              Icons.verified_rounded,
              size: 15,
              color: filters.verifiedOnly
                  ? Colors.white
                  : tokens.brandAccent,
            ),
            label: const Text('Verified'),
            selected: filters.verifiedOnly,
            selectedColor: tokens.brandAccent,
            backgroundColor: tokens.bgSubtle,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filters.verifiedOnly
                  ? Colors.white
                  : tokens.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.verifiedOnly
                    ? tokens.brandAccent
                    : tokens.borderLow,
              ),
            ),
            onSelected: (_) => cubit.toggleVerifiedOnly(),
          ),
        ],
      ),
    ),
  ),
);
  }

  void _openFullProfile(BuildContext context, Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullProfileScreen(
          profile: profile,
          onAction: (action) {
            context.read<HomeCubit>().takeAction(profile.uid, action);
            if (action == 'like' || action == 'superlike') {
              MatchesRepository.instance.recordOutgoingAction(profile, action);
            }
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, HomeState state) {
    final isFiltered = !state.filters.isDefault;

    return Center(
      child: AppEmptyState(
        icon: isFiltered
            ? Icons.filter_alt_off_rounded
            : Icons.search_off_rounded,
        title: isFiltered
            ? AppStrings.noAliensMatch
            : AppStrings.noProfilesToShow,
        subtitle: isFiltered
            ? AppStrings.noAliensMatchSubtitle
            : AppStrings.noProfilesToShowSubtitle,
        actionLabel: isFiltered
            ? AppStrings.resetAllFilters
            : AppStrings.refresh,
        onAction: isFiltered
            ? () => context.read<HomeCubit>().resetFilters()
            : () => context.read<HomeCubit>().loadProfiles(),
      ),
    );
  }

  Widget _buildFloatingControls(BuildContext context, Profile profile) {
    final inProgress = context.select(
      (HomeCubit c) => c.state.status == HomeStatus.actionInProgress,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rewind (VIP Perk indicator)
          _circleActionButton(
            icon: Icons.replay_rounded,
            color: Colors.amber.shade800,
            bgColor: Colors.amber.shade50,
            size: 46,
            iconSize: 22,
            tooltip: 'Rewind (VIP)',
            onPressed: inProgress
                ? null
                : () => context.read<HomeCubit>().previousProfile(),
          ),

          // Pass / Nope
          _circleActionButton(
            icon: Icons.close_rounded,
            color: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEE2E2),
            size: 60,
            iconSize: 32,
            tooltip: 'Pass',
            onPressed: inProgress
                ? null
                : () => context.read<HomeCubit>().takeAction(
                    profile.uid,
                    'later',
                  ),
          ),

          // Superlike (Special Highlight)
          _circleActionButton(
            icon: Icons.star_rounded,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            size: 50,
            iconSize: 28,
            tooltip: 'Superlike',
            onPressed: inProgress
                ? null
                : () {
                    context.read<HomeCubit>().takeAction(
                      profile.uid,
                      'superlike',
                    );
                    MatchesRepository.instance.recordOutgoingAction(
                      profile,
                      'superlike',
                    );
                  },
          ),

          // Like
          _circleActionButton(
            icon: Icons.favorite_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFD1FAE5),
            size: 60,
            iconSize: 32,
            tooltip: 'Like',
            onPressed: inProgress
                ? null
                : () {
                    context.read<HomeCubit>().takeAction(
                      profile.uid,
                      'like',
                    );
                    MatchesRepository.instance.recordOutgoingAction(
                      profile,
                      'like',
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _circleActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required double size,
    required double iconSize,
    String? tooltip,
    VoidCallback? onPressed,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      enabled: onPressed != null,
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: color.withValues(alpha: 0.18),
          highlightColor: color.withValues(alpha: 0.08),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip ?? '',
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(icon, color: color, size: iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen SwipeCardStack with Tinder-style gesture handling.
class SwipeCardStack extends StatefulWidget {
  const SwipeCardStack({
    required this.profiles,
    required this.onAction,
    super.key,
    this.onOpenDetails,
    this.onNoMore,
  });

  final List<Profile> profiles;
  final void Function(Profile profile, String action) onAction;
  final ValueChanged<Profile>? onOpenDetails;
  final VoidCallback? onNoMore;

  @override
  State<SwipeCardStack> createState() => _SwipeCardStackState();
}

class _SwipeCardStackState extends State<SwipeCardStack>
    with TickerProviderStateMixin {
  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0;
  late AnimationController _resetController;
  late Animation<Offset> _resetOffsetAnim;
  late Animation<double> _resetRotAnim;

  static const double _rotationFactor = 0.0028;
  static const double _swipeThreshold = 120;
  static const double _velocityThreshold = 750;

  @override
  void initState() {
    super.initState();
    _resetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 280),
        )..addListener(() {
          setState(() {
            _cardOffset = _resetOffsetAnim.value;
            _cardRotation = _resetRotAnim.value;
          });
        });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  bool _ignoreDragForEdgeSwipe = false;

  void _onPanStart(DragStartDetails d) {
    _resetController.stop();
    // Safeguard iOS edge-swipe back navigation: If drag originates from the outer left edge (<24px),
    // let system navigation gestures take precedence.
    if (d.localPosition.dx < 24.0) {
      _ignoreDragForEdgeSwipe = true;
      return;
    }
    _ignoreDragForEdgeSwipe = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_ignoreDragForEdgeSwipe) return;
    setState(() {
      _cardOffset += d.delta;
      _cardRotation = _rotationFactor * _cardOffset.dx;
    });
  }

  void _onPanEnd(DragEndDetails d, Profile topProfile) {
    if (_ignoreDragForEdgeSwipe) {
      _ignoreDragForEdgeSwipe = false;
      return;
    }
    final velocity = d.velocity.pixelsPerSecond;
    final primaryVel = velocity.distance;
    final shouldFling = primaryVel > _velocityThreshold;

    if (shouldFling) {
      final action = _determineAction(_cardOffset, velocity);
      _flingOut(_cardOffset, velocity, action, topProfile);
      return;
    }

    if (_cardOffset.dx.abs() > _swipeThreshold) {
      final action = _cardOffset.dx > 0 ? 'like' : 'later';
      _flingOut(_cardOffset, velocity, action, topProfile);
    } else if (_cardOffset.dy < -110 &&
        _cardOffset.dy.abs() > _cardOffset.dx.abs()) {
      _animateReset();
      widget.onOpenDetails?.call(topProfile);
    } else {
      _animateReset();
    }
  }

  String _determineAction(Offset offset, Offset velocity) {
    if (offset.dy < -90 && offset.dy.abs() > offset.dx.abs()) {
      return 'superlike';
    }
    if (offset.dx > 0) return 'like';
    return 'later';
  }

  void _flingOut(
    Offset offset,
    Offset velocity,
    String action,
    Profile profile,
  ) {
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      widget.onAction(profile, action);
      setState(() {
        _cardOffset = Offset.zero;
        _cardRotation = 0;
      });
      if (widget.profiles.length <= 1) {
        widget.onNoMore?.call();
      }
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final endOffset = Offset(
      offset.dx +
          (velocity.dx / 10) +
          (offset.dx.sign * screenSize.width * 1.5),
      offset.dy + (velocity.dy / 10),
    );

    final animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final anim = Tween<Offset>(begin: offset, end: endOffset).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOutCubic),
    );
    final rotAnim =
        Tween<double>(
          begin: _cardRotation,
          end: _cardRotation + (offset.dx.sign * 1.2),
        ).animate(
          CurvedAnimation(parent: animController, curve: Curves.easeOutCubic),
        );

    animController
      ..addListener(() {
        setState(() {
          _cardOffset = anim.value;
          _cardRotation = rotAnim.value;
        });
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          animController.dispose();
          widget.onAction(profile, action);
          setState(() {
            _cardOffset = Offset.zero;
            _cardRotation = 0;
          });

          if (widget.profiles.length <= 1) {
            widget.onNoMore?.call();
          }
        }
      })
      ..forward();
  }

  void _animateReset() {
    _resetOffsetAnim = Tween<Offset>(begin: _cardOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
        );
    _resetRotAnim = Tween<double>(begin: _cardRotation, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.profiles;
    if (profiles.isEmpty) return const SizedBox.shrink();

    final cards = <Widget>[];
    final maxVisible = min(3, profiles.length);

    for (var i = maxVisible - 1; i >= 0; i--) {
      final profile = profiles[i];
      final isTop = i == 0;
      final scale = isTop ? 1.0 : (0.96 - (i * 0.02));
      final translateY = isTop ? 0.0 : (8.0 + i * 6.0);
      final opacity = isTop ? 1.0 : (0.92 - i * 0.1);

      Widget card = Positioned.fill(
        child: Transform.translate(
          offset: isTop ? _cardOffset : Offset(0, translateY),
          child: Transform.rotate(
            angle: isTop ? _cardRotation : 0,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: ProfileCard(
                  profile: profile,
                  onOpenDetails: () => widget.onOpenDetails?.call(profile),
                ),
              ),
            ),
          ),
        ),
      );

      if (isTop) {
        card = Semantics(
          label: '${profiles[0].name}, ${profiles[0].age} years old. Double tap to view full profile. Swipe right to like, swipe left to pass.',
          button: true,
          child: GestureDetector(
            onTap: () => widget.onOpenDetails?.call(profiles[0]),
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (d) => _onPanEnd(d, profiles[0]),
            child: Stack(
              children: [
                card,
                // Stamp badges overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: _cardOffset.distance > 15 ? 1.0 : 0.0,
                      child: ActionStamps(offset: _cardOffset),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      cards.add(card);
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (profiles.isEmpty) return KeyEventResult.ignored;
        final top = profiles.first;

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          _flingOut(
            const Offset(-150, 0),
            const Offset(-800, 0),
            'later',
            top,
          );
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          _flingOut(
            const Offset(150, 0),
            const Offset(800, 0),
            'like',
            top,
          );
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.keyW) {
          _flingOut(
            const Offset(0, -150),
            const Offset(0, -800),
            'superlike',
            top,
          );
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.space) {
          widget.onOpenDetails?.call(top);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Stack(children: cards),
    );
  }
}

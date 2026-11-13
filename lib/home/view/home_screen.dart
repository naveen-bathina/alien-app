// home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myalien/discover/view/discovery_filter_sheet.dart';
import 'package:myalien/discover/view/full_profile_screen.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/cubit/home_cubit.dart';
import 'package:myalien/home/cubit/home_state.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';
import 'package:myalien/home/view/app_drawer.dart';
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
    return Scaffold(
      appBar: AppBar(
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
              return Padding(
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
                        color: const Color(0xFFF3EEFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6C4AB6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '$balance',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C4AB6),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.add_circle,
                            size: 13,
                            color: Color(0xFF6C4AB6),
                          ),
                        ],
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
      bottomNavigationBar: NavigationBar(
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
      body: IndexedStack(
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
                    : Stack(
                        children: [
                          // Full Screen Tinder Swiping Cards
                          Positioned.fill(
                            child: SwipeCardStack(
                              profiles: profiles.skip(index).take(3).toList(),
                              onAction: (profile, action) {
                                context.read<HomeCubit>().takeAction(
                                  profile.uid,
                                  action,
                                );
                                if (action == 'like' || action == 'superlike') {
                                  MatchesRepository.instance
                                      .recordOutgoingAction(profile, action);
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickFilterBar(BuildContext context, HomeState state) {
    final filters = state.filters;
    final cubit = context.read<HomeCubit>();

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          // Filter Tune Button with Badge
          ActionChip(
            avatar: Badge(
              isLabelVisible: filters.activeFilterCount > 0,
              label: Text(
                '${filters.activeFilterCount}',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: const Color(0xFF6C4AB6),
              child: Icon(
                Icons.tune_rounded,
                size: 16,
                color: filters.activeFilterCount > 0
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFF1E1E2D),
              ),
            ),
            label: Text(
              filters.activeFilterCount > 0
                  ? '${AppStrings.navFilters} (${filters.activeFilterCount})'
                  : AppStrings.navFilters,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: filters.activeFilterCount > 0
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFF1E1E2D),
              ),
            ),
            backgroundColor: filters.activeFilterCount > 0
                ? const Color(0xFFF7F5FC)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.activeFilterCount > 0
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFFE2DDF4),
              ),
            ),
            onPressed: () => _openFilterSheet(context),
          ),
          const SizedBox(width: 8),

          // Role quick toggles
          ChoiceChip(
            label: const Text('Earners'),
            selected: filters.role == 'Earner',
            selectedColor: const Color(0xFF6C4AB6),
            backgroundColor: const Color(0xFFF7F5FC),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filters.role == 'Earner'
                  ? Colors.white
                  : const Color(0xFF1E1E2D),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.role == 'Earner'
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFFE2DDF4),
              ),
            ),
            onSelected: (_) => cubit.toggleRole('Earner'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Sponsors'),
            selected: filters.role == 'Sponsor',
            selectedColor: const Color(0xFF6C4AB6),
            backgroundColor: const Color(0xFFF7F5FC),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filters.role == 'Sponsor'
                  ? Colors.white
                  : const Color(0xFF1E1E2D),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.role == 'Sponsor'
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFFE2DDF4),
              ),
            ),
            onSelected: (_) => cubit.toggleRole('Sponsor'),
          ),
          const SizedBox(width: 8),

          // Nearby GPS Quick Chip
          FilterChip(
            avatar: Icon(
              Icons.my_location_rounded,
              size: 14,
              color: filters.nearbyOnly
                  ? Colors.white
                  : const Color(0xFF6C4AB6),
            ),
            label: const Text('📍 Nearby'),
            selected: filters.nearbyOnly,
            selectedColor: const Color(0xFF6C4AB6),
            backgroundColor: const Color(0xFFF7F5FC),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filters.nearbyOnly
                  ? Colors.white
                  : const Color(0xFF1E1E2D),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.nearbyOnly
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFFE2DDF4),
              ),
            ),
            onSelected: (_) => cubit.toggleNearby(),
          ),
          const SizedBox(width: 8),

          // Available Today
          FilterChip(
            avatar: Icon(
              Icons.bolt_rounded,
              size: 16,
              color: filters.availableTodayOnly
                  ? Colors.white
                  : const Color(0xFF16A34A),
            ),
            label: const Text('Available Today'),
            selected: filters.availableTodayOnly,
            selectedColor: const Color(0xFF16A34A),
            backgroundColor: const Color(0xFFF0FDF4),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filters.availableTodayOnly
                  ? Colors.white
                  : const Color(0xFF15803D),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.availableTodayOnly
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            onSelected: (_) => cubit.toggleAvailableToday(),
          ),
          const SizedBox(width: 8),

          // Verified Only
          FilterChip(
            avatar: Icon(
              Icons.verified_rounded,
              size: 15,
              color: filters.verifiedOnly
                  ? Colors.white
                  : const Color(0xFF6C4AB6),
            ),
            label: const Text('Verified'),
            selected: filters.verifiedOnly,
            selectedColor: const Color(0xFF6C4AB6),
            backgroundColor: const Color(0xFFF7F5FC),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filters.verifiedOnly
                  ? Colors.white
                  : const Color(0xFF1E1E2D),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: filters.verifiedOnly
                    ? const Color(0xFF6C4AB6)
                    : const Color(0xFFE2DDF4),
              ),
            ),
            onSelected: (_) => cubit.toggleVerifiedOnly(),
          ),
        ],
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: Icon(icon, color: color, size: iconSize),
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

  void _onPanStart(DragStartDetails d) {
    _resetController.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _cardOffset += d.delta;
      _cardRotation = _rotationFactor * _cardOffset.dx;
    });
  }

  void _onPanEnd(DragEndDetails d, Profile topProfile) {
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
        card = GestureDetector(
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
                    child: _ActionStamps(offset: _cardOffset),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      cards.add(card);
    }

    return Stack(children: cards);
  }
}

/// Full-screen Tinder Profile Card with story progress dashes and coin rate.
class ProfileCard extends StatefulWidget {
  const ProfileCard({
    required this.profile,
    super.key,
    this.onOpenDetails,
  });

  final Profile profile;
  final VoidCallback? onOpenDetails;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _photoIndex = 0;

  void _nextPhoto() {
    final photos = widget.profile.photos;
    if (_photoIndex < photos.length - 1) {
      setState(() => _photoIndex++);
    }
  }

  void _prevPhoto() {
    if (_photoIndex > 0) {
      setState(() => _photoIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final photos = profile.photos;
    final isEarner = profile.isEarner;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 80),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Photo
          if (photos.isEmpty)
            ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.person, size: 96)),
            )
          else
            AppImage(source: photos[_photoIndex]),

          // Tap zones for photo navigation
          if (photos.length > 1) ...[
            // Left Tap: Previous photo
            Positioned(
              top: 0,
              left: 0,
              bottom: 180,
              width: 120,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _prevPhoto,
              ),
            ),
            // Right Tap: Next photo
            Positioned(
              top: 0,
              right: 0,
              bottom: 180,
              width: 120,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _nextPhoto,
              ),
            ),
          ],

          // Top Gradient & Story Progress Bars
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 90,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: photos.length > 1
                  ? Row(
                      children: List.generate(
                        photos.length,
                        (index) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              color: _photoIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Bottom Gradient & Information Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name, Age, Verified & Info Button
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${profile.name}, ${profile.age}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Info / Expand Details Button
                      GestureDetector(
                        onTap: widget.onOpenDetails,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Role & Coin Economics Pill
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isEarner
                                ? Colors.green.shade700
                                : Colors.purple.shade700,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (isEarner ? Colors.green : Colors.purple)
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEarner
                                    ? Icons.stars_rounded
                                    : Icons.diamond_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  isEarner && profile.coinsPerHour != null
                                      ? '🪙 ${profile.coinsPerHour} C/hr • Earner'
                                      : '👑 Sponsor • Host',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${profile.rating}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      if (isEarner) ...[
                        const SizedBox(width: 8),
                        // Instant 1-Tap Book Button
                        InkWell(
                          onTap: () => ScheduleHangoutSheet.show(
                            context,
                            profile: profile,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C4AB6),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Book',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Location & Distance
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Availability Status Pill
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: profile.availability.isAvailableToday
                              ? Colors.greenAccent.shade400
                              : Colors.orangeAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${profile.availability.statusText} • '
                          '${profile.availability.timeWindow}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Bio Snippet
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      profile.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic LIKE / NOPE / SUPER LIKE Stamp Badges
class _ActionStamps extends StatelessWidget {
  const _ActionStamps({required this.offset});
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final dx = offset.dx;
    final dy = offset.dy;

    final isLike = dx > 20;
    final isNope = dx < -20;
    final isSuper = dy < -40 && dy.abs() > dx.abs();

    if (isSuper) {
      final opacity = min<double>(dy.abs() / 120, 1);
      return Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: _stamp(
              'SUPER LIKE',
              Colors.blueAccent.shade400,
              icon: Icons.star_rounded,
            ),
          ),
        ),
      );
    }

    if (isLike) {
      final opacity = min<double>(dx.abs() / 100, 1);
      return Positioned(
        top: 50,
        left: 30,
        child: Transform.rotate(
          angle: -0.25,
          child: Opacity(
            opacity: opacity,
            child: _stamp(
              'LIKE',
              Colors.greenAccent.shade700,
              icon: Icons.favorite_rounded,
            ),
          ),
        ),
      );
    }

    if (isNope) {
      final opacity = min<double>(dx.abs() / 100, 1);
      return Positioned(
        top: 50,
        right: 30,
        child: Transform.rotate(
          angle: 0.25,
          child: Opacity(
            opacity: opacity,
            child: _stamp(
              'NOPE',
              Colors.redAccent.shade400,
              icon: Icons.close_rounded,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _stamp(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

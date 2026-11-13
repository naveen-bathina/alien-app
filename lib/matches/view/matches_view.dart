import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/app/view/responsive_breakpoints.dart';
import 'package:myalien/app/widgets/app_button.dart';
import 'package:myalien/app/widgets/app_card.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/chat/view/chat_screen.dart';
import 'package:myalien/discover/view/full_profile_screen.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/matches/cubit/matches_cubit.dart';
import 'package:myalien/matches/models/match_entry.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({
    super.key,
    this.cubit,
    this.onExploreTapped,
  });

  final MatchesCubit? cubit;
  final VoidCallback? onExploreTapped;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _MatchesContent(onExploreTapped: onExploreTapped),
      );
    }
    return BlocProvider(
      create: (_) => MatchesCubit(),
      child: _MatchesContent(onExploreTapped: onExploreTapped),
    );
  }
}

class _MatchesContent extends StatefulWidget {
  const _MatchesContent({this.onExploreTapped});

  final VoidCallback? onExploreTapped;

  @override
  State<_MatchesContent> createState() => _MatchesContentState();
}

class _MatchesContentState extends State<_MatchesContent> {
  final _searchCtrl = TextEditingController();
  Profile? _selectedChatProfile;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openChatWith(BuildContext context, Profile profile) {
    if (WebBreakpoints.isExpanded(context)) {
      setState(() => _selectedChatProfile = profile);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(
            userName: profile.name,
          ),
        ),
      );
    }
  }

  void _openFullProfile(BuildContext context, Profile profile) {
    final cubit = context.read<MatchesCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullProfileScreen(
          profile: profile,
          onAction: (action) {
            if (action == 'like') {
              cubit.likeBack(profile);
            } else if (action == 'superlike') {
              cubit.superlikeBack(profile);
            }
          },
        ),
      ),
    );
  }

  Future<void> _showBookingSheet(BuildContext context, Profile profile) async {
    final hangout = await ScheduleHangoutSheet.show(context, profile: profile);
    if (!context.mounted || hangout == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Hangout scheduled with ${profile.name} on ${hangout.dateFormatted}!',
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        if (state.status == MatchesStatus.loading && state.entries.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final visibleEntries = state.visibleEntries;
        final isDesktop = WebBreakpoints.isExpanded(context);

        final matchesList = CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) =>
                      context.read<MatchesCubit>().setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchMatchesHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<MatchesCubit>().setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header summary count (All in one unified place)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'All Connections',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.entries.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Content List or Empty State
            if (visibleEntries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context, state),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = visibleEntries[index];
                      final isSelected =
                          isDesktop &&
                          _selectedChatProfile?.uid == entry.profile.uid;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMatchCard(
                          context,
                          entry,
                          isSelected: isSelected,
                        ),
                      );
                    },
                    childCount: visibleEntries.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 440,
                  child: matchesList,
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _selectedChatProfile != null
                      ? Column(
                          children: [
                            _buildDesktopCompanionBanner(
                              context,
                              _selectedChatProfile!,
                            ),
                            Expanded(
                              child: ChatScreen(
                                userName: _selectedChatProfile!.name,
                                showBackButton: false,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Select a Match to Chat',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose a companion from the list to start chatting or plan a meetup.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: matchesList,
        );
      },
    );
  }

  Widget _buildDesktopCompanionBanner(BuildContext context, Profile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final coinsPerHour = profile.coinsPerHour ?? 80;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _openFullProfile(context, profile),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              child: SizedBox(
                width: 46,
                height: 46,
                child: profile.photos.isNotEmpty
                    ? AppImage(
                        source: profile.photos.first,
                        fit: BoxFit.cover,
                        memCacheWidth: 120,
                        memCacheHeight: 120,
                      )
                    : ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.person, size: 28),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${profile.name}, ${profile.age}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      profile.rating.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '• $coinsPerHour 🪙/hr',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Quick Hangout Action
          AppButton(
            label: 'Schedule Hangout',
            icon: Icons.calendar_month_rounded,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.sm,
            onPressed: () => _showBookingSheet(context, profile),
          ),
          const SizedBox(width: 8),
          AppButton(
            label: 'Profile',
            icon: Icons.info_outline_rounded,
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.sm,
            onPressed: () => _openFullProfile(context, profile),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    MatchEntry entry, {
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = entry.profile;
    final cubit = context.read<MatchesCubit>();

    // Determine visual status styling for card distinction
    final Color statusColor;
    final Color cardBorderColor;
    final Color cardBackgroundTint;

    if (entry.relation == MatchRelationType.mutuallySuperliked) {
      statusColor = Colors.amber.shade700;
      cardBorderColor = Colors.amber.shade400;
      cardBackgroundTint = Colors.amber.withValues(alpha: 0.05);
    } else if (entry.relation == MatchRelationType.mutuallyLiked) {
      statusColor = Colors.pinkAccent;
      cardBorderColor = Colors.pinkAccent.withValues(alpha: 0.4);
      cardBackgroundTint = Colors.pink.withValues(alpha: 0.03);
    } else if (entry.isReceived) {
      statusColor = const Color(0xFF6C4AB6);
      cardBorderColor = const Color(0xFF6C4AB6).withValues(alpha: 0.35);
      cardBackgroundTint = const Color(0xFF6C4AB6).withValues(alpha: 0.03);
    } else {
      statusColor = colorScheme.outlineVariant;
      cardBorderColor = colorScheme.outlineVariant.withValues(alpha: 0.4);
      cardBackgroundTint = Colors.transparent;
    }

    return AppCard(
      onTap: () {
        if (WebBreakpoints.isExpanded(context) && entry.isMutual) {
          _openChatWith(context, profile);
        } else {
          _openFullProfile(context, profile);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundTint,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: isSelected ? colorScheme.primary : cardBorderColor,
            width: isSelected || entry.isMutual ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar / Image
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusMd + 2,
                        ),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.5),
                          width: entry.isMutual ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        child: SizedBox(
                          width: 84,
                          height: 84,
                          child: profile.photos.isNotEmpty
                              ? AppImage(
                                  source: profile.photos.first,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 200,
                                  memCacheHeight: 200,
                                )
                              : ColoredBox(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.person, size: 44),
                                ),
                        ),
                      ),
                    ),
                    if (entry.isMutual)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            entry.relation ==
                                    MatchRelationType.mutuallySuperliked
                                ? Icons.auto_awesome_rounded
                                : Icons.favorite_rounded,
                            size: 14,
                            color:
                                entry.relation ==
                                    MatchRelationType.mutuallySuperliked
                                ? Colors.amber.shade700
                                : Colors.pinkAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Companion Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layman Status Badge
                      _buildRelationBadge(context, entry.relation),
                      const SizedBox(height: 6),

                      // Name & Age
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${profile.name}, ${profile.age}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Rating & Rate
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                profile.rating.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '(${profile.reviewsCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          if (profile.coinsPerHour != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${profile.coinsPerHour} 🪙/hr',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              profile.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (profile.tagline != null && profile.tagline!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                profile.tagline!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),

            // Bottom Action Row
            Row(
              children: [
                // Quick actions based on relationship
                if (entry.relation == MatchRelationType.receivedLike) ...[
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        cubit.likeBack(profile);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "It's a Mutual Match with ${profile.name}! 🎉",
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite_rounded, size: 16),
                      label: const Text(AppStrings.likeBack),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber.shade800,
                        side: BorderSide(color: Colors.amber.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        cubit.superlikeBack(profile);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "It's a Mutual Superlike Match with ${profile.name}! 🌟",
                            ),
                            backgroundColor: Colors.amber.shade800,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text(AppStrings.superlike),
                    ),
                  ),
                ] else if (entry.relation ==
                    MatchRelationType.receivedSuperlike) ...[
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        cubit.superlikeBack(profile);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "It's a Mutual Superlike Match with ${profile.name}! 🌟",
                            ),
                            backgroundColor: Colors.amber.shade800,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text(AppStrings.superlikeBack),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pinkAccent,
                        side: const BorderSide(color: Colors.pinkAccent),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        cubit.likeBack(profile);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "It's a Mutual Match with ${profile.name}! 🎉",
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite_rounded, size: 16),
                      label: const Text(AppStrings.likeBack),
                    ),
                  ),
                ] else if (entry.isMutual) ...[
                  // 1-Tap Say Hello / Chat
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _openChatWith(context, profile),
                      icon: const Icon(Icons.chat_bubble_rounded, size: 15),
                      label: const Text('Say Hello'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Book Hangout / Meetup
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showBookingSheet(context, profile),
                      icon: const Icon(Icons.calendar_month_rounded, size: 15),
                      label: const Text(AppStrings.bookHangout),
                    ),
                  ),
                ] else ...[
                  // Sent like or sent superlike
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _openFullProfile(context, profile),
                      icon: const Icon(Icons.person_outline_rounded, size: 16),
                      label: const Text(AppStrings.viewProfile),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationBadge(BuildContext context, MatchRelationType relation) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (relation) {
      case MatchRelationType.mutuallyLiked:
        bg = Colors.pink.shade50;
        fg = Colors.pinkAccent.shade700;
        label = AppStrings.matchMutuallyLiked;
        icon = Icons.favorite_rounded;
      case MatchRelationType.mutuallySuperliked:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        label = AppStrings.matchMutuallySuperliked;
        icon = Icons.auto_awesome_rounded;
      case MatchRelationType.receivedLike:
        bg = Colors.red.shade50;
        fg = Colors.redAccent.shade700;
        label = AppStrings.matchLikedYou;
        icon = Icons.favorite_border_rounded;
      case MatchRelationType.receivedSuperlike:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        label = AppStrings.matchSuperlikedYou;
        icon = Icons.star_rounded;
      case MatchRelationType.sentLike:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = AppStrings.matchLikedByYou;
        icon = Icons.thumb_up_alt_rounded;
      case MatchRelationType.sentSuperlike:
        bg = Colors.purple.shade50;
        fg = Colors.deepPurple;
        label = AppStrings.matchSuperlikedByYou;
        icon = Icons.rocket_launch_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MatchesState state) {
    if (state.searchQuery.isNotEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: AppStrings.noMatchesFound,
        subtitle: 'No companions match "${state.searchQuery}".',
      );
    }

    switch (state.selectedFilter) {
      case MatchFilter.all:
        return AppEmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'No Interactions Yet',
          subtitle:
              'Discover companions, like, and chat to start building connections!',
          actionLabel: AppStrings.exploreCompanions,
          onAction: widget.onExploreTapped,
        );
      case MatchFilter.mutuallyLiked:
        return AppEmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'No Mutually Liked Matches Yet',
          subtitle:
              'When you and another companion both like each other, you will connect here!',
          actionLabel: AppStrings.exploreCompanions,
          onAction: widget.onExploreTapped,
        );
      case MatchFilter.mutuallySuperliked:
        return AppEmptyState(
          icon: Icons.auto_awesome_rounded,
          title: 'No Mutually Superliked Matches Yet',
          subtitle:
              'When you and a companion both superlike each other, your special connection appears here!',
          actionLabel: AppStrings.exploreCompanions,
          onAction: widget.onExploreTapped,
        );
      case MatchFilter.likedYou:
        return const AppEmptyState(
          icon: Icons.favorite_rounded,
          title: 'No Likes Received Yet',
          subtitle:
              'Keep your profile active and discover companions to get noticed and receive likes.',
        );
      case MatchFilter.superlikedYou:
        return const AppEmptyState(
          icon: Icons.star_rounded,
          title: 'No Superlikes Received Yet',
          subtitle:
              'When a companion sends you a Superlike to make a memorable impression, they will appear here!',
        );
      case MatchFilter.youLiked:
        return AppEmptyState(
          icon: Icons.thumb_up_alt_outlined,
          title: "You Haven't Liked Anyone Yet",
          subtitle:
              'Explore companions in Discover and like profiles that match your vibe!',
          actionLabel: AppStrings.exploreCompanions,
          onAction: widget.onExploreTapped,
        );
      case MatchFilter.youSuperliked:
        return AppEmptyState(
          icon: Icons.rocket_launch_outlined,
          title: "You Haven't Superliked Anyone Yet",
          subtitle:
              "Send a Superlike to catch someone's eye and stand out in their inbox!",
          actionLabel: AppStrings.exploreCompanions,
          onAction: widget.onExploreTapped,
        );
    }
  }
}

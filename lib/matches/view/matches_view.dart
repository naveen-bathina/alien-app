import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/view/app_image.dart';
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Category Filter Pills Rail
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip(
                        context,
                        filter: MatchFilter.mutuallyLiked,
                        label: AppStrings.matchMutuallyLiked,
                        icon: Icons.favorite_rounded,
                        color: Colors.pinkAccent,
                        count: state.mutuallyLikedCount,
                        isSelected:
                            state.selectedFilter == MatchFilter.mutuallyLiked,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        filter: MatchFilter.mutuallySuperliked,
                        label: AppStrings.matchMutuallySuperliked,
                        icon: Icons.auto_awesome_rounded,
                        color: Colors.amber.shade700,
                        count: state.mutuallySuperlikedCount,
                        isSelected: state.selectedFilter ==
                            MatchFilter.mutuallySuperliked,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        filter: MatchFilter.likedYou,
                        label: AppStrings.matchLikedYou,
                        icon: Icons.favorite_border_rounded,
                        color: Colors.redAccent,
                        count: state.likedYouCount,
                        isSelected: state.selectedFilter == MatchFilter.likedYou,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        filter: MatchFilter.superlikedYou,
                        label: AppStrings.matchSuperlikedYou,
                        icon: Icons.star_rounded,
                        color: Colors.amber.shade600,
                        count: state.superlikedYouCount,
                        isSelected:
                            state.selectedFilter == MatchFilter.superlikedYou,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        filter: MatchFilter.youLiked,
                        label: AppStrings.matchYouLiked,
                        icon: Icons.thumb_up_alt_rounded,
                        color: AppColors.primary,
                        count: state.youLikedCount,
                        isSelected: state.selectedFilter == MatchFilter.youLiked,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        filter: MatchFilter.youSuperliked,
                        label: AppStrings.matchYouSuperliked,
                        icon: Icons.rocket_launch_rounded,
                        color: Colors.deepPurpleAccent,
                        count: state.youSuperlikedCount,
                        isSelected:
                            state.selectedFilter == MatchFilter.youSuperliked,
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildMatchCard(context, entry),
                        );
                      },
                      childCount: visibleEntries.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required MatchFilter filter,
    required String label,
    required IconData icon,
    required Color color,
    required int count,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => context.read<MatchesCubit>().selectFilter(filter),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : color,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      selectedColor: color,
      backgroundColor: colorScheme.surfaceContainerLow,
      side: BorderSide(
        color: isSelected
            ? color
            : colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = entry.profile;
    final cubit = context.read<MatchesCubit>();

    return AppCard(
      onTap: () => _openFullProfile(context, profile),
      child: Padding(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: profile.photos.isNotEmpty
                            ? AppImage(
                                source: profile.photos.first,
                                fit: BoxFit.cover,
                              )
                            : ColoredBox(
                                color: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.person, size: 48),
                              ),
                      ),
                    ),
                    if (entry.isMutual)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            entry.relation ==
                                    MatchRelationType.mutuallySuperliked
                                ? Icons.auto_awesome_rounded
                                : Icons.favorite_rounded,
                            size: 14,
                            color: entry.relation ==
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
                      // Status Badge
                      _buildRelationBadge(context, entry.relation),
                      const SizedBox(height: 6),

                      // Name & Age
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Rating & Reviews & Rate
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
                                size: 16,
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
                              const SizedBox(width: 4),
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
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${profile.coinsPerHour} C/hr',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
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
            const Divider(height: 1),
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChatScreen(
                              userName: profile.name,
                            ),
                          ),
                        );
                      },
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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
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

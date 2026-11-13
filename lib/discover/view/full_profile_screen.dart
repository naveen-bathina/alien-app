import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';

class FullProfileScreen extends StatefulWidget {
  const FullProfileScreen({
    required this.profile,
    super.key,
    this.onAction,
    this.isPreview = false,
  });

  final Profile profile;
  final void Function(String action)? onAction;
  final bool isPreview;

  @override
  State<FullProfileScreen> createState() => _FullProfileScreenState();
}

class _FullProfileScreenState extends State<FullProfileScreen> {
  int _currentPhotoIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showBookingSheet() async {
    final profile = widget.profile;
    final hangout = await ScheduleHangoutSheet.show(context, profile: profile);

    if (!mounted || hangout == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Hangout scheduled with ${profile.name} for '
                '${hangout.dateFormatted} (${hangout.timeRangeFormatted})! '
                '(${hangout.totalCoins} Coins reserved)',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = widget.profile;
    final photos = profile.photos;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Photo Carousel
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 480,
                      width: double.infinity,
                      child: photos.isEmpty
                          ? ColoredBox(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.person, size: 96),
                            )
                          : PageView.builder(
                              controller: _pageController,
                              itemCount: photos.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentPhotoIndex = i),
                              itemBuilder: (context, i) {
                                return AppImage(source: photos[i]);
                              },
                            ),
                    ),
                    // Gradient overlay at top for back button
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Back / Close Button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    // Photo Indicator Dots
                    if (photos.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            photos.length,
                            (index) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentPhotoIndex == index ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentPhotoIndex == index
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name, Age & Verified
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${profile.name}, ${profile.age}',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: Colors.blueAccent,
                                    size: 24,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Rating Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile.rating} (${profile.reviewsCount})',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (profile.tagline != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.tagline!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.location,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Role & Coin Economics Card
                      _buildEconomicsCard(theme, colorScheme),

                      const SizedBox(height: 22),

                      // About / Bio
                      _buildSectionTitle(AppStrings.about, theme),
                      const SizedBox(height: 8),
                      Text(
                        profile.bio.isNotEmpty
                            ? profile.bio
                            : 'No bio added yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),

                      if (profile.lookingFor != null) ...[
                        const SizedBox(height: 16),
                        _buildSectionTitle(AppStrings.hangoutFor, theme),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                profile.lookingFor!,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pinned Bottom Action Bar
          if (!widget.isPreview)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActionBar(colorScheme),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEconomicsCard(ThemeData theme, ColorScheme colorScheme) {
    final profile = widget.profile;
    final isEarner = profile.isEarner;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isEarner
            ? Colors.green.shade50.withValues(alpha: 0.5)
            : colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarner
              ? Colors.green.shade300
              : colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEarner ? Colors.green.shade700 : colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarner ? Icons.stars_rounded : Icons.diamond_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isEarner ? 'Companion Earner' : 'Community Sponsor',
                      style: TextStyle(
                        color: isEarner
                            ? Colors.green.shade900
                            : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (isEarner && profile.coinsPerHour != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${profile.coinsPerHour} Coins/hr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEarner
                      ? 'Available for cafe dates, movie companion, event '
                          'attendance & city guides.'
                      : 'Loves hosting dinners, sponsoring events, and funding '
                          'meetups for friends.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          IconButton.filledTonal(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onAction?.call('later');
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: const EdgeInsets.all(12),
            ),
          ),

          // Superlike Button
          IconButton.filledTonal(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onAction?.call('superlike');
            },
            icon: const Icon(
              Icons.star_rounded,
              color: Colors.blueAccent,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              padding: const EdgeInsets.all(12),
            ),
          ),

          // Like Button
          IconButton.filled(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onAction?.call('like');
            },
            icon: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(width: 4),

          // Prominent Floating Booking Bar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showBookingSheet,
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text(
                widget.profile.isEarner && widget.profile.coinsPerHour != null
                    ? 'Book • ${widget.profile.coinsPerHour} C/hr'
                    : 'Invite / Host Meetup',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.profile.isEarner
                    ? const Color(0xFF10B981)
                    : colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

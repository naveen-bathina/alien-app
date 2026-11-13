import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/app/widgets/app_badge.dart';
import 'package:myalien/app/widgets/app_button.dart';
import 'package:myalien/app/widgets/stat_card.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';

/// SaaS Bento Details Panel for Desktop Discover feed (Linear/Notion inspired).
class CompanionBentoPanel extends StatefulWidget {
  const CompanionBentoPanel({
    required this.profile,
    super.key,
    this.onAction,
  });

  final Profile profile;
  final void Function(String action)? onAction;

  @override
  State<CompanionBentoPanel> createState() => _CompanionBentoPanelState();
}

class _CompanionBentoPanelState extends State<CompanionBentoPanel> {
  int _photoIndex = 0;

  Future<void> _showBookingSheet() async {
    final hangout = await ScheduleHangoutSheet.show(
      context,
      profile: widget.profile,
    );
    if (!mounted || hangout == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hangout scheduled with ${widget.profile.name}!'),
        backgroundColor: AppTokens.brandPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final profile = widget.profile;
    final photos = profile.photos.isNotEmpty
        ? profile.photos
        : (profile.photoUrl != null ? [profile.photoUrl!] : <String>[]);
    final currentPhoto =
        photos.isNotEmpty ? photos[_photoIndex % photos.length] : null;

    final coinsPerHour = profile.coinsPerHour ?? 80;
    final inrRate = coinsPerHour * 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. High-Res Photo Card Bento
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: tokens.bgSurface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(color: tokens.borderLow),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  source: currentPhoto,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  memCacheHeight: 400,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                if (photos.length > 1) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 20),
                        onPressed: _photoIndex > 0
                            ? () => setState(() => _photoIndex--)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 20),
                        onPressed: _photoIndex < photos.length - 1
                            ? () => setState(() => _photoIndex++)
                            : null,
                      ),
                    ),
                  ),
                ],
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${profile.name}, ${profile.age}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (profile.isVerified)
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: AppTokens.brandPrimaryLight,
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  profile.location,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppBadge(
                        label: profile.role,
                        variant: AppBadgeVariant.primary,
                        hasDot: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space3),

          // 2. Bento Metrics Grid (Rate & Rating)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Hourly Booking',
                  value: '${profile.coinsPerHour} 🪙',
                  subtitle: '≈ ₹$inrRate INR / hour',
                  icon: Icons.monetization_on_outlined,
                  trend: 'Escrow Safe',
                  isPositiveTrend: true,
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: StatCard(
                  title: 'Companion Rating',
                  value: '${profile.rating} ★',
                  subtitle: '${profile.reviewsCount} verified reviews',
                  icon: Icons.star_border_rounded,
                  trend: 'Top Rated',
                  isPositiveTrend: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space3),

          // 3. Bento Bio & Availability Container
          Container(
            padding: const EdgeInsets.all(AppTokens.space4),
            decoration: BoxDecoration(
              color: tokens.bgSurface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(color: tokens.borderLow),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Companion Profile',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppBadge(
                      label: profile.availability.statusText,
                      variant: profile.availability.isAvailableToday
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      hasDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  profile.bio.isNotEmpty
                      ? profile.bio
                      : 'No bio provided yet.',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if (profile.lookingFor != null &&
                    profile.lookingFor!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: [
                      AppBadge(
                        label: 'Looking for: ${profile.lookingFor}',
                        variant: AppBadgeVariant.neutral,
                      ),
                      if (profile.isLocationFlexible)
                        const AppBadge(
                          label: 'Flexible Location',
                          variant: AppBadgeVariant.neutral,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space4),

          // 4. Action Button
          AppButton(
            onPressed: _showBookingSheet,
            label: 'Schedule Hangout (Escrow Safe)',
            icon: Icons.calendar_month_rounded,
            size: AppButtonSize.lg,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

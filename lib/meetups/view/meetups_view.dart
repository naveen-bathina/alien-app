import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/chat/view/chat_screen.dart';
import 'package:myalien/hangout/repository/hangout_repository.dart';
import 'package:myalien/models/hangout_request.dart';

/// Screen displaying the user's upcoming and active companion hangouts.
class MeetupsView extends StatefulWidget {
  const MeetupsView({
    super.key,
    this.onExploreTapped,
  });

  final VoidCallback? onExploreTapped;

  @override
  State<MeetupsView> createState() => _MeetupsViewState();
}

class _MeetupsViewState extends State<MeetupsView> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = History

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Segmented Tabs Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentButton(
                    title: 'Upcoming',
                    index: 0,
                    icon: Icons.access_time_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSegmentButton(
                    title: 'History',
                    index: 1,
                    icon: Icons.history_rounded,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Stream Content
          Expanded(
            child: StreamBuilder<List<HangoutRequest>>(
              stream: hangoutRepository.hangoutsStream,
              initialData: hangoutRepository.currentBookings,
              builder: (context, snapshot) {
                final allHangouts = snapshot.data ?? [];

                final upcoming = allHangouts.where((h) {
                  final s = h.status.toLowerCase();
                  return s == 'confirmed' || s == 'pending' || s == 'declined';
                }).toList();

                final history = allHangouts.where((h) {
                  final s = h.status.toLowerCase();
                  return s == 'completed' || s == 'cancelled' || s == 'rejected';
                }).toList();

                final displayed = _selectedTab == 0 ? upcoming : history;

                if (displayed.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      icon: _selectedTab == 0
                          ? Icons.calendar_month_outlined
                          : Icons.history_rounded,
                      title: _selectedTab == 0
                          ? AppStrings.noHangoutsScheduled
                          : 'No Past Meetups',
                      subtitle: _selectedTab == 0
                          ? AppStrings.noHangoutsScheduledSubtitle
                          : 'Your completed and past meetup history will appear here.',
                      actionLabel: (_selectedTab == 0 && widget.onExploreTapped != null)
                          ? AppStrings.exploreCompanions
                          : null,
                      onAction: widget.onExploreTapped,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: displayed.length,
                  itemBuilder: (context, index) {
                    final hangout = displayed[index];
                    return _buildHangoutCard(context, hangout);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required int index,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : const Color(0xFFF7F5FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2DDF4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHangoutCard(BuildContext context, HangoutRequest hangout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Companion avatar, name, role and status
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: AppImage(
                    source: hangout.companionAvatar,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hangout.companionName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🪙 ${hangout.coinsPerHour} Coins/hr • ${hangout.companionRole}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(hangout.status),
            ],
          ),
          const SizedBox(height: 14),

          // Date & Time Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  hangout.dateFormatted,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${hangout.timeRangeFormatted} '
                  '(${hangout.durationHours} hrs)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Activity & Location
          Row(
            children: [
              const Icon(
                Icons.local_activity_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                hangout.activity,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hangout.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),

          // Bottom: Total Coins + Message button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reserved Cost',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🪙 ${hangout.totalCoins} Coins',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (hangout.status.toLowerCase() == 'pending') ...[
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _handleReject(context, hangout),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _handleAccept(context, hangout),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ] else
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(
                          userName: hangout.companionName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    final normalized = status.toLowerCase();

    switch (normalized) {
      case 'pending':
        bg = AppColors.warningLight;
        fg = AppColors.warning;
      case 'declined':
      case 'rejected':
      case 'cancelled':
        bg = AppColors.errorLight;
        fg = AppColors.error;
      case 'confirmed':
      case 'accepted':
      default:
        bg = AppColors.successLight;
        fg = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: fg.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _handleAccept(BuildContext context, HangoutRequest hangout) {
    hangoutRepository.updateHangoutStatus(hangout.id, 'confirmed');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Accepted hangout with ${hangout.companionName}!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleReject(BuildContext context, HangoutRequest hangout) {
    hangoutRepository.updateHangoutStatus(hangout.id, 'declined');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Declined hangout with ${hangout.companionName}.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

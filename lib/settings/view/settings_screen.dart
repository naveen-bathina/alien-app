import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/app/widgets/app_card.dart';
import 'package:myalien/app/widgets/app_empty_state.dart';
import 'package:myalien/dev/synthetic_data_seeder.dart';
import 'package:myalien/settings/cubit/settings_cubit.dart';
import 'package:myalien/settings/cubit/settings_state.dart';
import 'package:myalien/settings/models/notification_item.dart';
import 'package:myalien/settings/repository/notification_repository.dart';
import 'package:myalien/wallet/view/wallet_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.repository,
  });

  final NotificationRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(repository: repository),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: const BrandAppBarTitle(AppStrings.settings),
        centerTitle: false,
        actions: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => context.read<SettingsCubit>().markAllAsRead(),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text(
                  AppStrings.markAllAsRead,
                  style: TextStyle(fontSize: 12),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // Header with subtitle & unread badge
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              AppStrings.realtimeNotifications,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (state.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${state.unreadCount} new',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Filter Chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildFilterChip(
                          context,
                          label: 'All',
                          filter: SettingsFilter.all,
                          activeFilter: state.filter,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Unread',
                          filter: SettingsFilter.unread,
                          activeFilter: state.filter,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Matches',
                          filter: SettingsFilter.matches,
                          activeFilter: state.filter,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Hangouts',
                          filter: SettingsFilter.hangouts,
                          activeFilter: state.filter,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Wallet',
                          filter: SettingsFilter.wallet,
                          activeFilter: state.filter,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Notifications List or Empty State
                if (state.filteredNotifications.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: AppEmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: AppStrings.noNotifications,
                          subtitle: AppStrings.noNotificationsSubtitle,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = state.filteredNotifications[index];
                          return _NotificationCard(
                            key: ValueKey(item.id),
                            item: item,
                            onTap: () => _handleNotificationTap(context, item),
                            onDismiss: () => context
                                .read<SettingsCubit>()
                                .deleteNotification(item.id),
                          );
                        },
                        childCount: state.filteredNotifications.length,
                      ),
                    ),
                  ),

                // Notification Preferences Accordion
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AppCard(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          leading: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                          ),
                          title: const Text(
                            AppStrings.notificationPreferences,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Synced realtime with Cloud Firestore',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          children: [
                            SwitchListTile.adaptive(
                              title: const Text(AppStrings.pushNotifications),
                              value:
                                  state.notificationPreferences['push'] ?? true,
                              activeColor: AppColors.primary,
                              onChanged: (val) => context
                                  .read<SettingsCubit>()
                                  .updatePreference('push', val),
                            ),
                            SwitchListTile.adaptive(
                              title: const Text(AppStrings.matchAlerts),
                              value: state.notificationPreferences['matches'] ??
                                  true,
                              activeColor: AppColors.primary,
                              onChanged: (val) => context
                                  .read<SettingsCubit>()
                                  .updatePreference('matches', val),
                            ),
                            SwitchListTile.adaptive(
                              title: const Text(AppStrings.hangoutAlerts),
                              value:
                                  state.notificationPreferences['hangouts'] ??
                                      true,
                              activeColor: AppColors.primary,
                              onChanged: (val) => context
                                  .read<SettingsCubit>()
                                  .updatePreference('hangouts', val),
                            ),
                            SwitchListTile.adaptive(
                              title: const Text(AppStrings.walletAlerts),
                              value: state.notificationPreferences['wallet'] ??
                                  true,
                              activeColor: AppColors.primary,
                              onChanged: (val) => context
                                  .read<SettingsCubit>()
                                  .updatePreference('wallet', val),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Developer & Testing Tools Accordion
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: AppCard(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          leading: const Icon(
                            Icons.developer_mode_rounded,
                            color: Color(0xFF8B5CF6),
                          ),
                          title: const Text(
                            'Developer & Testing Tools',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Seed synthetic companion & sponsor scenarios',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          children: const [
                            _DeveloperSeederControls(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required SettingsFilter filter,
    required SettingsFilter activeFilter,
  }) {
    final isSelected = filter == activeFilter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<SettingsCubit>().setFilter(filter),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationItem item) {
    if (!item.isRead) {
      context.read<SettingsCubit>().markAsRead(item.id);
    }

    if (item.actionRoute == 'wallet') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WalletScreen(),
        ),
      );
    } else if (item.actionRoute == 'matches' ||
        item.actionRoute == 'hangouts') {
      Navigator.of(context).pop();
    }
  }
}

class _DeveloperSeederControls extends StatefulWidget {
  const _DeveloperSeederControls();

  @override
  State<_DeveloperSeederControls> createState() =>
      _DeveloperSeederControlsState();
}

class _DeveloperSeederControlsState extends State<_DeveloperSeederControls> {
  bool _isSeeding = false;
  bool _isClearing = false;
  String? _statusMessage;

  Future<void> _handleSeed() async {
    setState(() {
      _isSeeding = true;
      _statusMessage = null;
    });

    try {
      const seeder = SyntheticDataSeeder();
      final count = await seeder.seedAll();
      if (!mounted) return;

      setState(() {
        _isSeeding = false;
        _statusMessage = '✓ Seeded $count synthetic profiles & bookings!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully seeded $count synthetic records!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _isSeeding = false;
        _statusMessage = 'Seeding notice: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notice: $e'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleClear() async {
    setState(() {
      _isClearing = true;
      _statusMessage = null;
    });

    try {
      const seeder = SyntheticDataSeeder();
      final count = await seeder.clearSyntheticData();
      if (!mounted) return;

      setState(() {
        _isClearing = false;
        _statusMessage = '✓ Removed $count synthetic records.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleared $count synthetic records from Firestore.'),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _isClearing = false;
        _statusMessage = 'Clear notice: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Populate 10 diverse synthetic companion & sponsor profiles '
            'across Hyderabad, Bangalore, Mumbai, Delhi, and Goa to test '
            'discovery, filtering, booking conflicts, and wallet flows.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_isSeeding || _isClearing) ? null : _handleSeed,
                  icon: _isSeeding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: Text(_isSeeding ? 'Seeding...' : 'Seed 10 Profiles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: (_isSeeding || _isClearing) ? null : _handleClear,
                icon: _isClearing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ],
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _statusMessage!,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  IconData get _icon {
    switch (item.type) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'match':
        return Icons.favorite_rounded;
      case 'hangout':
        return Icons.calendar_month_rounded;
      case 'system':
      default:
        return Icons.shield_rounded;
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case 'wallet':
        return AppColors.coinGold;
      case 'match':
        return Colors.pink;
      case 'hangout':
        return AppColors.primary;
      case 'system':
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF3EEFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.35),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight:
                        item.isRead ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!item.isRead) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.body,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(item.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

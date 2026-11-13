import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/theme/theme_cubit.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/app/widgets/command_palette_modal.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';
import 'package:myalien/wallet/view/buy_coins_sheet.dart';

/// Slim 56px global desktop app bar inspired by Linear and Vercel.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    super.key,
    this.breadcrumbs,
    this.onOpenCommandPalette,
    this.onOpenNotifications,
    this.trailing,
  });

  final String title;
  final List<String>? breadcrumbs;
  final VoidCallback? onOpenCommandPalette;
  final VoidCallback? onOpenNotifications;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(AppTokens.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    ThemeCubit? themeCubit;
    try {
      themeCubit = context.watch<ThemeCubit>();
    } on Object {
      // Allow usage when ThemeCubit is not above context (e.g. focused widget tests)
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: AppTokens.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space4),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        border: Border(bottom: BorderSide(color: tokens.borderLow)),
      ),
      child: Row(
        children: [
          // Breadcrumbs / Title
          Row(
            children: [
              Text(
                'MyAlien',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '/',
                  style: TextStyle(color: tokens.borderLow, fontSize: 13),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Central Command Palette Quick Trigger
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: InkWell(
                  onTap: onOpenCommandPalette,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: tokens.bgSubtle,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: Border.all(color: tokens.borderLow),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            size: 16, color: tokens.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search or jump to...',
                            style: TextStyle(
                              color: tokens.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: tokens.bgSurface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: tokens.borderLow),
                          ),
                          child: Text(
                            '⌘K',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Trailing Actions
          Row(
            children: [
              // Live Coin Balance Pill
              StreamBuilder<WalletStateData>(
                stream: walletRepository.walletStream,
                initialData: walletRepository.currentState,
                builder: (context, snapshot) {
                  final balance = snapshot.data?.availableBalance ?? 0;
                  return InkWell(
                    onTap: () => BuyCoinsSheet.show(context),
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tokens.bgSubtle,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusFull),
                        border: Border.all(color: tokens.borderLow),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            '$balance',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.brandAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // Theme Mode Toggle Button
              if (themeCubit != null)
                IconButton(
                  tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 19,
                    color: tokens.textSecondary,
                  ),
                  onPressed: () => themeCubit?.toggleTheme(),
                ),

              // Notifications Bell
              if (onOpenNotifications != null)
                IconButton(
                  tooltip: 'Notifications',
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    size: 19,
                    color: tokens.textSecondary,
                  ),
                  onPressed: onOpenNotifications,
                ),

              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

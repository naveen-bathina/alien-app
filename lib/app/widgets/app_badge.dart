import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_tokens.dart';

enum AppBadgeVariant { neutral, primary, success, warning, error }

/// Minimalist SaaS status badge or chip with subtle border and optional dot.
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.variant = AppBadgeVariant.neutral,
    this.hasDot = false,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;
  final bool hasDot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case AppBadgeVariant.neutral:
        bg = tokens.bgSubtle;
        fg = tokens.textSecondary;
        border = tokens.borderLow;
        break;
      case AppBadgeVariant.primary:
        bg = isDark
            ? AppTokens.brandPrimary.withValues(alpha: 0.25)
            : AppTokens.brandPrimary.withValues(alpha: 0.1);
        fg = isDark ? AppTokens.brandPrimaryLight : AppTokens.brandPrimary;
        border = fg.withValues(alpha: 0.3);
        break;
      case AppBadgeVariant.success:
        bg = isDark ? AppTokens.successBgDark : AppTokens.successBgLight;
        fg = AppTokens.success;
        border = fg.withValues(alpha: 0.3);
        break;
      case AppBadgeVariant.warning:
        bg = isDark ? AppTokens.warningBgDark : AppTokens.warningBgLight;
        fg = AppTokens.warning;
        border = fg.withValues(alpha: 0.3);
        break;
      case AppBadgeVariant.error:
        bg = isDark ? AppTokens.errorBgDark : AppTokens.errorBgLight;
        fg = AppTokens.error;
        border = fg.withValues(alpha: 0.3);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

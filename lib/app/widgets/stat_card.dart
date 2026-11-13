import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_tokens.dart';

/// Minimalist Bento Stat / Metric card with 1px border and trend indicators.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    super.key,
    this.subtitle,
    this.icon,
    this.trend,
    this.isPositiveTrend = true,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final String? trend;
  final bool isPositiveTrend;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: tokens.borderLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (icon != null)
                Icon(icon, size: 18, color: tokens.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null || trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (trend != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? AppTokens.success.withValues(alpha: 0.15)
                          : AppTokens.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trend!,
                      style: TextStyle(
                        color: isPositiveTrend
                            ? AppTokens.success
                            : AppTokens.error,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_colors.dart';

/// Reusable navigation & setting list tile with icon, title, optional value, and chevron.
class AppNavigationTile extends StatelessWidget {
  const AppNavigationTile({
    required this.title,
    required this.onTap,
    super.key,
    this.icon,
    this.value,
    this.subtitle,
    this.trailing,
    this.iconColor = AppColors.primary,
    this.iconBackgroundColor = AppColors.primaryLight,
    this.showBorder = true,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? value;
  final String? subtitle;
  final Widget? trailing;
  final Color iconColor;
  final Color iconBackgroundColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: showBorder ? Border.all(color: AppColors.border) : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}

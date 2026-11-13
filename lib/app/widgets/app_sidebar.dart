import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/view/brand_logo.dart';

class AppSidebarItem {
  const AppSidebarItem({
    required this.title,
    required this.icon,
    this.badgeCount,
  });

  final String title;
  final IconData icon;
  final int? badgeCount;
}

/// Linear-style collapsible sidebar navigation (expanded 240px or compact 68px rail).
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.items,
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapsed,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final List<AppSidebarItem> items;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final width = isCollapsed
        ? AppTokens.sidebarCollapsedWidth
        : AppTokens.sidebarExpandedWidth;

    return AnimatedContainer(
      duration: AppTokens.durationNormal,
      curve: AppTokens.curveStandard,
      width: width,
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        border: Border(right: BorderSide(color: tokens.borderLow)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Collapse Button Header
          Container(
            height: AppTokens.topBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: tokens.borderLow)),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed) ...[
                  Row(
                    children: [
                      const BrandLogo(size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'MyAlien',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const BrandLogo(size: 24),
                ],
                if (onToggleCollapsed != null && !isCollapsed)
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      size: 18,
                      color: tokens.textMuted,
                    ),
                    onPressed: onToggleCollapsed,
                    tooltip: 'Collapse sidebar',
                  ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return InkWell(
                  onTap: () => onSelectIndex(index),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 0 : 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.bgSubtle : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: isSelected
                          ? Border.all(color: tokens.borderLow)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: isSelected
                              ? tokens.brandAccent
                              : tokens.textSecondary,
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: isSelected
                                    ? tokens.textPrimary
                                    : tokens.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: tokens.brandAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Collapse Toggle (if collapsed)
          if (onToggleCollapsed != null && isCollapsed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  size: 18,
                  color: tokens.textMuted,
                ),
                onPressed: onToggleCollapsed,
                tooltip: 'Expand sidebar',
              ),
            ),
        ],
      ),
    );
  }
}

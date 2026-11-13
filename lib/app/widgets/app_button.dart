import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

enum AppButtonSize { sm, md, lg }

/// Reusable SaaS button with hover states, focus rings, and loading animations.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = _isHovered
            ? AppTokens.brandPrimaryHover
            : AppTokens.brandPrimary;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = _isHovered ? tokens.bgSubtle : tokens.bgSurface;
        fg = tokens.textPrimary;
        border = BorderSide(color: tokens.borderLow);
        break;
      case AppButtonVariant.ghost:
        bg = _isHovered ? tokens.bgSubtle : Colors.transparent;
        fg = tokens.textSecondary;
        break;
      case AppButtonVariant.destructive:
        bg = _isHovered ? const Color(0xFFDC2626) : AppTokens.error;
        fg = Colors.white;
        break;
    }

    if (!isEnabled) {
      bg = bg.withValues(alpha: 0.5);
      fg = fg.withValues(alpha: 0.5);
    }

    double height;
    double fontSize;
    double iconSize;
    EdgeInsets padding;

    switch (widget.size) {
      case AppButtonSize.sm:
        height = 32.0;
        fontSize = 13.0;
        iconSize = 15.0;
        padding = const EdgeInsets.symmetric(horizontal: 10.0);
        break;
      case AppButtonSize.md:
        height = 40.0;
        fontSize = 14.0;
        iconSize = 17.0;
        padding = const EdgeInsets.symmetric(horizontal: 14.0);
        break;
      case AppButtonSize.lg:
        height = 48.0;
        fontSize = 15.0;
        iconSize = 19.0;
        padding = const EdgeInsets.symmetric(horizontal: 18.0);
        break;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            color: fg,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTokens.durationFast,
        curve: AppTokens.curveStandard,
        height: height,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            side: border,
          ),
          child: InkWell(
            onTap: isEnabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

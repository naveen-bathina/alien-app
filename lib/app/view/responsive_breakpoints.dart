import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen size breakpoints for adaptive responsive layouts.
class WebBreakpoints {
  const WebBreakpoints._();

  /// Mobile breakpoint upper bound (portrait phone)
  static const double mobile = 600;

  /// Tablet breakpoint upper bound
  static const double tablet = 960;

  /// Large Desktop breakpoint for dual-pane inspector views
  static const double desktopLarge = 1100;

  /// Max width for single column content (Discover swipe card, Profile)
  static const double maxContentWidth = 520;

  /// Max width for full container on desktop
  static const double maxContainerWidth = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopLarge;

  static bool isDesktopWeb(BuildContext context) =>
      kIsWeb && MediaQuery.sizeOf(context).width >= mobile;
}

/// A wrapper widget that constrains content horizontally on wide desktop/web screens
class AdaptiveWebContainer extends StatelessWidget {
  const AdaptiveWebContainer({
    required this.child,
    super.key,
    this.maxWidth = WebBreakpoints.maxContentWidth,
    this.center = true,
  });

  final Widget child;
  final double maxWidth;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= maxWidth) {
      return child;
    }

    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    return center ? Center(child: constrained) : constrained;
  }
}

/// Master-Detail adaptive container for side-by-side desktop panels
class AdaptiveMasterDetail extends StatelessWidget {
  const AdaptiveMasterDetail({
    required this.master,
    required this.detail,
    super.key,
    this.masterWidth = 380,
    this.breakpoint = WebBreakpoints.tablet,
    this.emptyDetailPlaceholder,
  });

  final Widget master;
  final Widget? detail;
  final double masterWidth;
  final double breakpoint;
  final Widget? emptyDetailPlaceholder;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDualPane = screenWidth >= breakpoint;

    if (!isDualPane) {
      return detail ?? master;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: masterWidth,
          child: master,
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: detail ??
              emptyDetailPlaceholder ??
              const Center(
                child: Text(
                  'Select an item to view details',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
        ),
      ],
    );
  }
}

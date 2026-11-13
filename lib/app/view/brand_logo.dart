import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myalien/app/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    this.size = 28,
    this.color,
    super.key,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return SvgPicture.asset(
      'assets/images/logo.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      semanticsLabel: 'Myalien',
    );
  }
}

class BrandAppBarTitle extends StatelessWidget {
  const BrandAppBarTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showLogo = constraints.maxWidth >= 60;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLogo) ...[
              const BrandLogo(size: 22),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

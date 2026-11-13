import 'dart:math';
import 'package:flutter/material.dart';

/// Dynamic LIKE / NOPE / SUPER LIKE Stamp Badges
class ActionStamps extends StatelessWidget {
  const ActionStamps({required this.offset, super.key});
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final dx = offset.dx;
    final dy = offset.dy;

    final isLike = dx > 20;
    final isNope = dx < -20;
    final isSuper = dy < -40 && dy.abs() > dx.abs();

    if (isSuper) {
      final opacity = min<double>(dy.abs() / 120, 1);
      return Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: _stamp(
              'SUPER LIKE',
              Colors.blueAccent.shade400,
              icon: Icons.star_rounded,
            ),
          ),
        ),
      );
    }

    if (isLike) {
      final opacity = min<double>(dx.abs() / 100, 1);
      return Positioned(
        top: 50,
        left: 30,
        child: Transform.rotate(
          angle: -0.25,
          child: Opacity(
            opacity: opacity,
            child: _stamp(
              'LIKE',
              Colors.greenAccent.shade700,
              icon: Icons.favorite_rounded,
            ),
          ),
        ),
      );
    }

    if (isNope) {
      final opacity = min<double>(dx.abs() / 100, 1);
      return Positioned(
        top: 50,
        right: 30,
        child: Transform.rotate(
          angle: 0.25,
          child: Opacity(
            opacity: opacity,
            child: _stamp(
              'NOPE',
              Colors.redAccent.shade400,
              icon: Icons.close_rounded,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _stamp(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

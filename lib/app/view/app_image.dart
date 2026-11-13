import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders either a binary base64 data URI image (stored directly in Firebase)
/// or a standard network URL image, with caching and fallback error handling.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  final String? source;
  final BoxFit fit;
  final WidgetBuilder? placeholder;
  final WidgetBuilder? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.trim().isEmpty) {
      return errorWidget?.call(context) ?? _defaultPlaceholder(context);
    }

    final trimmed = source!.trim();

    // Check if source is binary base64 string or data URI
    if (trimmed.startsWith('data:image/') || !trimmed.startsWith('http')) {
      try {
        final commaIdx = trimmed.indexOf(',');
        final base64String = commaIdx != -1
            ? trimmed.substring(commaIdx + 1)
            : trimmed;
        final cleanBase64 = base64String.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          fit: fit,
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget?.call(context) ?? _defaultError(context);
          },
        );
      } on Object {
        return errorWidget?.call(context) ?? _defaultError(context);
      }
    }

    // Otherwise load from network with caching & memory bounds
    return CachedNetworkImage(
      imageUrl: trimmed,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) =>
          placeholder?.call(context) ?? _defaultPlaceholder(context),
      errorWidget: (context, url, error) =>
          errorWidget?.call(context) ?? _defaultError(context),
    );
  }

  Widget _defaultPlaceholder(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _defaultError(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, size: 48),
      ),
    );
  }
}

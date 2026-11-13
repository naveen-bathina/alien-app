import 'package:flutter/material.dart';

/// Represents a dynamically loaded option from Firestore (Activity Type or Looking For intention).
class MetadataOption {
  const MetadataOption({
    required this.id,
    required this.title,
    required this.subtitle,
    this.category,
    this.iconName = 'star_rounded',
    this.isCustom = false,
    this.createdBy,
  });

  factory MetadataOption.fromMap(Map<String, dynamic> m, {String? docId}) {
    return MetadataOption(
      id: docId ?? m['id'] as String? ?? m['title'] as String? ?? '',
      title: m['title'] as String? ?? '',
      subtitle: m['subtitle'] as String? ?? '',
      category: m['category'] as String?,
      iconName: m['iconName'] as String? ?? 'star_rounded',
      isCustom: m['isCustom'] as bool? ?? false,
      createdBy: m['createdBy'] as String?,
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String? category;
  final String iconName;
  final bool isCustom;
  final String? createdBy;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        if (category != null) 'category': category,
        'iconName': iconName,
        'isCustom': isCustom,
        if (createdBy != null) 'createdBy': createdBy,
        'createdAt': DateTime.now().toIso8601String(),
      };

  /// Resolves the string icon name to a Flutter [IconData].
  IconData get icon {
    switch (iconName.toLowerCase()) {
      case 'local_cafe_rounded':
      case 'local_cafe':
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'restaurant_rounded':
      case 'dinner':
      case 'food':
        return Icons.restaurant_rounded;
      case 'palette_rounded':
      case 'art':
      case 'music':
        return Icons.palette_rounded;
      case 'explore_rounded':
      case 'explore':
      case 'travel':
        return Icons.explore_rounded;
      case 'movie_rounded':
      case 'cinema':
      case 'film':
      case 'netflix':
      case 'tv':
      case 'tv_rounded':
        return Icons.tv_rounded;
      case 'fitness_center_rounded':
      case 'workout':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'menu_book_rounded':
      case 'study':
      case 'book':
        return Icons.menu_book_rounded;
      case 'sports_esports_rounded':
      case 'games':
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'celebration_outlined':
      case 'celebration':
      case 'event':
        return Icons.celebration_outlined;
      case 'favorite_outline_rounded':
      case 'heart':
      case 'love':
        return Icons.favorite_outline_rounded;
      case 'weekend_outlined':
      case 'chill':
      case 'casual':
        return Icons.weekend_outlined;
      case 'people_outline_rounded':
      case 'friends':
        return Icons.people_outline_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  /// Automatically picks an appropriate icon based on keywords in title.
  static String resolveIconNameFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('netflix') ||
        lower.contains('tv') ||
        lower.contains('chill') ||
        lower.contains('stream') ||
        lower.contains('binge')) {
      return 'tv_rounded';
    }
    if (lower.contains('coffee') ||
        lower.contains('cafe') ||
        lower.contains('tea') ||
        lower.contains('chai')) {
      return 'local_cafe_rounded';
    }
    if (lower.contains('dine') ||
        lower.contains('dinner') ||
        lower.contains('food') ||
        lower.contains('lunch') ||
        lower.contains('brunch')) {
      return 'restaurant_rounded';
    }
    if (lower.contains('movie') ||
        lower.contains('film') ||
        lower.contains('cinema')) {
      return 'movie_rounded';
    }
    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('run') ||
        lower.contains('sport') ||
        lower.contains('badminton')) {
      return 'fitness_center_rounded';
    }
    if (lower.contains('game') || lower.contains('arcade')) {
      return 'sports_esports_rounded';
    }
    if (lower.contains('art') ||
        lower.contains('music') ||
        lower.contains('concert')) {
      return 'palette_rounded';
    }
    if (lower.contains('book') ||
        lower.contains('study') ||
        lower.contains('work')) {
      return 'menu_book_rounded';
    }
    if (lower.contains('friend')) {
      return 'people_outline_rounded';
    }
    return 'auto_awesome_rounded';
  }
}

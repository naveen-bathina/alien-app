import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/widgets/app_selection_tile.dart';

/// Represents a selectable gender choice with icon and description.
class GenderOption {
  const GenderOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

/// Dedicated selection screen for Gender.
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({
    super.key,
    this.currentGender,
  });

  final String? currentGender;

  static const List<GenderOption> options = [
    GenderOption(
      title: 'Woman',
      subtitle: 'Identify as woman',
      icon: Icons.female_rounded,
    ),
    GenderOption(
      title: 'Man',
      subtitle: 'Identify as man',
      icon: Icons.male_rounded,
    ),
    GenderOption(
      title: 'Non-binary',
      subtitle: 'Identify as non-binary / gender diverse',
      icon: Icons.transgender_rounded,
    ),
    GenderOption(
      title: 'Prefer not to say',
      subtitle: 'Keep your gender private',
      icon: Icons.lock_outline_rounded,
    ),
  ];

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentGender ?? 'Woman';
  }

  void _chooseOption(String title) {
    setState(() => _selected = title);
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gender'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          const Text(
            'Select your gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This helps companions know how to refer to you.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ...GenderSelectionScreen.options.map((opt) {
            final isSelected = _selected == opt.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSelectionTile(
                title: opt.title,
                subtitle: opt.subtitle,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    opt.icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
                isSelected: isSelected,
                onTap: () => _chooseOption(opt.title),
              ),
            );
          }),
        ],
      ),
    );
  }
}

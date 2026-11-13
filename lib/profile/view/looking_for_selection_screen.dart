import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/widgets/app_selection_tile.dart';
import 'package:myalien/metadata/models/metadata_option.dart';
import 'package:myalien/metadata/repository/metadata_repository.dart';

/// Backward-compatible alias for IntentionOption
typedef IntentionOption = MetadataOption;

/// Dedicated selection screen for 'Looking For' intentions, dynamically backed by Firestore.
class LookingForSelectionScreen extends StatefulWidget {
  const LookingForSelectionScreen({
    super.key,
    this.currentIntention,
    this.repo,
  });

  final String? currentIntention;
  final MetadataRepository? repo;

  static List<MetadataOption> get options =>
      MetadataRepository.defaultIntentions;

  @override
  State<LookingForSelectionScreen> createState() =>
      _LookingForSelectionScreenState();
}

class _LookingForSelectionScreenState extends State<LookingForSelectionScreen> {
  final TextEditingController _customCtrl = TextEditingController();
  String? _selected;
  bool _isAdding = false;

  MetadataRepository get _repository => widget.repo ?? metadataRepository;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentIntention ?? 'Cafe Catchups';
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _chooseOption(String title) {
    setState(() => _selected = title);
    Navigator.of(context).pop(_selected);
  }

  Future<void> _submitCustomIntention() async {
    final custom = _customCtrl.text.trim();
    if (custom.isEmpty) return;

    setState(() => _isAdding = true);
    final newOpt = await _repository.addCustomLookingFor(title: custom);
    if (!mounted) return;
    setState(() => _isAdding = false);
    _chooseOption(newOpt.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.selectHangoutFor),
      ),
      body: StreamBuilder<List<MetadataOption>>(
        stream: _repository.watchLookingForIntentions(),
        initialData: MetadataRepository.defaultIntentions,
        builder: (context, snapshot) {
          final options = snapshot.data ?? MetadataRepository.defaultIntentions;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              const Text(
                'What kind of connections do you want?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'This helps us recommend compatible companions who share your goals.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              ...options.map((opt) {
                final isSelected = _selected?.toLowerCase().trim() ==
                    opt.title.toLowerCase().trim();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppSelectionTile(
                    title: opt.title,
                    subtitle: opt.subtitle,
                    badge: opt.isCustom ? 'Custom' : null,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primaryLight,
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

              const SizedBox(height: 8),

              // Add Custom Intention Tile
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add Custom Goal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Have a unique intention like "Netflix and Chill" or "Travel buddy"? Add it here.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'e.g. Netflix and Chill',
                              isDense: true,
                              fillColor: AppColors.background,
                              prefixIcon: const Icon(
                                Icons.favorite_border_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            onSubmitted: (_) => _submitCustomIntention(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isAdding ? null : _submitCustomIntention,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          child: _isAdding
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Add & Use'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

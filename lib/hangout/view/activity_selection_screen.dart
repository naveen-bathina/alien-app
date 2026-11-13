import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/widgets/app_selection_tile.dart';
import 'package:myalien/metadata/models/metadata_option.dart';
import 'package:myalien/metadata/repository/metadata_repository.dart';

/// Backward-compatible alias for ActivityOption
typedef ActivityOption = MetadataOption;

/// Dedicated selection screen for Hangout Activity Types, dynamically backed by Firestore.
class ActivitySelectionScreen extends StatefulWidget {
  const ActivitySelectionScreen({
    super.key,
    this.selectedActivity,
    this.repo,
  });

  final String? selectedActivity;
  final MetadataRepository? repo;

  static List<MetadataOption> get availableActivities =>
      MetadataRepository.defaultActivities;

  @override
  State<ActivitySelectionScreen> createState() =>
      _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customCtrl = TextEditingController();
  late String _currentSelected;
  String _activeCategory = 'All';
  bool _isAdding = false;

  final List<String> _categories = const [
    'All',
    'Food & Drink',
    'Social',
    'Entertainment',
    'Active',
    'Work & Study',
  ];

  MetadataRepository get _repository => widget.repo ?? metadataRepository;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedActivity ?? 'Coffee & Chat';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  void _chooseActivity(String title) {
    setState(() => _currentSelected = title);
    Navigator.of(context).pop(title);
  }

  Future<void> _submitCustomActivity() async {
    final custom = _customCtrl.text.trim();
    if (custom.isEmpty) return;

    setState(() => _isAdding = true);
    final newOpt = await _repository.addCustomActivityType(
      title: custom,
      category: _activeCategory == 'All' ? 'Entertainment' : _activeCategory,
    );
    if (!mounted) return;
    setState(() => _isAdding = false);
    _chooseActivity(newOpt.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.selectHangoutFor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: StreamBuilder<List<MetadataOption>>(
        stream: _repository.watchActivityTypes(),
        initialData: MetadataRepository.defaultActivities,
        builder: (context, snapshot) {
          final allActivities = snapshot.data ?? MetadataRepository.defaultActivities;
          final query = _searchCtrl.text.trim().toLowerCase();

          final filtered = allActivities.where((a) {
            final matchesQuery = query.isEmpty ||
                a.title.toLowerCase().contains(query) ||
                a.subtitle.toLowerCase().contains(query) ||
                (a.category != null && a.category!.toLowerCase().contains(query));

            final matchesCategory =
                _activeCategory == 'All' || a.category == _activeCategory;

            return matchesQuery && matchesCategory;
          }).toList();

          return Column(
            children: [
              // Search & Filter header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search or add activities (e.g. Netflix)...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Categories horizontal list
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == _activeCategory;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _activeCategory = cat),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Activity List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    Text(
                      '${filtered.length} Activities Available',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...filtered.map((activity) {
                      final isSelected = activity.title.toLowerCase() ==
                          _currentSelected.toLowerCase();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppSelectionTile(
                          title: activity.title,
                          subtitle: activity.subtitle,
                          badge: activity.isCustom ? 'Custom' : activity.category,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity.icon,
                              size: 20,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                          isSelected: isSelected,
                          onTap: () => _chooseActivity(activity.title),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Add Custom Activity Card
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
                                'Add Custom Activity',
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
                            'Can’t find what you’re looking for? Add any custom activity like "Netflix and Chill" to save it.',
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
                                    hintText: 'e.g. Netflix and Chill, Bowling night',
                                    isDense: true,
                                    prefixIcon: const Icon(Icons.flash_on_rounded, color: AppColors.coinGold, size: 18),
                                    fillColor: AppColors.background,
                                  ),
                                  onSubmitted: (_) => _submitCustomActivity(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isAdding ? null : _submitCustomActivity,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

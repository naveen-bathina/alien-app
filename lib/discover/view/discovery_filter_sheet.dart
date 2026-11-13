import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/widgets/app_section_header.dart';
import 'package:myalien/discover/models/discovery_filters.dart';
import 'package:myalien/home/cubit/home_cubit.dart';
import 'package:myalien/home/models/profile_model.dart';

/// Modal bottom sheet allowing users to customize their Discovery preferences.
class DiscoveryFilterSheet extends StatefulWidget {
  const DiscoveryFilterSheet({
    required this.initialFilters,
    required this.allProfiles,
    super.key,
  });

  final DiscoveryFilters initialFilters;
  final List<Profile> allProfiles;

  static Future<DiscoveryFilters?> show(
    BuildContext context, {
    required DiscoveryFilters initialFilters,
    required List<Profile> allProfiles,
  }) {
    return showModalBottomSheet<DiscoveryFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DiscoveryFilterSheet(
        initialFilters: initialFilters,
        allProfiles: allProfiles,
      ),
    );
  }

  @override
  State<DiscoveryFilterSheet> createState() => _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends State<DiscoveryFilterSheet> {
  late String _role;
  late List<String> _genders;
  late int _minAge;
  late int _maxAge;
  late String _city;
  late bool _nearbyOnly;
  late double _maxDistanceKm;
  late List<String> _intentions;
  late int _minCoins;
  late int _maxCoins;
  late bool _availableTodayOnly;
  late bool _verifiedOnly;
  late bool _flexibleLocationOnly;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _initFromFilters(widget.initialFilters);
  }

  void _initFromFilters(DiscoveryFilters f) {
    _role = f.role;
    _genders = List<String>.from(f.genders);
    _minAge = f.minAge;
    _maxAge = f.maxAge;
    _city = f.city;
    _nearbyOnly = f.nearbyOnly;
    _maxDistanceKm = f.maxDistanceKm;
    _intentions = List<String>.from(f.intentions);
    _minCoins = f.minCoinsPerHour;
    _maxCoins = f.maxCoinsPerHour;
    _availableTodayOnly = f.availableTodayOnly;
    _verifiedOnly = f.verifiedOnly;
    _flexibleLocationOnly = f.flexibleLocationOnly;
    _sortBy = f.sortBy;
  }

  DiscoveryFilters _buildCurrentFilters() {
    return DiscoveryFilters(
      role: _role,
      genders: _genders,
      minAge: _minAge,
      maxAge: _maxAge,
      city: _city,
      nearbyOnly: _nearbyOnly,
      maxDistanceKm: _maxDistanceKm,
      intentions: _intentions,
      minCoinsPerHour: _minCoins,
      maxCoinsPerHour: _maxCoins,
      availableTodayOnly: _availableTodayOnly,
      verifiedOnly: _verifiedOnly,
      flexibleLocationOnly: _flexibleLocationOnly,
      sortBy: _sortBy,
    );
  }

  void _resetToDefaults() {
    setState(() {
      _initFromFilters(DiscoveryFilters.defaultFilters());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final currentFilters = _buildCurrentFilters();
    final matchCount = HomeCubit.filterProfiles(
      widget.allProfiles,
      currentFilters,
    ).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: tokens.borderLow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: tokens.brandAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.discoveryPreferences,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetToDefaults,
                  child: Text(
                    AppStrings.reset,
                    style: TextStyle(
                      color: tokens.brandAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: tokens.borderLow),

          // Scrollable filter options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Role (Who to meet)
                _buildSectionHeader(AppStrings.filterWhoToMeet),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: AppStrings.filterAllAliens,
                      selected: _role == 'All',
                      onSelected: () => setState(() => _role = 'All'),
                    ),
                    _buildChoiceChip(
                      label: AppStrings.filterEarnersOnly,
                      selected: _role == 'Earner',
                      onSelected: () => setState(() => _role = 'Earner'),
                    ),
                    _buildChoiceChip(
                      label: AppStrings.filterSponsorsOnly,
                      selected: _role == 'Sponsor',
                      onSelected: () => setState(() => _role = 'Sponsor'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 2. Gender Preference
                _buildSectionHeader(AppStrings.filterGender),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: AppStrings.filterEveryone,
                      selected: _genders.isEmpty,
                      onSelected: () => setState(() => _genders.clear()),
                    ),
                    ...DiscoveryFilters.availableGenders.map((g) {
                      final isSelected = _genders.contains(g);
                      return FilterChip(
                        label: Text(g),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6C4AB6),
                        backgroundColor: const Color(0xFFF7F5FC),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E1E2D),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF6C4AB6)
                                : const Color(0xFFE2DDF4),
                          ),
                        ),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _genders.add(g);
                            } else {
                              _genders.remove(g);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 22),

                // 3. Age Range Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(AppStrings.filterAgeRange),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2DDF4)),
                      ),
                      child: Text(
                        '$_minAge – $_maxAge years',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C4AB6),
                        ),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_minAge.toDouble(), _maxAge.toDouble()),
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: const Color(0xFF6C4AB6),
                  inactiveColor: const Color(0xFFE2DDF4),
                  labels: RangeLabels('$_minAge', '$_maxAge'),
                  onChanged: (values) {
                    setState(() {
                      _minAge = values.start.round();
                      _maxAge = values.end.round();
                    });
                  },
                ),
                const SizedBox(height: 22),

                // 4. Location & GPS Nearby
                _buildSectionHeader(AppStrings.filterLocation),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      avatar: Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: _nearbyOnly
                            ? Colors.white
                            : const Color(0xFF6C4AB6),
                      ),
                      label: const Text(AppStrings.filterNearbyGps),
                      selected: _nearbyOnly,
                      selectedColor: const Color(0xFF6C4AB6),
                      backgroundColor: const Color(0xFFF7F5FC),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _nearbyOnly
                            ? Colors.white
                            : const Color(0xFF1E1E2D),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _nearbyOnly
                              ? const Color(0xFF6C4AB6)
                              : const Color(0xFFE2DDF4),
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          _nearbyOnly = val;
                          if (val) _city = 'All Cities';
                        });
                      },
                    ),
                    ...DiscoveryFilters.availableCities.map((c) {
                      final isSelected = !_nearbyOnly && _city == c;
                      return _buildChoiceChip(
                        label: c,
                        selected: isSelected,
                        onSelected: () {
                          setState(() {
                            _nearbyOnly = false;
                            _city = c;
                          });
                        },
                      );
                    }),
                  ],
                ),
                if (_nearbyOnly) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Maximum GPS Radius',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E2D),
                        ),
                      ),
                      Text(
                        'Within ${_maxDistanceKm.round()} km',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C4AB6),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxDistanceKm,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    activeColor: const Color(0xFF6C4AB6),
                    inactiveColor: const Color(0xFFE2DDF4),
                    onChanged: (val) => setState(() => _maxDistanceKm = val),
                  ),
                ],
                const SizedBox(height: 22),

                // 5. Hangout For
                _buildSectionHeader(AppStrings.filterHangoutFor),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DiscoveryFilters.availableIntentions.map((intent) {
                    final isSelected = _intentions.contains(intent);
                    return FilterChip(
                      label: Text(intent),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6C4AB6),
                      backgroundColor: const Color(0xFFF7F5FC),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E1E2D),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF6C4AB6)
                              : const Color(0xFFE2DDF4),
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _intentions.add(intent);
                          } else {
                            _intentions.remove(intent);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),

                // 6. Rate per Hour Budget (Earners)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('6. Earner Rate per Hour'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2DDF4)),
                      ),
                      child: Text(
                        '🪙 $_minCoins – $_maxCoins Coins/hr',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C4AB6),
                        ),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(
                    _minCoins.toDouble(),
                    _maxCoins.toDouble(),
                  ),
                  min: 20,
                  max: 200,
                  divisions: 18,
                  activeColor: const Color(0xFF6C4AB6),
                  inactiveColor: const Color(0xFFE2DDF4),
                  labels: RangeLabels('$_minCoins', '$_maxCoins'),
                  onChanged: (values) {
                    setState(() {
                      _minCoins = values.start.round();
                      _maxCoins = values.end.round();
                    });
                  },
                ),
                const SizedBox(height: 22),

                // 7. Safety & Availability Toggles
                _buildSectionHeader(AppStrings.filterAvailabilitySafety),
                const SizedBox(height: 10),
                _buildToggleTile(
                  title: AppStrings.filterAvailableToday,
                  subtitle: AppStrings.filterAvailableTodaySubtitle,
                  icon: Icons.bolt_rounded,
                  value: _availableTodayOnly,
                  onChanged: (val) => setState(() => _availableTodayOnly = val),
                ),
                const SizedBox(height: 8),
                _buildToggleTile(
                  title: AppStrings.filterVerifiedOnly,
                  subtitle: AppStrings.filterVerifiedOnlySubtitle,
                  icon: Icons.verified_user_rounded,
                  value: _verifiedOnly,
                  onChanged: (val) => setState(() => _verifiedOnly = val),
                ),
                const SizedBox(height: 8),
                _buildToggleTile(
                  title: AppStrings.filterFlexibleLocation,
                  subtitle: AppStrings.filterFlexibleLocationSubtitle,
                  icon: Icons.explore_outlined,
                  value: _flexibleLocationOnly,
                  onChanged: (val) =>
                      setState(() => _flexibleLocationOnly = val),
                ),
                const SizedBox(height: 22),

                // 8. Sort By
                _buildSectionHeader(AppStrings.filterSortOrder),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DiscoveryFilters.sortOptions.map((opt) {
                    return _buildChoiceChip(
                      label: opt,
                      selected: _sortBy == opt,
                      onSelected: () => setState(() => _sortBy = opt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_buildCurrentFilters());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C4AB6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '${AppStrings.applyPreferences} ($matchCount '
                    '${matchCount == 1 ? 'match' : 'matches'})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppSectionHeader(
      title: title,
      margin: EdgeInsets.zero,
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final tokens = AppColorTokens.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: tokens.brandAccent,
      backgroundColor: tokens.brandAccentSubtle,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : tokens.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? tokens.brandAccent : tokens.borderLow,
        ),
      ),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final tokens = AppColorTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.borderLow),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? tokens.brandAccent.withValues(alpha: 0.15)
                  : tokens.bgSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? tokens.brandAccent : tokens.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: tokens.brandAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

import 'package:equatable/equatable.dart';

/// Encapsulates user discovery preferences and filter parameters.
class DiscoveryFilters extends Equatable {
  const DiscoveryFilters({
    this.role = 'All',
    this.genders = const [],
    this.minAge = 18,
    this.maxAge = 50,
    this.city = 'All Cities',
    this.nearbyOnly = false,
    this.maxDistanceKm = 25.0,
    this.intentions = const [],
    this.minCoinsPerHour = 20,
    this.maxCoinsPerHour = 200,
    this.availableTodayOnly = false,
    this.verifiedOnly = false,
    this.flexibleLocationOnly = false,
    this.sortBy = 'Recommended',
  });

  const DiscoveryFilters.defaults()
      : role = 'All',
        genders = const [],
        minAge = 18,
        maxAge = 50,
        city = 'All Cities',
        nearbyOnly = false,
        maxDistanceKm = 25.0,
        intentions = const [],
        minCoinsPerHour = 20,
        maxCoinsPerHour = 200,
        availableTodayOnly = false,
        verifiedOnly = false,
        flexibleLocationOnly = false,
        sortBy = 'Recommended';

  factory DiscoveryFilters.fromMap(Map<String, dynamic> map) {
    return DiscoveryFilters(
      role: map['role'] as String? ?? 'All',
      genders: map['genders'] is List
          ? (map['genders'] as List).whereType<String>().toList()
          : const [],
      minAge: map['minAge'] as int? ?? 18,
      maxAge: map['maxAge'] as int? ?? 50,
      city: map['city'] as String? ?? 'All Cities',
      nearbyOnly: map['nearbyOnly'] as bool? ?? false,
      maxDistanceKm: (map['maxDistanceKm'] as num?)?.toDouble() ?? 25.0,
      intentions: map['intentions'] is List
          ? (map['intentions'] as List).whereType<String>().toList()
          : const [],
      minCoinsPerHour: map['minCoinsPerHour'] as int? ?? 20,
      maxCoinsPerHour: map['maxCoinsPerHour'] as int? ?? 200,
      availableTodayOnly: map['availableTodayOnly'] as bool? ?? false,
      verifiedOnly: map['verifiedOnly'] as bool? ?? false,
      flexibleLocationOnly: map['flexibleLocationOnly'] as bool? ?? false,
      sortBy: map['sortBy'] as String? ?? 'Recommended',
    );
  }

  /// Role filter: 'All', 'Earner', 'Sponsor'
  final String role;

  /// Gender preferences: empty means everyone
  final List<String> genders;

  /// Age range (18 to 65)
  final int minAge;
  final int maxAge;

  /// Selected city or 'All Cities'
  final String city;

  /// Filter profiles nearby current GPS location
  final bool nearbyOnly;

  /// Maximum distance in kilometers for GPS nearby filtering
  final double maxDistanceKm;

  /// Hangout intention tags
  final List<String> intentions;

  /// Rate per hour budget for earners (Coins)
  final int minCoinsPerHour;
  final int maxCoinsPerHour;

  /// Availability toggles
  final bool availableTodayOnly;
  final bool verifiedOnly;
  final bool flexibleLocationOnly;

  /// Sort criteria: 'Recommended', 'Highest Rated', 'Rate: Low to High',
  /// 'Rate: High to Low'
  final String sortBy;

  static const List<String> availableRoles = ['All', 'Earner', 'Sponsor'];

  static const List<String> availableGenders = [
    'Woman',
    'Man',
    'Non-binary',
  ];

  static const List<String> availableCities = [
    'All Cities',
    'Hyderabad',
    'Bangalore',
    'Mumbai',
    'Delhi',
    'Pune',
    'Goa',
  ];

  static const List<String> availableIntentions = [
    'Cafe Catchups',
    'Dinner Companion',
    'Live Music & Art',
    'City Explorer',
    'Fitness / Workout',
    'Movie & Chill',
    'New friends',
  ];

  static const List<String> sortOptions = [
    'Recommended',
    'Highest Rated',
    'Rate: Low to High',
    'Rate: High to Low',
  ];

  /// Counts how many non-default filter criteria are actively applied.
  int get activeFilterCount {
    var count = 0;
    if (role != 'All') count++;
    if (genders.isNotEmpty) count++;
    if (minAge > 18 || maxAge < 50) count++;
    if (city != 'All Cities') count++;
    if (nearbyOnly) count++;
    if (intentions.isNotEmpty) count++;
    if (minCoinsPerHour > 20 || maxCoinsPerHour < 200) count++;
    if (availableTodayOnly) count++;
    if (verifiedOnly) count++;
    if (flexibleLocationOnly) count++;
    if (sortBy != 'Recommended') count++;
    return count;
  }

  bool get isDefault => activeFilterCount == 0;

  static DiscoveryFilters defaultFilters() =>
      const DiscoveryFilters.defaults();

  DiscoveryFilters copyWith({
    String? role,
    List<String>? genders,
    int? minAge,
    int? maxAge,
    String? city,
    bool? nearbyOnly,
    double? maxDistanceKm,
    List<String>? intentions,
    int? minCoinsPerHour,
    int? maxCoinsPerHour,
    bool? availableTodayOnly,
    bool? verifiedOnly,
    bool? flexibleLocationOnly,
    String? sortBy,
  }) {
    return DiscoveryFilters(
      role: role ?? this.role,
      genders: genders ?? this.genders,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      city: city ?? this.city,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      intentions: intentions ?? this.intentions,
      minCoinsPerHour: minCoinsPerHour ?? this.minCoinsPerHour,
      maxCoinsPerHour: maxCoinsPerHour ?? this.maxCoinsPerHour,
      availableTodayOnly: availableTodayOnly ?? this.availableTodayOnly,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      flexibleLocationOnly: flexibleLocationOnly ?? this.flexibleLocationOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'genders': genders,
      'minAge': minAge,
      'maxAge': maxAge,
      'city': city,
      'nearbyOnly': nearbyOnly,
      'maxDistanceKm': maxDistanceKm,
      'intentions': intentions,
      'minCoinsPerHour': minCoinsPerHour,
      'maxCoinsPerHour': maxCoinsPerHour,
      'availableTodayOnly': availableTodayOnly,
      'verifiedOnly': verifiedOnly,
      'flexibleLocationOnly': flexibleLocationOnly,
      'sortBy': sortBy,
    };
  }

  @override
  List<Object?> get props => [
    role,
    genders,
    minAge,
    maxAge,
    city,
    nearbyOnly,
    maxDistanceKm,
    intentions,
    minCoinsPerHour,
    maxCoinsPerHour,
    availableTodayOnly,
    verifiedOnly,
    flexibleLocationOnly,
    sortBy,
  ];
}

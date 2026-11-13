class ProfileAvailability {
  const ProfileAvailability({
    this.isAvailableToday = true,
    this.statusText = 'Available Today',
    this.availableDays = const ['Mon', 'Wed', 'Fri', 'Sat', 'Sun'],
    this.timeWindow = '6:00 PM – 10:00 PM',
  });

  factory ProfileAvailability.fromMap(Map<String, dynamic> m) {
    return ProfileAvailability(
      isAvailableToday: m['isAvailableToday'] as bool? ?? true,
      statusText: m['statusText'] as String? ?? 'Available Today',
      availableDays: m['availableDays'] is List
          ? (m['availableDays'] as List).whereType<String>().toList()
          : const ['Mon', 'Wed', 'Fri', 'Sat', 'Sun'],
      timeWindow: m['timeWindow'] as String? ?? '6:00 PM – 10:00 PM',
    );
  }

  final bool isAvailableToday;
  final String statusText;
  final List<String> availableDays;
  final String timeWindow;

  Map<String, dynamic> toMap() => {
        'isAvailableToday': isAvailableToday,
        'statusText': statusText,
        'availableDays': availableDays,
        'timeWindow': timeWindow,
      };

  ProfileAvailability copyWith({
    bool? isAvailableToday,
    String? statusText,
    List<String>? availableDays,
    String? timeWindow,
  }) {
    return ProfileAvailability(
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      statusText: statusText ?? this.statusText,
      availableDays: availableDays ?? this.availableDays,
      timeWindow: timeWindow ?? this.timeWindow,
    );
  }
}

/// Single canonical Profile model for MyAlien.
class Profile {
  Profile({
    required this.uid,
    required this.name,
    this.dob,
    this.gender = '',
    this.location = '',
    this.fullName,
    this.displayName,
    this.lookingFor,
    this.bio = '',
    this.tagline,
    this.photoUrl,
    this.photos = const [],
    this.role = 'Earner',
    this.coinsPerHour = 80,
    this.rating = 4.9,
    this.reviewsCount = 14,
    this.isVerified = true,
    this.isDiscoveryActive = true,
    this.isLocationFlexible = true,
    this.availability = const ProfileAvailability(),
  });

  factory Profile.fromMap(Map<String, dynamic> m) {
    final rawPhotos = m['photos'];
    final photoList = <String>[];
    if (rawPhotos is List) {
      for (final p in rawPhotos) {
        if (p is String && p.trim().isNotEmpty) photoList.add(p);
      }
    }
    final singlePhoto = m['photoUrl'] as String?;
    if (photoList.isEmpty && singlePhoto != null && singlePhoto.isNotEmpty) {
      photoList.add(singlePhoto);
    }

    final rawName = m['name'] as String? ?? 'Alien';
    final rawFullName = m['fullName'] as String?;
    final rawDisplayName = m['displayName'] as String?;
    final primaryName = (rawDisplayName?.isNotEmpty ?? false)
        ? rawDisplayName!
        : ((rawFullName?.isNotEmpty ?? false) ? rawFullName! : rawName);

    final rawAvailability = m['availability'];
    final availability = rawAvailability is Map<String, dynamic>
        ? ProfileAvailability.fromMap(rawAvailability)
        : const ProfileAvailability();

    return Profile(
      uid: m['uid'] as String? ?? '',
      name: primaryName,
      fullName: rawFullName ?? primaryName,
      displayName: rawDisplayName ?? primaryName,
      dob: DateTime.tryParse(m['dob'] as String? ?? ''),
      gender: m['gender'] as String? ?? '',
      location: m['location'] as String? ?? 'Nearby',
      lookingFor: m['lookingFor'] as String?,
      bio: m['bio'] as String? ?? '',
      tagline: m['tagline'] as String?,
      photoUrl: photoList.isNotEmpty ? photoList.first : singlePhoto,
      photos: photoList,
      role: m['role'] as String? ?? 'Earner',
      coinsPerHour: m['coinsPerHour'] as int? ??
          (m['role'] == 'Sponsor' ? null : 80),
      rating: (m['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: m['reviewsCount'] as int? ?? 14,
      isVerified: m['isVerified'] as bool? ?? true,
      isDiscoveryActive: m['isDiscoveryActive'] as bool? ?? true,
      isLocationFlexible: m['isLocationFlexible'] as bool? ?? true,
      availability: availability,
    );
  }

  final String uid;
  final String name;
  final String? fullName;
  final String? displayName;
  final DateTime? dob;
  final String gender;
  final String location;
  final String? photoUrl;
  final List<String> photos;
  final String? lookingFor;
  final String bio;
  final String? tagline;
  final String role;
  final int? coinsPerHour;
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final bool isDiscoveryActive;
  final bool isLocationFlexible;
  final ProfileAvailability availability;

  bool get isEarner => role.toLowerCase() == 'earner';
  bool get isSponsor => role.toLowerCase() == 'sponsor';

  int? get age {
    if (dob == null) return null;
    final today = DateTime.now();
    var a = today.year - dob!.year;
    if (today.month < dob!.month ||
        (today.month == dob!.month && today.day < dob!.day)) {
      a--;
    }
    return a;
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': (displayName?.isNotEmpty ?? false)
            ? displayName
            : ((fullName?.isNotEmpty ?? false) ? fullName : name),
        'fullName': fullName ?? name,
        'displayName': displayName ?? name,
        if (dob != null) 'dob': dob!.toIso8601String(),
        'gender': gender,
        'location': location,
        'photoUrl': photos.isNotEmpty ? photos.first : photoUrl,
        'photos': photos,
        'lookingFor': lookingFor,
        'bio': bio,
        'tagline': tagline,
        'role': role,
        'coinsPerHour': coinsPerHour,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'isVerified': isVerified,
        'isDiscoveryActive': isDiscoveryActive,
        'isLocationFlexible': isLocationFlexible,
        'availability': availability.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

  Profile copyWith({
    String? uid,
    String? name,
    String? fullName,
    String? displayName,
    DateTime? dob,
    String? gender,
    String? location,
    String? photoUrl,
    List<String>? photos,
    String? lookingFor,
    String? bio,
    String? tagline,
    String? role,
    int? coinsPerHour,
    double? rating,
    int? reviewsCount,
    bool? isVerified,
    bool? isDiscoveryActive,
    bool? isLocationFlexible,
    ProfileAvailability? availability,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      photos: photos ?? this.photos,
      lookingFor: lookingFor ?? this.lookingFor,
      bio: bio ?? this.bio,
      tagline: tagline ?? this.tagline,
      role: role ?? this.role,
      coinsPerHour: coinsPerHour ?? this.coinsPerHour,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isVerified: isVerified ?? this.isVerified,
      isDiscoveryActive: isDiscoveryActive ?? this.isDiscoveryActive,
      isLocationFlexible: isLocationFlexible ?? this.isLocationFlexible,
      availability: availability ?? this.availability,
    );
  }
}

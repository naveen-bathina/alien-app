class HangoutRequest {
  const HangoutRequest({
    required this.id,
    required this.companionUid,
    required this.companionName,
    required this.companionAvatar,
    required this.requesterUid,
    required this.requesterName,
    required this.date,
    required this.startHour,
    required this.startMinute,
    required this.durationHours,
    required this.location,
    required this.activity,
    required this.coinsPerHour,
    required this.totalCoins,
    this.companionRole = 'Earner',
    this.requesterAvatar = '',
    this.notes = '',
    this.status = 'confirmed',
    this.createdAt,
  });

  factory HangoutRequest.fromMap(Map<String, dynamic> m) {
    return HangoutRequest(
      id: m['id'] as String? ?? '',
      companionUid: m['companionUid'] as String? ?? '',
      companionName: m['companionName'] as String? ?? 'Companion',
      companionAvatar: m['companionAvatar'] as String? ?? '',
      companionRole: m['companionRole'] as String? ?? 'Earner',
      requesterUid: m['requesterUid'] as String? ?? '',
      requesterName: m['requesterName'] as String? ?? 'User',
      requesterAvatar: m['requesterAvatar'] as String? ?? '',
      date: m['date'] is String
          ? DateTime.tryParse(m['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      startHour: m['startHour'] as int? ?? 18,
      startMinute: m['startMinute'] as int? ?? 0,
      durationHours: m['durationHours'] as int? ?? 2,
      location: m['location'] as String? ?? 'Coffee House',
      activity: m['activity'] as String? ?? 'Coffee & Chat',
      notes: m['notes'] as String? ?? '',
      coinsPerHour: m['coinsPerHour'] as int? ?? 80,
      totalCoins: m['totalCoins'] as int? ?? 160,
      status: m['status'] as String? ?? 'confirmed',
      createdAt: m['createdAt'] is String
          ? DateTime.tryParse(m['createdAt'] as String)
          : null,
    );
  }

  final String id;
  final String companionUid;
  final String companionName;
  final String companionAvatar;
  final String companionRole;
  final String requesterUid;
  final String requesterName;
  final String requesterAvatar;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int durationHours;
  final String location;
  final String activity;
  final String notes;
  final int coinsPerHour;
  final int totalCoins;
  final String status;
  final DateTime? createdAt;

  DateTime get startDateTime =>
      DateTime(date.year, date.month, date.day, startHour, startMinute);

  DateTime get endDateTime =>
      startDateTime.add(Duration(hours: durationHours));

  String formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get timeRangeFormatted {
    final startStr = formatTime(startHour, startMinute);
    final end = endDateTime;
    final endStr = formatTime(end.hour, end.minute);
    return '$startStr – $endStr';
  }

  String get dateFormatted {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, $monthName ${date.day}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'companionUid': companionUid,
        'companionName': companionName,
        'companionAvatar': companionAvatar,
        'companionRole': companionRole,
        'requesterUid': requesterUid,
        'requesterName': requesterName,
        'requesterAvatar': requesterAvatar,
        'date': date.toIso8601String(),
        'startHour': startHour,
        'startMinute': startMinute,
        'durationHours': durationHours,
        'location': location,
        'activity': activity,
        'notes': notes,
        'coinsPerHour': coinsPerHour,
        'totalCoins': totalCoins,
        'status': status,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  HangoutRequest copyWith({
    String? id,
    String? companionUid,
    String? companionName,
    String? companionAvatar,
    String? companionRole,
    String? requesterUid,
    String? requesterName,
    String? requesterAvatar,
    DateTime? date,
    int? startHour,
    int? startMinute,
    int? durationHours,
    String? location,
    String? activity,
    String? notes,
    int? coinsPerHour,
    int? totalCoins,
    String? status,
    DateTime? createdAt,
  }) {
    return HangoutRequest(
      id: id ?? this.id,
      companionUid: companionUid ?? this.companionUid,
      companionName: companionName ?? this.companionName,
      companionAvatar: companionAvatar ?? this.companionAvatar,
      companionRole: companionRole ?? this.companionRole,
      requesterUid: requesterUid ?? this.requesterUid,
      requesterName: requesterName ?? this.requesterName,
      requesterAvatar: requesterAvatar ?? this.requesterAvatar,
      date: date ?? this.date,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      durationHours: durationHours ?? this.durationHours,
      location: location ?? this.location,
      activity: activity ?? this.activity,
      notes: notes ?? this.notes,
      coinsPerHour: coinsPerHour ?? this.coinsPerHour,
      totalCoins: totalCoins ?? this.totalCoins,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

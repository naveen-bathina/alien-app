import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/models/hangout_request.dart';

class TimeWindowRange {
  const TimeWindowRange(this.startMinutes, this.endMinutes);
  final int startMinutes;
  final int endMinutes;
}

class ConflictCheckResult {
  const ConflictCheckResult({
    required this.hasConflict,
    this.conflictReason,
    this.isOutsideOperatingHours = false,
    this.conflictingHangout,
  });

  final bool hasConflict;
  final String? conflictReason;
  final bool isOutsideOperatingHours;
  final HangoutRequest? conflictingHangout;
}

class HangoutRepository {
  HangoutRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore {
    _seedInitialBookings();
  }

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  final List<HangoutRequest> _memoryBookings = [];
  final StreamController<List<HangoutRequest>> _hangoutsStreamController =
      StreamController<List<HangoutRequest>>.broadcast();

  Stream<List<HangoutRequest>> get hangoutsStream =>
      _hangoutsStreamController.stream;

  List<HangoutRequest> get currentBookings =>
      List.unmodifiable(_memoryBookings);

  void _seedInitialBookings() {
    final now = DateTime.now();
    // Find next Friday or upcoming date for Maya Rao (at least tomorrow if today is Friday 18:00+ so it's active)
    var targetDate = now;
    if (targetDate.weekday == DateTime.friday && targetDate.hour >= 18) {
      targetDate = targetDate.add(const Duration(days: 7));
    } else {
      while (targetDate.weekday != DateTime.friday) {
        targetDate = targetDate.add(const Duration(days: 1));
      }
    }

    const mayaAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb'
        '?auto=format&fit=crop&w=800&q=80';

    _memoryBookings.addAll([
      HangoutRequest(
        id: 'seed-maya-friday',
        companionUid: 'sample_maya_1',
        companionName: 'Maya Rao',
        companionAvatar: mayaAvatar,
        requesterUid: 'other_user_01',
        requesterName: 'Aarav Patel',
        date: DateTime(targetDate.year, targetDate.month, targetDate.day),
        startHour: 18,
        startMinute: 0,
        durationHours: 2,
        location: 'Roastery Coffee House, Banjara Hills',
        activity: 'Coffee & Chat',
        coinsPerHour: 80,
        totalCoins: 160,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      HangoutRequest(
        id: 'seed-maya-saturday',
        companionUid: 'sample_maya_1',
        companionName: 'Maya Rao',
        companionAvatar: mayaAvatar,
        requesterUid: 'other_user_02',
        requesterName: 'Kunal Sen',
        date: DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day + 1,
        ),
        startHour: 19,
        startMinute: 0,
        durationHours: 3,
        location: 'Gallery Cafe, Film Nagar',
        activity: 'Live Music & Art',
        coinsPerHour: 80,
        totalCoins: 240,
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
    ]);

    _emitStream();
  }

  void _emitStream() {
    _hangoutsStreamController.add(List.unmodifiable(_memoryBookings));
  }

  /// Parses 12-hour format strings like "6:00 PM" or "6 PM" into total
  /// minutes from midnight.
  static int? _parseTimeToMinutes(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');
      if (!isPm && !isAm) return null;

      final noMeridiem = clean
          .replaceAll('PM', '')
          .replaceAll('AM', '')
          .trim();
      int hour;
      var minute = 0;
      if (noMeridiem.contains(':')) {
        final parts = noMeridiem.split(':');
        hour = int.parse(parts[0].trim());
        minute = parts.length > 1 ? int.parse(parts[1].trim()) : 0;
      } else {
        hour = int.parse(noMeridiem);
      }

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return hour * 60 + minute;
    } on Object {
      return null;
    }
  }

  /// Parses multi-range time windows such as:
  /// "6:00 AM – 11:00 AM & 5:00 PM – 9:00 PM"
  static List<TimeWindowRange> parseTimeRanges(String timeWindow) {
    final ranges = <TimeWindowRange>[];
    if (timeWindow.trim().isEmpty) return ranges;

    // Split multiple ranges separated by & or ,
    final segments = timeWindow.split(RegExp('[&,]'));
    for (final seg in segments) {
      final s = seg.trim();
      if (s.isEmpty) continue;

      // Split start and end by en-dash, em-dash, hyphen, or 'to'
      final parts = s.split(
        RegExp(r'[–—\-]|(\s+to\s+)', caseSensitive: false),
      );
      if (parts.length >= 2) {
        final startMin = _parseTimeToMinutes(parts[0].trim());
        final endMin = _parseTimeToMinutes(parts[1].trim());
        if (startMin != null && endMin != null) {
          ranges.add(TimeWindowRange(startMin, endMin));
        }
      }
    }
    return ranges;
  }

  static String _formatMinutes(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final displayH = h % 12 == 0 ? 12 : h % 12;
    final displayM = m.toString().padLeft(2, '0');
    final p = h >= 12 ? 'PM' : 'AM';
    return '$displayH:$displayM $p';
  }

  /// Finds the first available date for the companion starting from today.
  DateTime getFirstAvailableDate(Profile companionProfile) {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final availableDays = companionProfile.availability.availableDays;
    final ranges = parseTimeRanges(companionProfile.availability.timeWindow);

    for (var i = 0; i < 14; i++) {
      final candidate = DateTime(now.year, now.month, now.day).add(
        Duration(days: i),
      );
      final dayName = days[candidate.weekday - 1];

      if (availableDays.isNotEmpty && !availableDays.contains(dayName)) {
        continue;
      }

      // If today, check if there are remaining working hours
      if (i == 0 && ranges.isNotEmpty) {
        final nowMinutes = now.hour * 60 + now.minute;
        final hasRemainingHours = ranges.any(
          (r) => r.endMinutes - 60 > nowMinutes,
        );
        if (!hasRemainingHours) {
          continue; // Past for today, check next available day
        }
      }

      return candidate;
    }

    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  /// Calculates an initial valid starting time for the companion on a date.
  TimeOfDay getInitialAvailableTime(Profile companionProfile, DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final ranges = parseTimeRanges(companionProfile.availability.timeWindow);

    if (ranges.isEmpty) {
      return const TimeOfDay(hour: 18, minute: 0);
    }

    if (isToday) {
      final nowMinutes = now.hour * 60 + now.minute;
      for (final r in ranges) {
        if (r.endMinutes - 60 > nowMinutes) {
          // Round up to next 30-min block
          var candidateMin = ((nowMinutes + 45) ~/ 30) * 30;
          if (candidateMin < r.startMinutes) candidateMin = r.startMinutes;
          if (candidateMin + 60 <= r.endMinutes) {
            return TimeOfDay(
              hour: candidateMin ~/ 60,
              minute: candidateMin % 60,
            );
          }
        }
      }
    }

    // Default to the first available range's start time
    final first = ranges.first;
    return TimeOfDay(
      hour: first.startMinutes ~/ 60,
      minute: first.startMinutes % 60,
    );
  }

  /// Checks whether a requested slot conflicts with:
  /// 1. Past time on current day
  /// 2. Companion's active days
  /// 3. Companion's daily time window
  /// 4. Companion's existing bookings
  /// 5. Requester's existing bookings
  ConflictCheckResult checkConflict({
    required String companionUid,
    required String requesterUid,
    required DateTime date,
    required int startHour,
    required int startMinute,
    required int durationHours,
    required Profile companionProfile,
  }) {
    final slotStart = DateTime(
      date.year,
      date.month,
      date.day,
      startHour,
      startMinute,
    );
    final slotEnd = slotStart.add(Duration(hours: durationHours));
    final now = DateTime.now();

    // 0. Verify slot is not in the past
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    if (isToday && slotStart.isBefore(now)) {
      return const ConflictCheckResult(
        hasConflict: true,
        isOutsideOperatingHours: true,
        conflictReason:
            'Selected time has already passed today. '
            'Please pick an upcoming time.',
      );
    }

    // 1. Verify day of week
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const fullDays = [
      'Mondays',
      'Tuesdays',
      'Wednesdays',
      'Thursdays',
      'Fridays',
      'Saturdays',
      'Sundays',
    ];
    final dayName = days[date.weekday - 1];
    final fullDayName = fullDays[date.weekday - 1];
    final availableDays = companionProfile.availability.availableDays;

    if (availableDays.isNotEmpty && !availableDays.contains(dayName)) {
      final formattedDays = availableDays.join(', ');
      return ConflictCheckResult(
        hasConflict: true,
        isOutsideOperatingHours: true,
        conflictReason:
            '${companionProfile.name} is not available on $fullDayName. '
            'Active days: $formattedDays.',
      );
    }

    // 2. Verify operating time window
    final timeWindow = companionProfile.availability.timeWindow;
    final ranges = parseTimeRanges(timeWindow);

    if (ranges.isNotEmpty) {
      final slotStartMinutes = startHour * 60 + startMinute;
      final slotEndMinutes = slotStartMinutes + (durationHours * 60);

      // Check if completely inside at least one window
      final fitsInWindow = ranges.any((r) =>
          slotStartMinutes >= r.startMinutes &&
          slotEndMinutes <= r.endMinutes);

      if (!fitsInWindow) {
        // Check if start time is inside a range but slot extends past window
        final matchingStartRange = ranges.where(
          (r) =>
              slotStartMinutes >= r.startMinutes &&
              slotStartMinutes < r.endMinutes,
        ).firstOrNull;

        if (matchingStartRange != null) {
          final windowEnd = _formatMinutes(matchingStartRange.endMinutes);
          final slotEnd = _formatMinutes(slotEndMinutes);
          final cName = companionProfile.name;
          return ConflictCheckResult(
            hasConflict: true,
            isOutsideOperatingHours: true,
            conflictReason:
                'Slot ends at $slotEnd, which is past '
                "$cName's operating hours (closes at $windowEnd).",
          );
        }

        final slotStartFormatted = _formatMinutes(slotStartMinutes);
        return ConflictCheckResult(
          hasConflict: true,
          isOutsideOperatingHours: true,
          conflictReason:
              'Slot ($slotStartFormatted) is outside '
              '${companionProfile.name} operating hours ($timeWindow).',
        );
      }
    }

    // 3. Verify conflicts with companion's other confirmed/pending hangouts
    for (final booking in _memoryBookings) {
      if (booking.status == 'cancelled' || booking.status == 'declined') {
        continue;
      }

      // Check same calendar day
      final isSameDay = booking.date.year == date.year &&
          booking.date.month == date.month &&
          booking.date.day == date.day;
      if (!isSameDay) continue;

      final existingStart = booking.startDateTime;
      final existingEnd = booking.endDateTime;

      // Overlap condition:
      // slotStart < existingEnd && slotEnd > existingStart
      final overlaps =
          slotStart.isBefore(existingEnd) && slotEnd.isAfter(existingStart);

      if (overlaps) {
        final isCompanionMatch = booking.companionUid == companionUid ||
            (companionUid == 'maya_01' &&
                booking.companionUid == 'sample_maya_1') ||
            (companionUid == 'sample_maya_1' &&
                booking.companionUid == 'maya_01');

        if (isCompanionMatch) {
          final cName = companionProfile.name;
          final tRange = booking.timeRangeFormatted;
          final dFormatted = booking.dateFormatted;
          return ConflictCheckResult(
            hasConflict: true,
            conflictReason:
                '$cName already has a hangout scheduled '
                'from $tRange on $dFormatted.',
            conflictingHangout: booking,
          );
        }

        if (booking.requesterUid == requesterUid) {
          return ConflictCheckResult(
            hasConflict: true,
            conflictReason:
                'You already have a hangout with ${booking.companionName} '
                'from ${booking.timeRangeFormatted} on this day.',
            conflictingHangout: booking,
          );
        }
      }
    }

    return const ConflictCheckResult(hasConflict: false);
  }

  /// Book a new hangout and save to cache & Firestore
  Future<HangoutRequest> createHangout(HangoutRequest hangout) async {
    _memoryBookings.insert(0, hangout);
    _emitStream();

    try {
      await firestore
          ?.collection('hangouts')
          .doc(hangout.id)
          .set(hangout.toMap());
    } on Object catch (e) {
      debugPrint('Firestore save hangout notice: $e');
    }

    return hangout;
  }

  /// Update the status of an existing hangout (e.g. 'confirmed', 'declined')
  Future<void> updateHangoutStatus(String hangoutId, String status) async {
    final index = _memoryBookings.indexWhere((h) => h.id == hangoutId);
    if (index != -1) {
      _memoryBookings[index] = _memoryBookings[index].copyWith(status: status);
      _emitStream();
    }

    try {
      await firestore
          ?.collection('hangouts')
          .doc(hangoutId)
          .update({'status': status});
    } on Object catch (e) {
      debugPrint('Firestore update hangout status notice: $e');
    }
  }

  /// Clear all memory bookings (useful for testing)
  void clearMemoryBookings() {
    _memoryBookings.clear();
    _emitStream();
  }

  /// Get hangouts filtered for a given user
  List<HangoutRequest> getHangoutsForUser(String uid) {
    return _memoryBookings.where((h) {
      return h.requesterUid == uid || h.companionUid == uid;
    }).toList();
  }
}

// Global singleton instance for app-wide reactive state
final hangoutRepository = HangoutRepository();

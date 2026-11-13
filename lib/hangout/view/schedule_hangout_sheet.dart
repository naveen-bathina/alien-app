import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_tokens.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/hangout/repository/hangout_repository.dart';
import 'package:myalien/hangout/view/activity_selection_screen.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/models/hangout_request.dart';
import 'package:myalien/profile/view/location_picker_screen.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';
import 'package:myalien/wallet/view/buy_coins_sheet.dart';

class ScheduleHangoutSheet extends StatefulWidget {
  const ScheduleHangoutSheet({
    required this.profile,
    super.key,
  });

  final Profile profile;

  static Future<HangoutRequest?> show(
    BuildContext context, {
    required Profile profile,
  }) {
    return showModalBottomSheet<HangoutRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScheduleHangoutSheet(profile: profile),
    );
  }

  @override
  State<ScheduleHangoutSheet> createState() => _ScheduleHangoutSheetState();
}

class _ScheduleHangoutSheetState extends State<ScheduleHangoutSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _durationHours = 2;
  String _selectedActivity = 'Coffee & Chat';
  late String _selectedLocation;
  final TextEditingController _notesController = TextEditingController();

  int get _userCoinBalance =>
      walletRepository.currentState.availableBalance;

  final List<String> _popularVenues = const [
    'Roastery Coffee House',
    'Third Wave Coffee',
    'Gallery Cafe',
    'Concu Jubilee Hills',
    'Botanical Gardens',
  ];

  @override
  void initState() {
    super.initState();
    // Intelligently find the earliest available date for this companion
    _selectedDate = hangoutRepository.getFirstAvailableDate(widget.profile);
    // Find a valid initial starting time on that date
    _selectedTime = hangoutRepository.getInitialAvailableTime(
      widget.profile,
      _selectedDate,
    );

    // Initial location: earner's fixed location or default venue
    _selectedLocation = widget.profile.location.isNotEmpty
        ? widget.profile.location
        : 'Third Wave Coffee, Jubilee Hills';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _ratePerHour => widget.profile.coinsPerHour ?? 80;

  int get _totalCoins => _ratePerHour * _durationHours;

  bool get _hasSufficientBalance => _userCoinBalance >= _totalCoins;

  ConflictCheckResult _checkConflict() {
    var currentUid = 'guest_user';
    try {
      currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
    } on Object {
      currentUid = 'guest_user';
    }
    return hangoutRepository.checkConflict(
      companionUid: widget.profile.uid,
      requesterUid: currentUid,
      date: _selectedDate,
      startHour: _selectedTime.hour,
      startMinute: _selectedTime.minute,
      durationHours: _durationHours,
      companionProfile: widget.profile,
    );
  }

  Future<void> _selectCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF6C4AB6),
              onSurface: Colors.grey.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _navigateToActivitySelection() async {
    final chosen = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ActivitySelectionScreen(
          selectedActivity: _selectedActivity,
        ),
      ),
    );

    if (chosen != null && mounted) {
      setState(() => _selectedActivity = chosen);
    }
  }

  Future<void> _navigateToLocationPicker() async {
    final chosen = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (chosen != null && mounted) {
      setState(() => _selectedLocation = chosen);
    }
  }

  Future<void> _confirmBooking() async {
    final conflict = _checkConflict();
    if (conflict.hasConflict) return;

    var currentUid = 'guest_user';
    var currentName = 'Aarav';
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      currentUid = currentUser?.uid ?? 'guest_user';
      currentName = currentUser?.displayName ?? 'Aarav';
    } on Object {
      // Fallback in testing or offline
    }

    final effectiveLocation = widget.profile.isLocationFlexible
        ? (_selectedLocation.trim().isEmpty
            ? 'Selected Venue'
            : _selectedLocation.trim())
        : widget.profile.location;

    final request = HangoutRequest(
      id: 'hangout_${DateTime.now().millisecondsSinceEpoch}',
      companionUid: widget.profile.uid,
      companionName: widget.profile.name,
      companionAvatar: widget.profile.photos.isNotEmpty
          ? widget.profile.photos.first
          : '',
      companionRole: widget.profile.role,
      requesterUid: currentUid,
      requesterName: currentName,
      date: _selectedDate,
      startHour: _selectedTime.hour,
      startMinute: _selectedTime.minute,
      durationHours: _durationHours,
      location: effectiveLocation,
      activity: _selectedActivity,
      notes: _notesController.text.trim(),
      coinsPerHour: _ratePerHour,
      totalCoins: _totalCoins,
      createdAt: DateTime.now(),
    );

    await hangoutRepository.createHangout(request);

    // Lock coins into escrow using Tokenomics engine
    walletRepository.lockEscrow(
      request.id,
      _totalCoins,
      widget.profile.name,
    );

    if (!mounted) return;
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final conflict = _checkConflict();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final tokens = AppColorTokens.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: AppImage(
                      source: widget.profile.photos.isNotEmpty
                          ? widget.profile.photos.first
                          : '',
                      memCacheWidth: 120,
                      memCacheHeight: 120,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Request ${widget.profile.name}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            color: tokens.brandAccent,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🪙 $_ratePerHour Coins / hr  •  '
                        '${widget.profile.role}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
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

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Date Selection
                  _buildSectionHeader(AppStrings.selectDate),
                  const SizedBox(height: 10),
                  _buildDatePills(),
                  const SizedBox(height: 20),

                  // 2. Start Time (Custom Time Selection)
                  _buildSectionHeader(AppStrings.startTime),
                  const SizedBox(height: 10),
                  _buildTimeSelectionTile(),
                  const SizedBox(height: 20),

                  // 3. Duration Stepper
                  _buildSectionHeader(AppStrings.slotDuration),
                  const SizedBox(height: 10),
                  _buildDurationStepper(),
                  const SizedBox(height: 20),

                  // 4. Real-time Conflict Banner
                  _buildConflictBanner(conflict),
                  const SizedBox(height: 20),

                  // 5. Hangout For Tile
                  _buildSectionHeader(AppStrings.hangoutFor),
                  const SizedBox(height: 10),
                  _buildActivityTile(),
                  const SizedBox(height: 20),

                  // 6. Venue Location (Fixed vs Flexible)
                  _buildSectionHeader(AppStrings.location),
                  const SizedBox(height: 10),
                  _buildVenueSection(),
                  const SizedBox(height: 20),

                  // 7. Coin Economics Breakdown
                  _buildPricingCard(),
                ],
              ),
            ),
          ),

          // Bottom Fixed Action Bar
          _buildBottomActionBar(conflict),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E2D),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildDatePills() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = DateTime(now.year, now.month, now.day).add(
            Duration(days: index),
          );
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final dayName = days[date.weekday - 1];
          final monthName = months[date.month - 1];
          final isDayAvailable = widget.profile.availability.availableDays
              .contains(dayName);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                // If switching to date where selected time is invalid, re-check
                final ranges = HangoutRepository.parseTimeRanges(
                  widget.profile.availability.timeWindow,
                );
                if (ranges.isNotEmpty) {
                  final slotMin =
                      _selectedTime.hour * 60 + _selectedTime.minute;
                  final slotEnd = slotMin + (_durationHours * 60);
                  final fits = ranges.any(
                    (r) => slotMin >= r.startMinutes && slotEnd <= r.endMinutes,
                  );
                  if (!fits) {
                    _selectedTime = hangoutRepository.getInitialAvailableTime(
                      widget.profile,
                      date,
                    );
                  }
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C4AB6)
                    : (isDayAvailable
                        ? const Color(0xFFF7F5FC)
                        : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C4AB6)
                      : (isDayAvailable
                          ? const Color(0xFFE2DDF4)
                          : Colors.grey.shade300),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : (isDayAvailable
                              ? Colors.grey.shade700
                              : Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDayAvailable
                              ? const Color(0xFF1E1E2D)
                              : Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isDayAvailable)
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey.shade500,
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Off',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelectionTile() {
    final h = _selectedTime.hour % 12 == 0 ? 12 : _selectedTime.hour % 12;
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    final p = _selectedTime.hour >= 12 ? 'PM' : 'AM';
    final timeFormatted = '$h:$m $p';
    final endTimeFormatted = _calculateEndTimeString();

    return InkWell(
      onTap: _selectCustomTime,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2DDF4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF6C4AB6),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeFormatted,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Slot: $timeFormatted – $endTimeFormatted '
                    '($_durationHours hrs)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2DDF4)),
              ),
              child: const Row(
                children: [
                  Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C4AB6),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.edit_calendar_rounded,
                    size: 14,
                    color: Color(0xFF6C4AB6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2DDF4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_durationHours '
                '${_durationHours == 1 ? 'Hour' : 'Hours'} Slot',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ending at ${_calculateEndTimeString()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: _durationHours > 1
                    ? const Color(0xFF6C4AB6)
                    : Colors.grey.shade400,
                onPressed: _durationHours > 1
                    ? () => setState(() => _durationHours--)
                    : null,
              ),
              Text(
                '$_durationHours',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: _durationHours < 6
                    ? const Color(0xFF6C4AB6)
                    : Colors.grey.shade400,
                onPressed: _durationHours < 6
                    ? () => setState(() => _durationHours++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateEndTimeString() {
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final end = start.add(Duration(hours: _durationHours));
    final h = end.hour % 12 == 0 ? 12 : end.hour % 12;
    final m = end.minute.toString().padLeft(2, '0');
    final p = end.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  Widget _buildConflictBanner(ConflictCheckResult conflict) {
    if (conflict.hasConflict) {
      final isHours = conflict.isOutsideOperatingHours;
      final bgColor = isHours
          ? const Color(0xFFFFF7ED)
          : const Color(0xFFFFF1F2);
      final borderColor = isHours
          ? const Color(0xFFFFEDD5)
          : const Color(0xFFFFE4E6);
      final iconColor = isHours
          ? const Color(0xFFEA580C)
          : const Color(0xFFE11D48);

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isHours ? Icons.schedule_rounded : Icons.warning_amber_rounded,
              color: iconColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHours
                        ? 'Outside Operating Hours'
                        : 'Schedule Conflict Detected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conflict.conflictReason ??
                        'Selected time conflicts with an existing booking.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Slot Available: ${_selectedTime.format(context)} – '
              '${_calculateEndTimeString()} (${widget.profile.name} is free)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile() {
    return InkWell(
      onTap: _navigateToActivitySelection,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2DDF4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_activity_rounded,
                color: Color(0xFF6C4AB6),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedActivity,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.tapToChooseHangoutFor,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6C4AB6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueSection() {
    final isFlexible = widget.profile.isLocationFlexible;

    if (!isFlexible) {
      // Fixed Earner Location Display
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2DDF4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pin_drop_rounded,
                color: Color(0xFF6C4AB6),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.profile.location.isNotEmpty
                              ? widget.profile.location
                              : 'Earner Fixed Venue',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E2D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 11,
                              color: Color(0xFF6C4AB6),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Fixed Venue',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C4AB6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.profile.name} only meets at their '
                    'designated venue.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Flexible Location Selection for Sponsor
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _navigateToLocationPicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2DDF4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF6C4AB6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation.isNotEmpty
                            ? _selectedLocation
                            : 'Select Google Location / Address',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _selectedLocation.isNotEmpty
                              ? const Color(0xFF1E1E2D)
                              : Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Earner is flexible • Tap to choose on Google Maps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6C4AB6),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _popularVenues.map((venue) {
            final isChosen = _selectedLocation == venue;
            return ActionChip(
              avatar: isChosen
                  ? const Icon(Icons.check, size: 14, color: Color(0xFF6C4AB6))
                  : null,
              label: Text(
                venue,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                  color: isChosen
                      ? const Color(0xFF6C4AB6)
                      : const Color(0xFF1E1E2D),
                ),
              ),
              backgroundColor: isChosen
                  ? const Color(0xFFF7F5FC)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isChosen
                      ? const Color(0xFF6C4AB6)
                      : Colors.grey.shade300,
                ),
              ),
              onPressed: () {
                setState(() => _selectedLocation = venue);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rate ($_ratePerHour Coins × $_durationHours hrs)',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '🪙 $_totalCoins Coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Wallet Balance',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '★ $_userCoinBalance Coins',
                style: TextStyle(
                  color: _hasSufficientBalance
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFF87171),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF4ADE80), size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Escrow Safe: Coins are locked & only released upon completed meetup.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ConflictCheckResult conflict) {
    final canBook = !conflict.hasConflict && _hasSufficientBalance;
    final shortfall = _totalCoins - _userCoinBalance;

    return Container(
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
            onPressed: conflict.hasConflict
                ? null
                : (canBook
                    ? _confirmBooking
                    : () async {
                        await BuyCoinsSheet.show(context);
                        if (mounted) {
                          setState(() {});
                        }
                      }),
            style: ElevatedButton.styleFrom(
              backgroundColor: canBook
                  ? const Color(0xFF6C4AB6)
                  : (conflict.hasConflict
                      ? Colors.grey.shade300
                      : const Color(0xFF10B981)),
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!conflict.hasConflict && !_hasSufficientBalance) ...[
                  const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  canBook
                      ? 'Confirm Hangout ($_totalCoins Coins)'
                      : (conflict.hasConflict
                          ? 'Slot Unavailable'
                          : 'Top Up $shortfall Coins & Book'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: conflict.hasConflict
                        ? Colors.grey.shade600
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

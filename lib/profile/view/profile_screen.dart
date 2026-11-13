import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/discover/view/full_profile_screen.dart';
import 'package:myalien/home/models/profile_model.dart' as home_models;
import 'package:myalien/profile/cubit/profile_cubit.dart';
import 'package:myalien/profile/cubit/profile_state.dart';
import 'package:myalien/profile/models/profile_model.dart';
import 'package:myalien/profile/view/gender_selection_screen.dart';
import 'package:myalien/profile/view/location_picker_screen.dart';
import 'package:myalien/profile/view/looking_for_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _genders = [
    'Woman',
    'Man',
    'Non-binary',
    'Prefer not to say',
  ];

  static const _intentions = [
    'Cafe Catchups',
    'Event Companion',
    'Activity Partner',
    'Long-term relationship',
    'Something casual',
    'New friends',
  ];

  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();

  DateTime? _dob;
  String? _gender = 'Woman';
  String? _lookingFor = 'Cafe Catchups';
  String _role = 'Earner';
  int _coinsPerHour = 80;
  bool _isDiscoveryActive = true;
  bool _isLocationFlexible = true;
  final List<String> _photos = [];

  // Working Hours State
  bool _isAvailableToday = true;
  final Set<String> _availableDays = {'Mon', 'Wed', 'Fri', 'Sat', 'Sun'};
  TimeOfDay _startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  File? _pendingImageUpload;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _displayNameCtrl.dispose();
    _locationCtrl.dispose();
    _taglineCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _applyProfile(ProfileLoaded state) {
    final profile = state.profile;
    if (profile == null) return;

    _fullNameCtrl.text = profile.fullName ?? profile.name;
    _displayNameCtrl.text = profile.displayName ?? profile.name;
    _locationCtrl.text = profile.location;
    _taglineCtrl.text = profile.tagline ?? '';
    _bioCtrl.text = profile.bio;
    _dob = profile.dob;
    _gender = _genders.contains(profile.gender) ? profile.gender : 'Woman';
    _lookingFor = _intentions.contains(profile.lookingFor)
        ? profile.lookingFor
        : 'Cafe Catchups';
    _role = profile.role;
    _coinsPerHour = profile.coinsPerHour ?? 80;
    _isDiscoveryActive = profile.isDiscoveryActive;
    _isLocationFlexible = profile.isLocationFlexible;

    _photos
      ..clear()
      ..addAll(profile.photos);
    if (_photos.isEmpty && profile.photoUrl != null) {
      _photos.add(profile.photoUrl!);
    }

    // Availability
    final avail = profile.availability;
    _isAvailableToday = avail.isAvailableToday;
    _availableDays
      ..clear()
      ..addAll(avail.availableDays);
    _parseTimeWindow(avail.timeWindow);

    setState(() {});
  }

  void _parseTimeWindow(String window) {
    if (!window.contains('–') && !window.contains('-')) return;
    final parts =
        window.contains('–') ? window.split('–') : window.split('-');
    if (parts.length != 2) return;

    final start = _parseTod(parts[0]);
    final end = _parseTod(parts[1]);
    if (start != null) _startTime = start;
    if (end != null) _endTime = end;
  }

  TimeOfDay? _parseTod(String s) {
    try {
      final clean = s.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');
      if (!isPm && !isAm) return null;
      final t = clean.replaceAll('PM', '').replaceAll('AM', '').trim();
      final p = t.split(':');
      var hour = int.parse(p[0].trim());
      final min = p.length > 1 ? int.parse(p[1].trim()) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: min);
    } on Object {
      return null;
    }
  }

  String _formatTod(TimeOfDay tod) {
    final h = tod.hour % 12 == 0 ? 12 : tod.hour % 12;
    final m = tod.minute.toString().padLeft(2, '0');
    final p = tod.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  String get _timeWindowString =>
      '${_formatTod(_startTime)} – ${_formatTod(_endTime)}';

  int? get _calculatedAge {
    if (_dob == null) return null;
    final today = DateTime.now();
    var a = today.year - _dob!.year;
    if (today.month < _dob!.month ||
        (today.month == _dob!.month && today.day < _dob!.day)) {
      a--;
    }
    return a;
  }

  bool _isAdult(DateTime date) {
    final today = DateTime.now();
    final adultDate = DateTime(today.year - 18, today.month, today.day);
    return !date.isAfter(adultDate);
  }

  Future<void> _pickImage(int slotIndex) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final result = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (result != null && mounted) {
      final file = File(result.path);
      final bytes = await file.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        if (slotIndex < _photos.length) {
          _photos[slotIndex] = base64String;
        } else {
          _photos.add(base64String);
        }
      });
    }
  }

  void _removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      setState(() => _photos.removeAt(index));
    }
  }

  void _setAsMainPhoto(int index) {
    if (index > 0 && index < _photos.length) {
      setState(() {
        final p = _photos.removeAt(index);
        _photos.insert(0, p);
      });
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final latestAdultDate = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dob != null && !_dob!.isAfter(latestAdultDate)
          ? _dob!
          : DateTime(today.year - 24),
      firstDate: DateTime(1920),
      lastDate: today,
      helpText: 'Select your birthday',
    );
    if (selectedDate != null) setState(() => _dob = selectedDate);
  }

  Future<void> _selectTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      _showToast('Please select your date of birth.');
      return;
    }
    if (!_isAdult(_dob!)) {
      _showToast('You must be 18 or older to join MyAlien.');
      return;
    }
    if (_photos.isEmpty) {
      _showToast('Add at least one profile photo.');
      return;
    }

    final availability = ProfileAvailability(
      isAvailableToday: _isAvailableToday,
      statusText: _isAvailableToday ? 'Available Today' : 'Off Duty Today',
      availableDays: _availableDays.toList(),
      timeWindow: _timeWindowString,
    );

    context.read<ProfileCubit>().saveProfile(
      name: _displayNameCtrl.text.trim().isNotEmpty
          ? _displayNameCtrl.text.trim()
          : _fullNameCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      displayName: _displayNameCtrl.text.trim(),
      dob: _dob!,
      gender: _gender ?? 'Woman',
      location: _locationCtrl.text.trim(),
      lookingFor: _lookingFor ?? 'Cafe Catchups',
      bio: _bioCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      role: _role,
      coinsPerHour: _coinsPerHour,
      isDiscoveryActive: _isDiscoveryActive,
      isLocationFlexible: _isLocationFlexible,
      availability: availability,
      existingPhotos: _photos,
      existingPhotoUrl: _photos.isNotEmpty ? _photos.first : null,
      imageFile: _pendingImageUpload,
    );
  }

  void _previewProfile() {
    final preview = home_models.Profile(
      uid: 'me',
      name: _displayNameCtrl.text.trim().isNotEmpty
          ? _displayNameCtrl.text.trim()
          : (_fullNameCtrl.text.trim().isNotEmpty
              ? _fullNameCtrl.text.trim()
              : 'You'),
      dob: _dob ?? DateTime(2000),
      gender: _gender ?? 'Woman',
      location: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : 'Hyderabad, India',
      photos: _photos.isNotEmpty
          ? _photos
          : const [
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
            ],
      lookingFor: _lookingFor,
      bio: _bioCtrl.text.trim().isNotEmpty
          ? _bioCtrl.text.trim()
          : 'Enthusiastic explorer ready to hangout!',
      tagline: _taglineCtrl.text.trim().isNotEmpty
          ? _taglineCtrl.text.trim()
          : 'Social Companion',
      role: _role,
      coinsPerHour: _coinsPerHour,
      isLocationFlexible: _isLocationFlexible,
      availability: home_models.ProfileAvailability(
        isAvailableToday: _isAvailableToday,
        statusText: _isAvailableToday ? 'Available Today' : 'Off Duty Today',
        availableDays: _availableDays.toList(),
        timeWindow: _timeWindowString,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullProfileScreen(
          profile: preview,
          isPreview: true,
        ),
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _applyProfile(state);
        } else if (state is ProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is ProfileError) {
          _showToast(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const BackButton(),
          titleSpacing: 0,
          title: const Text(
            AppStrings.profile,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E1E2D),
          actions: [
            TextButton.icon(
              onPressed: _previewProfile,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Preview'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6C4AB6),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(colorScheme),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              // 1. Discovery Visibility Toggle
              _buildDiscoveryToggleCard(colorScheme),
              const SizedBox(height: 14),

              // 2. Photo Gallery (3x2 Grid)
              _buildPhotoGalleryCard(colorScheme),
              const SizedBox(height: 14),

              // 3. Role & Coin Economics (Earner vs Sponsor)
              _buildRoleAndCoinsCard(colorScheme),
              const SizedBox(height: 14),

              // 4. Working Hours & Availability Schedule
              _buildWorkingHoursCard(colorScheme),
              const SizedBox(height: 14),

              // 5. Identity & Basic Info
              _buildIdentityCard(colorScheme),
              const SizedBox(height: 14),

              // 6. Bio, Tagline & Intentions
              _buildBioCard(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION BUILDERS ---

  Widget _buildCardContainer({
    required Widget child,
    required ColorScheme colorScheme,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEAF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDiscoveryToggleCard(ColorScheme colorScheme) {
    return _buildCardContainer(
      colorScheme: colorScheme,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isDiscoveryActive
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isDiscoveryActive
                  ? Icons.explore_rounded
                  : Icons.explore_off_rounded,
              color: _isDiscoveryActive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFE11D48),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isDiscoveryActive
                          ? 'Visible on Discover'
                          : 'Profile Snoozed (Hidden)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2D),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isDiscoveryActive
                            ? const Color(0xFF16A34A)
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isDiscoveryActive
                      ? 'Other Aliens can discover & request hangouts.'
                      : 'Hidden from swipe cards. Existing chats remain.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDiscoveryActive,
            activeTrackColor: const Color(0xFF6C4AB6),
            onChanged: (val) => setState(() => _isDiscoveryActive = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGalleryCard(ColorScheme colorScheme) {
    return _buildCardContainer(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Photos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
              Text(
                '${_photos.length} / 6 Photos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final hasPhoto = index < _photos.length;
              final isMain = index == 0 && hasPhoto;

              if (hasPhoto) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AppImage(
                        source: _photos[index],
                      ),
                    ),
                    if (isMain)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C4AB6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '★ Main',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (!isMain)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _setAsMainPhoto(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Make Main',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }

              final isNextSlot = index == _photos.length;

              return GestureDetector(
                onTap: isNextSlot ? () => _pickImage(index) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isNextSlot
                        ? const Color(0xFFF7F5FC)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isNextSlot
                          ? const Color(0xFFC7B9E8)
                          : Colors.grey.shade300,
                      style: isNextSlot ? BorderStyle.solid : BorderStyle.none,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isNextSlot
                            ? Icons.add_photo_alternate_outlined
                            : Icons.photo_outlined,
                        size: 24,
                        color: isNextSlot
                            ? const Color(0xFF6C4AB6)
                            : Colors.grey.shade400,
                      ),
                      if (isNextSlot) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Add Photo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C4AB6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleAndCoinsCard(ColorScheme colorScheme) {
    final isEarner = _role.toLowerCase() == 'earner';

    return _buildCardContainer(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alien Community Role & Pricing',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 10),

          // Role Switcher Segmented
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _role = 'Earner'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isEarner ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isEarner
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: isEarner
                                ? const Color(0xFF16A34A)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Earner',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isEarner
                                  ? const Color(0xFF1E1E2D)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _role = 'Sponsor'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: !isEarner ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isEarner
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 16,
                            color: !isEarner
                                ? const Color(0xFF6C4AB6)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sponsor',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !isEarner
                                  ? const Color(0xFF1E1E2D)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Price / Budget Stepper Container (Only increase and decrease by one)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isEarner
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFAF8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEarner
                    ? const Color(0xFFBBF7D0)
                    : const Color(0xFFE2DDF4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEarner ? 'My Hourly Rate' : 'My Hourly Budget',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isEarner
                            ? const Color(0xFF166534)
                            : const Color(0xFF4C1D95),
                      ),
                    ),
                    Text(
                      '🪙 $_coinsPerHour Coins / hr',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isEarner
                            ? const Color(0xFF15803D)
                            : const Color(0xFF6C4AB6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isEarner
                      ? 'Requesters pay this in Alien Coins to book a hangout.'
                      : 'Budget you are willing to spend per hour on hangouts.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 14),
                // Stepper: Only Increase and Decrease by One
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEarner
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFD8B4FE),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_rounded),
                        iconSize: 28,
                        color: _coinsPerHour > 1
                            ? (isEarner
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6C4AB6))
                            : Colors.grey.shade400,
                        tooltip: 'Decrease by 1',
                        onPressed: _coinsPerHour > 1
                            ? () => setState(() => _coinsPerHour -= 1)
                            : null,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🪙',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_coinsPerHour',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isEarner
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF4C1D95),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Coins / hr',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_rounded),
                        iconSize: 28,
                        color: _coinsPerHour < 1000
                            ? (isEarner
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6C4AB6))
                            : Colors.grey.shade400,
                        tooltip: 'Increase by 1',
                        onPressed: _coinsPerHour < 1000
                            ? () => setState(() => _coinsPerHour += 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard(ColorScheme colorScheme) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _buildCardContainer(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Working Hours & Schedule',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isAvailableToday
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isAvailableToday ? '● Open Today' : '○ Off Today',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isAvailableToday
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Hangout requests will be verified against these hours.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Available Today Instant Switch
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Accepting Hangout Requests Today',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _isAvailableToday
                  ? 'Active today in discovery and bookings'
                  : 'Take a break today without disabling discovery',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            value: _isAvailableToday,
            activeTrackColor: const Color(0xFF6C4AB6),
            onChanged: (val) => setState(() => _isAvailableToday = val),
          ),
          const Divider(height: 16),

          // Operating Days Selector
          const Text(
            'Active Days of Week',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSel = _availableDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSel) {
                      if (_availableDays.length > 1) {
                        _availableDays.remove(day);
                      }
                    } else {
                      _availableDays.add(day);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSel
                        ? const Color(0xFF6C4AB6)
                        : const Color(0xFFF7F5FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel
                          ? const Color(0xFF6C4AB6)
                          : const Color(0xFFE2DDF4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day[0],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Day Presets
          Row(
            children: [
              ActionChip(
                label: const Text('Everyday', style: TextStyle(fontSize: 10)),
                onPressed: () => setState(() => _availableDays.addAll(days)),
              ),
              const SizedBox(width: 6),
              ActionChip(
                label: const Text('Mon–Fri', style: TextStyle(fontSize: 10)),
                onPressed: () {
                  setState(() {
                    _availableDays
                      ..clear()
                      ..addAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
                  });
                },
              ),
              const SizedBox(width: 6),
              ActionChip(
                label: const Text('Sat–Sun', style: TextStyle(fontSize: 10)),
                onPressed: () {
                  setState(() {
                    _availableDays
                      ..clear()
                      ..addAll(['Sat', 'Sun']);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Operating Time Window
          const Text(
            'Daily Working Hours Window',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(isStart: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DDF4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Time',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTod(_startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('to', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(isStart: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DDF4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Time',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTod(_endTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(ColorScheme colorScheme) {
    return _buildCardContainer(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Details & Identity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 12),

          // Display Name & Full Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _displayNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'e.g. Maya',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF7F5FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Display name required'
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _fullNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. Maya Rao',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF7F5FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Birthday & Age
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DDF4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dob != null
                              ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                              : 'Select Birthday',
                          style: TextStyle(
                            fontSize: 13,
                            color: _dob != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Color(0xFF6C4AB6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_calculatedAge != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2DDF4)),
                  ),
                  child: Text(
                    '$_calculatedAge yrs',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C4AB6),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Gender Selection Tile
          _buildNavigationTile(
            label: 'Gender',
            value: _gender ?? 'Select Gender',
            icon: Icons.person_outline_rounded,
            isPlaceholder: _gender == null,
            onTap: () async {
              final chosen = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => GenderSelectionScreen(
                    currentGender: _gender,
                  ),
                ),
              );
              if (chosen != null) {
                setState(() => _gender = chosen);
              }
            },
          ),
          const SizedBox(height: 12),

          // Location Selection Tile (Google Maps Picker)
          _buildNavigationTile(
            label: _isLocationFlexible && _role == 'Earner'
                ? 'Base City / Area'
                : 'Fixed Meeting Venue / City',
            value: _locationCtrl.text.isNotEmpty
                ? _locationCtrl.text
                : 'Select Location on Map',
            icon: Icons.location_on_outlined,
            isPlaceholder: _locationCtrl.text.isEmpty,
            onTap: () async {
              final chosen = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => LocationPickerScreen(
                    initialLocation: _locationCtrl.text,
                  ),
                ),
              );
              if (chosen != null) {
                setState(() => _locationCtrl.text = chosen);
              }
            },
          ),
          if (_role == 'Earner') ...[
            const SizedBox(height: 12),
            const Text(
              'Meetup Venue Flexibility',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2D),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: !_isLocationFlexible
                              ? Colors.white
                              : const Color(0xFF1E1E2D),
                        ),
                        const SizedBox(width: 4),
                        const Text('Fixed Venue'),
                      ],
                    ),
                    selected: !_isLocationFlexible,
                    selectedColor: const Color(0xFF6C4AB6),
                    backgroundColor: const Color(0xFFF7F5FC),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: !_isLocationFlexible
                          ? Colors.white
                          : const Color(0xFF1E1E2D),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: !_isLocationFlexible
                            ? const Color(0xFF6C4AB6)
                            : const Color(0xFFE2DDF4),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _isLocationFlexible = false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alt_route_rounded,
                          size: 14,
                          color: _isLocationFlexible
                              ? Colors.white
                              : const Color(0xFF1E1E2D),
                        ),
                        const SizedBox(width: 4),
                        const Text('Flexible'),
                      ],
                    ),
                    selected: _isLocationFlexible,
                    selectedColor: const Color(0xFF6C4AB6),
                    backgroundColor: const Color(0xFFF7F5FC),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isLocationFlexible
                          ? Colors.white
                          : const Color(0xFF1E1E2D),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _isLocationFlexible
                            ? const Color(0xFF6C4AB6)
                            : const Color(0xFFE2DDF4),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _isLocationFlexible = true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _isLocationFlexible
                  ? 'Sponsors can choose any Google location or venue in '
                      'your city.'
                  : 'Sponsors must meet at your designated fixed venue '
                      'above.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioCard(ColorScheme colorScheme) {
    return _buildCardContainer(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio, Tagline & Intentions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 12),

          // Tagline
          TextFormField(
            controller: _taglineCtrl,
            maxLength: 60,
            decoration: InputDecoration(
              labelText: 'Profile Punchline (Tagline)',
              hintText: 'e.g. Specialty Coffee Connoisseur & Tech Enthusiast',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF7F5FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bio
          TextFormField(
            controller: _bioCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'About Me',
              hintText: 'Tell other aliens what makes you unique...',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF7F5FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2DDF4)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Hangout For Selection Tile
          _buildNavigationTile(
            label: AppStrings.hangoutFor,
            value: _lookingFor ?? AppStrings.selectHangoutFor,
            icon: Icons.favorite_outline_rounded,
            isPlaceholder: _lookingFor == null,
            onTap: () async {
              final chosen = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => LookingForSelectionScreen(
                    currentIntention: _lookingFor,
                  ),
                ),
              );
              if (chosen != null) {
                setState(() => _lookingFor = chosen);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E2D),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2DDF4)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF6C4AB6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isPlaceholder
                          ? FontWeight.normal
                          : FontWeight.w600,
                      color: isPlaceholder
                          ? Colors.grey.shade500
                          : const Color(0xFF1E1E2D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C4AB6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Profile Changes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

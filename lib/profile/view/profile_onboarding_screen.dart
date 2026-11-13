import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/app/widgets/app_card.dart';
import 'package:myalien/app/widgets/app_selection_tile.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:myalien/home/view/home_screen.dart';
import 'package:myalien/profile/cubit/profile_cubit.dart';
import 'package:myalien/profile/cubit/profile_state.dart';

/// Streamlined 3-step questionnaire onboarding:
/// Step 1: Your Name (Single clear name field, no duplicate Full/Display names)
/// Step 2: About You (Gender selection + Age / Date of Birth verification)
/// Step 3: City & Photo (Location with quick choices & Profile Photo)
class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  static const int _totalSteps = 3;
  final PageController _pageController = PageController();

  int _currentStep = 0;

  // Controllers & Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: 'Hyderabad');

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();

  String? _selectedGender = 'Woman';
  DateTime? _selectedDob;
  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();
  String? _stepError;

  static const List<Map<String, String>> _genderOptions = [
    {'title': 'Woman', 'icon': '👩', 'desc': 'Identify as woman'},
    {'title': 'Man', 'icon': '👨', 'desc': 'Identify as man'},
    {'title': 'Non-binary', 'icon': '⚧️', 'desc': 'Identify as non-binary'},
    {'title': 'Prefer not to say', 'icon': '🔒', 'desc': 'Keep it private'},
  ];

  static const List<String> _popularCities = [
    'Hyderabad',
    'Bangalore',
    'Mumbai',
    'Delhi',
    'Pune',
    'Goa',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDob = DateTime(today.year - 24, today.month, today.day);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _nameFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  int? get _calculatedAge {
    if (_selectedDob == null) return null;
    final today = DateTime.now();
    var age = today.year - _selectedDob!.year;
    if (today.month < _selectedDob!.month ||
        (today.month == _selectedDob!.month && today.day < _selectedDob!.day)) {
      age--;
    }
    return age;
  }

  bool _isAdult(DateTime date) {
    final today = DateTime.now();
    final eighteenthBirthday = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    return !date.isAfter(eighteenthBirthday);
  }

  void _clearError() {
    if (_stepError != null) {
      setState(() => _stepError = null);
    }
  }

  bool _validateCurrentStep() {
    setState(() => _stepError = null);
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().length < 2) {
          setState(() {
            _stepError = 'Please enter your name (at least 2 letters)';
          });
          _nameFocus.requestFocus();
          return false;
        }
        return true;
      case 1:
        if (_selectedGender == null) {
          setState(() {
            _stepError = 'Please select your gender to continue';
          });
          return false;
        }
        if (_selectedDob == null || !_isAdult(_selectedDob!)) {
          setState(() {
            _stepError = 'You must be 18 or older to join MyAlien';
          });
          return false;
        }
        return true;
      case 2:
        if (_locationController.text.trim().length < 2) {
          setState(() {
            _stepError = 'Please enter your city or location';
          });
          _locationFocus.requestFocus();
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _goToNextStep() {
    FocusScope.of(context).unfocus();
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      final next = _currentStep + 1;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = next;
        _stepError = null;
      });
    } else {
      _submitProfile();
    }
  }

  void _goToPreviousStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      final prev = _currentStep - 1;
      _pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = prev;
        _stepError = null;
      });
    } else {
      _showExitDialog();
    }
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Setup?'),
        content: const Text(
          'Your profile is not complete yet. You will need to finish setup '
          'next time you log in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Setup'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if ((shouldExit ?? false) && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _pickImage() async {
    _clearError();
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
      maxWidth: 600,
      maxHeight: 600,
    );

    if (result != null && mounted) {
      setState(() {
        _pickedImage = File(result.path);
        _stepError = null;
      });
    }
  }

  Future<void> _pickBirthday() async {
    _clearError();
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(today.year - 24),
      firstDate: DateTime(1920),
      lastDate: today,
      helpText: 'Select your birthday',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDob = picked;
        if (!_isAdult(picked)) {
          _stepError = 'You must be 18 or older to join MyAlien';
        } else {
          _stepError = null;
        }
      });
    }
  }

  void _submitProfile() {
    if (!_validateCurrentStep()) return;

    final name = _nameController.text.trim();
    context.read<ProfileCubit>().saveProfile(
      name: name,
      fullName: name,
      displayName: name,
      dob: _selectedDob ?? DateTime(2000, 1, 1),
      gender: _selectedGender ?? 'Woman',
      location: _locationController.text.trim(),
      imageFile: _pickedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToPreviousStep();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Previous question',
            onPressed: _goToPreviousStep,
          ),
          title: Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _showExitDialog,
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Welcome to MyAlien! Profile created 🎉'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              } else if (state is ProfileError) {
                setState(() => _stepError = state.message);
              }
            },
            builder: (context, state) {
              final isSaving = state is ProfileSaving;

              return Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildNameStep(),
                        _buildAboutYouStep(),
                        _buildLocationAndPhotoStep(),
                      ],
                    ),
                  ),

                  // Bottom Error Notification
                  if (_stepError != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _stepError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Continue / Finish Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _goToNextStep,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Creating your profile...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == _totalSteps - 1
                                      ? 'Finish & Explore MyAlien 🎉'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == _totalSteps - 1
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- STEP 1: Single Friendly Name ---
  Widget _buildNameStep() {
    return _buildQuestionScaffold(
      icon: Icons.person_outline_rounded,
      title: "What's your name?",
      subtitle: 'This is the name companions and friends will see.',
      content: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _goToNextStep(),
              onChanged: (_) => _clearError(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. Alex Sharma',
                prefixIcon: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: About You (Gender + Age verification) ---
  Widget _buildAboutYouStep() {
    return _buildQuestionScaffold(
      icon: Icons.face_rounded,
      title: 'A little about you',
      subtitle: 'Select how you identify and verify you are 18+.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender Identity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._genderOptions.map((opt) {
            final isSelected = _selectedGender == opt['title'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSelectionTile(
                title: opt['title']!,
                subtitle: opt['desc'],
                icon: Text(opt['icon']!, style: const TextStyle(fontSize: 22)),
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedGender = opt['title']);
                  _clearError();
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Age & Date of Birth',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            onTap: _pickBirthday,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cake_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDob == null
                            ? 'Select your birthday'
                            : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year} (${_calculatedAge ?? 18} years old)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Must be 18+ to join',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.edit_calendar_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: Location & Profile Photo ---
  Widget _buildLocationAndPhotoStep() {
    return _buildQuestionScaffold(
      icon: Icons.place_rounded,
      title: 'City & Photo',
      subtitle: 'Where are you based and what do you look like?',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'City / Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _locationController,
            focusNode: _locationFocus,
            onChanged: (_) => _clearError(),
            decoration: InputDecoration(
              hintText: 'Enter your city',
              prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: AppColors.primary),
                tooltip: 'Use current location',
                onPressed: () {
                  setState(() => _locationController.text = 'Hyderabad, Jubilee Hills');
                  _clearError();
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _popularCities.map((city) {
              final isSelected = _locationController.text.contains(city);
              return ChoiceChip(
                label: Text(city),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _locationController.text = city);
                  _clearError();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? const Icon(
                            Icons.person,
                            size: 54,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScaffold({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }
}

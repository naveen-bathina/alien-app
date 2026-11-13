/// Centralized application strings and configurable text constants.
///
/// Provides compile-time `const` strings for optimal Flutter widget rebuild
/// performance, along with dynamic runtime override support for remote config
/// and white-labeling.
class AppStrings {
  AppStrings._();

  // ---------------------------------------------------------------------------
  // Dynamic Configuration & Overrides
  // ---------------------------------------------------------------------------
  static final Map<String, String> _overrides = {};

  /// Configure runtime string overrides dynamically (e.g. from Remote Config).
  static void configure(Map<String, String> customStrings) {
    _overrides.addAll(customStrings);
  }

  /// Clears any dynamic runtime string overrides.
  static void clearOverrides() {
    _overrides.clear();
  }

  /// Resolves a string with dynamic override support, falling back to
  /// [defaultValue].
  static String get(String key, String defaultValue) =>
      _overrides[key] ?? defaultValue;

  // ---------------------------------------------------------------------------
  // 1. App & Branding
  // ---------------------------------------------------------------------------
  static const String appName = 'MyAlien';
  static const String appTagline = 'Connect with friendly companions';
  static const String appVersion = 'v1.0.0';
  static const String copyrightAllRightsReserved =
      '© $appName • $appVersion • All Rights Reserved';

  // ---------------------------------------------------------------------------
  // 2. Navigation & Drawer
  // ---------------------------------------------------------------------------
  static const String navDiscover = 'Discover';
  static const String navHangouts = 'Hangouts';
  static const String navMatches = 'Matches';
  static const String navWallet = 'Wallet';
  static const String navProfile = 'Profile';
  static const String navSettings = 'Settings';
  static const String navFilters = 'Filters';
  static const String navSafetyHelp = 'Safety & Help';
  static const String navEditProfile = 'Edit Profile';

  // Drawer specific
  static const String logoutDialogTitle = 'Log out of MyAlien?';
  static const String logoutDialogContent =
      'You will need to verify your phone number to sign back in.';

  // ---------------------------------------------------------------------------
  // 3. Discovery & Filters
  // ---------------------------------------------------------------------------
  static const String discoveryPreferences = 'Discovery Preferences';
  static const String filterWhoToMeet = '1. Who Do You Want to Meet?';
  static const String filterGender = '2. Interested in Gender';
  static const String filterAgeRange = '3. Age Range';
  static const String filterLocation = '4. Location & Nearby Distance';
  static const String filterHangoutFor = '5. Hangout For';
  static const String filterAvailabilitySafety = '7. Availability & Safety';
  static const String filterSortOrder = '8. Sort Order';

  static const String filterAllAliens = 'All Aliens';
  static const String filterEarnersOnly = 'Earners Only';
  static const String filterSponsorsOnly = 'Sponsors Only';
  static const String filterEveryone = 'Everyone';
  static const String filterNearbyGps = '📍 Nearby (Current GPS)';
  static const String filterAvailableToday = 'Available Today Only';
  static const String filterAvailableTodaySubtitle =
      'Only show companions free for hangout today';
  static const String filterVerifiedOnly = 'Verified Profiles Only';
  static const String filterVerifiedOnlySubtitle =
      'Show only verified authentic alien profiles';
  static const String filterFlexibleLocation = 'Flexible Location Only';
  static const String filterFlexibleLocationSubtitle =
      'Companions open to meeting anywhere in city';

  static const String reset = 'Reset';
  static const String resetAllFilters = 'Reset All Filters';
  static const String applyPreferences = 'Apply Preferences';

  // Swiper / Discovery Empty States
  static const String noAliensMatch = 'No Aliens Match Your Filters';
  static const String noAliensMatchSubtitle =
      'Try relaxing your age range, increasing distance radius, '
      'or clearing specific filters.';
  static const String noProfilesToShow = 'No Profiles to Show';
  static const String noProfilesToShowSubtitle =
      'We don’t have any more profiles right now. Check back soon!';

  // ---------------------------------------------------------------------------
  // 4. Hangout & Booking
  // ---------------------------------------------------------------------------
  static const String selectHangoutFor = 'Select Hangout For';
  static const String selectDate = 'Select Date';
  static const String startTime = 'Start Time';
  static const String slotDuration = 'Slot Duration';
  static const String hangoutFor = 'Hangout For';
  static const String location = 'Location';
  static const String scheduleHangout = 'Schedule Hangout';
  static const String tapToChooseHangoutFor =
      'Tap to choose what to hangout for';
  static const String hoursSuffix = 'hrs';
  static const String hourSuffix = 'hr';
  static const String coinsPerHourSuffix = 'Coins / hr';

  // ---------------------------------------------------------------------------
  // 5. Matches
  // ---------------------------------------------------------------------------
  static const String matchMutuallyLiked = 'Mutually Liked';
  static const String matchMutuallySuperliked = 'Mutually Superliked';
  static const String matchLikedYou = 'Liked You';
  static const String matchSuperlikedYou = 'Superliked You';
  static const String matchYouLiked = 'You Liked';
  static const String matchYouSuperliked = 'You Superliked';
  static const String matchLikedByYou = 'Liked by You';
  static const String matchSuperlikedByYou = 'Superliked by You';
  static const String searchMatchesHint = 'Search matches...';
  static const String viewProfile = 'View Profile';
  static const String likeBack = 'Like Back';
  static const String superlike = 'Superlike';
  static const String superlikeBack = 'Superlike Back';
  static const String bookHangout = 'Book Hangout';
  static const String noMatchesFound = 'No Matches Found';
  static const String noMatchesFoundSubtitle =
      'Try searching for another companion name or tagline.';
  static const String noMatchesYet = 'No matches yet';

  // ---------------------------------------------------------------------------
  // 6. Profile & Details
  // ---------------------------------------------------------------------------
  static const String profile = 'Profile';
  static const String about = 'About';
  static const String bio = 'Bio';
  static const String basicInfo = 'Basic Info';
  static const String displayName = 'Display Name';
  static const String fullName = 'Full Name';
  static const String dateOfBirth = 'Date of Birth';
  static const String gender = 'Gender';
  static const String city = 'City';
  static const String hourlyRate = 'Hourly Rate (Coins)';
  static const String addCustomIntention = 'Add Custom';

  // ---------------------------------------------------------------------------
  // 7. Auth & Onboarding
  // ---------------------------------------------------------------------------
  static const String welcomeToMyAlien = 'Welcome to MyAlien';
  static const String enterPhoneNumber = 'Enter your phone number';
  static const String phonePlaceholder = '9876543210';
  static const String sendOtp = 'Send OTP';
  static const String sendingOtp = 'Sending OTP...';
  static const String verifyOtp = 'Verify OTP';
  static const String verifying = 'Verifying...';
  static const String enterOtpCode = 'Enter the 6-digit code sent to';
  static const String resendOtp = 'Resend OTP';
  static const String invalidPhoneError =
      'Please enter a valid 10-digit mobile number';
  static const String termsAndPrivacyNotice =
      'By continuing, you agree to our Terms of Service & Privacy Policy.';
  static const String byContinuingPrefix = 'By continuing, you agree to our ';
  static const String termsOfService = 'Terms of Service';
  static const String andSeparator = ' & ';
  static const String privacyPolicy = 'Privacy Policy';

  // ---------------------------------------------------------------------------
  // 8. Meetups & Hangouts View
  // ---------------------------------------------------------------------------
  static const String noHangoutsScheduled = 'No Hangouts Scheduled Yet';
  static const String noHangoutsScheduledSubtitle =
      'Discover friendly companions in your city and book your first coffee, '
      'dinner, or activity hangout.';
  static const String exploreCompanions = 'Explore Companions';

  // ---------------------------------------------------------------------------
  // 9. Wallet & Coins
  // ---------------------------------------------------------------------------
  static const String myWallet = 'My Wallet';
  static const String balance = 'Balance';
  static const String coins = 'Coins';
  static const String coinBalance = 'Coin Balance';
  static const String rechargeWallet = 'Recharge Wallet';
  static const String transactionHistory = 'Transaction History';

  // ---------------------------------------------------------------------------
  // 10. Settings & Notifications
  // ---------------------------------------------------------------------------
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String realtimeNotifications = 'Realtime Notifications';
  static const String markAllAsRead = 'Mark all as read';
  static const String clearAll = 'Clear all';
  static const String noNotifications = 'No Notifications Yet';
  static const String noNotificationsSubtitle =
      'You are all caught up! Realtime hangout requests, matches, and wallet coin updates will appear here.';
  static const String notificationPreferences = 'Notification Preferences';
  static const String pushNotifications = 'Push Notifications';
  static const String matchAlerts = 'Match & Like Alerts';
  static const String hangoutAlerts = 'Hangout & Meetup Reminders';
  static const String walletAlerts = 'Wallet & Coin Rewards';

  // ---------------------------------------------------------------------------
  // 11. Common & Feedback
  // ---------------------------------------------------------------------------
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String close = 'Close';
  static const String done = 'Done';
  static const String refresh = 'Refresh';
  static const String retry = 'Retry';
  static const String logOut = 'Log Out';
  static const String errorGeneric = 'Something went wrong. Please try again.';
}

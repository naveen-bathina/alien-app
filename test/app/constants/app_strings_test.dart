import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/app/constants/app_strings.dart';

void main() {
  group('AppStrings Tests', () {
    test('core constants are defined and non-empty', () {
      expect(AppStrings.appName, equals('MyAlien'));
      expect(AppStrings.navDiscover, equals('Discover'));
      expect(AppStrings.navHangouts, equals('Hangouts'));
      expect(AppStrings.navMatches, equals('Matches'));
      expect(AppStrings.navFilters, equals('Filters'));
      expect(AppStrings.navSafetyHelp, equals('Safety & Help'));
      expect(AppStrings.navEditProfile, equals('Edit Profile'));

      expect(AppStrings.discoveryPreferences, equals('Discovery Preferences'));
      expect(AppStrings.filterWhoToMeet, equals('1. Who Do You Want to Meet?'));
      expect(AppStrings.filterGender, equals('2. Interested in Gender'));
      expect(AppStrings.filterAgeRange, equals('3. Age Range'));
      expect(AppStrings.filterLocation, equals('4. Location & Nearby Distance'));
      expect(AppStrings.filterHangoutFor, equals('5. Hangout For'));
      expect(AppStrings.filterAvailabilitySafety, equals('7. Availability & Safety'));

      expect(AppStrings.selectHangoutFor, equals('Select Hangout For'));
      expect(AppStrings.selectDate, equals('Select Date'));
      expect(AppStrings.startTime, equals('Start Time'));
      expect(AppStrings.slotDuration, equals('Slot Duration'));
      expect(AppStrings.hangoutFor, equals('Hangout For'));
      expect(AppStrings.location, equals('Location'));

      expect(AppStrings.matchMutuallyLiked, equals('Mutually Liked'));
      expect(AppStrings.matchMutuallySuperliked, equals('Mutually Superliked'));
      expect(AppStrings.matchLikedYou, equals('Liked You'));
      expect(AppStrings.matchSuperlikedYou, equals('Superliked You'));
      expect(AppStrings.matchYouLiked, equals('You Liked'));
      expect(AppStrings.matchYouSuperliked, equals('You Superliked'));
      expect(AppStrings.viewProfile, equals('View Profile'));
      expect(AppStrings.searchMatchesHint, equals('Search matches...'));
    });

    test('supports dynamic runtime configuration overrides', () {
      // Clear initially
      AppStrings.clearOverrides();

      expect(AppStrings.get('appName', AppStrings.appName), equals('MyAlien'));

      // Apply runtime override
      AppStrings.configure({'appName': 'MyAlien Partner'});
      expect(
        AppStrings.get('appName', AppStrings.appName),
        equals('MyAlien Partner'),
      );

      // Clean up
      AppStrings.clearOverrides();
      expect(AppStrings.get('appName', AppStrings.appName), equals('MyAlien'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myalien/discover/view/discovery_filter_sheet.dart';
import 'package:myalien/home/view/app_drawer.dart';
import 'package:myalien/home/view/home_screen.dart';
import 'package:myalien/matches/view/matches_view.dart';
import 'package:myalien/meetups/view/meetups_view.dart';
import 'package:myalien/models/profile_model.dart';
import 'package:myalien/profile/repository/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group('HomeScreen & Drawer Navigation Tests', () {
    late MockProfileRepository repo;
    late Profile testProfile;

    setUp(() {
      repo = MockProfileRepository();
      testProfile = Profile(
        uid: 'user_123',
        name: 'Naveen Kumar',
        displayName: 'Naveen Kumar',
        gender: 'Man',
        location: 'Hyderabad, Jubilee Hills',
        role: 'Earner',
        photos: const [],
      );
    });

    testWidgets('HomeScreen starts on Discover when initialIndex is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(initialIndex: 0),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Discover'), findsWidgets);
    });

    testWidgets('HomeScreen starts on Hangouts when initialIndex is 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(initialIndex: 1),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MeetupsView), findsOneWidget);
    });

    testWidgets('HomeScreen starts on Matches when initialIndex is 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(initialIndex: 2),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MatchesView), findsOneWidget);
    });

    testWidgets('HomeScreen opens DiscoveryFilterSheet when openFilterSheet is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(initialIndex: 0, openFilterSheet: true),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DiscoveryFilterSheet), findsOneWidget);
      expect(find.text('Discovery Preferences'), findsOneWidget);
    });

    testWidgets('AppDrawer on HomeScreen switches tabs on tapping Hangouts and Matches', (tester) async {
      int? selectedTab;
      bool filtersOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              currentTabIndex: 0,
              onSelectTab: (idx) => selectedTab = idx,
              onOpenFilters: () => filtersOpened = true,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));

      // Test Hangouts tap
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Hangouts'));
      await tester.pumpAndSettle();
      expect(selectedTab, 1);

      // Test Matches tap
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Matches'));
      await tester.pumpAndSettle();
      expect(selectedTab, 2);

      // Test Filters tap
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Filters'));
      await tester.pumpAndSettle();
      expect(filtersOpened, isTrue);
    });

    testWidgets('AppDrawer from subscreen (null onSelectTab) navigates to HomeScreen on tapping Discover, Hangouts, Matches', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              activeItem: AppDrawerItem.profile,
            ),
            body: const Text('Subscreen Body'),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));

      // Open drawer on subscreen and tap Hangouts
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Hangouts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifies it navigated to HomeScreen with Hangouts
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(MeetupsView), findsOneWidget);
    });

    testWidgets('AppDrawer from subscreen navigates to HomeScreen with Filters open on tapping Filters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              activeItem: AppDrawerItem.wallet,
            ),
            body: const Text('Wallet Body'),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));

      // Open drawer on wallet subscreen and tap Filters
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Filters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifies it navigated to HomeScreen and opened DiscoveryFilterSheet
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(DiscoveryFilterSheet), findsOneWidget);
    });

    testWidgets('HomeScreen action bar displays Refresh Icon and removes PopupMenuButton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(initialIndex: 0),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify PopupMenuButton and more_vert icon are removed
      expect(find.byIcon(Icons.more_vert_rounded), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);

      // Verify Refresh icon is present in the action bar
      final refreshButton = find.byIcon(Icons.refresh_rounded);
      expect(refreshButton, findsOneWidget);

      // Verify tapping refresh icon executes cleanly
      await tester.tap(refreshButton);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

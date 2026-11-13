import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myalien/home/view/app_drawer.dart';
import 'package:myalien/home/view/community_safety_sheet.dart';
import 'package:myalien/models/profile_model.dart';
import 'package:myalien/profile/repository/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group('AppDrawer Widget Tests', () {
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

    testWidgets('renders logged-in user profile details (name, role, location)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check user details in drawer header
      expect(find.text('Naveen Kumar'), findsOneWidget);
      expect(find.text('Earner'), findsOneWidget);
      expect(find.text('Hyderabad, Jubilee Hills'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('renders Safety & Help tile and opens safety sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final safetyTileFinder = find.text('Safety & Help');
      expect(safetyTileFinder, findsOneWidget);

      await tester.tap(safetyTileFinder);
      await tester.pumpAndSettle();

      // Check safety sheet is opened
      expect(find.byType(CommunitySafetySheet), findsOneWidget);
      expect(find.text('Community Safety & Trust'), findsOneWidget);
      expect(find.text('4 Golden Rules for Meetups'), findsOneWidget);
      expect(find.text('Emergency SOS: 112'), findsOneWidget);
    });

    testWidgets('renders Profile, Wallet without coin badge, and Settings tiles', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              activeItem: AppDrawerItem.discover,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check Profile tile is renamed from "View & Edit Profile" to "Profile"
      expect(find.text('View & Edit Profile'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Profile'), findsOneWidget);

      // Check Wallet tile is renamed from "Wallet Balance" to "Wallet"
      expect(find.text('Wallet Balance'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Wallet'), findsOneWidget);

      // Check no coins badge in Wallet tile
      expect(find.textContaining('250 Coins'), findsNothing);

      // Check Settings tile exists
      expect(find.widgetWithText(ListTile, 'Settings'), findsOneWidget);

      // Verify unselected states on Discover
      final profileTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Profile'));
      expect(profileTile.selected, isFalse);

      final walletTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Wallet'));
      expect(walletTile.selected, isFalse);

      final settingsTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Settings'));
      expect(settingsTile.selected, isFalse);

      final safetyTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Safety & Help'));
      expect(safetyTile.selected, isFalse);
    });

    testWidgets('highlights Profile only when activeItem is profile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              activeItem: AppDrawerItem.profile,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final profileTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Profile'));
      expect(profileTile.selected, isTrue);

      final walletTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Wallet'));
      expect(walletTile.selected, isFalse);
    });

    testWidgets('highlights Wallet only when activeItem is wallet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              activeItem: AppDrawerItem.wallet,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final walletTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Wallet'));
      expect(walletTile.selected, isTrue);

      final profileTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Profile'));
      expect(profileTile.selected, isFalse);
    });

    testWidgets('highlights Settings only when activeItem is settings', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              initialProfile: testProfile,
              profileRepo: repo,
              activeItem: AppDrawerItem.settings,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final settingsTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Settings'));
      expect(settingsTile.selected, isTrue);
    });
  });
}

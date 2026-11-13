import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';
import 'package:myalien/wallet/view/buy_coins_sheet.dart';
import 'package:myalien/wallet/view/redeem_coins_sheet.dart';
import 'package:myalien/wallet/view/wallet_screen.dart';

void main() {
  group('WalletScreen Tests', () {
    setUp(() {
      walletRepository.setBalancesForTesting(
        available: 350,
        escrow: 100,
        lifetime: 2450,
        monthly: 680,
        hangoutsCount: 4,
      );
    });

    testWidgets('renders balance cards, companion earnings, and quick top up',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Coin Balance'), findsOneWidget);
      expect(find.text('450'), findsOneWidget); // 350 + 100
      expect(find.text('🪙 350 Coins'), findsOneWidget);
      expect(find.text('🪙 100 Coins'), findsOneWidget);

      // Companion Earnings Section
      expect(find.text('Companion Earnings'), findsOneWidget);
      expect(find.text('🪙 2450'), findsOneWidget);
      expect(find.text('🪙 680'), findsOneWidget);
      expect(find.text('4 hangouts completed'), findsOneWidget);

      // Actions
      expect(find.text('Buy Coins'), findsOneWidget);
      expect(find.text('Redeem'), findsOneWidget);
      expect(find.text('Quick Coin Top-Up'), findsOneWidget);

      // Active Subscribed Packs
      expect(find.text('Active & Subscribed Packs'), findsOneWidget);
      expect(find.text('Alien Companion VIP Pass'), findsOneWidget);
      expect(find.text('ACTIVE VIP'), findsOneWidget);
    });

    testWidgets('tapping View All Statements opens TransactionHistoryScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('View All Statements'), findsOneWidget);
      await tester.tap(find.text('View All Statements'));
      await tester.pumpAndSettle();

      expect(find.text('Transactions & Statement'), findsOneWidget);
    });

    testWidgets('tapping Buy Coins opens BuyCoinsSheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buy Coins'));
      await tester.pumpAndSettle();

      expect(find.byType(BuyCoinsSheet), findsOneWidget);
      expect(find.text('Select Pack'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(BuyCoinsSheet), findsNothing);
    });

    testWidgets('tapping Redeem opens RedeemCoinsSheet with Cash-Out & Perks',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Redeem'));
      await tester.pumpAndSettle();

      expect(find.byType(RedeemCoinsSheet), findsOneWidget);
      expect(find.text('💰 Cash-Out Earnings'), findsOneWidget);
      expect(find.text('⚡ Alien In-App Perks'), findsOneWidget);
      expect(find.textContaining('1 Alien Coin = ₹1'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(RedeemCoinsSheet), findsNothing);
    });
  });
}

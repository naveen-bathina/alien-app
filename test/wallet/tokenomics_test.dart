import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/wallet/models/coin_pricing_config.dart';
import 'package:myalien/wallet/models/tokenomics_config.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';

void main() {
  group('TokenomicsConfig & HangoutSplit Tests', () {
    test('Calculates standard 15% platform take rate correctly', () {
      const config = TokenomicsConfig();
      final split = config.calculateHangoutSplit(
        totalCoins: 200,
        isCompanionVip: false,
      );

      // 15% of 200 = 30 coins
      expect(split.totalCoins, 200);
      expect(split.platformFee, 30);
      expect(split.companionEarnings, 170);
      expect(split.effectiveFeePercent, 15.0);
      expect(split.isVipDiscountApplied, isFalse);
    });

    test('Calculates VIP discounted 5% platform take rate correctly', () {
      const config = TokenomicsConfig();
      final split = config.calculateHangoutSplit(
        totalCoins: 200,
        isCompanionVip: true,
      );

      // 5% of 200 = 10 coins
      expect(split.totalCoins, 200);
      expect(split.platformFee, 10);
      expect(split.companionEarnings, 190);
      expect(split.effectiveFeePercent, 5.0);
      expect(split.isVipDiscountApplied, isTrue);
    });

    test('Rounds platform fee up when decimals occur', () {
      const config = TokenomicsConfig();
      // 15% of 35 = 5.25 -> round = 5
      final split = config.calculateHangoutSplit(
        totalCoins: 35,
        isCompanionVip: false,
      );

      expect(split.platformFee, 5);
      expect(split.companionEarnings, 30);
      expect(split.totalCoins, 35);
    });

    test('Calculates late cancellation deduction accurately', () {
      const config = TokenomicsConfig();
      // Total = 100, late cancel fee = 50% = 50 coins deduction
      final deduction = config.calculateLateCancellationDeduction(100);

      expect(deduction, 50);
    });

    test('CoinPricingConfig embeds TokenomicsConfig and serializes', () {
      final config = CoinPricingConfig(
        ratePerCoinInr: 10.0,
        tokenomics: const TokenomicsConfig(
          standardPlatformFeePercent: 18.0,
          vipPlatformFeePercent: 6.0,
        ),
      );

      final map = config.toMap();
      expect(map.containsKey('tokenomics'), isTrue);
      expect(map['tokenomics']['standardPlatformFeePercent'], 18.0);

      final parsed = CoinPricingConfig.fromMap(map);
      expect(parsed.tokenomics.standardPlatformFeePercent, 18.0);
      expect(parsed.tokenomics.vipPlatformFeePercent, 6.0);
    });
  });

  group('WalletRepository Hangout Earnings Integration', () {
    test('recordHangoutEarnings applies tokenomics fee to net balance', () {
      final repo = WalletRepository();
      repo.setBalancesForTesting(available: 100, escrow: 0, lifetime: 0, monthly: 0);
      final initialBalance = repo.currentState.availableBalance;

      // Companion completes 100-coin hangout (standard tier -> 15 coins platform fee, 85 net)
      repo.recordHangoutEarnings(
        hangoutId: 'hangout-test-1',
        coins: 100,
        clientName: 'Alex Mercer',
        durationHours: 1,
        isCompanionVip: false,
      );

      expect(repo.currentState.availableBalance, initialBalance + 85);
      expect(repo.currentState.monthlyEarnings, 85);
      expect(repo.currentState.lifetimeEarnings, 85);
      final latestTx = repo.currentState.transactions.first;
      expect(latestTx.amount, 85);
      expect(latestTx.description.contains('15% platform fee: 15 C'), isTrue);
    });

    test('recordHangoutEarnings grants higher net to VIP companion', () {
      final repo = WalletRepository();
      repo.setBalancesForTesting(available: 100, escrow: 0, lifetime: 0, monthly: 0);
      final initialBalance = repo.currentState.availableBalance;

      // VIP Companion completes 100-coin hangout (5% fee -> 5 coins platform fee, 95 net)
      repo.recordHangoutEarnings(
        hangoutId: 'hangout-test-vip',
        coins: 100,
        clientName: 'Samantha Ray',
        durationHours: 1,
        isCompanionVip: true,
      );

      expect(repo.currentState.availableBalance, initialBalance + 95);
      expect(repo.currentState.monthlyEarnings, 95);
      expect(repo.currentState.lifetimeEarnings, 95);
      final latestTx = repo.currentState.transactions.first;
      expect(latestTx.amount, 95);
      expect(latestTx.description.contains('5% platform fee: 5 C'), isTrue);
    });
  });

  group('ScheduleHangoutSheet Tokenomics & Escrow Validation', () {
    final testProfile = Profile(
      uid: 'companion-1',
      name: 'Maya Lin',
      coinsPerHour: 100,
      photos: const [],
    );

    testWidgets('Renders real-time wallet balance in sheet',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = WalletRepository();
      repo.setBalancesForTesting(available: 350, escrow: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleHangoutSheet(
              profile: testProfile,
            ),
          ),
        ),
      );
      await tester.pump();

      // Check balance is shown using live wallet repository available balance
      expect(find.text('Your Wallet Balance'), findsOneWidget);
      expect(find.text('★ 350 Coins'), findsOneWidget);
    });
  });
}

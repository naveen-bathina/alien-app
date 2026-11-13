import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/wallet/models/coin_pricing_config.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';
import 'package:myalien/wallet/view/buy_coins_sheet.dart';
import 'package:myalien/wallet/view/redeem_coins_sheet.dart';
import 'package:myalien/wallet/view/wallet_screen.dart';

void main() {
  group('Dynamic Coin Pricing Tests', () {
    late WalletRepository repo;

    setUp(() {
      repo = WalletRepository();
      repo.clearTransactionsForTesting();
    });

    test('CoinPricingConfig calculates conversions accurately', () {
      const config = CoinPricingConfig(ratePerCoinInr: 1.5, currencySymbol: '₹');
      expect(config.coinsToFiat(100), equals(150.0));
      expect(config.formatCoinsInFiat(100), equals('₹150'));

      const floatConfig = CoinPricingConfig(ratePerCoinInr: 1.25, currencySymbol: '₹');
      expect(floatConfig.coinsToFiat(50), equals(62.5));
      expect(floatConfig.formatCoinsInFiat(50), equals('₹62.50'));
    });

    test('updateCoinPricingConfig changes state and persists rate in payouts', () async {
      repo.setBalancesForTesting(available: 500, escrow: 0);

      // Change rate to 1 Coin = ₹1.5
      await repo.updateCoinPricingConfig(
        const CoinPricingConfig(
          ratePerCoinInr: 1.5,
          minRedemptionCoins: 50,
          purchasePacks: [
            CoinPackConfig(coins: 100, priceInr: 120),
            CoinPackConfig(coins: 300, priceInr: 320),
          ],
        ),
      );

      final state = repo.currentState;
      expect(state.coinConfig.ratePerCoinInr, equals(1.5));
      expect(state.coinConfig.purchasePacks.length, equals(2));

      // Request payout with new conversion rate
      final success = await repo.requestPayout(
        coins: 100,
        upiIdOrAccount: 'alex@upi',
        beneficiaryName: 'Alex',
      );

      expect(success, isTrue);
      final tx = repo.currentState.transactions.first;
      expect(tx.amount, equals(100));
      expect(tx.rateAtTransaction, equals(1.5));
      expect(tx.fiatAmount, equals(150.0));
      expect(tx.description, contains('₹150'));
    });

    testWidgets('RedeemCoinsSheet renders dynamic coin conversion banner',
        (tester) async {
      walletRepository.setBalancesForTesting(
        available: 400,
        escrow: 50,
        coinConfig: const CoinPricingConfig(ratePerCoinInr: 1.5),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RedeemCoinsSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('1 Alien Coin = ₹1.50'), findsOneWidget);
    });

    testWidgets('BuyCoinsSheet renders dynamic purchase packs from config',
        (tester) async {
      walletRepository.setBalancesForTesting(
        available: 100,
        escrow: 0,
        coinConfig: const CoinPricingConfig(
          purchasePacks: [
            CoinPackConfig(coins: 150, priceInr: 140, bonus: '+10 Free'),
            CoinPackConfig(coins: 400, priceInr: 350),
          ],
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BuyCoinsSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🪙 150 Coins'), findsOneWidget);
      expect(find.text('₹140'), findsOneWidget);
      expect(find.text('+10 Free'), findsOneWidget);

      expect(find.text('🪙 400 Coins'), findsOneWidget);
      expect(find.text('₹350'), findsOneWidget);
    });
  });
}

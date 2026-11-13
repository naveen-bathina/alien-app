import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/wallet/models/wallet_transaction.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';

void main() {
  group('WalletRepository Tests', () {
    late WalletRepository repo;

    setUp(() {
      repo = WalletRepository();
    });

    test('initial state contains seeded balances and transactions', () {
      final state = repo.currentState;
      expect(state.availableBalance, equals(350));
      expect(state.escrowBalance, equals(100));
      expect(state.totalBalance, equals(450));
      expect(state.lifetimeEarnings, equals(2450));
      expect(state.monthlyEarnings, equals(680));
      expect(state.completedHangoutsCount, equals(4));
      expect(state.transactions.isNotEmpty, isTrue);
    });

    test('buyCoins increases available balance and logs top-up transaction', () async {
      final initialAvailable = repo.currentState.availableBalance;
      await repo.buyCoins(100, price: '₹99', paymentMethod: 'UPI');

      final updated = repo.currentState;
      expect(updated.availableBalance, equals(initialAvailable + 100));
      expect(updated.transactions.first.category, equals(WalletTransactionCategory.topUp));
      expect(updated.transactions.first.amount, equals(100));
      expect(updated.transactions.first.isCredit, isTrue);
    });

    test('requestPayout validates balance, deducts available, and records pending payout', () async {
      repo.setBalancesForTesting(available: 200, escrow: 50);

      // Attempt to withdraw more than available
      final failedResult = await repo.requestPayout(
        coins: 300,
        upiIdOrAccount: 'test@upi',
        beneficiaryName: 'Alex',
      );
      expect(failedResult, isFalse);

      // Successful withdrawal
      final successResult = await repo.requestPayout(
        coins: 100,
        upiIdOrAccount: 'test@upi',
        beneficiaryName: 'Alex',
      );
      expect(successResult, isTrue);

      final state = repo.currentState;
      expect(state.availableBalance, equals(100));
      expect(state.transactions.first.category, equals(WalletTransactionCategory.payout));
      expect(state.transactions.first.status, equals(WalletTransactionStatus.pendingPayout));
      expect(state.transactions.first.amount, equals(100));
    });

    test('recordHangoutEarnings increases available, lifetime, and monthly earnings', () {
      repo.setBalancesForTesting(
        available: 100,
        escrow: 50,
        lifetime: 1000,
        monthly: 300,
        hangoutsCount: 2,
      );

      repo.recordHangoutEarnings(
        hangoutId: 'h_123',
        clientName: 'Priya Sharma',
        coins: 160,
        durationHours: 2,
      );

      final state = repo.currentState;
      // 160 coins minus 15% platform take-rate (24 coins) = 136 coins net companion earnings
      expect(state.availableBalance, equals(236));
      expect(state.lifetimeEarnings, equals(1136));
      expect(state.monthlyEarnings, equals(436));
      expect(state.completedHangoutsCount, equals(3));
      expect(state.transactions.first.category, equals(WalletTransactionCategory.earning));
      expect(state.transactions.first.status, equals(WalletTransactionStatus.settled));
      expect(state.transactions.first.hangoutClientName, equals('Priya Sharma'));
    });

    test('lockEscrow locks available coins into escrow balance', () {
      repo.setBalancesForTesting(available: 300, escrow: 50);

      repo.lockEscrow('hangout_456', 150, 'Rahul');

      final state = repo.currentState;
      expect(state.availableBalance, equals(150));
      expect(state.escrowBalance, equals(200));
      expect(state.totalBalance, equals(350));
      expect(state.transactions.first.category, equals(WalletTransactionCategory.escrowLock));
    });

    test('releaseEscrow releases escrow coins back to available balance', () {
      repo.setBalancesForTesting(available: 150, escrow: 200);

      repo.releaseEscrow('hangout_456', 100);

      final state = repo.currentState;
      expect(state.availableBalance, equals(250));
      expect(state.escrowBalance, equals(100));
      expect(state.transactions.first.category, equals(WalletTransactionCategory.escrowRelease));
    });
  });
}

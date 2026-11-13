import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/wallet/models/subscribed_pack.dart';
import 'package:myalien/wallet/models/wallet_transaction.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';
import 'package:myalien/wallet/view/transaction_history_screen.dart';

void main() {
  group('TransactionHistoryScreen Tests', () {
    setUp(() {
      walletRepository.clearTransactionsForTesting();
      final now = DateTime.now();

      walletRepository.buyCoins(100, price: '₹99');
      walletRepository.recordHangoutEarnings(
        hangoutId: 'h_1',
        clientName: 'Priya Sharma',
        coins: 160,
        durationHours: 2,
      );
    });

    testWidgets('renders search, timeframe filters, and transaction entries',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transactions & Statement'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Earnings 💰'), findsOneWidget);

      expect(find.text('Hangout with Priya Sharma'), findsOneWidget);
      // Net after 15% platform take-rate is 136 Coins
      expect(find.text('+136 Coins'), findsOneWidget);
      expect(find.text('+100 Coins'), findsOneWidget);
    });

    testWidgets('filtering by category displays only matching items',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Earnings 💰'));
      await tester.pumpAndSettle();

      expect(find.text('Hangout with Priya Sharma'), findsOneWidget);
      expect(find.text('Coin Top-up (₹99)'), findsNothing);
    });

    testWidgets('search filters entries by client name query',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Priya',
      );
      await tester.pumpAndSettle();

      expect(find.text('Hangout with Priya Sharma'), findsOneWidget);
      expect(find.text('Coin Top-up (₹99)'), findsNothing);
    });
  });
}

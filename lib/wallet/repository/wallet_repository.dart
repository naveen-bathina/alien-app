import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myalien/wallet/models/coin_pricing_config.dart';
import 'package:myalien/wallet/models/subscribed_pack.dart';
import 'package:myalien/wallet/models/wallet_transaction.dart';

class WalletStateData {
  const WalletStateData({
    required this.availableBalance,
    required this.escrowBalance,
    required this.lifetimeEarnings,
    required this.monthlyEarnings,
    required this.completedHangoutsCount,
    required this.transactions,
    required this.activePacks,
    required this.coinConfig,
  });

  final int availableBalance;
  final int escrowBalance;
  final int lifetimeEarnings;
  final int monthlyEarnings;
  final int completedHangoutsCount;
  final List<WalletTransaction> transactions;
  final List<SubscribedPack> activePacks;
  final CoinPricingConfig coinConfig;

  int get totalBalance => availableBalance + escrowBalance;
}

class WalletRepository {
  WalletRepository({FirebaseFirestore? firestore}) : _firestore = firestore {
    _initCoinPricingListener();
    _seedInitialState();
  }

  final FirebaseFirestore? _firestore;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _pricingSubscription;

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  int _availableBalance = 350;
  int _escrowBalance = 100;
  int _lifetimeEarnings = 2450;
  int _monthlyEarnings = 680;
  int _completedHangoutsCount = 4;
  final List<WalletTransaction> _transactions = [];
  final List<SubscribedPack> _activePacks = [];
  CoinPricingConfig _coinConfig = const CoinPricingConfig();

  final StreamController<WalletStateData> _controller =
      StreamController<WalletStateData>.broadcast();

  Stream<WalletStateData> get walletStream => _controller.stream;

  WalletStateData get currentState => WalletStateData(
        availableBalance: _availableBalance,
        escrowBalance: _escrowBalance,
        lifetimeEarnings: _lifetimeEarnings,
        monthlyEarnings: _monthlyEarnings,
        completedHangoutsCount: _completedHangoutsCount,
        transactions: List.unmodifiable(_transactions),
        activePacks: List.unmodifiable(_activePacks),
        coinConfig: _coinConfig,
      );

  CoinPricingConfig get coinConfig => _coinConfig;

  void _initCoinPricingListener() {
    try {
      final fs = firestore;
      if (fs != null) {
        _pricingSubscription = fs
            .collection('config')
            .doc('coin_pricing')
            .snapshots()
            .listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              _coinConfig = CoinPricingConfig.fromMap(snapshot.data()!);
              _emit();
            }
          },
          onError: (Object error) {
            debugPrint('Firestore coin_pricing sync notice: $error');
          },
        );
      }
    } on Object catch (e) {
      debugPrint('Firestore coin_pricing init notice: $e');
    }
  }

  void dispose() {
    _pricingSubscription?.cancel();
  }

  void _seedInitialState() {
    final now = DateTime.now();
    _transactions.addAll([
      WalletTransaction(
        id: 'tx_seed_1',
        title: 'Hangout with Kunal Sen',
        description: 'Completed 3 hrs hangout at Gallery Cafe',
        timestamp: now.subtract(const Duration(hours: 4)),
        amount: 240,
        isCredit: true,
        category: WalletTransactionCategory.earning,
        status: WalletTransactionStatus.settled,
        hangoutClientName: 'Kunal Sen',
        hangoutHours: 3,
      ),
      WalletTransaction(
        id: 'tx_seed_2',
        title: 'Escrow Locked for Hangout',
        description: 'Reserved for upcoming hangout with Maya Rao',
        timestamp: now.subtract(const Duration(days: 1)),
        amount: 100,
        isCredit: false,
        category: WalletTransactionCategory.escrowLock,
        status: WalletTransactionStatus.lockedInEscrow,
      ),
      WalletTransaction(
        id: 'tx_seed_3',
        title: 'Earnings Payout to UPI',
        description: 'Transferred to maya@okhdfc',
        timestamp: now.subtract(const Duration(days: 2)),
        amount: 500,
        isCredit: false,
        category: WalletTransactionCategory.payout,
        status: WalletTransactionStatus.completed,
        payoutUpiOrAccount: 'maya@okhdfc',
      ),
      WalletTransaction(
        id: 'tx_seed_4',
        title: 'Hangout with Aarav Patel',
        description: 'Completed 2 hrs hangout at Roastery Coffee',
        timestamp: now.subtract(const Duration(days: 3)),
        amount: 160,
        isCredit: true,
        category: WalletTransactionCategory.earning,
        status: WalletTransactionStatus.settled,
        hangoutClientName: 'Aarav Patel',
        hangoutHours: 2,
      ),
      WalletTransaction(
        id: 'tx_seed_5',
        title: 'Coin Top-up via UPI',
        description: 'Purchased 250 Alien Coins pack',
        timestamp: now.subtract(const Duration(days: 5)),
        amount: 250,
        isCredit: true,
        category: WalletTransactionCategory.topUp,
        status: WalletTransactionStatus.completed,
      ),
    ]);

    _activePacks.addAll([
      SubscribedPack(
        id: 'pack_sub_1',
        name: 'Alien Companion VIP Pass',
        price: '₹299/mo',
        renewalOrExpiryDate: now.add(const Duration(days: 18)),
        benefits: const [
          '500 Monthly Coins added',
          'Priority profile listing in Discover',
          '0% platform commission on payouts',
          'Unlimited Rewinds',
        ],
        coinsAllocated: 500,
        badge: 'ACTIVE VIP',
      ),
      SubscribedPack(
        id: 'pack_sub_2',
        name: '24h Profile Spotlight Booster',
        price: '20 Coins',
        renewalOrExpiryDate: now.add(const Duration(hours: 14)),
        isAutoRenew: false,
        status: SubscribedPackStatus.active,
        billingCycle: PackBillingCycle.oneTime,
        benefits: const [
          '5x more views in your area',
          'Highlighted card border in discover feed',
        ],
        badge: 'BOOSTER ACTIVE',
      ),
    ]);

    _emit();
  }

  void _emit() {
    _controller.add(currentState);
  }

  /// Top-up Alien Coins
  Future<void> buyCoins(
    int coins, {
    required String price,
    String paymentMethod = 'UPI',
    double? fiatAmount,
  }) async {
    _availableBalance += coins;
    final currentRate = _coinConfig.ratePerCoinInr;
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Coin Top-up ($price)',
      description: 'Added $coins coins via $paymentMethod',
      timestamp: DateTime.now(),
      amount: coins,
      isCredit: true,
      category: WalletTransactionCategory.topUp,
      status: WalletTransactionStatus.completed,
      rateAtTransaction: currentRate,
      fiatAmount: fiatAmount,
    );
    _transactions.insert(0, tx);
    _emit();

    try {
      await firestore?.collection('wallet_transactions').doc(tx.id).set(tx.toMap());
    } on Object catch (e) {
      debugPrint('Firestore save wallet tx notice: $e');
    }
  }

  /// Request cash-out payout to UPI or Bank Account
  Future<bool> requestPayout({
    required int coins,
    required String upiIdOrAccount,
    required String beneficiaryName,
  }) async {
    if (coins <= 0 || coins > _availableBalance) {
      return false;
    }

    _availableBalance -= coins;
    final currentRate = _coinConfig.ratePerCoinInr;
    final inrAmount = coins * currentRate;

    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Earnings Payout to $beneficiaryName',
      description:
          'Redeemed ₹${inrAmount.toStringAsFixed(inrAmount % 1 == 0 ? 0 : 2)} to $upiIdOrAccount',
      timestamp: DateTime.now(),
      amount: coins,
      isCredit: false,
      category: WalletTransactionCategory.payout,
      status: WalletTransactionStatus.pendingPayout,
      payoutUpiOrAccount: upiIdOrAccount,
      rateAtTransaction: currentRate,
      fiatAmount: inrAmount,
    );
    _transactions.insert(0, tx);
    _emit();

    try {
      await firestore?.collection('wallet_transactions').doc(tx.id).set(tx.toMap());
    } on Object catch (e) {
      debugPrint('Firestore save payout tx notice: $e');
    }
    return true;
  }

  /// Redeem an in-app digital perk
  Future<bool> redeemPerk(String perkTitle, int coinCost) async {
    if (coinCost > _availableBalance) {
      return false;
    }

    _availableBalance -= coinCost;
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Perk: $perkTitle',
      description: 'Activated $perkTitle in-app perk',
      timestamp: DateTime.now(),
      amount: coinCost,
      isCredit: false,
      category: WalletTransactionCategory.perk,
      status: WalletTransactionStatus.completed,
    );
    _transactions.insert(0, tx);
    _emit();

    return true;
  }

  /// Record companion hangout earnings when hangout completes with Tokenomics fee split
  void recordHangoutEarnings({
    required String hangoutId,
    required String clientName,
    required int coins,
    required int durationHours,
    bool isCompanionVip = false,
  }) {
    final split = _coinConfig.tokenomics.calculateHangoutSplit(
      totalCoins: coins,
      isCompanionVip: isCompanionVip,
    );
    final netEarnings = split.companionEarnings;

    _availableBalance += netEarnings;
    _lifetimeEarnings += netEarnings;
    _monthlyEarnings += netEarnings;
    _completedHangoutsCount += 1;

    final feeNote = split.platformFee > 0
        ? ' (Net after ${split.effectiveFeePercent.toInt()}% platform fee: ${split.platformFee} C)'
        : '';

    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Hangout with $clientName',
      description: 'Completed $durationHours hrs meetup$feeNote',
      timestamp: DateTime.now(),
      amount: netEarnings,
      isCredit: true,
      category: WalletTransactionCategory.earning,
      status: WalletTransactionStatus.settled,
      hangoutClientName: clientName,
      hangoutHours: durationHours,
      rateAtTransaction: _coinConfig.ratePerCoinInr,
      fiatAmount: netEarnings * _coinConfig.ratePerCoinInr,
    );
    _transactions.insert(0, tx);
    _emit();
  }

  /// Lock coins into escrow for a booked hangout
  void lockEscrow(String hangoutId, int amount, String companionName) {
    if (amount <= _availableBalance) {
      _availableBalance -= amount;
      _escrowBalance += amount;
      final tx = WalletTransaction(
        id: 'tx_escrow_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Escrow Locked: Hangout',
        description: 'Reserved for meetup with $companionName',
        timestamp: DateTime.now(),
        amount: amount,
        isCredit: false,
        category: WalletTransactionCategory.escrowLock,
        status: WalletTransactionStatus.lockedInEscrow,
      );
      _transactions.insert(0, tx);
      _emit();
    }
  }

  /// Release escrow back to available (e.g. if cancelled)
  void releaseEscrow(String hangoutId, int amount) {
    if (_escrowBalance >= amount) {
      _escrowBalance -= amount;
      _availableBalance += amount;
      final tx = WalletTransaction(
        id: 'tx_release_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Escrow Released',
        description: 'Refunded for cancelled reservation',
        timestamp: DateTime.now(),
        amount: amount,
        isCredit: true,
        category: WalletTransactionCategory.escrowRelease,
        status: WalletTransactionStatus.refunded,
      );
      _transactions.insert(0, tx);
      _emit();
    }
  }

  /// Fetch transactions with network/query bounds (reducing load)
  List<WalletTransaction> getFilteredTransactions({
    WalletTransactionCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var result = _transactions.where((tx) {
      if (category != null && tx.category != category) return false;
      if (startDate != null && tx.timestamp.isBefore(startDate)) return false;
      if (endDate != null && tx.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (limit != null && result.length > limit) {
      result = result.sublist(0, limit);
    }
    return result;
  }

  /// Update dynamic coin pricing config and persist to Firestore
  Future<void> updateCoinPricingConfig(CoinPricingConfig newConfig) async {
    _coinConfig = newConfig;
    _emit();

    try {
      await firestore
          ?.collection('config')
          .doc('coin_pricing')
          .set(newConfig.toMap());
    } on Object catch (e) {
      debugPrint('Firestore update coin pricing notice: $e');
    }
  }

  /// Reset or set values for unit tests
  void setBalancesForTesting({
    required int available,
    required int escrow,
    int? lifetime,
    int? monthly,
    int? hangoutsCount,
    List<SubscribedPack>? activePacks,
    CoinPricingConfig? coinConfig,
  }) {
    _availableBalance = available;
    _escrowBalance = escrow;
    if (lifetime != null) _lifetimeEarnings = lifetime;
    if (monthly != null) _monthlyEarnings = monthly;
    if (hangoutsCount != null) _completedHangoutsCount = hangoutsCount;
    if (activePacks != null) {
      _activePacks.clear();
      _activePacks.addAll(activePacks);
    }
    if (coinConfig != null) {
      _coinConfig = coinConfig;
    }
    _emit();
  }

  void clearTransactionsForTesting() {
    _transactions.clear();
    _emit();
  }
}

final walletRepository = WalletRepository();

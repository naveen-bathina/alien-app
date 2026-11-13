import 'package:myalien/wallet/models/tokenomics_config.dart';

class CoinPackConfig {
  const CoinPackConfig({
    required this.coins,
    required this.priceInr,
    this.bonus,
  });

  factory CoinPackConfig.fromMap(Map<String, dynamic> map) {
    return CoinPackConfig(
      coins: map['coins'] as int? ?? 100,
      priceInr: (map['priceInr'] as num?)?.toDouble() ?? 99.0,
      bonus: map['bonus'] as String?,
    );
  }

  final int coins;
  final double priceInr;
  final String? bonus;

  String get formattedPrice => '₹${priceInr.toStringAsFixed(priceInr % 1 == 0 ? 0 : 2)}';

  Map<String, dynamic> toMap() {
    return {
      'coins': coins,
      'priceInr': priceInr,
      'bonus': bonus,
    };
  }
}

class CoinPricingConfig {
  const CoinPricingConfig({
    this.ratePerCoinInr = 1.0,
    this.minRedemptionCoins = 50,
    this.currencySymbol = '₹',
    this.purchasePacks = defaultPacks,
    this.tokenomics = const TokenomicsConfig(),
    this.updatedAt,
  });

  factory CoinPricingConfig.fromMap(Map<String, dynamic> map) {
    return CoinPricingConfig(
      ratePerCoinInr: (map['ratePerCoinInr'] as num?)?.toDouble() ?? 1.0,
      minRedemptionCoins: map['minRedemptionCoins'] as int? ?? 50,
      currencySymbol: map['currencySymbol'] as String? ?? '₹',
      tokenomics: map['tokenomics'] is Map
          ? TokenomicsConfig.fromMap(
              Map<String, dynamic>.from(map['tokenomics'] as Map),
            )
          : const TokenomicsConfig(),
      purchasePacks: map['purchasePacks'] is List
          ? (map['purchasePacks'] as List)
              .map((e) => CoinPackConfig.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : defaultPacks,
      updatedAt: map['updatedAt'] is String
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  final double ratePerCoinInr;
  final int minRedemptionCoins;
  final String currencySymbol;
  final List<CoinPackConfig> purchasePacks;
  final TokenomicsConfig tokenomics;
  final DateTime? updatedAt;

  static const List<CoinPackConfig> defaultPacks = [
    CoinPackConfig(coins: 100, priceInr: 99.0),
    CoinPackConfig(coins: 250, priceInr: 199.0, bonus: '+25 Free'),
    CoinPackConfig(coins: 500, priceInr: 349.0, bonus: '+100 Free'),
    CoinPackConfig(coins: 1000, priceInr: 649.0, bonus: '+250 Free'),
  ];

  double coinsToFiat(int coins) => coins * ratePerCoinInr;

  String formatFiat(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  }

  String formatCoinsInFiat(int coins) => formatFiat(coinsToFiat(coins));

  Map<String, dynamic> toMap() {
    return {
      'ratePerCoinInr': ratePerCoinInr,
      'minRedemptionCoins': minRedemptionCoins,
      'currencySymbol': currencySymbol,
      'purchasePacks': purchasePacks.map((p) => p.toMap()).toList(),
      'tokenomics': tokenomics.toMap(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  CoinPricingConfig copyWith({
    double? ratePerCoinInr,
    int? minRedemptionCoins,
    String? currencySymbol,
    List<CoinPackConfig>? purchasePacks,
    TokenomicsConfig? tokenomics,
    DateTime? updatedAt,
  }) {
    return CoinPricingConfig(
      ratePerCoinInr: ratePerCoinInr ?? this.ratePerCoinInr,
      minRedemptionCoins: minRedemptionCoins ?? this.minRedemptionCoins,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      purchasePacks: purchasePacks ?? this.purchasePacks,
      tokenomics: tokenomics ?? this.tokenomics,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

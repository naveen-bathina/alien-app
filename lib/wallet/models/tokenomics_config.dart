class HangoutSplit {
  const HangoutSplit({
    required this.totalCoins,
    required this.companionEarnings,
    required this.platformFee,
    required this.effectiveFeePercent,
    required this.isVipDiscountApplied,
  });

  final int totalCoins;
  final int companionEarnings;
  final int platformFee;
  final double effectiveFeePercent;
  final bool isVipDiscountApplied;
}

class TokenomicsConfig {
  const TokenomicsConfig({
    this.standardPlatformFeePercent = 15.0,
    this.vipPlatformFeePercent = 5.0,
    this.lateCancellationFeePercent = 50.0,
    this.minBookingCoinsPerHour = 50,
    this.maxBookingCoinsPerHour = 1000,
  });

  factory TokenomicsConfig.fromMap(Map<String, dynamic> map) {
    return TokenomicsConfig(
      standardPlatformFeePercent:
          (map['standardPlatformFeePercent'] as num?)?.toDouble() ?? 15.0,
      vipPlatformFeePercent:
          (map['vipPlatformFeePercent'] as num?)?.toDouble() ?? 5.0,
      lateCancellationFeePercent:
          (map['lateCancellationFeePercent'] as num?)?.toDouble() ?? 50.0,
      minBookingCoinsPerHour: map['minBookingCoinsPerHour'] as int? ?? 50,
      maxBookingCoinsPerHour: map['maxBookingCoinsPerHour'] as int? ?? 1000,
    );
  }

  final double standardPlatformFeePercent;
  final double vipPlatformFeePercent;
  final double lateCancellationFeePercent;
  final int minBookingCoinsPerHour;
  final int maxBookingCoinsPerHour;

  Map<String, dynamic> toMap() {
    return {
      'standardPlatformFeePercent': standardPlatformFeePercent,
      'vipPlatformFeePercent': vipPlatformFeePercent,
      'lateCancellationFeePercent': lateCancellationFeePercent,
      'minBookingCoinsPerHour': minBookingCoinsPerHour,
      'maxBookingCoinsPerHour': maxBookingCoinsPerHour,
    };
  }

  /// Calculates net companion earnings and platform fee based on VIP status
  HangoutSplit calculateHangoutSplit({
    required int totalCoins,
    bool isCompanionVip = false,
  }) {
    final feePercent =
        isCompanionVip ? vipPlatformFeePercent : standardPlatformFeePercent;
    final fee = (totalCoins * (feePercent / 100.0)).round();
    final companionNet = totalCoins - fee;

    return HangoutSplit(
      totalCoins: totalCoins,
      companionEarnings: companionNet,
      platformFee: fee,
      effectiveFeePercent: feePercent,
      isVipDiscountApplied: isCompanionVip,
    );
  }

  /// Calculates cancellation deductions for late cancellations
  int calculateLateCancellationDeduction(int totalCoins) {
    return (totalCoins * (lateCancellationFeePercent / 100.0)).round();
  }
}

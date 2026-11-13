import 'package:flutter/material.dart';

enum WalletTransactionCategory {
  earning,
  topUp,
  escrowLock,
  escrowRelease,
  payout,
  perk,
  bonus,
}

enum WalletTransactionStatus {
  completed,
  settled,
  lockedInEscrow,
  pendingPayout,
  refunded,
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.amount,
    required this.isCredit,
    required this.category,
    this.description = '',
    this.status = WalletTransactionStatus.completed,
    this.hangoutClientName,
    this.hangoutHours,
    this.payoutUpiOrAccount,
    this.rateAtTransaction,
    this.fiatAmount,
  });

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] is String
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      amount: map['amount'] as int? ?? 0,
      isCredit: map['isCredit'] as bool? ?? true,
      category: WalletTransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => WalletTransactionCategory.bonus,
      ),
      status: WalletTransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WalletTransactionStatus.completed,
      ),
      hangoutClientName: map['hangoutClientName'] as String?,
      hangoutHours: map['hangoutHours'] as int?,
      payoutUpiOrAccount: map['payoutUpiOrAccount'] as String?,
      rateAtTransaction: (map['rateAtTransaction'] as num?)?.toDouble(),
      fiatAmount: (map['fiatAmount'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final int amount;
  final bool isCredit;
  final WalletTransactionCategory category;
  final WalletTransactionStatus status;
  final String? hangoutClientName;
  final int? hangoutHours;
  final String? payoutUpiOrAccount;
  final double? rateAtTransaction;
  final double? fiatAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'isCredit': isCredit,
      'category': category.name,
      'status': status.name,
      'hangoutClientName': hangoutClientName,
      'hangoutHours': hangoutHours,
      'payoutUpiOrAccount': payoutUpiOrAccount,
      'rateAtTransaction': rateAtTransaction,
      'fiatAmount': fiatAmount,
    };
  }

  IconData get iconData {
    switch (category) {
      case WalletTransactionCategory.earning:
        return Icons.monetization_on_rounded;
      case WalletTransactionCategory.topUp:
        return Icons.add_circle_outline_rounded;
      case WalletTransactionCategory.escrowLock:
        return Icons.lock_outline_rounded;
      case WalletTransactionCategory.escrowRelease:
        return Icons.lock_open_rounded;
      case WalletTransactionCategory.payout:
        return Icons.account_balance_rounded;
      case WalletTransactionCategory.perk:
        return Icons.rocket_launch_rounded;
      case WalletTransactionCategory.bonus:
        return Icons.card_giftcard_rounded;
    }
  }

  String get formattedStatus {
    switch (status) {
      case WalletTransactionStatus.completed:
        return 'COMPLETED';
      case WalletTransactionStatus.settled:
        return 'SETTLED';
      case WalletTransactionStatus.lockedInEscrow:
        return 'IN ESCROW';
      case WalletTransactionStatus.pendingPayout:
        return 'PROCESSING';
      case WalletTransactionStatus.refunded:
        return 'REFUNDED';
    }
  }
}

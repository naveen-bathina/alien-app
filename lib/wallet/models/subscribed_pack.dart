enum PackBillingCycle {
  monthly,
  weekly,
  annual,
  oneTime,
}

enum SubscribedPackStatus {
  active,
  expiringSoon,
  cancelled,
}

class SubscribedPack {
  const SubscribedPack({
    required this.id,
    required this.name,
    required this.price,
    required this.renewalOrExpiryDate,
    required this.benefits,
    this.badge = 'ACTIVE',
    this.isAutoRenew = true,
    this.status = SubscribedPackStatus.active,
    this.billingCycle = PackBillingCycle.monthly,
    this.coinsAllocated = 0,
  });

  factory SubscribedPack.fromMap(Map<String, dynamic> map) {
    return SubscribedPack(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
      renewalOrExpiryDate: map['renewalOrExpiryDate'] is String
          ? DateTime.tryParse(map['renewalOrExpiryDate'] as String) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      benefits: (map['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      badge: map['badge'] as String? ?? 'ACTIVE',
      isAutoRenew: map['isAutoRenew'] as bool? ?? true,
      status: SubscribedPackStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscribedPackStatus.active,
      ),
      billingCycle: PackBillingCycle.values.firstWhere(
        (e) => e.name == map['billingCycle'],
        orElse: () => PackBillingCycle.monthly,
      ),
      coinsAllocated: map['coinsAllocated'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String price;
  final DateTime renewalOrExpiryDate;
  final List<String> benefits;
  final String badge;
  final bool isAutoRenew;
  final SubscribedPackStatus status;
  final PackBillingCycle billingCycle;
  final int coinsAllocated;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'renewalOrExpiryDate': renewalOrExpiryDate.toIso8601String(),
      'benefits': benefits,
      'badge': badge,
      'isAutoRenew': isAutoRenew,
      'status': status.name,
      'billingCycle': billingCycle.name,
      'coinsAllocated': coinsAllocated,
    };
  }

  String get renewalFormatted {
    final d = renewalOrExpiryDate;
    return '${d.day}/${d.month}/${d.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';

class RedeemCoinsSheet extends StatefulWidget {
  const RedeemCoinsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RedeemCoinsSheet(),
    );
  }

  @override
  State<RedeemCoinsSheet> createState() => _RedeemCoinsSheetState();
}

class _RedeemCoinsSheetState extends State<RedeemCoinsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _upiOrAccountController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _upiOrAccountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handlePayout(int availableBalance) async {
    final amountText = _amountController.text.trim();
    final upiOrAccount = _upiOrAccountController.text.trim();
    final name = _nameController.text.trim();

    final coins = int.tryParse(amountText);
    if (coins == null || coins <= 0) {
      setState(() => _error = 'Please enter a valid coin amount');
      return;
    }

    final coinConfig = walletRepository.currentState.coinConfig;

    if (coins > availableBalance) {
      setState(() => _error = 'Amount exceeds available balance ($availableBalance Coins)');
      return;
    }

    if (coins < coinConfig.minRedemptionCoins) {
      setState(() => _error =
          'Minimum withdrawal threshold is ${coinConfig.minRedemptionCoins} Coins');
      return;
    }

    if (upiOrAccount.isEmpty) {
      setState(() => _error = 'Please enter your UPI ID or Bank Account Number');
      return;
    }

    if (name.isEmpty) {
      setState(() => _error = 'Please enter the beneficiary account name');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final success = await walletRepository.requestPayout(
      coins: coins,
      upiIdOrAccount: upiOrAccount,
      beneficiaryName: name,
    );

    if (!mounted) return;

    if (success) {
      final fiatValue = coinConfig.formatCoinsInFiat(coins);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Withdrawal of 🪙 $coins (~$fiatValue) requested successfully! Arriving in 2-4 hrs.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setState(() {
        _isProcessing = false;
        _error = 'Failed to process withdrawal. Check balance.';
      });
    }
  }

  Future<void> _handleRedeemPerk(String title, int cost) async {
    final success = await walletRepository.redeemPerk(title, cost);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activated "$title"! (-$cost Coins)'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient available coins for "$title"!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletState = walletRepository.currentState;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeem Coins & Earnings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Withdrawable Available: 🪙 ${walletState.availableBalance} Coins (~₹${walletState.availableBalance})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: '💰 Cash-Out Earnings'),
                  Tab(text: '⚡ Alien In-App Perks'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCashOutView(walletState.availableBalance),
                  _buildPerksView(walletState.availableBalance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOutView(int availableBalance) {
    final coinConfig = walletRepository.currentState.coinConfig;
    final rateDisplay =
        '1 Alien Coin = ${coinConfig.currencySymbol}${coinConfig.ratePerCoinInr.toStringAsFixed(coinConfig.ratePerCoinInr % 1 == 0 ? 0 : 2)}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dynamic conversion rate banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$rateDisplay • 0% Platform Fee on withdrawals',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Amount to withdraw
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Coins to Withdraw',
              hintText: 'e.g. 200',
              prefixIcon: const Icon(Icons.monetization_on_outlined),
              suffixText: 'Coins',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              helperText: 'Available: $availableBalance Coins (Min: 50 Coins)',
            ),
          ),
          const SizedBox(height: 14),

          // Beneficiary Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Beneficiary Name',
              hintText: 'As per bank / PAN card',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          // UPI ID or Account
          TextField(
            controller: _upiOrAccountController,
            decoration: InputDecoration(
              labelText: 'UPI ID or Bank Account No.',
              hintText: 'e.g. name@okhdfc or 9876543210@paytm',
              prefixIcon: const Icon(Icons.account_balance_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              helperText: 'Direct transfer arrives in 2-4 business hours',
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isProcessing ? null : () => _handlePayout(availableBalance),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Confirm & Withdraw Earnings',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerksView(int availableBalance) {
    final perks = <Map<String, dynamic>>[
      {
        'title': 'Profile Spotlight',
        'desc': '5x more views for 1 hour in Discover',
        'cost': 20,
        'icon': Icons.bolt_rounded,
      },
      {
        'title': 'Super Likes Pack',
        'desc': 'Stand out with 5 priority super-likes',
        'cost': 30,
        'icon': Icons.star_rounded,
      },
      {
        'title': 'Rewind Swipe',
        'desc': 'Revisit your last passed profile',
        'cost': 15,
        'icon': Icons.replay_rounded,
      },
      {
        'title': 'Incognito Mode',
        'desc': 'Browse companion profiles discreetly for 24h',
        'cost': 25,
        'icon': Icons.visibility_off_rounded,
      },
    ];

    return ListView.builder(
      itemCount: perks.length,
      itemBuilder: (context, index) {
        final perk = perks[index];
        final title = perk['title'] as String? ?? '';
        final desc = perk['desc'] as String? ?? '';
        final cost = perk['cost'] as int? ?? 0;
        final icon = perk['icon'] as IconData? ?? Icons.star;
        final canAfford = availableBalance >= cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: canAfford ? () => _handleRedeemPerk(title, cost) : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: canAfford ? AppColors.primary : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: Text(
                  '$cost Coins',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canAfford ? AppColors.primary : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

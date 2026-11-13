import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_colors.dart';
import 'package:myalien/wallet/models/wallet_transaction.dart';
import 'package:myalien/wallet/repository/wallet_repository.dart';

enum _HistoryTimeframe { all, thisMonth, last30Days, last3Months }

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  _HistoryTimeframe _timeframe = _HistoryTimeframe.all;
  WalletTransactionCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime? get _startDate {
    final now = DateTime.now();
    switch (_timeframe) {
      case _HistoryTimeframe.thisMonth:
        return DateTime(now.year, now.month, 1);
      case _HistoryTimeframe.last30Days:
        return now.subtract(const Duration(days: 30));
      case _HistoryTimeframe.last3Months:
        return now.subtract(const Duration(days: 90));
      case _HistoryTimeframe.all:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Transactions & Statement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<WalletStateData>(
        stream: walletRepository.walletStream,
        initialData: walletRepository.currentState,
        builder: (context, snapshot) {
          final allTransactions =
              walletRepository.getFilteredTransactions(
            category: _selectedCategory,
            startDate: _startDate,
          );

          final filtered = allTransactions.where((tx) {
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            return tx.title.toLowerCase().contains(query) ||
                tx.description.toLowerCase().contains(query) ||
                (tx.hangoutClientName?.toLowerCase().contains(query) ?? false);
          }).toList();

          final totalIn = filtered
              .where((t) => t.isCredit)
              .fold<int>(0, (sum, t) => sum + t.amount);
          final totalOut = filtered
              .where((t) => !t.isCredit)
              .fold<int>(0, (sum, t) => sum + t.amount);

          return Column(
            children: [
              // Search & Filter controls container
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search by client, title, or ID...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Timeframe row (reduces payload bounds)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTimeframeChip('All Time', _HistoryTimeframe.all),
                          _buildTimeframeChip('This Month', _HistoryTimeframe.thisMonth),
                          _buildTimeframeChip('Last 30 Days', _HistoryTimeframe.last30Days),
                          _buildTimeframeChip('Last 3 Months', _HistoryTimeframe.last3Months),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All Categories', null),
                          _buildCategoryChip('Earnings 💰', WalletTransactionCategory.earning),
                          _buildCategoryChip('Escrow 🔒', WalletTransactionCategory.escrowLock),
                          _buildCategoryChip('Top-Up ⚡', WalletTransactionCategory.topUp),
                          _buildCategoryChip('Payouts 🏦', WalletTransactionCategory.payout),
                          _buildCategoryChip('Perks 🚀', WalletTransactionCategory.perk),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Banner for currently filtered data
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.primaryLight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} entries found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '+$totalIn C',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '-$totalOut C',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filtered List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            const Text(
                              'No transactions found for current filter',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return _buildTransactionCard(context, tx);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeframeChip(String label, _HistoryTimeframe value) {
    final isSelected = _timeframe == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _timeframe = value),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, WalletTransactionCategory? cat) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = cat),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, WalletTransaction tx) {
    final isCredit = tx.isCredit;

    Color badgeColor;
    switch (tx.status) {
      case WalletTransactionStatus.settled:
      case WalletTransactionStatus.completed:
        badgeColor = AppColors.success;
      case WalletTransactionStatus.lockedInEscrow:
        badgeColor = Colors.amber.shade800;
      case WalletTransactionStatus.pendingPayout:
        badgeColor = AppColors.primary;
      case WalletTransactionStatus.refunded:
        badgeColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isCredit
                ? AppColors.successLight
                : (tx.category == WalletTransactionCategory.escrowLock
                    ? Colors.amber.shade50
                    : AppColors.errorLight),
            child: Icon(
              tx.iconData,
              color: isCredit
                  ? AppColors.success
                  : (tx.category == WalletTransactionCategory.escrowLock
                      ? Colors.amber.shade800
                      : AppColors.error),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tx.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${isCredit ? "+" : "-"}${tx.amount} Coins',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (tx.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year} • ${_formatTime(tx.timestamp)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.formattedStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

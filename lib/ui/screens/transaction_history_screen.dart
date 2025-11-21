import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/providers/ton_wallet_provider.dart';
import '../../core/providers/theme_provider.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              _buildStatsBar(context),
              _buildTabContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Text(
            'Transaction History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          color: const Color(0xFF7B61FF),
          borderRadius: BorderRadius.circular(8),
        ),
        tabs: const [
          Tab(text: 'Chakra Coins'),
          Tab(text: 'TON Crypto'),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return Consumer2<WalletProvider, TonWalletProvider>(
      builder: (context, walletProvider, tonProvider, child) {
        final totalEarned = walletProvider.transactions
            .where((t) => t.isEarned)
            .fold(0.0, (sum, t) => sum + t.amount);
            
        final totalSpent = walletProvider.transactions
            .where((t) => !t.isEarned)
            .fold(0.0, (sum, t) => sum + t.amount);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Earned', '+${totalEarned.toInt()}', Icons.trending_up, const Color(0xFF00D2A8)),
              _buildStatItem('Total Spent', '-${totalSpent.toInt()}', Icons.trending_down, const Color(0xFFFC466B)),
              _buildStatItem('TON Scans', tonProvider.totalScans.toString(), Icons.qr_code_scanner, const Color(0xFF0098EA)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          // Chakra Coins Transactions
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) => 
                _buildChakraTransactions(context, walletProvider),
          ),
          
          // TON Transactions
          Consumer<TonWalletProvider>(
            builder: (context, tonProvider, child) =>
                _buildTonTransactions(context, tonProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildChakraTransactions(BuildContext context, WalletProvider walletProvider) {
    if (walletProvider.transactions.isEmpty) {
      return _buildEmptyState(
        context,
        'No Transactions Yet',
        'Start scanning QR codes to earn Chakra Coins!',
        Icons.receipt_long,
      );
    }

    // Group transactions by date
    final Map<String, List<ChakraTransaction>> groupedTransactions = {};
    
    for (final transaction in walletProvider.transactions) {
      final dateKey = _formatDateKey(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => _compareDateKeys(a, b));

    return ListView(
      children: [
        for (final dateKey in sortedDates)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  dateKey,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
              ...groupedTransactions[dateKey]!.map((transaction) => 
                  _buildChakraTransactionItem(context, transaction)),
            ],
          ),
      ],
    );
  }

  Widget _buildTonTransactions(BuildContext context, TonWalletProvider tonProvider) {
    final tonTransactions = tonProvider.transactions;

    if (tonTransactions.isEmpty) {
      return _buildEmptyState(
        context,
        'No TON Transactions',
        'Connect your TON wallet and earn cryptocurrency rewards!',
        Icons.currency_bitcoin,
      );
    }

    // Group TON transactions by date
    final Map<String, List<TonRewardRecord>> groupedTonTransactions = {};
    
    for (final transaction in tonTransactions) {
      final dateKey = _formatDateKey(transaction.date);
      if (!groupedTonTransactions.containsKey(dateKey)) {
        groupedTonTransactions[dateKey] = [];
      }
      groupedTonTransactions[dateKey]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTonTransactions.keys.toList()
      ..sort((a, b) => _compareDateKeys(a, b));

    return ListView(
      children: [
        for (final dateKey in sortedDates)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  dateKey,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
              ...groupedTonTransactions[dateKey]!.map((transaction) => 
                  _buildTonTransactionItem(context, transaction, tonProvider)),
            ],
          ),
      ],
    );
  }

  Widget _buildChakraTransactionItem(BuildContext context, ChakraTransaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.isEarned
                  ? const Color(0xFF00D2A8).withOpacity(0.1)
                  : const Color(0xFFFC466B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isEarned ? Icons.add : Icons.remove,
              color: transaction.isEarned ? const Color(0xFF00D2A8) : const Color(0xFFFC466B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.store,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (transaction.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  transaction.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                ),
                Text(
                  transaction.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                ),
                if (transaction.tonReward > 0)
                  Text(
                    '+${transaction.tonReward.toStringAsFixed(3)} TON reward',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF0098EA),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isEarned ? '+' : '-'}${transaction.amount.toInt()}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: transaction.isEarned ? const Color(0xFF00D2A8) : const Color(0xFFFC466B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Chakra Coins',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTonTransactionItem(
    BuildContext context,
    TonRewardRecord transaction,
    TonWalletProvider tonProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0098EA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.currency_bitcoin,
              color: Color(0xFF0098EA),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (transaction.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  tonProvider.walletAddress != null
                      ? 'Wallet: ${tonProvider.getShortAddress()}'
                      : 'Wallet disconnected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                ),
                Text(
                  _formatRelativeDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${transaction.amount.toStringAsFixed(3)} TON',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF0098EA),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                transaction.isPremium ? 'Premium Reward' : 'QR Reward',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) return 'Today';
    if (dateDay == yesterday) return 'Yesterday';
    
    final difference = now.difference(date);
    if (difference.inDays < 7) {
      return 'This Week';
    } else if (difference.inDays < 30) {
      return 'This Month';
    } else {
      return '${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  int _compareDateKeys(String a, String b) {
    final order = ['Today', 'Yesterday', 'This Week', 'This Month'];
    final aIndex = order.indexOf(a);
    final bIndex = order.indexOf(b);
    
    if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
    if (aIndex != -1) return -1;
    if (bIndex != -1) return 1;
    
    return b.compareTo(a);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

}
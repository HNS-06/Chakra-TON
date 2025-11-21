import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/providers/ton_wallet_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'rewards_catalog_screen.dart';
import 'wallet_connect_screen.dart';
import 'store_locator_screen.dart';
import 'transaction_history_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');
    
    if (userName != null && userName.isNotEmpty) {
      setState(() {
        _userName = userName;
      });
    } else {
      // Fallback to UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.name != 'Guest') {
        setState(() {
          _userName = userProvider.name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(context),
              _buildTonWalletSection(context),
              const SizedBox(height: 16),
              _buildLoyaltyStatus(context, userProvider),
              const SizedBox(height: 16),
              _buildBalanceCard(context, walletProvider, userProvider),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, walletProvider),
              const SizedBox(height: 20),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Row(
            children: [
              // Profile Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "$_userName 👋", // Use the loaded user name
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: themeProvider.toggleTheme,
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).primaryColor,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(12),
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.3, end: 0);
  }

  Widget _buildLoyaltyStatus(BuildContext context, UserProvider userProvider) {
    final progressPercentage = (userProvider.progressToNextTier * 100).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get next tier name from the description
    String nextTierName = 'Next Tier';
    if (userProvider.nextTierDescription != 'Max Tier Reached') {
      final parts = userProvider.nextTierDescription.split(' ');
      if (parts.isNotEmpty) {
        nextTierName = parts[0];
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getTierBackgroundColor(userProvider.loyaltyTier, isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getTierColor(userProvider.loyaltyTier).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getTierColor(userProvider.loyaltyTier).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  userProvider.getTierIcon(),
                  color: AppTheme.getTierColor(userProvider.loyaltyTier),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userProvider.loyaltyTier} Tier',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTierTextColor(userProvider.loyaltyTier),
                      ),
                    ),
                    Text(
                      userProvider.nextTierDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTierTextColor(userProvider.loyaltyTier).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getTierColor(userProvider.loyaltyTier).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${userProvider.totalPointsEarned} pts',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTierTextColor(userProvider.loyaltyTier),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to $nextTierName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTierTextColor(userProvider.loyaltyTier).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$progressPercentage%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTierTextColor(userProvider.loyaltyTier),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  LinearProgressIndicator(
                    value: userProvider.progressToNextTier,
                    backgroundColor: isDark 
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    color: AppTheme.getTierColor(userProvider.loyaltyTier),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  if (userProvider.progressToNextTier > 0)
                    Positioned(
                      left: (userProvider.progressToNextTier * 100) - 2,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${userProvider.pointsToNextTier} points to go',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.getTierTextColor(userProvider.loyaltyTier).withOpacity(0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: Text(
                      'View Details',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.getTierColor(userProvider.loyaltyTier),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 300)).slideY(begin: 0.2, end: 0);
  }

  Widget _buildBalanceCard(BuildContext context, WalletProvider walletProvider, UserProvider userProvider) {
    // Calculate earned and spent totals
    double totalEarned = walletProvider.transactions
        .where((t) => t.isEarned)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    
    double totalSpent = walletProvider.transactions
        .where((t) => !t.isEarned)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final uniqueStoresVisited = walletProvider.transactions.map((t) => t.store).toSet().length;
    final storesVisitedDisplay = uniqueStoresVisited > 0
        ? uniqueStoresVisited.toString()
        : userProvider.storesVisited.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF9E8EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B61FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Balance",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            walletProvider.balance.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Chakra Coins",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetric("Earned", totalEarned.toInt().toString()),
              const SizedBox(width: 20),
              _buildMetric("Spent", totalSpent.toInt().toString()),
              const SizedBox(width: 20),
              _buildMetric("Stores", storesVisitedDisplay),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.3, end: 0);
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<_ActionItem> actions = [
      const _ActionItem("Scan & Earn", Icons.qr_code_scanner, Color(0xFF00C6FF)),
      const _ActionItem("Redeem", Icons.card_giftcard, Color(0xFFFC466B)),
      const _ActionItem("Stores", Icons.store, Color(0xFF7B61FF)),
      const _ActionItem("History", Icons.history, Color(0xFF00D2A8)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildActionCard(context, actions[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, _ActionItem action, int index) {
    final int delay = 600 + (index * 100);
    
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          if (action.label == "Scan & Earn") {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QrScannerScreen()),
            );
          } else if (action.label == "Redeem") {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RewardsCatalogScreen()),
            );
          } else if (action.label == "Stores") {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const StoreLocatorScreen()),
            );
          } else if (action.label == "History") {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.3, end: 0);
  }

  Widget _buildTonWalletSection(BuildContext context) {
    final tonProvider = Provider.of<TonWalletProvider>(context);
    
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WalletConnectScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0098EA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF0098EA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TON Wallet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tonProvider.isConnected 
                        ? 'Connected • ${tonProvider.tonBalance} TON'
                        : 'Connect to earn real crypto',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WalletProvider walletProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                );
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...walletProvider.transactions.take(3).map((transaction) => 
          _buildTransactionItem(context, transaction)
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, ChakraTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTransactionIcon(transaction.store),
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Text(
                    transaction.store,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (transaction.isPremium) ...[
                    const SizedBox(width: 6),
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
                ],
              ),
                Text(
                  transaction.type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
          Text(
            "${transaction.isEarned ? '+' : '-'}${transaction.amount.toInt()}",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: transaction.isEarned ? const Color(0xFF00D2A8) : const Color(0xFFFC466B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String store) {
    switch (store.toLowerCase()) {
      case 'starbucks': return Icons.coffee;
      case 'nike store': return Icons.shopping_bag;
      case 'mcdonald\'s': return Icons.fastfood;
      default: return Icons.store;
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 1000));
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('user_name'); // Remove the stored name

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;

  const _ActionItem(this.label, this.icon, this.color);
}
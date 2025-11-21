import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/providers/ton_wallet_provider.dart';

class RewardsCatalogScreen extends StatelessWidget {
  const RewardsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final tonProvider = Provider.of<TonWalletProvider>(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildBalanceInfo(context, walletProvider, tonProvider),
              _buildTabBar(),
              _buildTabBarContent(context, walletProvider, tonProvider),
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
            'Rewards Catalog',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
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

  Widget _buildBalanceInfo(BuildContext context, WalletProvider walletProvider, TonWalletProvider tonProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chakra Coins Balance
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chakra Coins',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${walletProvider.balance.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // TON Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TON Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tonProvider.isConnected ? tonProvider.getFormattedBalance() : 'Not Connected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // TON Connection Status
          if (!tonProvider.isConnected)
            GestureDetector(
              onTap: () {
                // Navigate to wallet connect screen
                // Navigator.push(context, MaterialPageRoute(builder: (context) => WalletConnectScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.currency_bitcoin, color: Colors.yellow, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Connect TON Wallet for Premium Rewards',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Tab(text: 'TON Premium'),
        ],
      ),
    );
  }

  Widget _buildTabBarContent(BuildContext context, WalletProvider walletProvider, TonWalletProvider tonProvider) {
    return Expanded(
      child: TabBarView(
        children: [
          _buildRewardGrid(context, walletProvider, RewardType.chakra),
          _buildRewardGrid(context, walletProvider, RewardType.ton, tonProvider: tonProvider),
        ],
      ),
    );
  }

  Widget _buildRewardGrid(BuildContext context, WalletProvider walletProvider, RewardType type, {TonWalletProvider? tonProvider}) {
    final rewards = type == RewardType.chakra ? _chakraRewards : _tonRewards;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          return _buildRewardCard(context, reward, walletProvider, tonProvider);
        },
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, Reward reward, WalletProvider walletProvider, TonWalletProvider? tonProvider) {
    final available = reward.rewardType == RewardType.chakra
        ? walletProvider.balance >= reward.cost
        : (tonProvider?.tonBalance ?? 0.0) >= reward.cost;
    final buttonColor = reward.rewardType == RewardType.ton
        ? const Color(0xFF0098EA)
        : Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => _showRedeemDialog(context, reward, walletProvider, tonProvider),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: reward.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(reward.icon, color: reward.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              reward.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              reward.store,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${reward.cost} ${reward.rewardType == RewardType.ton ? 'TON' : 'Chakra'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: available
                    ? () => _showRedeemDialog(context, reward, walletProvider, tonProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: available ? buttonColor : Colors.grey.withOpacity(0.3),
                  foregroundColor: available ? Colors.white : Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  elevation: available ? 3 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.card_giftcard, size: 18),
                    const SizedBox(width: 8),
                    Text(available ? 'Redeem Now' : 'Redeem'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, Reward reward, WalletProvider? walletProvider, TonWalletProvider? tonProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem ${reward.rewardType == RewardType.ton ? 'TON Premium' : 'Chakra'} Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: reward.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(reward.icon, color: reward.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.store,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This will cost you ${reward.cost} ${reward.rewardType == RewardType.ton ? 'TON' : 'Chakra Coins'}.',
              style: const TextStyle(fontSize: 14),
            ),
            if (reward.description != null) ...[
              const SizedBox(height: 8),
              Text(
                reward.description!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (reward.rewardType == RewardType.chakra && walletProvider != null) {
                      walletProvider.spendCoins(reward.cost, reward.store);
                    } else if (reward.rewardType == RewardType.ton && tonProvider != null) {
                      tonProvider.receiveReward(-reward.cost);
                    }
                    Navigator.of(context).pop();
                    _showRedemptionSuccess(context, reward);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reward.rewardType == RewardType.ton ? const Color(0xFF0098EA) : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Redeem'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRedemptionSuccess(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '${reward.rewardType == RewardType.ton ? 'TON Premium ' : ''}Reward Redeemed!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You successfully redeemed ${reward.title} from ${reward.store}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reward.rewardType == RewardType.ton ? const Color(0xFF0098EA) : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Reward {
  final String store;
  final String title;
  final double cost;
  final IconData icon;
  final Color color;
  final String category;
  final RewardType rewardType;
  final String? description;

  Reward(
    this.store,
    this.title,
    this.cost,
    this.icon,
    this.color,
    this.category, {
    this.rewardType = RewardType.chakra,
    this.description,
  });
}

enum RewardType {
  chakra,
  ton,
}

final List<Reward> _chakraRewards = [
  Reward('Coffee House', 'Free Small Coffee', 25, Icons.local_cafe, Colors.brown, 'Food', description: 'Enjoy a fresh-brewed small coffee on us.'),
  Reward('Juice Bar', 'Fresh Smoothie', 45, Icons.local_drink, Colors.orange, 'Food', description: 'Grab a blended fruit smoothie of your choice.'),
  Reward('Urban Bakery', 'Box of Pastries', 80, Icons.cake, Colors.pinkAccent, 'Food', description: 'Assorted pastries perfect for your morning treat.'),
  Reward('Bookstore', '10% Off Purchase', 120, Icons.menu_book, Colors.deepPurple, 'Shopping', description: 'Save on books, stationery, and gifts.'),
  Reward('Fitness Hub', 'Day Gym Pass', 150, Icons.fitness_center, Colors.green, 'Wellness', description: 'Full-day access to gym facilities and classes.'),
  Reward('Tech World', 'Phone Accessory Voucher', 180, Icons.devices, Colors.blueGrey, 'Electronics', description: 'Redeem for chargers, cables, or cases.'),
  Reward('Cinema', 'Movie Ticket', 220, Icons.movie, Colors.indigo, 'Entertainment', description: 'Any 2D screening at participating cinemas.'),
  Reward('RideShare', '₹150 Ride Credit', 240, Icons.local_taxi, Colors.amber, 'Transport', description: 'Applies to your next ride within the city.'),
  Reward('Wellness Spa', '30-min Massage', 260, Icons.spa, Colors.teal, 'Wellness', description: 'Relax with a quick stress-relief massage.'),
  Reward('Gourmet Deli', 'Dinner for Two', 320, Icons.restaurant, Colors.redAccent, 'Food', description: 'Chef-selected dinner menu for two guests.'),
  Reward('Music Stream', '3-Month Premium', 360, Icons.music_note, Colors.deepOrange, 'Entertainment', description: 'Unlock ad-free streaming and downloads.'),
  Reward('Travel Mate', 'Airport Lounge Pass', 420, Icons.flight_takeoff, Colors.blue, 'Travel', description: 'Single-entry lounge access with refreshments.'),
  Reward('Lifestyle Store', '₹500 Shopping Voucher', 480, Icons.shopping_bag, Colors.purple, 'Shopping', description: 'Spend on apparel, accessories, or home goods.'),
];

final List<Reward> _tonRewards = [
  Reward('Premium Skin', 'Golden Avatar Skin', 0.5, Icons.star, Colors.amber, 'Premium', rewardType: RewardType.ton, description: 'Exclusive golden avatar finish for your profile.'),
  Reward('VIP Status', '7-day VIP Access', 2.0, Icons.verified, Colors.teal, 'Membership', rewardType: RewardType.ton, description: 'Priority support, boosted earnings, and special offers.'),
  Reward('Launchpad', 'Whitelist Spot', 1.2, Icons.rocket_launch, Colors.deepPurple, 'Events', rewardType: RewardType.ton, description: 'Guaranteed access to the next partner NFT mint.'),
  Reward('Creator Hub', 'Commission Boost', 1.8, Icons.trending_up, Colors.orange, 'Earnings', rewardType: RewardType.ton, description: 'Increase your earnings share for one month.'),
  Reward('Metaverse Club', 'Virtual Suite Rental', 2.5, Icons.chair_alt, Colors.blueAccent, 'Experiences', rewardType: RewardType.ton, description: 'Host friends in a private virtual lounge for a weekend.'),
  Reward('Pro Toolkit', 'Analytics Dashboard', 3.0, Icons.bar_chart, Colors.green, 'Productivity', rewardType: RewardType.ton, description: 'Unlock advanced analytics and export files for 30 days.'),
  Reward('Event Pass', 'Exclusive AMA Seat', 0.9, Icons.mic, Colors.pinkAccent, 'Events', rewardType: RewardType.ton, description: 'Join invite-only AMA with a TON ecosystem leader.'),
  Reward('Collectibles', 'Limited NFT Drop', 4.5, Icons.palette, Colors.cyan, 'Collectibles', rewardType: RewardType.ton, description: 'Claim a rare collectible before it hits the marketplace.'),
  Reward('Node Access', 'Validator Priority Queue', 5.0, Icons.lock_clock, Colors.deepOrange, 'Infrastructure', rewardType: RewardType.ton, description: 'Priority placement for new validator onboarding.'),
  Reward('Travel Partner', 'Premium Airport Transfer', 2.2, Icons.directions_car, Colors.indigo, 'Travel', rewardType: RewardType.ton, description: 'Executive car pickup from select airports.'),
];
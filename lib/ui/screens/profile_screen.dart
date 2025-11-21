import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/providers/ton_wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import 'account_settings_screen.dart';
import 'app_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.name;
    _emailController.text = userProvider.email;
    _phoneController.text = userProvider.phone;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final tonProvider = Provider.of<TonWalletProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProfileCard(context, userProvider),
              const SizedBox(height: 16),
              _buildLoyaltyStats(context, userProvider, walletProvider, tonProvider, isDark),
              const SizedBox(height: 16),
              _buildAccountSettings(context, userProvider),
              const SizedBox(height: 16),
              _buildAppSettings(context, userProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        // Edit/Save Button
        IconButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) {
                _saveProfile();
              }
            });
          },
          icon: Icon(
            _isEditing ? Icons.save : Icons.edit,
            color: Theme.of(context).primaryColor,
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // User Name (Editable when in edit mode)
          if (_isEditing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text(
              userProvider.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          
          const SizedBox(height: 4),
          
          // Email (Editable when in edit mode)
          if (_isEditing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _emailController,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text(
              userProvider.email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Loyalty Tier Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: userProvider.tierColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: userProvider.tierColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  userProvider.getTierIcon(),
                  color: userProvider.tierColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${userProvider.loyaltyTier} Member',
                  style: TextStyle(
                    color: userProvider.tierColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyStats(BuildContext context, UserProvider userProvider, WalletProvider walletProvider, TonWalletProvider tonProvider, bool isDark) {
    final progressPercentage = (userProvider.progressToNextTier * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loyalty Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _buildStatCard(
                context,
                'Member Since',
                userProvider.formattedMemberSince,
                Icons.calendar_today,
                const Color(0xFF7B61FF),
              ),
              _buildStatCard(
                context,
                'Days Active',
                '${userProvider.daysAsMember} days',
                Icons.event_available,
                const Color(0xFF00C6FF),
              ),
              _buildStatCard(
                context,
                'Total Points',
                '${userProvider.totalPointsEarned}',
                Icons.emoji_events,
                const Color(0xFFFFD700),
              ),
              _buildStatCard(
                context,
                'Stores Visited',
                '${userProvider.storesVisited}',
                Icons.store,
                const Color(0xFF00D2A8),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Next Tier Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getTierBackgroundColor(userProvider.loyaltyTier, isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getTierColor(userProvider.loyaltyTier).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      userProvider.getTierIcon(),
                      color: AppTheme.getTierColor(userProvider.loyaltyTier),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userProvider.nextTierDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTierTextColor(userProvider.loyaltyTier),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: userProvider.progressToNextTier,
                      backgroundColor: isDark 
                          ? Colors.grey.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      color: AppTheme.getTierColor(userProvider.loyaltyTier),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progressPercentage}% to next tier',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTierTextColor(userProvider.loyaltyTier).withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${userProvider.pointsToNextTier} points needed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTierTextColor(userProvider.loyaltyTier).withOpacity(0.8),
                        fontWeight: FontWeight.w500,
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            context,
            'Edit Profile',
            Icons.person_outline,
            () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
          _buildSettingsItem(
            context,
            'Account Settings',
            Icons.settings,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            'Payment Methods',
            Icons.payment,
            () {
              // This will now be handled in AccountSettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            'Security & Privacy',
            Icons.security,
            () {
              // This will now be handled in AccountSettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            context,
            'App Settings',
            Icons.settings_applications,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            'Notifications',
            Icons.notifications_none,
            () {
              // This will now be handled in AppSettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            'Language & Theme',
            Icons.language,
            () {
              // This will now be handled in AppSettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            'Help & Support',
            Icons.help_outline,
            () {
              // This will now be handled in AppSettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            'About App',
            Icons.info_outline,
            () {
              // This will now be handled in AppSettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemWithValue(BuildContext context, String title, IconData icon, String value, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleSettingsItem(BuildContext context, String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, UserProvider userProvider) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              return ListTile(
                title: Text(language),
                trailing: language == userProvider.language
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  userProvider.updateLanguage(language);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Language changed to $language')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (_nameController.text.trim().isNotEmpty) {
      userProvider.updateName(_nameController.text.trim());
    }
    if (_emailController.text.trim().isNotEmpty) {
      userProvider.updateEmail(_emailController.text.trim());
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Chakra Loyalty'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chakra Loyalty v1.0.0'),
            SizedBox(height: 8),
            Text('A revolutionary loyalty platform powered by TON blockchain.'),
            SizedBox(height: 12),
            Text('Features:'),
            Text('• QR Code Scanning'),
            Text('• Dual Reward System'),
            Text('• TON Cryptocurrency Integration'),
            Text('• Premium Rewards'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon!'),
        content: Text('We\'re working hard to bring you $feature feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/theme_provider.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Notifications & Preferences'),
              _buildNotificationSettings(context, userProvider),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Appearance & Language'),
              _buildAppearanceSettings(context, themeProvider, userProvider),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Support & About'),
              _buildSupportSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, UserProvider userProvider) {
    return Container(
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
      child: Column(
        children: [
          _buildToggleSettingsItem(
            context,
            'Push Notifications',
            Icons.notifications_none,
            'Receive push notifications for updates',
            userProvider.notificationsEnabled,
            (value) => userProvider.toggleNotifications(value),
          ),
          _buildDivider(),
          _buildToggleSettingsItem(
            context,
            'Email Notifications',
            Icons.email_outlined,
            'Receive updates via email',
            false, // This would be a separate setting
            (value) {
              _showComingSoon(context, 'Email Notifications');
            },
          ),
          _buildDivider(),
          _buildToggleSettingsItem(
            context,
            'Promotional Offers',
            Icons.local_offer_outlined,
            'Get notified about special offers',
            true, // This would be a separate setting
            (value) {
              _showComingSoon(context, 'Promotional Offers');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context, ThemeProvider themeProvider, UserProvider userProvider) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingsItemWithValue(
            context,
            'Language',
            Icons.language,
            'App language and region',
            userProvider.language,
            () {
              _showLanguageDialog(context, userProvider);
            },
          ),
          _buildDivider(),
          _buildToggleSettingsItem(
            context,
            'Dark Mode',
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            'Switch between light and dark theme',
            themeProvider.isDarkMode,
            (value) => themeProvider.toggleTheme(),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'Font Size',
            Icons.format_size,
            'Adjust text size throughout the app',
            () {
              _showComingSoon(context, 'Font Size Settings');
            },
            showTrailingIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingsItem(
            context,
            'Help & Support',
            Icons.help_outline,
            'Get help and contact support',
            () {
              _showHelpSupportDialog(context);
            },
            showTrailingIcon: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'About App',
            Icons.info_outline,
            'App version and information',
            () {
              _showAboutDialog(context);
            },
            showTrailingIcon: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'Rate App',
            Icons.star_outline,
            'Rate us on the app store',
            () {
              _showComingSoon(context, 'Rate App');
            },
            showTrailingIcon: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'Terms of Service',
            Icons.description_outlined,
            'Read our terms and conditions',
            () {
              _showComingSoon(context, 'Terms of Service');
            },
            showTrailingIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap, {
    bool showTrailingIcon = false,
  }) {
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),
      trailing: showTrailingIcon
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemWithValue(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    String value,
    VoidCallback onTap,
  ) {
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
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

  Widget _buildToggleSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  void _showLanguageDialog(BuildContext context, UserProvider userProvider) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Korean', 'Arabic'];
    
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

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Here are your options:'),
            SizedBox(height: 12),
            Text('📞 Call: +1-800-CHAKRA'),
            Text('📧 Email: support@chakra.com'),
            Text('💬 Live Chat: Available 24/7'),
            SizedBox(height: 8),
            Text('Our support team is here to help you with any questions or issues.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context, 'Contact Support');
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
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
            Text('Build: 2024.11.1'),
            SizedBox(height: 12),
            Text('A revolutionary loyalty platform powered by TON blockchain.'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• QR Code Scanning'),
            Text('• Dual Reward System'),
            Text('• TON Cryptocurrency Integration'),
            Text('• Premium Rewards'),
            Text('• Multi-tier Loyalty Program'),
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
}
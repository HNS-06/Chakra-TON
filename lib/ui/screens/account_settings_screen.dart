import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Account Settings'),
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
              _buildSectionHeader('Profile Settings'),
              _buildProfileSettings(context, userProvider),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Security & Privacy'),
              _buildSecuritySettings(context, userProvider),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Payment & Data'),
              _buildPaymentSettings(context, userProvider),
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

  Widget _buildProfileSettings(BuildContext context, UserProvider userProvider) {
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
            'Edit Profile',
            Icons.person_outline,
            'Update your personal information',
            () {
              // Navigate to edit profile screen
              _showEditProfileDialog(context, userProvider);
            },
            showTrailingIcon: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'Change Email',
            Icons.email_outlined,
            'Update your email address',
            () {
              _showChangeEmailDialog(context, userProvider);
            },
            showTrailingIcon: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'Change Phone',
            Icons.phone_outlined,
            'Update your phone number',
            () {
              _showChangePhoneDialog(context, userProvider);
            },
            showTrailingIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context, UserProvider userProvider) {
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
            'Security',
            Icons.security,
            'Enable additional security features',
            userProvider.securityEnabled,
            (value) => userProvider.toggleSecurity(value),
          ),
          _buildDivider(),
          _buildToggleSettingsItem(
            context,
            'Two-Factor Authentication',
            Icons.lock_outline,
            'Add extra security to your account',
            false, // This would be a separate setting
            (value) {
              _showComingSoon(context, 'Two-Factor Authentication');
            },
          ),
          _buildDivider(),
          _buildToggleSettingsItem(
            context,
            'Biometric Login',
            Icons.fingerprint,
            'Use fingerprint or face ID to login',
            false, // This would be a separate setting
            (value) {
              _showComingSoon(context, 'Biometric Login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSettings(BuildContext context, UserProvider userProvider) {
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
            'Payment Methods',
            Icons.payment,
            'Manage your payment options',
            userProvider.paymentMethodsEnabled,
            (value) => userProvider.togglePaymentMethods(value),
          ),
          _buildDivider(),
          _buildToggleSettingsItem(
            context,
            'Privacy Policy',
            Icons.privacy_tip,
            'Accept our privacy policy terms',
            userProvider.privacyPolicyAccepted,
            (value) => userProvider.togglePrivacyPolicy(value),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            'Data & Privacy',
            Icons.data_usage,
            'Manage your data and privacy settings',
            () {
              _showComingSoon(context, 'Data & Privacy');
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

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('This feature will allow you to update your profile information including name, bio, and profile picture.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context, 'Edit Profile');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: const Text('You will be able to update your email address and verify the new one.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context, 'Change Email');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showChangePhoneDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Phone Number'),
        content: const Text('Update your phone number for account recovery and notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context, 'Change Phone Number');
            },
            child: const Text('Continue'),
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
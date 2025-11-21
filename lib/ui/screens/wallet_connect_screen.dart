// lib/ui/screens/wallet_connect_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ton_wallet_provider.dart';

class WalletConnectScreen extends StatelessWidget {
  const WalletConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tonProvider = Provider.of<TonWalletProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 60),
              _buildWalletInfo(context, tonProvider),
              const Spacer(),
              _buildConnectButton(context, tonProvider),
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
        const SizedBox(width: 16),
        Text(
          'TON Wallet',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletInfo(BuildContext context, TonWalletProvider tonProvider) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: 50,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          tonProvider.isConnected ? 'Wallet Connected' : 'Connect TON Wallet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tonProvider.isConnected 
            ? 'Your wallet is connected to Chakra Loyalty'
            : 'Connect your TON wallet to earn real cryptocurrency rewards',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        if (tonProvider.isConnected) _buildConnectedInfo(context, tonProvider),
      ],
    );
  }

  Widget _buildConnectedInfo(BuildContext context, TonWalletProvider tonProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Address:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tonProvider.getShortAddress(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TON Balance:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tonProvider.getFormattedBalance(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, TonWalletProvider tonProvider) {
    return SizedBox(
      width: double.infinity,
      child: tonProvider.isLoading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: tonProvider.isConnected
                  ? () => tonProvider.disconnectWallet()
                  : () => tonProvider.connectWallet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: tonProvider.isConnected 
                    ? Colors.red 
                    : Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                tonProvider.isConnected ? 'Disconnect Wallet' : 'Connect TON Wallet',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
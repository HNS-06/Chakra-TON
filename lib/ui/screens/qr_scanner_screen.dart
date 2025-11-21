import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/providers/ton_wallet_provider.dart';
import '../../core/providers/user_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  int _scanCount = 0;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleQrCodeDetect(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
          _isProcessing = true;
        });
        
        // Process the scanned QR code
        _processScannedCode(barcode.rawValue!);
        break; // Process only first valid barcode
      }
    }
  }

  void _processScannedCode(String qrData) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final tonProvider = Provider.of<TonWalletProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      // Parse QR code data
      final nextScanCount = _scanCount + 1;
      final parsedData = _parseQRCode(qrData, nextScanCount);
      final String storeName = parsedData['storeName'];
      final double chakraReward = parsedData['chakraReward'];
      final double tonReward = parsedData['tonReward'];
      final bool isPremium = parsedData['isPremium'];
      
      // Update scan count
      _scanCount = nextScanCount;
      
      // Add TON rewards if wallet is connected
      bool tonRewardGiven = false;
      if (tonProvider.isConnected && tonReward > 0) {
        tonRewardGiven = await tonProvider.receiveReward(
          tonReward,
          source: storeName,
          isPremium: isPremium,
        );
      }
      
      // Add Chakra Coins
      walletProvider.addCoins(
        chakraReward,
        storeName,
        tonReward: tonRewardGiven ? tonReward : 0.0,
        isPremium: isPremium,
      );

      final storeOccurrences = walletProvider.transactions
          .where((t) => t.store.toLowerCase() == storeName.toLowerCase())
          .length;
      userProvider.updateStats(
        points: chakraReward.toInt(),
        stores: storeOccurrences == 1 ? 1 : 0,
      );
      
      _showRewardDialog(
        storeName, 
        chakraReward, 
        tonReward, 
        tonRewardGiven, 
        tonProvider.isConnected,
        isPremium,
      );
      
    } catch (e) {
      _showError('Invalid QR code: ${e.toString()}');
    }
  }

  Map<String, dynamic> _parseQRCode(String qrData, int scanCount) {
    // Try to parse as JSON first (for structured data)
    try {
      final jsonData = jsonDecode(qrData);
      if (jsonData is Map<String, dynamic>) {
        return {
          'storeName': jsonData['store'] ?? 'Partner Store',
          'chakraReward': (jsonData['chakra_coins'] ?? 50).toDouble(),
          'tonReward': (jsonData['ton_coins'] ?? 0.0).toDouble(),
          'isPremium': jsonData['premium'] ?? false,
        };
      }
    } catch (_) {
      // If not JSON, try URL scheme parsing
    }
    
    // Try URL scheme parsing (chakra://)
    if (qrData.startsWith('chakra://')) {
      final uri = Uri.parse(qrData);
      switch (uri.host) {
        case 'reward':
          return {
            'storeName': uri.queryParameters['store'] ?? 'Partner Store',
            'chakraReward': double.tryParse(uri.queryParameters['amount'] ?? '50') ?? 50.0,
            'tonReward': double.tryParse(uri.queryParameters['ton'] ?? '0') ?? 0.0,
            'isPremium': uri.queryParameters['premium'] == 'true',
          };
        case 'product':
          return {
            'storeName': 'Product Purchase',
            'chakraReward': 25.0,
            'tonReward': 0.0,
            'isPremium': false,
          };
        case 'promo':
          return {
            'storeName': 'Promotional Offer',
            'chakraReward': double.tryParse(uri.queryParameters['coins'] ?? '100') ?? 100.0,
            'tonReward': 0.0,
            'isPremium': true,
          };
      }
    }
    
    // Fallback: Simple text parsing
    return {
      'storeName': _extractStoreName(qrData),
      'chakraReward': _calculateChakraReward(qrData),
          'tonReward': _calculateTonReward(qrData, scanCount),
      'isPremium': qrData.toLowerCase().contains('premium'),
    };
  }

  void _showRewardDialog(
    String storeName, 
    double chakraReward, 
    double tonReward, 
    bool tonRewardGiven, 
    bool isTonConnected,
    bool isPremium,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Rewards Earned! 🎉',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store: $storeName',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isPremium) 
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM REWARD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Chakra Coins Reward
            _buildRewardRow(
              'Chakra Coins',
              '+${chakraReward.toInt()}',
              Icons.monetization_on,
              const Color(0xFF7B61FF),
            ),
            
            const SizedBox(height: 12),
            
            // TON Reward (if applicable)
            if (isTonConnected && tonRewardGiven)
              _buildRewardRow(
                'TON Cryptocurrency',
                '+${tonReward.toStringAsFixed(3)} TON',
                Icons.currency_bitcoin,
                const Color(0xFF0098EA),
              )
            else if (isTonConnected && tonReward > 0)
              _buildRewardRow(
                'TON Cryptocurrency',
                'Processing...',
                Icons.currency_bitcoin,
                Colors.orange,
              )
            else if (isTonConnected)
              _buildRewardRow(
                'TON Cryptocurrency',
                'No TON this time',
                Icons.currency_bitcoin,
                Colors.grey,
              )
            else
              _buildRewardRow(
                'TON Cryptocurrency',
                'Connect Wallet to Earn',
                Icons.currency_bitcoin,
                Colors.grey,
              ),
            
            const SizedBox(height: 20),
            
            // Progress to next TON reward
            _buildProgressIndicator(context),
            
            const SizedBox(height: 16),
            
            // Scan Statistics
            _buildScanStats(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetScanner();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Continue Scanning'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final progress = (_scanCount % 5) / 5.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TON Reward Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            Text(
              '${(_scanCount % 5)}/5 scans',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withOpacity(0.2),
          color: Theme.of(context).primaryColor,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          _getProgressMessage(_scanCount % 5),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildScanStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Scans', _scanCount.toString()),
          _buildStatItem('Today', '${_scanCount % 10}'),
          _buildStatItem('Streak', '${_scanCount % 7} days'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getProgressMessage(int scans) {
    switch (scans) {
      case 0:
        return 'Start scanning to earn TON!';
      case 1:
        return 'Great start! 4 more scans for TON reward';
      case 2:
        return 'Keep going! 3 more scans needed';
      case 3:
        return 'Almost there! 2 more scans';
      case 4:
        return 'One more scan for TON reward!';
      default:
        return 'Scan to earn rewards';
    }
  }

  String _extractStoreName(String qrData) {
    final lowerData = qrData.toLowerCase();
    if (lowerData.contains('starbucks')) return 'Starbucks';
    if (lowerData.contains('nike')) return 'Nike Store';
    if (lowerData.contains('mcdonald')) return 'McDonald\'s';
    if (lowerData.contains('coffee')) return 'Coffee Shop';
    if (lowerData.contains('restaurant')) return 'Restaurant';
    return 'Partner Store';
  }

  double _calculateChakraReward(String qrData) {
    // Base reward with variations
    const baseReward = 50.0;
    final randomBonus = DateTime.now().millisecond % 30; // 0-29 bonus
    
    if (qrData.toLowerCase().contains('premium')) return baseReward + 100;
    if (qrData.toLowerCase().contains('special')) return baseReward + 50;
    
    return baseReward + randomBonus.toDouble();
  }

  double _calculateTonReward(String qrData, int scanCount) {
    // TON rewards are rarer
    if (qrData.toLowerCase().contains('ton_reward') || 
        qrData.toLowerCase().contains('premium')) {
      return 0.01; // Special TON reward
    }
    
    // Every 5th scan gives TON reward
    if (scanCount % 5 == 0) {
      return 0.005; // Regular TON reward
    }
    
    return 0.0;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _resetScanner();
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _isProcessing = false;
    });
  }

  void _simulateQrScan() {
    // Simulate different types of QR codes for testing
    final testCodes = [
      'chakra://reward?store=starbucks&amount=75&premium=true',
      '{"store": "Nike Store", "chakra_coins": 60, "ton_coins": 0.005}',
      'STARBUCKS_REGULAR_REWARD',
      'PREMIUM_TON_REWARD_OFFER',
    ];
    
    final randomCode = testCodes[DateTime.now().millisecond % testCodes.length];
    _processScannedCode(randomCode);
  }

  @override
  Widget build(BuildContext context) {
    final tonProvider = Provider.of<TonWalletProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: _handleQrCodeDetect,
            ),

            _buildScannerOverlay(),

            _buildHeader(),

            _buildBottomActions(context, tonProvider),

            _buildFlashToggle(),

            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Scan QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner borders
                _buildCorner(Alignment.topLeft),
                _buildCorner(Alignment.topRight),
                _buildCorner(Alignment.bottomLeft),
                _buildCorner(Alignment.bottomRight),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Align QR code within the frame',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white,
              width: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 3 : 0,
            ),
            left: BorderSide(
              color: Colors.white,
              width: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? 3 : 0,
            ),
            right: BorderSide(
              color: Colors.white,
              width: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? 3 : 0,
            ),
            bottom: BorderSide(
              color: Colors.white,
              width: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 3 : 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashToggle() {
    return Positioned(
      top: 80,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () {
            cameraController.toggleTorch();
          },
          icon: const Icon(Icons.flash_on, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, TonWalletProvider tonProvider) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // TON Wallet Status
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.currency_bitcoin,
                  color: tonProvider.isConnected ? Colors.green : Colors.yellow,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  tonProvider.isConnected 
                    ? 'TON Connected • ${tonProvider.tonBalance} TON'
                    : 'Connect TON for Crypto Rewards',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Scan Button
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: IconButton(
              onPressed: _isProcessing ? null : _simulateQrScan,
              icon: Icon(
                Icons.qr_code_scanner, 
                size: 30, 
                color: _isProcessing ? Colors.grey : Colors.white
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isProcessing ? 'Processing...' : 'Tap to scan QR code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Processing Reward...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TonWalletProvider with ChangeNotifier {
  String? _walletAddress;
  double _tonBalance = 0.0;
  bool _isConnected = false;
  bool _isLoading = false;
  int _totalScans = 0;

  String? get walletAddress => _walletAddress;
  double get tonBalance => _tonBalance;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  int get totalScans => _totalScans;

  List<TonRewardRecord> _transactions = [];

  List<TonRewardRecord> get transactions => List.unmodifiable(_transactions);

  // Simulate TON wallet connection
  Future<void> connectWallet() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call/blockchain interaction delay
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes - mock TON wallet address and balance
    _walletAddress = "EQCD39VS5jcptHL8vMjEXrzGaRcCVYto7HUn4bpAOg8xqB2N";
    _tonBalance = 12.5; // Mock TON balance
    _isConnected = true;
    _isLoading = false;

    await _loadTransactions();

    notifyListeners();
  }

  Future<void> disconnectWallet() async {
    _walletAddress = null;
    _tonBalance = 0.0;
    _isConnected = false;
    _transactions = [];
    await _saveTransactions();
    notifyListeners();
  }

  // Simulate sending TON rewards (in real app, this would be actual blockchain transaction)
  Future<bool> sendReward(String toAddress, double amount) async {
    if (!_isConnected) return false;
    
    _isLoading = true;
    notifyListeners();

    // Simulate blockchain transaction processing
    await Future.delayed(const Duration(seconds: 3));

    // In production, this would:
    // 1. Create TON transaction
    // 2. Sign transaction
    // 3. Broadcast to TON blockchain
    // 4. Wait for confirmation
    
    _isLoading = false;
    notifyListeners();
    
    return true; // Transaction success
  }

  // Simulate receiving TON rewards
  Future<bool> receiveReward(
    double amount, {
    String source = 'QR Reward',
    bool isPremium = false,
  }) async {
    if (!_isConnected) return false;
    
    _isLoading = true;
    notifyListeners();

    // Simulate receiving TON (in real app, this would listen to blockchain events)
    await Future.delayed(const Duration(seconds: 2));

    _tonBalance += amount;
    _totalScans++;
    _transactions.insert(
      0,
      TonRewardRecord(
        amount: amount,
        date: DateTime.now(),
        description: source,
        isPremium: isPremium,
      ),
    );
    await _saveTransactions();

    _isLoading = false;
    
    notifyListeners();
    return true;
  }

  // Get shortened wallet address for UI display
  String getShortAddress() {
    if (_walletAddress == null) return "Not Connected";
    return "${_walletAddress!.substring(0, 6)}...${_walletAddress!.substring(_walletAddress!.length - 4)}";
  }

  // Format TON balance for display
  String getFormattedBalance() {
    return '${_tonBalance.toStringAsFixed(2)} TON';
  }

  // ignore: unused_element
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String transactionsJson = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('ton_transactions', transactionsJson);
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('ton_transactions');
    if (transactionsJson != null) {
      final List<dynamic> transactionList = jsonDecode(transactionsJson);
      _transactions = transactionList
          .map((json) => TonRewardRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }
}

class TonRewardRecord {
  final double amount;
  final DateTime date;
  final String description;
  final bool isPremium;

  TonRewardRecord({
    required this.amount,
    required this.date,
    required this.description,
    required this.isPremium,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'isPremium': isPremium,
    };
  }

  factory TonRewardRecord.fromJson(Map<String, dynamic> json) {
    return TonRewardRecord(
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.parse(json['date']),
      description: json['description'] ?? 'Reward',
      isPremium: json['isPremium'] ?? false,
    );
  }
}
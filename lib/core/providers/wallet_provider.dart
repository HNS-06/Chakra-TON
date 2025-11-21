import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WalletProvider with ChangeNotifier {
  double _balance = 1250.0;
  List<ChakraTransaction> _transactions = [];
  bool _isInitialized = false;

  double get balance => _balance;
  List<ChakraTransaction> get transactions => _transactions;

  WalletProvider() {
    _loadData();
  }

  // Load data from shared preferences
  Future<void> _loadData() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load balance
    _balance = prefs.getDouble('chakra_balance') ?? 1250.0;
    
    // Load transactions
    final transactionsJson = prefs.getString('chakra_transactions');
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = json.decode(transactionsJson);
      _transactions = transactionsList.map((item) => ChakraTransaction.fromJson(item)).toList();
    } else {
      // Initial demo transactions
      _transactions = [
        ChakraTransaction(
          store: "Starbucks",
          type: "Earned",
          amount: 50,
          isEarned: true,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          tonReward: 0.005,
          isPremium: true,
        ),
        ChakraTransaction(
          store: "Nike Store",
          type: "Spent",
          amount: 200,
          isEarned: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ChakraTransaction(
          store: "Welcome Bonus",
          type: "Earned",
          amount: 100,
          isEarned: true,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _saveTransactions();
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  // Save transactions to shared preferences
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = json.encode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('chakra_transactions', transactionsJson);
  }

  // Save balance to shared preferences
  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('chakra_balance', _balance);
  }

  void addCoins(
    double amount,
    String store, {
    double tonReward = 0.0,
    bool isPremium = false,
  }) {
    _balance += amount;
    _transactions.insert(
      0,
      ChakraTransaction(
        store: store,
        type: "Earned",
        amount: amount,
        isEarned: true,
        date: DateTime.now(),
        tonReward: tonReward,
        isPremium: isPremium,
      ),
    );
    _saveBalance();
    _saveTransactions();
    notifyListeners();
  }

  void spendCoins(double amount, String store) {
    _balance -= amount;
    _transactions.insert(
      0,
      ChakraTransaction(
        store: store,
        type: "Spent",
        amount: amount,
        isEarned: false,
        date: DateTime.now(),
      ),
    );
    _saveBalance();
    _saveTransactions();
    notifyListeners();
  }

  // Clear all data (for testing)
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chakra_balance');
    await prefs.remove('chakra_transactions');
    _balance = 1250.0;
    _transactions = [
      ChakraTransaction(
        store: "Starbucks",
        type: "Earned",
        amount: 50,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        tonReward: 0.005,
        isPremium: true,
      ),
      ChakraTransaction(
        store: "Nike Store",
        type: "Spent",
        amount: 200,
        isEarned: false,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChakraTransaction(
        store: "Welcome Bonus",
        type: "Earned",
        amount: 100,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    notifyListeners();
  }
}

class ChakraTransaction {
  final String store;
  final String type;
  final double amount;
  final bool isEarned;
  final DateTime date;
  final double tonReward;
  final bool isPremium;

  const ChakraTransaction({
    required this.store,
    required this.type,
    required this.amount,
    required this.isEarned,
    required this.date,
    this.tonReward = 0.0,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'store': store,
      'type': type,
      'amount': amount,
      'isEarned': isEarned,
      'date': date.toIso8601String(),
      'tonReward': tonReward,
      'isPremium': isPremium,
    };
  }

  factory ChakraTransaction.fromJson(Map<String, dynamic> json) {
    return ChakraTransaction(
      store: json['store'] ?? 'Store',
      type: json['type'] ?? 'Earned',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      isEarned: json['isEarned'] ?? true,
      date: DateTime.parse(json['date']),
      tonReward: json['tonReward'] is num
          ? (json['tonReward'] as num).toDouble()
          : double.tryParse(json['tonReward']?.toString() ?? '0') ?? 0.0,
      isPremium: json['isPremium'] ?? false,
    );
  }

  String get formattedDate {
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
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Guest';
  String _email = 'alex@example.com';
  String _phone = '+1 234 567 8900';
  int _memberSince = DateTime.now().subtract(const Duration(days: 45)).millisecondsSinceEpoch;
  String _loyaltyTier = 'Gold';
  int _totalPointsEarned = 1750;
  int _storesVisited = 12;
  bool _isInitialized = false;
  
  // Settings states
  bool _paymentMethodsEnabled = true;
  bool _notificationsEnabled = true;
  String _language = 'English';
  bool _securityEnabled = false;
  bool _privacyPolicyAccepted = false;

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  int get memberSince => _memberSince;
  String get loyaltyTier => _loyaltyTier;
  int get totalPointsEarned => _totalPointsEarned;
  int get storesVisited => _storesVisited;
  bool get paymentMethodsEnabled => _paymentMethodsEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  bool get securityEnabled => _securityEnabled;
  bool get privacyPolicyAccepted => _privacyPolicyAccepted;

  // Tier requirements
  static const Map<String, int> tierRequirements = {
    'Bronze': 0,
    'Silver': 500,
    'Gold': 1500,
    'Diamond': 3500,
  };

  UserProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    _name = prefs.getString('user_name') ?? 'Guest';
    _email = prefs.getString('user_email') ?? 'alex@example.com';
    _phone = prefs.getString('user_phone') ?? '+1 234 567 8900';
    _memberSince = prefs.getInt('user_member_since') ?? DateTime.now().subtract(const Duration(days: 45)).millisecondsSinceEpoch;
    _loyaltyTier = prefs.getString('user_loyalty_tier') ?? 'Gold';
    _totalPointsEarned = prefs.getInt('user_total_points') ?? 1750;
    _storesVisited = prefs.getInt('user_stores_visited') ?? 12;
    
    // Load settings
    _paymentMethodsEnabled = prefs.getBool('payment_methods_enabled') ?? true;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _language = prefs.getString('app_language') ?? 'English';
    _securityEnabled = prefs.getBool('security_enabled') ?? false;
    _privacyPolicyAccepted = prefs.getBool('privacy_policy_accepted') ?? false;
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_phone', _phone);
    await prefs.setInt('user_member_since', _memberSince);
    await prefs.setString('user_loyalty_tier', _loyaltyTier);
    await prefs.setInt('user_total_points', _totalPointsEarned);
    await prefs.setInt('user_stores_visited', _storesVisited);
    
    // Save settings
    await prefs.setBool('payment_methods_enabled', _paymentMethodsEnabled);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('app_language', _language);
    await prefs.setBool('security_enabled', _securityEnabled);
    await prefs.setBool('privacy_policy_accepted', _privacyPolicyAccepted);
  }

  // Loyalty System Methods
  int get pointsToNextTier {
    final currentTierPoints = tierRequirements[_loyaltyTier] ?? 0;
    final nextTier = _getNextTierName();
    if (nextTier == 'Max Tier') return 0;
    final nextTierPoints = tierRequirements[nextTier] ?? 0;
    return nextTierPoints - _totalPointsEarned;
  }

  double get progressToNextTier {
    final currentTierPoints = tierRequirements[_loyaltyTier] ?? 0;
    final nextTier = _getNextTierName();
    if (nextTier == 'Max Tier') return 1.0;
    
    final nextTierPoints = tierRequirements[nextTier] ?? 0;
    final pointsEarnedInCurrentTier = _totalPointsEarned - currentTierPoints;
    final pointsNeededForNextTier = nextTierPoints - currentTierPoints;
    
    return pointsEarnedInCurrentTier / pointsNeededForNextTier;
  }

  String get nextTierDescription {
    final nextTier = _getNextTierName();
    if (nextTier == 'Max Tier') return 'Max Tier Reached';
    return '$nextTier (earn $pointsToNextTier more points)';
  }

  String _getNextTierName() {
    switch (_loyaltyTier) {
      case 'Bronze': return 'Silver';
      case 'Silver': return 'Gold';
      case 'Gold': return 'Diamond';
      default: return 'Max Tier';
    }
  }

  void addPoints(int points) {
    if (points > 0) {
      _totalPointsEarned += points;
      _updateLoyaltyTier();
      _saveData();
      notifyListeners();
    }
  }

  void _updateLoyaltyTier() {
    if (_totalPointsEarned >= tierRequirements['Diamond']!) {
      _loyaltyTier = 'Diamond';
    } else if (_totalPointsEarned >= tierRequirements['Gold']!) {
      _loyaltyTier = 'Gold';
    } else if (_totalPointsEarned >= tierRequirements['Silver']!) {
      _loyaltyTier = 'Silver';
    } else {
      _loyaltyTier = 'Bronze';
    }
  }

  // Settings Methods
  Future<void> togglePaymentMethods(bool enabled) async {
    _paymentMethodsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_methods_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    notifyListeners();
  }

  Future<void> toggleSecurity(bool enabled) async {
    _securityEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_enabled', enabled);
    notifyListeners();
  }

  Future<void> togglePrivacyPolicy(bool accepted) async {
    _privacyPolicyAccepted = accepted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_policy_accepted', accepted);
    notifyListeners();
  }

  // Profile Methods
  Future<void> updateName(String newName) async {
    if (newName.trim().isNotEmpty) {
      _name = newName.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name);
      notifyListeners();
    }
  }

  Future<void> updateEmail(String newEmail) async {
    _email = newEmail.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', _email);
    notifyListeners();
  }

  Future<void> updateBasicProfile(String name, String email) async {
    _name = name.trim();
    _email = email.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
    await prefs.setString('user_email', _email);
    notifyListeners();
  }

  Future<void> logout() async {
    _name = 'Guest';
    _email = '';
    _phone = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    if (name != null) _name = name;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    
    await _saveData();
    notifyListeners();
  }

  void updateStats({int? points, int? stores}) {
    if (points != null) _totalPointsEarned += points;
    if (stores != null) _storesVisited += stores;
    _updateLoyaltyTier();
    _saveData();
    notifyListeners();
  }

  String get formattedMemberSince {
    final date = DateTime.fromMillisecondsSinceEpoch(_memberSince);
    return '${date.day}/${date.month}/${date.year}';
  }

  int get daysAsMember {
    final joinDate = DateTime.fromMillisecondsSinceEpoch(_memberSince);
    final now = DateTime.now();
    return now.difference(joinDate).inDays;
  }

  Color get tierColor {
    switch (_loyaltyTier) {
      case 'Diamond': return const Color(0xFFB9F2FF);
      case 'Gold': return const Color(0xFFFFD700);
      case 'Silver': return const Color(0xFFC0C0C0);
      default: return const Color(0xFFCD7F32);
    }
  }

  IconData getTierIcon() {
    switch (_loyaltyTier) {
      case 'Diamond': return Icons.diamond;
      case 'Gold': return Icons.star;
      case 'Silver': return Icons.workspace_premium;
      default: return Icons.military_tech;
    }
  }

  // Reset user data for testing
  void resetForTesting() {
    _totalPointsEarned = 1750;
    _loyaltyTier = 'Gold';
    _saveData();
    notifyListeners();
  }
}
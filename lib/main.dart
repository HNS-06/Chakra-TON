import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/wallet_provider.dart'; // Your existing Chakra Coins
import 'core/providers/ton_wallet_provider.dart'; // New TON blockchain provider
import 'core/providers/user_provider.dart'; // User Profile Provider
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/login_screen.dart'; // Add login screen import
import 'ui/screens/dashboard_screen.dart'; // Your main dashboard
// ignore: unused_import
import 'ui/screens/wallet_connect_screen.dart'; // Keep for future use

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences and check login status
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => WalletProvider()), // Chakra Coins
        ChangeNotifierProvider(create: (context) => TonWalletProvider()), // TON Blockchain
        ChangeNotifierProvider(create: (context) => UserProvider()), // User Profile
      ],
      child: ChakraApp(
        isLoggedIn: isLoggedIn,
        hasSeenOnboarding: hasSeenOnboarding,
      ),
    ),
  );
}

class ChakraApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool hasSeenOnboarding;
  
  const ChakraApp({
    super.key,
    required this.isLoggedIn,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Chakra Loyalty',
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          // Smart routing based on user state
          home: _getInitialScreen(),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }

  Widget _getInitialScreen() {
    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    } else if (!isLoggedIn) {
      return const LoginScreen();
    } else {
      return const DashboardScreen();
    }
  }
}
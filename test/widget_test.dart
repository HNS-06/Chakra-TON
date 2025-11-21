// Basic smoke test for Chakra Loyalty app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chakra_loyalty/main.dart';

void main() {
  // Setup shared preferences for testing
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: false,
    ));

    // Verify that our onboarding screen is displayed with correct text
    expect(find.text('Loyalty Reimagined'), findsOneWidget);
    expect(find.text('Scan & Earn'), findsNothing);
    expect(find.text('Redeem Anywhere'), findsNothing);

    // Verify that theme toggle is present
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('Onboarding screen has all required elements', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: false,
    ));

    // Check for main UI elements
    expect(find.byType(PageView), findsOneWidget);
    
    // Look for the page indicator by its visual characteristics
    expect(find.byWidgetPredicate(
      (widget) => widget is Container && 
                  widget.decoration != null &&
                  widget.decoration is BoxDecoration
    ), findsWidgets);
    
    expect(find.text('Skip'), findsOneWidget);
    
    // Look for Lottie animations by checking for specific asset containers
    expect(find.byWidgetPredicate(
      (widget) => widget.toString().contains('Lottie') ||
                  widget.toString().contains('lottie')
    ), findsWidgets);
  });

  testWidgets('Theme toggle functionality works', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: false,
    ));

    // Verify initial state
    expect(find.text('Light Mode'), findsOneWidget);
    
    // Find and tap the switch
    final switchWidget = find.byType(Switch);
    await tester.tap(switchWidget);
    await tester.pump();
    
    // Should now show Dark Mode
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets('Navigation from onboarding to login works', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: false,
    ));

    // Find and tap the Skip button
    final skipButton = find.text('Skip');
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    // Should navigate to login screen - look for login elements
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('App shows login screen when onboarding completed', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: true,
    ));

    // Should show login screen directly
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('App shows dashboard when already logged in', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: true,
      hasSeenOnboarding: true,
    ));

    await tester.pumpAndSettle();

    // Should show dashboard directly - look for dashboard elements
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Your Balance'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('Login screen has all required fields', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: true,
    ));

    // Verify login screen elements
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Don\'t have an account?'), findsOneWidget);
  });

  testWidgets('Signup mode toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: false,
      hasSeenOnboarding: true,
    ));

    // Tap on "Sign Up" text to switch to signup mode
    final signUpText = find.text('Sign Up');
    await tester.tap(signUpText);
    await tester.pumpAndSettle();

    // Should now show signup screen
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
  });

  testWidgets('Dashboard shows wallet information', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: true,
      hasSeenOnboarding: true,
    ));

    await tester.pumpAndSettle();

    // Verify wallet and balance information
    expect(find.text('Chakra Coins'), findsOneWidget);
    expect(find.text('TON Wallet'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    
    // Check for quick action buttons
    expect(find.text('Scan & Earn'), findsOneWidget);
    expect(find.text('Redeem'), findsOneWidget);
    expect(find.text('Stores'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('Navigation between screens works', (WidgetTester tester) async {
    await tester.pumpWidget(const ChakraApp(
      isLoggedIn: true,
      hasSeenOnboarding: true,
    ));

    await tester.pumpAndSettle();

    // Tap on History button
    final historyButton = find.text('History');
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    // Should navigate to transaction history
    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });
}
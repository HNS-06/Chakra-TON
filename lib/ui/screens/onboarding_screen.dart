import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/branding_utils.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart'; // Add login screen import

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: "Loyalty Reimagined",
      subtitle: "Turn every purchase into rewards with blockchain-powered loyalty tokens",
      lottieAsset: "assets/animations/rewards.json",
      gradient: [Color(0xFF7B61FF), Color(0xFF9E8EFF)],
    ),
    const OnboardingPage(
      title: "Scan & Earn",
      subtitle: "Simply scan QR codes at partner stores to collect Chakra Coins instantly",
      lottieAsset: "assets/animations/qrcode.json",
      gradient: [Color(0xFF00C6FF), Color(0xFF0072FF)],
    ),
    const OnboardingPage(
      title: "Redeem Anywhere",
      subtitle: "Use your earned coins across all partner stores in the network",
      lottieAsset: "assets/animations/shopping_success.json",
      gradient: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Column(
            children: [
              _buildBrandHeader(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),
              _buildPageIndicator(),
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            BrandingUtils.chakraLogo(size: 60),
            const SizedBox(height: 16),
            BrandingUtils.appName(fontSize: 28, color: Colors.white),
            BrandingUtils.tagline(color: Colors.white.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _pages[_currentPage].gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ).animate().fade(duration: const Duration(milliseconds: 800));
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Lottie.asset(
              page.lottieAsset,
              animate: true,
              fit: BoxFit.contain,
              frameRate: FrameRate.max,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _pages.length,
      effect: ExpandingDotsEffect(
        dotColor: Colors.white.withOpacity(0.4),
        activeDotColor: Colors.white,
        dotHeight: 8,
        dotWidth: 8,
        spacing: 12,
        expansionFactor: 3,
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 600));
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          _currentPage == _pages.length - 1
              ? _buildAnimatedButton(
                  "Get Started",
                  () => _completeOnboarding(),
                  isPrimary: true,
                )
              : _buildAnimatedButton(
                  "Skip",
                  () => _completeOnboarding(),
                  isPrimary: false,
                ),
          const SizedBox(height: 16),
          _buildThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(String text, VoidCallback onTap, {bool isPrimary = true}) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: isPrimary ? Colors.white : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: isPrimary ? const Color(0xFF7B61FF) : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 800)).slideY(begin: 0.5, end: 0);
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
              activeColor: Colors.white,
            ),
          ],
        ).animate().fadeIn(delay: const Duration(milliseconds: 1000));
      },
    );
  }

  // Updated method to complete onboarding and navigate to login
  Future<void> _completeOnboarding() async {
    // Save that user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final List<Color> gradient;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.gradient,
  });
}
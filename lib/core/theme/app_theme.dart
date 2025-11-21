import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7B61FF);
  static const Color secondaryColor = Color(0xFF00C6FF);
  static const Color accentColor = Color(0xFF00D2A8);
  static const Color warningColor = Color(0xFFFC466B);
  
  // Loyalty Tier Colors
  static const Color diamondColor = Color(0xFFB9F2FF);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color silverColor = Color(0xFFC0C0C0);
  static const Color bronzeColor = Color(0xFFCD7F32);
  
  // Progress & Settings Colors
  static const Color progressBackground = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF48BB78);
  static const Color settingsCardColor = Color(0xFFF7FAFC);
  static const Color settingsBorderColor = Color(0xFFE2E8F0);
  
  static String get primaryFont => 'Inter';
  static String get displayFont => 'Plus Jakarta Sans';
  
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryColorDark: const Color(0xFF5A4BCC),
      primaryColorLight: const Color(0xFF9E8EFF),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.getFont(
          displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1D29),
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont(
          displayFont,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1D29),
        ),
        displayMedium: GoogleFonts.getFont(
          displayFont,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1D29),
        ),
        titleLarge: GoogleFonts.getFont(
          primaryFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1D29),
        ),
        bodyLarge: GoogleFonts.getFont(
          primaryFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4A5568),
        ),
        bodyMedium: GoogleFonts.getFont(
          primaryFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF718096),
        ),
        labelSmall: GoogleFonts.getFont(
          primaryFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF718096),
        ),
      ),
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: progressBackground,
      ),
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey[300]!;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey[400]!;
        }),
      ),
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF8B7AFF),
      primaryColorDark: const Color(0xFF6D5CE8),
      primaryColorLight: const Color(0xFFA99EFF),
      scaffoldBackgroundColor: const Color(0xFF0F1218),
      cardColor: const Color(0xFF1A1D29),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.getFont(
          displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B7AFF)),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8B7AFF),
        secondary: Color(0xFF00C6FF),
        surface: Color(0xFF1A1D29),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont(
          displayFont,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.getFont(
          displayFont,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.getFont(
          primaryFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.getFont(
          primaryFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFCBD5E0),
        ),
        bodyMedium: GoogleFonts.getFont(
          primaryFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA0AEC0),
        ),
        labelSmall: GoogleFonts.getFont(
          primaryFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFA0AEC0),
        ),
      ),
      // Progress indicator theme for dark mode
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF8B7AFF),
        linearTrackColor: Color(0xFF2D3748),
      ),
      // Switch theme for dark mode
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF8B7AFF);
          }
          return Colors.grey[600]!;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF8B7AFF).withOpacity(0.5);
          }
          return Colors.grey[700]!;
        }),
      ),
      // Divider theme for dark mode
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D3748),
        thickness: 1,
        space: 0,
      ),
    );
  }

  // Helper methods for loyalty tier styling
  static Color getTierColor(String tier) {
    switch (tier) {
      case 'Diamond':
        return diamondColor;
      case 'Gold':
        return goldColor;
      case 'Silver':
        return silverColor;
      case 'Bronze':
        return bronzeColor;
      default:
        return bronzeColor;
    }
  }

  static Color getTierTextColor(String tier) {
    switch (tier) {
      case 'Diamond':
        return const Color(0xFF0F4C75);
      case 'Gold':
        return const Color(0xFF8B6914);
      case 'Silver':
        return const Color(0xFF525252);
      case 'Bronze':
        return const Color(0xFF8B4513);
      default:
        return const Color(0xFF8B4513);
    }
  }

  static Color getTierBackgroundColor(String tier, bool isDark) {
    switch (tier) {
      case 'Diamond':
        return isDark ? const Color(0xFF0A2A3A) : const Color(0xFFE6F7FF);
      case 'Gold':
        return isDark ? const Color(0xFF332900) : const Color(0xFFFFFBEB);
      case 'Silver':
        return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7);
      case 'Bronze':
        return isDark ? const Color(0xFF3A2600) : const Color(0xFFFDF6E3);
      default:
        return isDark ? const Color(0xFF3A2600) : const Color(0xFFFDF6E3);
    }
  }

  // Progress bar gradient
  static Gradient get progressGradient => const LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // Settings section styling
  static BoxDecoration get settingsSectionDecoration => BoxDecoration(
        color: settingsCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settingsBorderColor, width: 1),
      );

  static BoxDecoration get settingsSectionDecorationDark => BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      );
}
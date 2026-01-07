import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Using Blue theme
  static const Color primaryOrange = Color(0xFF5BA4F5); // Now using blue
  static const Color primaryYellow = Color(0xFF64B5F6);  // Light blue
  static const Color primaryBlue = Color(0xFF5BA4F5);
  
  // Light Theme Background Colors - Soft grey to complement black card
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundPeach = Color(0xFFEFEFF1);
  static const Color cardBackground = Colors.white;
  
  // Dark Theme Background Colors
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardBackgroundDark = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Colors.white;
  static const Color textDarkPrimary = Color(0xFFE0E0E0);
  static const Color textDarkSecondary = Color(0xFF9E9E9E);
  
  // Category Colors
  static const Color foodColor = Color(0xFF4A90E2);
  static const Color shoppingColor = Color(0xFFFF9F43);
  static const Color entertainmentColor = Color(0xFFFF6B6B);
  static const Color travelColor = Color(0xFF5F9EE9);
  static const Color homeColor = Color(0xFFFFB347);
  static const Color petColor = Color(0xFF9B59B6);
  static const Color rechargeColor = Color(0xFF2ECC71);
  static const Color incomeColor = Color(0xFF27AE60);
  static const Color expenseColor = Color(0xFFE74C3C);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient saveButtonGradient = LinearGradient(
    colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF), Color(0xFF667EEA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient chartBarGradient = LinearGradient(
    colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  
  // Theme Data - Light (Soft grey background with black card accent)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.promptTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
      dividerColor: Colors.grey.shade300,
    );
  }

  // Theme Data - Dark
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.promptTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDarkPrimary,
        ),
        iconTheme: const IconThemeData(color: textDarkPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBackgroundDark,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
      ),
      dividerColor: Colors.grey.shade800,
    );
  }
}

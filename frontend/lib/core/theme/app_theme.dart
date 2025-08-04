import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryOrangeLight = Color(0xFFFFB74D);
  static const Color secondaryOrangeDark = Color(0xFFF57C00);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentYellow = Color(0xFFFFEB3B);
  static const Color accentRed = Color(0xFFF44336);
  
  // Neutral Colors
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralBlack = Color(0xFF000000);
  static const Color neutralGrey50 = Color(0xFFFAFAFA);
  static const Color neutralGrey100 = Color(0xFFF5F5F5);
  static const Color neutralGrey200 = Color(0xFFEEEEEE);
  static const Color neutralGrey300 = Color(0xFFE0E0E0);
  static const Color neutralGrey400 = Color(0xFFBDBDBD);
  static const Color neutralGrey500 = Color(0xFF9E9E9E);
  static const Color neutralGrey600 = Color(0xFF757575);
  static const Color neutralGrey700 = Color(0xFF616161);
  static const Color neutralGrey800 = Color(0xFF424242);
  static const Color neutralGrey900 = Color(0xFF212121);
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryGreenLight,
        secondary: secondaryOrange,
        secondaryContainer: secondaryOrangeLight,
        surface: neutralWhite,
        background: neutralGrey50,
        error: errorRed,
        onPrimary: neutralWhite,
        onSecondary: neutralBlack,
        onSurface: neutralGrey900,
        onBackground: neutralGrey900,
        onError: neutralWhite,
      ),
      textTheme: _buildTextTheme(neutralGrey900),
      appBarTheme: const AppBarTheme(
        backgroundColor: neutralWhite,
        foregroundColor: neutralGrey900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: neutralGrey900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      cardTheme: CardTheme(
        color: neutralWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: neutralWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutralGrey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          color: neutralGrey600,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        hintStyle: const TextStyle(
          color: neutralGrey500,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neutralWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: neutralGrey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: neutralWhite,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutralGrey200,
        selectedColor: primaryGreenLight,
        labelStyle: const TextStyle(
          color: neutralGrey700,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: neutralGrey300,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreenLight,
        primaryContainer: primaryGreen,
        secondary: secondaryOrangeLight,
        secondaryContainer: secondaryOrange,
        surface: neutralGrey800,
        background: neutralGrey900,
        error: errorRed,
        onPrimary: neutralBlack,
        onSecondary: neutralBlack,
        onSurface: neutralGrey100,
        onBackground: neutralGrey100,
        onError: neutralWhite,
      ),
      textTheme: _buildTextTheme(neutralGrey100),
      appBarTheme: const AppBarTheme(
        backgroundColor: neutralGrey900,
        foregroundColor: neutralGrey100,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: neutralGrey100,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      cardTheme: CardTheme(
        color: neutralGrey800,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenLight,
          foregroundColor: neutralBlack,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreenLight,
          side: const BorderSide(color: primaryGreenLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutralGrey800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreenLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          color: neutralGrey400,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        hintStyle: const TextStyle(
          color: neutralGrey500,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neutralGrey900,
        selectedItemColor: primaryGreenLight,
        unselectedItemColor: neutralGrey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreenLight,
        foregroundColor: neutralBlack,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutralGrey700,
        selectedColor: primaryGreen,
        labelStyle: const TextStyle(
          color: neutralGrey300,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: neutralGrey700,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Build Text Theme
  static TextTheme _buildTextTheme(Color color) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
} 
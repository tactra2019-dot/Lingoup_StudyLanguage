import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryMint,
        secondary: AppColors.accentBlue,
        surface: AppColors.surfaceWhite,
        background: AppColors.background,
        error: AppColors.errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: Colors.white, letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceWhite,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMint,
          side: const BorderSide(color: AppColors.primaryMint, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2EBF0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2EBF0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryMint, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textHint, fontSize: 14, fontFamily: 'Nunito',
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryMint,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8F0F4),
        thickness: 1,
      ),
    );
  }
}

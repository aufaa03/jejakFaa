import 'package:flutter/material.dart';

class AppColors {
  // primary adventure tones
  static const primary = Color(0xFF2E7D32); // deep forest green
  static const primaryVariant = Color(0xFF1B5E20);
  static const secondary = Color(0xFF0288D1); // sky blue
  static const accent = Color(0xFFFFB74D); // warm sunset
  static const background = Color(0xFFF6F6F6);
  static const surface = Colors.white;
  static const darkBackground = Color(0xFF0B0F12);
}

// Use the Inter font (make sure pubspec.yaml fonts set to family 'Inter')
class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F1720),
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F1720)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.12),
      labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      background: AppColors.darkBackground,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF071018),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Color(0xFF071018),
      indicatorColor: AppColors.primary.withOpacity(0.18),
      labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12)),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF081018),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white60),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white60),
    ),
  );
}

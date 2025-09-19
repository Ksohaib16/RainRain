import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Modern gradient colors
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  static ThemeData get dark => ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryPurple,
      tertiary: accentPink,
      surface: surfaceDark,
      background: backgroundDark,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardTheme: CardThemeData(
      color: cardDark.withOpacity(0.8),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: primaryBlue.withOpacity(0.3),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryBlue.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryBlue),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );

  // Glass morphism effect
  static BoxDecoration glassMorphism = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
      colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
  );

  // Weather condition gradients
  static LinearGradient getWeatherGradient(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'clouds':
        return const LinearGradient(
          colors: [Color(0xFFA4B0BE), Color(0xFF57606F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          colors: [Color(0xFF5F27CD), Color(0xFF341F97)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'thunderstorm':
        return const LinearGradient(
          colors: [Color(0xFF2D3436), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'snow':
        return const LinearGradient(
          colors: [Color(0xFFECE9E6), Color(0xFFBBC4C2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}

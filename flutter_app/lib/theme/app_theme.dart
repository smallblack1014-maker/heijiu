import 'package:flutter/material.dart';

class AppTheme {
  // 酒红色系
  static const Color wineRed = Color(0xFF722F37);
  static const Color wineRedDark = Color(0xFF4A1C22);
  static const Color wineRedLight = Color(0xFF9B4449);
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color wineGold = Color(0xFFD4A853);

  // 深色主题色
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF2D2D44);

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle score = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: wineRed,
  );

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createWineMaterialColor(),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: wineRed,
        secondary: wineGold,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: wineRed),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: wineRed,
        unselectedItemColor: textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: wineRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: wineRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: wineRed,
        inactiveTrackColor: wineRed.withValues(alpha: 0.2),
        thumbColor: wineRed,
        overlayColor: wineRed.withValues(alpha: 0.1),
        valueIndicatorColor: wineRed,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      chipTheme: ChipThemeData(
        selectedColor: wineRed,
        backgroundColor: Colors.grey[100],
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createWineMaterialColor(),
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: wineRedLight,
        secondary: wineGold,
        surface: darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: darkCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: wineRedLight,
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF16213E),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: wineRedLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: wineRedLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: darkCard,
        filled: true,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: wineRedLight,
        inactiveTrackColor: wineRedLight.withValues(alpha: 0.2),
        thumbColor: wineRedLight,
        overlayColor: wineRedLight.withValues(alpha: 0.1),
        valueIndicatorColor: wineRedLight,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      chipTheme: ChipThemeData(
        selectedColor: wineRedLight,
        backgroundColor: const Color(0xFF3D3D55),
        labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3D3D55),
        thickness: 1,
      ),
    );
  }

  static MaterialColor _createWineMaterialColor() {
    final swatches = <int, Color>{
      50: const Color(0xFFF3E6E7),
      100: const Color(0xFFE0C0C3),
      200: const Color(0xFFCC969A),
      300: const Color(0xFFB36C72),
      400: const Color(0xFF9F4D53),
      500: wineRed,
      600: const Color(0xFF662A31),
      700: const Color(0xFF59252B),
      800: const Color(0xFF4C1F25),
      900: const Color(0xFF3A181C),
    };
    return MaterialColor(0xFF722F37, swatches);
  }
}

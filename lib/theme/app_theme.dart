// app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getAppTheme() {
  return ThemeData(
    primaryColor: Color(0xFF8C6A4B),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF8C6A4B),
      secondary: Color(0xFFCD9F68),
      background: Color(0xFFF8F5F1),
    ),
    scaffoldBackgroundColor: Color(0xFFF8F5F1),
    textTheme: TextTheme(
      headlineSmall: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E2E),
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        color: Color(0xFF2E2E2E).withOpacity(0.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8C6A4B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 1,
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      iconTheme: IconThemeData(color: Color(0xFF2E2E2E)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF8C6A4B),
      unselectedItemColor: Color(0xFF2E2E2E).withOpacity(0.5),
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: Color(0xFF2E2E2E).withOpacity(0.6),
      suffixIconColor: Color(0xFFCD9F68),
      hintStyle: GoogleFonts.manrope(
        fontSize: 14,
        color: Color(0xFF2E2E2E).withOpacity(0.5),
      ),
    ),
  );
}

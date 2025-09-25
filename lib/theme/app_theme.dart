// app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_utils.dart';

class AppColors {
  static const Color primary = Color(0xFF8C6A4B);
  static const Color secondary = Color(0xFFCD9F68);
  static const Color background = Color(0xFFF8F5F1);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF2E2E2E);
  static const Color accent = Color(0xFF005230);
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color textLight = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}

ThemeData getAppTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // Responsive Typography Scale Builder
    textTheme: _buildResponsiveTextTheme(),

    // Responsive Button Styles
    elevatedButtonTheme: _buildResponsiveElevatedButtonTheme(),
    filledButtonTheme: _buildResponsiveFilledButtonTheme(),
    outlinedButtonTheme: _buildResponsiveOutlinedButtonTheme(),
    textButtonTheme: _buildResponsiveTextButtonTheme(),

    // Responsive Card Style
    cardTheme: _buildResponsiveCardTheme(),

    // Responsive App Bar
    appBarTheme: _buildResponsiveAppBarTheme(),

    // Responsive Bottom Navigation
    bottomNavigationBarTheme: _buildResponsiveBottomNavTheme(),

    // Responsive Input Decoration
    inputDecorationTheme: _buildResponsiveInputTheme(),

    // Responsive Chip Theme
    chipTheme: _buildResponsiveChipTheme(),

    // Responsive Divider
    dividerTheme: _buildResponsiveDividerTheme(),
  );
}

// Helper functions for responsive theme components
TextTheme _buildResponsiveTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 32, // Will be scaled responsively
      fontWeight: FontWeight.w800,
      color: AppColors.onSurface,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
      letterSpacing: -0.25,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    headlineLarge: GoogleFonts.montserrat(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleMedium: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleSmall: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    bodyLarge: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      height: 1.4,
    ),
    bodySmall: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight,
      height: 1.3,
    ),
    labelLarge: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
    ),
    labelMedium: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
    ),
    labelSmall: GoogleFonts.montserrat(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textLight,
    ),
  );
}

ElevatedButtonThemeData _buildResponsiveElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ), // Will be handled in widgets
      textStyle: GoogleFonts.montserrat(
        fontSize: 14, // Will be scaled in widgets
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

FilledButtonThemeData _buildResponsiveFilledButtonTheme() {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

OutlinedButtonThemeData _buildResponsiveOutlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

TextButtonThemeData _buildResponsiveTextButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

CardThemeData _buildResponsiveCardTheme() {
  return CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.divider, width: 0.5),
    ),
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
  );
}

AppBarTheme _buildResponsiveAppBarTheme() {
  return AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    centerTitle: false,
    titleSpacing: 20, // Will be scaled in widgets
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    iconTheme: IconThemeData(color: AppColors.onSurface, size: 24),
    actionsIconTheme: IconThemeData(color: AppColors.onSurface, size: 24),
  );
}

BottomNavigationBarThemeData _buildResponsiveBottomNavTheme() {
  return BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textLight,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: GoogleFonts.montserrat(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.montserrat(
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
  );
}

InputDecorationTheme _buildResponsiveInputTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
    labelStyle: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textLight,
    ),
    hintStyle: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight,
    ),
    prefixIconColor: AppColors.textLight,
    suffixIconColor: AppColors.textLight,
  );
}

ChipThemeData _buildResponsiveChipTheme() {
  return ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primary,
    labelStyle: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.divider),
    ),
    selectedShadowColor: Colors.transparent,
    shadowColor: Colors.transparent,
  );
}

DividerThemeData _buildResponsiveDividerTheme() {
  return DividerThemeData(color: AppColors.divider, thickness: 0.5, space: 1);
}

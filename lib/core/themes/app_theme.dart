import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      surface: const Color(0xFFE3F2FD),
    ),
    textTheme: GoogleFonts.openSansTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    ),
  );

  // Post-specific styling constants
  static const double postCardMargin = 16.0;
  static const double postHeaderPadding = 12.0;
  static const double postContentPadding = 16.0;
  static const double postActionsPadding = 8.0;
  static const double avatarRadius = 20.0;
  static const double cardBorderRadius = 12.0;
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Bhagavad Gita Sacred Palette ──────────────────────────────────────────
  static const Color primaryColor   = Color(0xFFD4A017); // Sacred Gold
  static const Color secondaryColor = Color(0xFFB8860B); // Dark Goldenrod
  static const Color accentColor    = Color(0xFFFF6B35); // Saffron / Agni
  static const Color backgroundColor= Color(0xFF0A0C18); // Deep Midnight Navy
  static const Color surfaceColor   = Color(0xFF141828); // Dark Lapis
  static const Color cardColor      = Color(0xFF1E2235); // Deep Indigo Card
  static const Color textPrimary    = Color(0xFFF5E6C8); // Warm Cream
  static const Color textSecondary  = Color(0xFFB0A090); // Muted Sandstone
  static const Color shimmerGold    = Color(0xFFFFD700); // Pure Gold
  static const Color saffron        = Color(0xFFFF9933); // Saffron Flag

  // Legacy alias used in older files
  static const Color primaryLight   = Color(0xFFE8C040);
  static const Color darkBrown      = Color(0xFF0A0C18);

  // ── Decoration Helpers ────────────────────────────────────────────────────
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.04),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: primaryColor.withOpacity(0.25), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.08),
        blurRadius: 24,
        spreadRadius: 2,
      ),
    ],
  );

  static BoxDecoration get goldCardDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.18),
        surfaceColor,
      ],
    ),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: primaryColor.withOpacity(0.35), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get softCardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // ── Gradient backgrounds ──────────────────────────────────────────────────
  static BoxDecoration get sacredBgDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A0C18),
        const Color(0xFF0D1030),
        const Color(0xFF0A0C18),
      ],
    ),
  );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textSecondary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5E6C8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 10,
          shadowColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}

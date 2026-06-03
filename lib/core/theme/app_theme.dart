import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// The complete dark theme for Arise.
/// All screens inherit from this — you never hardcode colors in widgets.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    // Force the status bar to show light icons on dark background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ── Color scheme ───────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:       AppColors.primary,
        secondary:     AppColors.secondary,
        surface:       AppColors.surface,
        error:         AppColors.error,
        onPrimary:     Colors.white,
        onSecondary:   Colors.white,
        onSurface:     AppColors.textPrimary,
        onError:       Colors.white,
      ),

      // ── Background ────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ── Typography (Rajdhani gives a futuristic feel) ─────────
      textTheme: GoogleFonts.rajdhaniTextTheme().copyWith(
        displayLarge: GoogleFonts.rajdhani(
          fontSize: 48, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.rajdhani(
          fontSize: 36, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: 1.5,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: 1,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.rajdhani(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: 1,
        ),
      ),

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryGlow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.rajdhani(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.rajdhani(
            fontSize: 11, fontWeight: FontWeight.w400,
            color: AppColors.textHint,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return const IconThemeData(color: AppColors.textHint, size: 22);
        }),
      ),

      // ── Cards ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // ── Input fields ──────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        hintStyle: GoogleFonts.rajdhani(
          color: AppColors.textHint, fontSize: 14,
        ),
        labelStyle: GoogleFonts.rajdhani(
          color: AppColors.textSecondary, fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
      ),

      // ── Elevated buttons ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1,
          ),
        ),
      ),

      // ── Text buttons ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.rajdhani(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Chips ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        labelStyle: GoogleFonts.rajdhani(
          color: AppColors.textSecondary, fontSize: 12,
        ),
        side: const BorderSide(color: AppColors.surfaceBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ── Dividers ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 0.5,
        space: 0,
      ),

      // ── Icon ──────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }
}
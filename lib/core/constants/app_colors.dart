import 'package:flutter/material.dart';

/// Every color used in Arise lives here.
/// Dark theme inspired by Solo Leveling — deep navy blacks, electric blues, purples.
class AppColors {
  AppColors._(); // Prevents instantiation

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background       = Color(0xFF0A0A0F); // Near-black base
  static const Color surface          = Color(0xFF12121A); // Card surfaces
  static const Color surfaceElevated  = Color(0xFF1A1A26); // Elevated cards
  static const Color surfaceBorder    = Color(0xFF2A2A3D); // Subtle borders

  // ── Primary Accent — Electric Blue ───────────────────────────
  static const Color primary          = Color(0xFF4B7BF5); // Main blue
  static const Color primaryLight     = Color(0xFF7BA3FF); // Hover / lighter
  static const Color primaryDark      = Color(0xFF2D5BD4); // Pressed state
  static const Color primaryGlow      = Color(0x334B7BF5); // Glow effect (20% opacity)

  // ── Secondary Accent — Purple ─────────────────────────────────
  static const Color secondary        = Color(0xFF8B5CF6); // Main purple
  static const Color secondaryLight   = Color(0xFFAB7FF8); // Lighter purple
  static const Color secondaryGlow    = Color(0x338B5CF6); // Purple glow

  // ── XP / Progress ─────────────────────────────────────────────
  static const Color xpColor          = Color(0xFF4B7BF5); // XP bar fill
  static const Color xpBackground     = Color(0xFF1E2240); // XP bar track

  // ── Rank Colors (E → S) ───────────────────────────────────────
  static const Color rankE            = Color(0xFF9CA3AF); // Gray
  static const Color rankD            = Color(0xFF10B981); // Green
  static const Color rankC            = Color(0xFF3B82F6); // Blue
  static const Color rankB            = Color(0xFF8B5CF6); // Purple
  static const Color rankA            = Color(0xFFF59E0B); // Gold
  static const Color rankS            = Color(0xFFEF4444); // Red (legendary)

  // ── Stats Colors ─────────────────────────────────────────────
  static const Color statStr          = Color(0xFFEF4444); // STR — Red
  static const Color statInt          = Color(0xFF3B82F6); // INT — Blue
  static const Color statCre          = Color(0xFFF59E0B); // CRE — Gold
  static const Color statCha          = Color(0xFFEC4899); // CHA — Pink
  static const Color statSkl          = Color(0xFF10B981); // SKL — Green

  // ── Semantic ─────────────────────────────────────────────────
  static const Color success          = Color(0xFF10B981); // Green
  static const Color warning          = Color(0xFFF59E0B); // Amber
  static const Color error            = Color(0xFFEF4444); // Red
  static const Color info             = Color(0xFF3B82F6); // Blue

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary      = Color(0xFFE2E8F0); // Almost white
  static const Color textSecondary    = Color(0xFF94A3B8); // Muted
  static const Color textHint         = Color(0xFF4A5568); // Very muted

  // ── Streak / Special ─────────────────────────────────────────
  static const Color streakFire       = Color(0xFFFF6B35); // Orange flame

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceElevated, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns the color associated with a rank string like "S", "A", "E"
  static Color forRank(String rank) {
    switch (rank.toUpperCase()) {
      case 'S': return rankS;
      case 'A': return rankA;
      case 'B': return rankB;
      case 'C': return rankC;
      case 'D': return rankD;
      default:  return rankE;
    }
  }

  /// Returns the color for a stat abbreviation like "STR", "INT"
  static Color forStat(String stat) {
    switch (stat.toUpperCase()) {
      case 'STR': return statStr;
      case 'INT': return statInt;
      case 'CRE': return statCre;
      case 'CHA': return statCha;
      case 'SKL': return statSkl;
      default:    return textSecondary;
    }
  }
}
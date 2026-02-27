import 'package:flutter/material.dart';

/// Finamio premium dark-first color palette
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0B0E1A);
  static const Color surface = Color(0xFF141826);
  static const Color surfaceElevated = Color(0xFF1C2236);
  static const Color card = Color(0xFF1A1F33);
  static const Color cardBorder = Color(0xFF252A40);

  // ── Brand accent (electric indigo + cyan glow) ───────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF4A43CC);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentGlow = Color(0x2900D4FF);

  // ── Semantic colours ─────────────────────────────────────────────────────
  static const Color income = Color(0xFF00D97E);
  static const Color incomeSubtle = Color(0x1A00D97E);
  static const Color expense = Color(0xFFFF5D78);
  static const Color expenseSubtle = Color(0x1AFF5D78);
  static const Color warning = Color(0xFFFFAA00);
  static const Color warningSubtle = Color(0x1AFFAA00);
  static const Color goal = Color(0xFF845EF7);
  static const Color goalSubtle = Color(0x1A845EF7);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF9BA3C0);
  static const Color textTertiary = Color(0xFF5B6180);
  static const Color textDisabled = Color(0xFF3A4060);

  // ── Utility ──────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF1E2438);
  static const Color overlay = Color(0x99000000);
  static const Color shimmerBase = Color(0xFF1C2236);
  static const Color shimmerHighlight = Color(0xFF252A40);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00D97E), Color(0xFF00B8A9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF5D78), Color(0xFFFF9A44)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goalGradient = LinearGradient(
    colors: [Color(0xFF845EF7), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B0E1A), Color(0xFF0F1422)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

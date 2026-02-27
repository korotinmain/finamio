import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic spacing constants used throughout Finamio
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // Padding helpers
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(xxl);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  static BorderRadius get cardRadius => BorderRadius.circular(radiusXl);
  static BorderRadius get buttonRadius => BorderRadius.circular(radiusMd);
  static BorderRadius get chipRadius => BorderRadius.circular(radiusFull);
  static BorderRadius get inputRadius => BorderRadius.circular(radiusMd);

  // Elevation / shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get incomeShadow => [
    BoxShadow(
      color: AppColors.income.withOpacity(0.25),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get expenseShadow => [
    BoxShadow(
      color: AppColors.expense.withOpacity(0.25),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];
}

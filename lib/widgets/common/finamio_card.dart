import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Glass-morphism style card with optional gradient border
class FinamioCard extends StatelessWidget {
  const FinamioCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.shadows,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? AppSpacing.cardRadius;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? AppColors.card) : null,
        borderRadius: br,
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
          width: borderWidth,
        ),
        boxShadow: shadows ?? AppSpacing.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: br,
            splashColor: AppColors.primary.withOpacity(0.05),
            highlightColor: AppColors.primary.withOpacity(0.03),
            child: Padding(
              padding: padding ?? AppSpacing.cardPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width gradient banner card
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.primaryGradient,
    this.padding,
    this.onTap,
    this.height,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return FinamioCard(
      gradient: gradient,
      borderColor: Colors.transparent,
      padding: padding,
      onTap: onTap,
      shadows: [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(0.35),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ],
      child: height != null ? SizedBox(height: height, child: child) : child,
    );
  }
}

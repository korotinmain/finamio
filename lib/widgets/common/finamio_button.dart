import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

/// Premium gradient button with optional loading state and animation
class FinamioButton extends StatelessWidget {
  const FinamioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradient,
    this.height = 52,
    this.width,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isOutlined;
  final Gradient? gradient;
  final double height;
  final double? width;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return _OutlinedVariant(
        label: label,
        onPressed: enabled && !isLoading ? onPressed : null,
        icon: icon,
        isLoading: isLoading,
        height: height,
        width: width,
      );
    }

    return SizedBox(
          height: height,
          width: width ?? double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient:
                  enabled && !isLoading
                      ? (gradient ?? AppColors.primaryGradient)
                      : null,
              color: enabled && !isLoading ? null : AppColors.surfaceElevated,
              borderRadius: AppSpacing.buttonRadius,
              boxShadow: enabled && !isLoading ? AppSpacing.glowShadow : [],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: AppSpacing.buttonRadius,
              child: InkWell(
                onTap: enabled && !isLoading ? onPressed : null,
                borderRadius: AppSpacing.buttonRadius,
                child: Center(
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                icon!,
                                const SizedBox(width: AppSpacing.sm),
                              ],
                              Text(label, style: AppTextStyles.labelLarge),
                            ],
                          ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.97, end: 1.0, duration: 300.ms);
  }
}

class _OutlinedVariant extends StatelessWidget {
  const _OutlinedVariant({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: onPressed != null ? AppColors.primary : AppColors.cardBorder,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(label, style: AppTextStyles.labelLarge),
                  ],
                ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hero type
// ─────────────────────────────────────────────────────────────────────────────

enum AuthHeroType { signIn, signUp, forgotPassword }

// ─────────────────────────────────────────────────────────────────────────────
// Friendly error mapper (shared across all auth screens)
// ─────────────────────────────────────────────────────────────────────────────

String authFriendlyError(Object? e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
    }
  }
  assert(() {
    // ignore: avoid_print
    print('[AuthError] ${e.runtimeType}: $e');
    return true;
  }());
  if (e is Exception) {
    final msg = e.toString();
    if (msg.contains('aborted') ||
        msg.contains('canceled') ||
        msg.contains('cancelled')) {
      return 'Sign-in cancelled.';
    }
    if (msg.contains('network')) {
      return 'Network error. Check your connection.';
    }
  }
  return 'Something went wrong. Please try again.';
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero illustration widget
// ─────────────────────────────────────────────────────────────────────────────

class AuthHeroWidget extends StatelessWidget {
  const AuthHeroWidget({super.key, required this.type, this.height = 200});
  final AuthHeroType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient radial glow backdrop
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.22),
                  AppColors.accent.withOpacity(0.07),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Secondary accent glow
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central card
          _HeroCard(type: type),

          // Top-right floating pill
          Positioned(
            top: 14,
            right: 40,
            child: _FloatingPill(
              icon: _topIcon(type),
              color: _topColor(type),
              label: _topLabel(type),
            ),
          ),

          // Bottom-left floating pill
          Positioned(
            bottom: 18,
            left: 36,
            child: _FloatingPill(
              icon: _bottomIcon(type),
              color: AppColors.primary,
              label: _bottomLabel(type),
            ),
          ),
        ],
      ),
    );
  }

  IconData _topIcon(AuthHeroType t) {
    switch (t) {
      case AuthHeroType.signIn:
        return Icons.trending_up_rounded;
      case AuthHeroType.signUp:
        return Icons.stars_rounded;
      case AuthHeroType.forgotPassword:
        return Icons.shield_outlined;
    }
  }

  Color _topColor(AuthHeroType t) {
    switch (t) {
      case AuthHeroType.signIn:
        return AppColors.income;
      case AuthHeroType.signUp:
        return AppColors.warning;
      case AuthHeroType.forgotPassword:
        return AppColors.income;
    }
  }

  String _topLabel(AuthHeroType t) {
    switch (t) {
      case AuthHeroType.signIn:
        return '+12.4%';
      case AuthHeroType.signUp:
        return 'Goals';
      case AuthHeroType.forgotPassword:
        return 'Secure';
    }
  }

  IconData _bottomIcon(AuthHeroType t) {
    switch (t) {
      case AuthHeroType.signIn:
        return Icons.account_balance_wallet_outlined;
      case AuthHeroType.signUp:
        return Icons.savings_outlined;
      case AuthHeroType.forgotPassword:
        return Icons.lock_reset_outlined;
    }
  }

  String _bottomLabel(AuthHeroType t) {
    switch (t) {
      case AuthHeroType.signIn:
        return 'Portfolio';
      case AuthHeroType.signUp:
        return 'Savings';
      case AuthHeroType.forgotPassword:
        return 'Reset';
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.type});
  final AuthHeroType type;

  IconData get _icon {
    switch (type) {
      case AuthHeroType.signIn:
        return Icons.show_chart_rounded;
      case AuthHeroType.signUp:
        return Icons.person_add_alt_1_rounded;
      case AuthHeroType.forgotPassword:
        return Icons.lock_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated, AppColors.card],
        ),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 32,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback:
              (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Icon(_icon, size: 48, color: Colors.white),
        ),
      ),
    );
  }
}

class _FloatingPill extends StatelessWidget {
  const _FloatingPill({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: color.withOpacity(0.18), blurRadius: 12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: GoogleFontFallback.pill),
        ],
      ),
    );
  }
}

// Inline pill style (avoids importing google_fonts in this file)
class GoogleFontFallback {
  static const pill = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth text field
// ─────────────────────────────────────────────────────────────────────────────

class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(
          color:
              _focused
                  ? AppColors.primary.withOpacity(0.65)
                  : AppColors.cardBorder,
          width: _focused ? 1.5 : 1.0,
        ),
        boxShadow:
            _focused
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.10),
                    blurRadius: 12,
                  ),
                ]
                : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color: _focused ? AppColors.primary : AppColors.textTertiary,
          ),
          suffixIcon: widget.suffixIcon,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.expense.withOpacity(0.7)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.expense.withOpacity(0.7)),
          ),
          errorStyle: AppTextStyles.caption.copyWith(color: AppColors.expense),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary gradient button
// ─────────────────────────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.primaryGradient,
          color: isLoading ? AppColors.surfaceElevated : null,
          borderRadius: AppSpacing.buttonRadius,
          boxShadow:
              isLoading
                  ? []
                  : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.42),
                      blurRadius: 22,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                  ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppSpacing.buttonRadius,
          child: InkWell(
            borderRadius: AppSpacing.buttonRadius,
            onTap: isLoading ? null : onPressed,
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : Text(
                        label,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google social button
// ─────────────────────────────────────────────────────────────────────────────

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppSpacing.buttonRadius,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppSpacing.buttonRadius,
          child: InkWell(
            borderRadius: AppSpacing.buttonRadius,
            onTap: isLoading ? null : onPressed,
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "or continue with" divider
// ─────────────────────────────────────────────────────────────────────────────

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom cross-navigation link
// ─────────────────────────────────────────────────────────────────────────────

class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });
  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            '$text ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

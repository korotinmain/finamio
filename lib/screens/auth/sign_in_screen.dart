import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth mode toggle
// ─────────────────────────────────────────────────────────────────────────────

enum _AuthMode { signIn, register }

final _authModeProvider = StateProvider<_AuthMode>((_) => _AuthMode.signIn);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _friendlyError(Object? e) {
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
    return 'Something went wrong. Please try again.';
  }

  Future<void> _submitEmail(_AuthMode mode) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (mode == _AuthMode.signIn) {
      await notifier.signInWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
    } else {
      await notifier.registerWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        displayName: _nameCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(_authModeProvider);
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) {
      if (state is AsyncError) {
        context.showSnack(_friendlyError(state.error), isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Ambient glow orbs ──────────────────────────────────────────
          _GlowOrb(
            color: AppColors.primary.withOpacity(0.18),
            size: 340,
            top: -80,
            left: -80,
          ),
          _GlowOrb(
            color: AppColors.accent.withOpacity(0.10),
            size: 260,
            top: 160,
            right: -100,
          ),
          _GlowOrb(
            color: AppColors.primary.withOpacity(0.08),
            size: 220,
            bottom: 80,
            left: 60,
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo mark ──────────────────────────────────────────
                  _LogoMark()
                      .animate()
                      .fadeIn(duration: 700.ms)
                      .scale(begin: const Offset(0.85, 0.85)),

                  const SizedBox(height: 28),

                  // ── Headline ───────────────────────────────────────────
                  ShaderMask(
                        shaderCallback:
                            (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          'finamio',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.15, end: 0),

                  const SizedBox(height: 6),

                  Text(
                        mode == _AuthMode.signIn
                            ? 'Welcome back.'
                            : 'Start your journey.',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.15, end: 0),

                  const SizedBox(height: 36),

                  // ── Tab switcher ───────────────────────────────────────
                  _TabSwitcher(
                    current: mode,
                    onChanged:
                        (m) => ref.read(_authModeProvider.notifier).state = m,
                  ).animate(delay: 250.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 28),

                  // ── Form card ──────────────────────────────────────────
                  _FormCard(
                        formKey: _formKey,
                        mode: mode,
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        confirmCtrl: _confirmCtrl,
                        obscurePass: _obscurePass,
                        obscureConfirm: _obscureConfirm,
                        isLoading: isLoading,
                        onTogglePass:
                            () => setState(() => _obscurePass = !_obscurePass),
                        onToggleConfirm:
                            () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                        onSubmit: () => _submitEmail(mode),
                      )
                      .animate(delay: 320.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.12, end: 0),

                  const SizedBox(height: 24),

                  // ── Divider ────────────────────────────────────────────
                  _OrDivider().animate(delay: 400.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // ── Google button ──────────────────────────────────────
                  _GoogleButton(
                        isLoading: isLoading,
                        onPressed:
                            () =>
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithGoogle(),
                      )
                      .animate(delay: 460.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 32),

                  // ── Footer ─────────────────────────────────────────────
                  Center(
                    child: Text(
                      'By continuing you agree to our Terms & Privacy Policy.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ).animate(delay: 520.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo mark
// ─────────────────────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'F',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab switcher
// ─────────────────────────────────────────────────────────────────────────────

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.current, required this.onChanged});
  final _AuthMode current;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Sign In',
            active: current == _AuthMode.signIn,
            onTap: () => onChanged(_AuthMode.signIn),
          ),
          _Tab(
            label: 'Register',
            active: current == _AuthMode.register,
            onTap: () => onChanged(_AuthMode.register),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: active ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow:
                active
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 14,
                        spreadRadius: -2,
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form card
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.mode,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.isLoading,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final _AuthMode mode;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePass;
  final bool obscureConfirm;
  final bool isLoading;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.7)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field — only for register
                if (mode == _AuthMode.register) ...[
                  _PremiumField(
                    controller: nameCtrl,
                    label: 'Full name',
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Enter your name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                ],

                _PremiumField(
                  controller: emailCtrl,
                  label: 'Email',
                  hint: 'hello@finamio.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _PremiumField(
                  controller: passCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscurePass,
                  suffixIcon: IconButton(
                    onPressed: onTogglePass,
                    icon: Icon(
                      obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                if (mode == _AuthMode.register) ...[
                  const SizedBox(height: 16),
                  _PremiumField(
                    controller: confirmCtrl,
                    label: 'Confirm password',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: obscureConfirm,
                    suffixIcon: IconButton(
                      onPressed: onToggleConfirm,
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Confirm your password';
                      if (v != passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Submit button
                _SubmitButton(
                  label:
                      mode == _AuthMode.signIn ? 'Sign In' : 'Create Account',
                  isLoading: isLoading,
                  onPressed: onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium text field
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumField extends StatefulWidget {
  const _PremiumField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.titleSmall.copyWith(
            color: _isFocused ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _isFocused
                      ? AppColors.primary.withOpacity(0.6)
                      : AppColors.cardBorder,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow:
                _isFocused
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                    : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: AppTextStyles.bodyMedium,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused ? AppColors.primary : AppColors.textTertiary,
                size: 20,
              ),
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.expense.withOpacity(0.6),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.expense.withOpacity(0.6),
                ),
              ),
              errorStyle: AppTextStyles.caption.copyWith(
                color: AppColors.expense,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit button
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
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
      height: 52,
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
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : Text(
                        label,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
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
// Or divider
// ─────────────────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
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
// Google button
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/google.png',
                            width: 20,
                            height: 20,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4),
                                        Color(0xFF34A853),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
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
// Ambient glow orb
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      ),
    );
  }
}

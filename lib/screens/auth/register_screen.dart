import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authNotifierProvider.notifier)
        .registerWithEmail(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          displayName: _nameCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) {
      if (state is AsyncError) {
        context.showSnack(authFriendlyError(state.error), isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // ── Hero ────────────────────────────────────────────────
                AuthHeroWidget(type: AuthHeroType.signUp, height: 140)
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 12),

                // ── Title ───────────────────────────────────────────────
                Text(
                      'Sign Up',
                      style: AppTextStyles.displayMedium,
                      textAlign: TextAlign.center,
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 4),

                Text(
                  'Use proper information to continue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // ── Full name ────────────────────────────────────────────
                AuthField(
                      controller: _nameCtrl,
                      hint: 'Full name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter your name'
                                  : null,
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 10),

                // ── Email ────────────────────────────────────────────────
                AuthField(
                      controller: _emailCtrl,
                      hint: 'Email address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    )
                    .animate(delay: 260.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 10),

                // ── Password ─────────────────────────────────────────────
                AuthField(
                      controller: _passCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        onPressed:
                            () => setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    )
                    .animate(delay: 320.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 10),

                // ── Confirm password ─────────────────────────────────────
                AuthField(
                      controller: _confirmCtrl,
                      hint: 'Confirm password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        onPressed:
                            () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Confirm your password';
                        if (v != _passCtrl.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    )
                    .animate(delay: 380.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 10),

                // ── Terms note ───────────────────────────────────────────
                Text.rich(
                  TextSpan(
                    text: 'By signing up, you agree to our ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 420.ms).fadeIn(duration: 400.ms),

                const Spacer(),

                // ── Create account button ────────────────────────────────
                AuthPrimaryButton(
                      label: 'Create Account',
                      isLoading: isLoading,
                      onPressed: _submit,
                    )
                    .animate(delay: 460.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 16),

                // ── Bottom crosslink ─────────────────────────────────────
                AuthBottomLink(
                  text: 'Already have an Account?',
                  linkText: 'Sign in',
                  onTap:
                      () =>
                          context.canPop()
                              ? context.pop()
                              : context.go('/sign-in'),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

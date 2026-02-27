import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailCtrl.text);
      if (mounted)
        setState(() {
          _isLoading = false;
          _sent = true;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showSnack(authFriendlyError(e), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 16),

                // ── Hero ─────────────────────────────────────────────────
                AuthHeroWidget(type: AuthHeroType.forgotPassword)
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 16),

                // ── Title ────────────────────────────────────────────────
                Text(
                      'Forget Password',
                      style: AppTextStyles.displayMedium,
                      textAlign: TextAlign.center,
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 4),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    key: ValueKey(_sent),
                    _sent
                        ? 'Check your inbox — a reset link has been sent.'
                        : "Don't worry, it happens. Please enter the address\nassociated with your account.",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _sent ? AppColors.income : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                if (!_sent) ...[
                  // ── Email field ────────────────────────────────────────
                  AuthField(
                        controller: _emailCtrl,
                        hint: 'Email address',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 28),

                  // ── Send OTP button ────────────────────────────────────
                  AuthPrimaryButton(
                        label: 'Send OTP',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      )
                      .animate(delay: 260.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, end: 0),
                  const Spacer(),
                ] else ...[
                  // ── Success state ──────────────────────────────────────
                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.incomeSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.income.withOpacity(0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.income,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Reset email sent!',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 24),

                  AuthPrimaryButton(
                    label: 'Back to Sign In',
                    isLoading: false,
                    onPressed: () => context.go('/sign-in'),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ],

                const SizedBox(height: 16),

                if (!_sent)
                  AuthBottomLink(
                    text: 'You remember your password?',
                    linkText: 'Sign in',
                    onTap:
                        () =>
                            context.canPop()
                                ? context.pop()
                                : context.go('/sign-in'),
                  ).animate(delay: 320.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

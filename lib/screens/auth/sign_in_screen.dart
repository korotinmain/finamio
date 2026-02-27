import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmail(email: _emailCtrl.text, password: _passCtrl.text);
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
                const SizedBox(height: 12),

                // ── Hero ─────────────────────────────────────────────────
                AuthHeroWidget(type: AuthHeroType.signIn)
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 16),

                // ── Title ────────────────────────────────────────────────
                Text(
                      'Sign In',
                      style: AppTextStyles.displayMedium,
                      textAlign: TextAlign.center,
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 4),

                Text(
                  'Enter your credentials to continue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

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
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────────────────
                AuthField(
                      controller: _passCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
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
                        if (v == null || v.isEmpty)
                          return 'Enter your password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    )
                    .animate(delay: 260.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 12),

                // ── Forgot password ──────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const Spacer(),

                // ── Login button ─────────────────────────────────────────
                AuthPrimaryButton(
                      label: 'Login',
                      isLoading: isLoading,
                      onPressed: _submit,
                    )
                    .animate(delay: 340.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 16),

                // ── Divider ──────────────────────────────────────────────
                const AuthOrDivider()
                    .animate(delay: 380.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // ── Google button ────────────────────────────────────────
                AuthGoogleButton(
                      isLoading: isLoading,
                      onPressed:
                          () =>
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .signInWithGoogle(),
                    )
                    .animate(delay: 420.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),

                const SizedBox(height: 16),

                // ── Bottom crosslink ─────────────────────────────────────
                AuthBottomLink(
                  text: "Haven't any account?",
                  linkText: 'Sign up',
                  onTap: () => context.push('/register'),
                ).animate(delay: 460.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

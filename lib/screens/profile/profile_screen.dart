import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/currency_service.dart';
import '../../widgets/common/finamio_card.dart';
import '../../widgets/common/finamio_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final baseCurrency = ref.watch(currencyServiceProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // ── Avatar & name ─────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage:
                      profile?.photoUrl != null
                          ? NetworkImage(profile!.photoUrl!)
                          : null,
                  child:
                      profile?.photoUrl == null
                          ? Text(
                            profile?.displayName.isNotEmpty == true
                                ? profile!.displayName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 14),
                Text(
                  profile?.displayName ?? 'User',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(profile?.email ?? '', style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // ── Settings ──────────────────────────────────────────────────────
          Text('Settings', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),

          FinamioCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Base Currency',
                  trailing: Text(
                    baseCurrency,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  onTap:
                      () => _pickCurrency(
                        context,
                        ref,
                        ref.read(supportedCurrenciesProvider),
                      ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Privacy',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text('About', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),

          FinamioCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.info_outline_rounded,
                  label: 'App Version',
                  trailing: Text('1.0.0', style: AppTextStyles.bodySmall),
                  onTap: null,
                ),
                const Divider(height: 1, indent: 56),
                _SettingTile(
                  icon: Icons.star_outline_rounded,
                  label: 'Rate Finamio',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // ── Sign out ──────────────────────────────────────────────────────
          FinamioButton(
            label: 'Sign Out',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go('/sign-in');
            },
            isLoading: authState.isLoading,
            isOutlined: true,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickCurrency(
    BuildContext context,
    WidgetRef ref,
    List<Currency> currencies,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder:
          (_) => ListView(
            padding: const EdgeInsets.all(8),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Base Currency',
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              ...currencies.map(
                (c) => ListTile(
                  leading: Text(
                    c.symbol,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(c.code, style: AppTextStyles.titleMedium),
                  subtitle: Text(c.name, style: AppTextStyles.bodySmall),
                  trailing:
                      c.code == ref.read(currencyServiceProvider)
                          ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                          : null,
                  onTap: () => Navigator.pop(context, c.code),
                ),
              ),
            ],
          ),
    );
    if (selected != null) {
      await ref
          .read(currencyServiceProvider.notifier)
          .setBaseCurrency(selected);
    }
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

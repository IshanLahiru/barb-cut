import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.titleMedium),
        toolbarHeight: 22,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: AppSpacing.paddingLG,
        children: [
          Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.borderLight, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guest User', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'guest@barbcut.app',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: Text(
              'Account',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildTile(icon: Icons.edit, title: 'Edit Profile'),
          _buildTile(icon: Icons.payment, title: 'Payment Methods'),
          _buildTile(icon: Icons.history, title: 'Appointments'),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: Text(
              'Settings',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildTile(icon: Icons.notifications, title: 'Notifications'),
          _buildTile(icon: Icons.lock, title: 'Privacy & Security'),
          _buildTile(icon: Icons.palette, title: 'Appearance'),
          _buildTile(icon: Icons.help_outline, title: 'Help & Support'),
          const SizedBox(height: 20),
          _buildTile(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          padding: AppSpacing.paddingSM,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        trailing: Icon(
          Icons.chevron_right,
          size: 22,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}

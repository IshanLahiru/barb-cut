import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_spacing.dart';
import 'appearance_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: textTheme.titleMedium),
        toolbarHeight: 22,
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.paddingLG,
        children: [
          Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.outline, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow,
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
                    color: scheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.person, size: 40, color: scheme.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guest User', style: textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text('guest@barbcut.app', style: textTheme.bodyMedium),
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
            child: Text('Account', style: textTheme.labelSmall),
          ),
          _buildTile(context, icon: Icons.edit, title: 'Edit Profile'),
          _buildTile(context, icon: Icons.payment, title: 'Payment Methods'),
          _buildTile(context, icon: Icons.history, title: 'Appointments'),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: Text('Settings', style: textTheme.labelSmall),
          ),
          _buildTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
          ),
          _buildTile(context, icon: Icons.lock, title: 'Privacy & Security'),
          _buildTile(
            context,
            icon: Icons.palette,
            title: 'Appearance',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AppearanceView()));
            },
          ),
          _buildTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
          ),
          const SizedBox(height: 20),
          _buildTile(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outline, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow,
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
          decoration: BoxDecoration(color: scheme.primary.withOpacity(0.08)),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        title: Text(title, style: textTheme.titleMedium),
        trailing: Icon(
          Icons.chevron_right,
          size: 22,
          color: scheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }
}

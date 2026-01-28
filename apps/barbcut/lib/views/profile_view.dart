import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';
import 'appearance_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AiColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AiColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AiColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AiSpacing.lg,
          vertical: AiSpacing.md,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AiSpacing.lg),
            decoration: BoxDecoration(
              color: AiColors.surface,
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(color: AiColors.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AiColors.neonCyan.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AiColors.neonCyan.withValues(alpha: 0.3),
                        AiColors.neonPurple.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AiColors.neonCyan.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AiColors.neonCyan,
                  ),
                ),
                const SizedBox(width: AiSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guest User',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AiColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: AiSpacing.xs),
                      Text(
                        'guest@barbcut.app',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AiColors.textTertiary,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AiSpacing.xxxl),
          Padding(
            padding: const EdgeInsets.only(
              left: AiSpacing.sm,
              bottom: AiSpacing.md,
            ),
            child: Text(
              'ACCOUNT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AiColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
            ),
          ),
          _buildTile(context,
              icon: Icons.edit,
              title: 'Edit Profile',
              accentColor: AiColors.neonCyan),
          _buildTile(context,
              icon: Icons.payment,
              title: 'Payment Methods',
              accentColor: AiColors.sunsetCoral),
          _buildTile(context,
              icon: Icons.history,
              title: 'Appointments',
              accentColor: AiColors.neonPurple),
          const SizedBox(height: AiSpacing.xxl),
          Padding(
            padding: const EdgeInsets.only(
              left: AiSpacing.sm,
              bottom: AiSpacing.md,
            ),
            child: Text(
              'SETTINGS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AiColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
            ),
          ),
          _buildTile(context,
              icon: Icons.notifications,
              title: 'Notifications',
              accentColor: AiColors.neonCyan),
          _buildTile(context,
              icon: Icons.lock,
              title: 'Privacy & Security',
              accentColor: AiColors.sunsetCoral),
          _buildTile(
            context,
            icon: Icons.palette,
            title: 'Appearance',
            accentColor: AiColors.neonPurple,
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppearanceView()));
            },
          ),
          _buildTile(context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              accentColor: AiColors.neonCyan),
          const SizedBox(height: AiSpacing.lg),
          _buildTile(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            accentColor: AiColors.sunsetCoral,
            isDestructive: true,
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
    required Color accentColor,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AiSpacing.md),
      decoration: BoxDecoration(
        color: isDestructive
            ? AiColors.error.withValues(alpha: 0.1)
            : AiColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: isDestructive
              ? AiColors.error.withValues(alpha: 0.3)
              : accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AiSpacing.lg,
          vertical: AiSpacing.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AiSpacing.sm),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDestructive ? AiColors.error : accentColor,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDestructive ? AiColors.error : AiColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 22,
          color: AiColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}

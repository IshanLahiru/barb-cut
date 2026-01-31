import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/ai_colors.dart';
import '../theme/adaptive_theme_colors.dart';
import '../theme/ai_spacing.dart';
import '../shared/widgets/molecules/stat_item.dart';
import 'appearance_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        toolbarHeight: 48,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AiSpacing.lg,
          vertical: AiSpacing.md,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AiSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AdaptiveThemeColors.backgroundSecondary(context),
                  AdaptiveThemeColors.surface(context),
                ],
              ),
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: AdaptiveThemeColors.borderLight(context),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AdaptiveThemeColors.neonCyan(
                    context,
                  ).withValues(alpha: 0.1),
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
                        AdaptiveThemeColors.neonCyan(
                          context,
                        ).withValues(alpha: 0.3),
                        AdaptiveThemeColors.neonPurple(
                          context,
                        ).withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AdaptiveThemeColors.neonCyan(
                          context,
                        ).withValues(alpha: 0.2),
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AdaptiveThemeColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AiSpacing.xs),
                      Text(
                        'guest@barbcut.app',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AdaptiveThemeColors.textTertiary(context),
                        ),
                      ),
                      const SizedBox(height: AiSpacing.md),
                      Row(
                        children: [
                          const StatItem(
                            label: 'Generations',
                            value: '24',
                          ),
                          const SizedBox(width: AiSpacing.md),
                          const StatItem(
                            label: 'Favorites',
                            value: '8',
                          ),
                          const SizedBox(width: AiSpacing.md),
                          const StatItem(
                            label: 'Bookings',
                            value: '3',
                          ),
                        ],
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
                color: AdaptiveThemeColors.textTertiary(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildTile(
            context,
            icon: Icons.edit,
            title: 'Edit Profile',
            accentColor: AdaptiveThemeColors.neonCyan(context),
          ),
          _buildTile(
            context,
            icon: Icons.payment,
            title: 'Payment Methods',
            accentColor: AdaptiveThemeColors.sunsetCoral(context),
          ),
          _buildTile(
            context,
            icon: Icons.history,
            title: 'Appointments',
            accentColor: AdaptiveThemeColors.neonPurple(context),
          ),
          const SizedBox(height: AiSpacing.xxl),
          Padding(
            padding: const EdgeInsets.only(
              left: AiSpacing.sm,
              bottom: AiSpacing.md,
            ),
            child: Text(
              'SETTINGS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AdaptiveThemeColors.textTertiary(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            accentColor: AdaptiveThemeColors.neonCyan(context),
          ),
          _buildTile(
            context,
            icon: Icons.lock,
            title: 'Privacy & Security',
            accentColor: AdaptiveThemeColors.sunsetCoral(context),
          ),
          _buildTile(
            context,
            icon: Icons.palette,
            title: 'Appearance',
            accentColor: AdaptiveThemeColors.neonPurple(context),
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
            accentColor: AdaptiveThemeColors.neonCyan(context),
          ),
          const SizedBox(height: AiSpacing.lg),
          _buildTile(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            accentColor: AdaptiveThemeColors.sunsetCoral(context),
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
            ? AdaptiveThemeColors.error(context).withValues(alpha: 0.1)
            : AdaptiveThemeColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: isDestructive
              ? AdaptiveThemeColors.error(context).withValues(alpha: 0.3)
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
            color: isDestructive
                ? AdaptiveThemeColors.error(context)
                : accentColor,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDestructive
                ? AdaptiveThemeColors.error(context)
                : AdaptiveThemeColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 22,
          color: AdaptiveThemeColors.textTertiary(context),
        ),
        onTap: onTap,
      ),
    );
  }

}

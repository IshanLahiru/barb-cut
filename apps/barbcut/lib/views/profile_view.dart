import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../theme/theme.dart';
import '../core/di/service_locator.dart';
import '../features/profile/domain/entities/profile_entity.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/profile/presentation/bloc/profile_event.dart';
import '../features/profile/presentation/bloc/profile_state.dart';

import 'questionnaire_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _username = 'Loading...';
  String _email = 'Loading...';

  void _updateProfileData(ProfileEntity profile) {
    setState(() {
      _username = profile.username;
      _email = profile.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(getProfileUseCase: getIt<GetProfileUseCase>())
            ..add(const ProfileLoadRequested()),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _updateProfileData(state.profile);
          }
        },
        child: Scaffold(
          backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
          appBar: AppBar(
            backgroundColor: AdaptiveThemeColors.backgroundDark(context),
            elevation: 0,
            toolbarHeight: 48,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AdaptiveThemeColors.backgroundSecondary(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AdaptiveThemeColors.textPrimary(context),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Settings',
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
            padding: EdgeInsets.all(AiSpacing.lg),
            children: [
              _buildProfileCard(context),
              SizedBox(height: AiSpacing.lg),
              _buildSectionLabel(context, 'Other settings'),
              SizedBox(height: AiSpacing.sm),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'Profile details',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuestionnaireView(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock_rounded,
                    title: 'Password',
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark mode',
                    trailing: Switch.adaptive(
                      value: context.watch<ThemeController>().isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeController>().toggleDarkMode(value);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AiSpacing.lg),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About application',
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help/FAQ',
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.delete_outline_rounded,
                    title: 'Deactivate my account',
                    isDestructive: true,
                  ),
                ],
              ),
              SizedBox(height: AiSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AiSpacing.lg),
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AdaptiveThemeColors.backgroundSecondary(context),
            child: Icon(
              Icons.person_rounded,
              color: AdaptiveThemeColors.textPrimary(context),
            ),
          ),
          SizedBox(width: AiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AdaptiveThemeColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  _email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdaptiveThemeColors.textTertiary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AdaptiveThemeColors.textTertiary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AdaptiveThemeColors.textTertiary(context),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: _buildSeparatedTiles(children)),
    );
  }

  List<Widget> _buildSeparatedTiles(List<Widget> tiles) {
    final List<Widget> separated = [];
    for (int i = 0; i < tiles.length; i++) {
      separated.add(tiles[i]);
      if (i < tiles.length - 1) {
        separated.add(
          Divider(
            height: 1,
            color: AdaptiveThemeColors.borderLight(
              context,
            ).withValues(alpha: 0.2),
          ),
        );
      }
    }
    return separated;
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final Color textColor = isDestructive
        ? AdaptiveThemeColors.error(context)
        : AdaptiveThemeColors.textPrimary(context);
    final Color iconColor = isDestructive
        ? AdaptiveThemeColors.error(context)
        : AdaptiveThemeColors.textSecondary(context);

    return InkWell(
      onTap: trailing == null ? onTap : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AiSpacing.lg,
          vertical: AiSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AdaptiveThemeColors.backgroundSecondary(context),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            SizedBox(width: AiSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AdaptiveThemeColors.textTertiary(context),
                ),
          ],
        ),
      ),
    );
  }
}

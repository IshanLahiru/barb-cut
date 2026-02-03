import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsSettingsPage(),
                        ),
                      );
                    },
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

// ChangePasswordPage - Full screen page for password change
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate with current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(_newPasswordController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AiSpacing.sm),
            Text(
              'Current Password',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AiSpacing.xs),
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              decoration: InputDecoration(
                hintText: 'Enter current password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(
                      () => _showCurrentPassword = !_showCurrentPassword,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AiSpacing.lg),
            Text('New Password', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AiSpacing.xs),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showNewPassword = !_showNewPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: AiSpacing.lg),
            Text(
              'Confirm Password',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AiSpacing.xs),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AiSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NotificationsSettingsPage - Full screen page for notification preferences
class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _updateNotifications = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load saved preferences
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    // TODO: Load from SharedPreferences or Firebase
    // For now, using default values
  }

  Future<void> _saveNotificationPreferences() async {
    setState(() => _isSaving = true);
    try {
      // TODO: Save to SharedPreferences or Firebase
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AiSpacing.lg,
        vertical: AiSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AiSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AiSpacing.lg),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: AiSpacing.md),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNotificationToggle(
                    'Email Notifications',
                    'Receive email updates about your account',
                    _emailNotifications,
                    (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                  _buildNotificationToggle(
                    'Push Notifications',
                    'Receive push notifications on your device',
                    _pushNotifications,
                    (value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                  _buildNotificationToggle(
                    'Update Notifications',
                    'Receive notifications about app updates',
                    _updateNotifications,
                    (value) {
                      setState(() => _updateNotifications = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AiSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveNotificationPreferences,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Preferences'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

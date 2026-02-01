import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../theme/theme.dart';
import '../shared/widgets/molecules/stat_item.dart';
import '../core/di/service_locator.dart';
import '../features/profile/domain/entities/profile_entity.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/profile/presentation/bloc/profile_event.dart';
import '../features/profile/presentation/bloc/profile_state.dart';
import 'appearance_view.dart';
import 'questionnaire_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _username = 'Loading...';
  String _email = 'Loading...';
  int _appointmentsCount = 0;
  int _favoritesCount = 0;
  double _averageRating = 0.0;

  void _updateProfileData(ProfileEntity profile) {
    setState(() {
      _username = profile.username;
      _email = profile.email;
      _appointmentsCount = profile.appointmentsCount;
      _favoritesCount = profile.favoritesCount;
      _averageRating = profile.averageRating;
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
            padding: EdgeInsets.symmetric(
              horizontal: AiSpacing.lg,
              vertical: AiSpacing.md,
            ),
            children: [
              Container(
                padding: EdgeInsets.all(AiSpacing.lg),
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
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
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
                    SizedBox(width: AiSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textPrimary(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: AiSpacing.xs),
                          Text(
                            _email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textTertiary(
                                    context,
                                  ),
                                ),
                          ),
                          SizedBox(height: AiSpacing.md),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                StatItem(
                                  label: 'Appointments',
                                  value: '$_appointmentsCount',
                                ),
                                SizedBox(width: AiSpacing.md),
                                StatItem(
                                  label: 'Favorites',
                                  value: '$_favoritesCount',
                                ),
                                SizedBox(width: AiSpacing.md),
                                StatItem(
                                  label: 'Rating',
                                  value: _averageRating.toStringAsFixed(1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AiSpacing.xxxl),
              Padding(
                padding: EdgeInsets.only(
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
                icon: Icons.quiz_outlined,
                title: 'My Profile & Photos',
                accentColor: AdaptiveThemeColors.neonPurple(context),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuestionnaireView(),
                    ),
                  );
                },
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
              SizedBox(height: AiSpacing.xxl),
              Padding(
                padding: EdgeInsets.only(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppearanceView()),
                  );
                },
              ),
              _buildTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                accentColor: AdaptiveThemeColors.neonCyan(context),
              ),
              _buildTile(
                context,
                icon: Icons.person_outline,
                title: 'User Details',
                accentColor: AdaptiveThemeColors.neonPurple(context),
                onTap: () => _showUserDetailsDialog(context),
              ),
              SizedBox(height: AiSpacing.lg),
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
        ),
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AdaptiveThemeColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
            side: BorderSide(
              color: AdaptiveThemeColors.borderLight(context),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(AiSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Details',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AdaptiveThemeColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: AiSpacing.md),
                  Divider(color: AdaptiveThemeColors.borderLight(context)),
                  SizedBox(height: AiSpacing.md),
                  _buildDetailRow(
                    context,
                    'Display Name:',
                    user?.displayName ?? 'N/A',
                  ),
                  SizedBox(height: AiSpacing.md),
                  _buildDetailRow(context, 'Email:', user?.email ?? 'N/A'),
                  SizedBox(height: AiSpacing.md),
                  _buildDetailRow(context, 'User ID:', user?.uid ?? 'N/A'),
                  SizedBox(height: AiSpacing.md),
                  _buildDetailRow(
                    context,
                    'Email Verified:',
                    user?.emailVerified == true ? 'Yes' : 'No',
                  ),
                  SizedBox(height: AiSpacing.md),
                  _buildDetailRow(
                    context,
                    'Phone:',
                    user?.phoneNumber ?? 'Not set',
                  ),
                  SizedBox(height: AiSpacing.md),
                  _buildDetailRow(
                    context,
                    'Account Created:',
                    user?.metadata?.creationTime?.toString().split('.').first ??
                        'N/A',
                  ),
                  SizedBox(height: AiSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdaptiveThemeColors.neonCyan(context),
                        foregroundColor: AdaptiveThemeColors.surface(context),
                        padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AdaptiveThemeColors.surface(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AdaptiveThemeColors.textTertiary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AiSpacing.xs),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AiSpacing.sm),
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
            border: Border.all(
              color: AdaptiveThemeColors.borderLight(context),
              width: 0.5,
            ),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontFamily: 'monospace',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
      margin: EdgeInsets.only(bottom: AiSpacing.md),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: AiSpacing.lg,
          vertical: AiSpacing.sm,
        ),
        leading: Container(
          padding: EdgeInsets.all(AiSpacing.sm),
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

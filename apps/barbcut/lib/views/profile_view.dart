import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            padding: EdgeInsets.all(AiSpacing.lg),
            children: [
              // Profile header card
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
                    color: AdaptiveThemeColors.borderLight(
                      context,
                    ).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AdaptiveThemeColors.neonCyan(
                        context,
                      ).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar and name
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
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
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: AdaptiveThemeColors.neonCyan(context),
                          ),
                        ),
                        SizedBox(width: AiSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _username,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AdaptiveThemeColors.textPrimary(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AiSpacing.xs),
                              Text(
                                _email,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AdaptiveThemeColors.textTertiary(
                                        context,
                                      ),
                                      fontSize: 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AiSpacing.lg),
                    Divider(
                      color: AdaptiveThemeColors.borderLight(
                        context,
                      ).withValues(alpha: 0.2),
                      height: 1,
                    ),
                    SizedBox(height: AiSpacing.md),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Appointments',
                          '$_appointmentsCount',
                          AdaptiveThemeColors.neonCyan(context),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AdaptiveThemeColors.borderLight(
                            context,
                          ).withValues(alpha: 0.2),
                        ),
                        _buildStatItem(
                          context,
                          'Favorites',
                          '$_favoritesCount',
                          AdaptiveThemeColors.neonPurple(context),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AdaptiveThemeColors.borderLight(
                            context,
                          ).withValues(alpha: 0.2),
                        ),
                        _buildStatItem(
                          context,
                          'Rating',
                          _averageRating.toStringAsFixed(1),
                          AdaptiveThemeColors.sunsetCoral(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AiSpacing.xl),

              // Account section
              _buildSectionHeader(context, 'ACCOUNT'),
              SizedBox(height: AiSpacing.md),
              _buildMenuItem(
                context,
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
                accentColor: AdaptiveThemeColors.neonCyan(context),
              ),
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.quiz_rounded,
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
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.payment_rounded,
                title: 'Payment Methods',
                accentColor: AdaptiveThemeColors.sunsetCoral(context),
              ),
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.history_rounded,
                title: 'Appointments',
                accentColor: AdaptiveThemeColors.neonCyan(context),
              ),

              SizedBox(height: AiSpacing.xl),

              // Settings section
              _buildSectionHeader(context, 'SETTINGS'),
              SizedBox(height: AiSpacing.md),
              _buildMenuItem(
                context,
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                accentColor: AdaptiveThemeColors.neonCyan(context),
              ),
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.lock_rounded,
                title: 'Privacy & Security',
                accentColor: AdaptiveThemeColors.sunsetCoral(context),
              ),
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.palette_rounded,
                title: 'Appearance',
                accentColor: AdaptiveThemeColors.neonPurple(context),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppearanceView()),
                  );
                },
              ),
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                accentColor: AdaptiveThemeColors.neonCyan(context),
              ),
              SizedBox(height: AiSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.person_outline_rounded,
                title: 'User Details',
                accentColor: AdaptiveThemeColors.neonPurple(context),
                onTap: () => _showUserDetailsDialog(context),
              ),

              SizedBox(height: AiSpacing.xl),

              // Sign out button
              _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                accentColor: AdaptiveThemeColors.error(context),
                isDestructive: true,
                onTap: () => context.read<AuthController>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: AiSpacing.xs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AdaptiveThemeColors.textTertiary(context),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AiSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AdaptiveThemeColors.textTertiary(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color accentColor,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdaptiveThemeColors.backgroundSecondary(context),
            AdaptiveThemeColors.surface(context).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: isDestructive
              ? AdaptiveThemeColors.error(context).withValues(alpha: 0.3)
              : accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AiSpacing.md,
              vertical: AiSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AiSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.2),
                        accentColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive
                        ? AdaptiveThemeColors.error(context)
                        : accentColor,
                  ),
                ),
                SizedBox(width: AiSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDestructive
                          ? AdaptiveThemeColors.error(context)
                          : AdaptiveThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AdaptiveThemeColors.textTertiary(
                    context,
                  ).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AdaptiveThemeColors.surface(context),
                  AdaptiveThemeColors.backgroundSecondary(context),
                ],
              ),
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: AdaptiveThemeColors.borderLight(
                  context,
                ).withValues(alpha: 0.3),
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
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
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
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AdaptiveThemeColors.neonCyan(dialogContext),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: AiSpacing.sm),
                        Expanded(
                          child: Text(
                            'User Details',
                            style: Theme.of(dialogContext).textTheme.titleLarge
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textPrimary(
                                    dialogContext,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AdaptiveThemeColors.textSecondary(
                              dialogContext,
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AiSpacing.md),
                    Divider(
                      color: AdaptiveThemeColors.borderLight(
                        dialogContext,
                      ).withValues(alpha: 0.2),
                    ),
                    SizedBox(height: AiSpacing.md),

                    // User details
                    _buildDetailRow(
                      dialogContext,
                      'Display Name',
                      user?.displayName ?? 'N/A',
                    ),
                    SizedBox(height: AiSpacing.md),
                    _buildDetailRow(
                      dialogContext,
                      'Email',
                      user?.email ?? 'N/A',
                    ),
                    SizedBox(height: AiSpacing.md),
                    _buildDetailRow(
                      dialogContext,
                      'User ID',
                      user?.uid ?? 'N/A',
                    ),
                    SizedBox(height: AiSpacing.md),
                    _buildDetailRow(
                      dialogContext,
                      'Email Verified',
                      user?.emailVerified == true ? 'Yes' : 'No',
                    ),
                    SizedBox(height: AiSpacing.md),
                    _buildDetailRow(
                      dialogContext,
                      'Phone',
                      user?.phoneNumber ?? 'Not set',
                    ),
                    SizedBox(height: AiSpacing.md),
                    _buildDetailRow(
                      dialogContext,
                      'Account Created',
                      user?.metadata?.creationTime
                              ?.toString()
                              .split('.')
                              .first ??
                          'N/A',
                    ),

                    SizedBox(height: AiSpacing.xl),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdaptiveThemeColors.neonCyan(
                            dialogContext,
                          ),
                          foregroundColor: AdaptiveThemeColors.backgroundDeep(
                            dialogContext,
                          ),
                          padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AiSpacing.radiusMedium,
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Close',
                          style: Theme.of(dialogContext).textTheme.labelLarge
                              ?.copyWith(
                                color: AdaptiveThemeColors.backgroundDeep(
                                  dialogContext,
                                ),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AdaptiveThemeColors.textTertiary(context),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        SizedBox(height: AiSpacing.xs),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AiSpacing.sm),
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.backgroundSecondary(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
            border: Border.all(
              color: AdaptiveThemeColors.borderLight(
                context,
              ).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

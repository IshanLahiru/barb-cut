import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';
import '../widgets/ai_buttons.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  const LoginView({super.key, required this.onSwitchToRegister});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _localError;
  bool _showPassword = false;

  Future<void> _submit(AuthController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!email.contains('@')) {
      setState(() => _localError = 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _localError = null);
    await controller.login(email, password);
    if (!mounted) return;
    setState(() => _localError = controller.error);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    return Scaffold(
      backgroundColor: AiColors.backgroundDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AiSpacing.lg),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AiColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AiSpacing.sm),
              Text(
                'Sign in to continue',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AiColors.textTertiary),
              ),
              const SizedBox(height: AiSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(AiSpacing.lg),
                decoration: BoxDecoration(
                  color: AiColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                  border: Border.all(color: AiColors.borderLight, width: 1.5),
                ),
                child: Column(
                  children: [
                    // Email field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AiColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AiColors.textTertiary),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: AiColors.neonCyan,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AiColors.backgroundDeep,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AiSpacing.md,
                          vertical: AiSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AiColors.borderLight,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AiColors.borderLight,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AiColors.neonCyan,
                            width: 2,
                          ),
                        ),
                      ),
                      cursorColor: AiColors.neonCyan,
                    ),
                    const SizedBox(height: AiSpacing.md),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AiColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AiColors.textTertiary),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AiColors.neonCyan,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AiColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AiColors.backgroundDeep,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AiSpacing.md,
                          vertical: AiSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AiColors.borderLight,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AiColors.borderLight,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AiColors.neonCyan,
                            width: 2,
                          ),
                        ),
                      ),
                      cursorColor: AiColors.neonCyan,
                    ),
                    const SizedBox(height: AiSpacing.lg),
                    if (_localError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AiSpacing.md),
                        decoration: BoxDecoration(
                          color: AiColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          border: Border.all(
                            color: AiColors.error.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _localError!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AiColors.error),
                        ),
                      ),
                      const SizedBox(height: AiSpacing.md),
                    ],
                    if (controller.isLoading)
                      const SizedBox(
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AiColors.neonCyan,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: AiPrimaryButton(
                          label: 'Sign in',
                          onPressed: () => _submit(controller),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AiSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: widget.onSwitchToRegister,
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AiColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AiColors.neonCyan,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

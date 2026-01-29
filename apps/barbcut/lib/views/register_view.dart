import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';
import '../widgets/ai_buttons.dart';

class RegisterView extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const RegisterView({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  String? _localError;

  Future<void> _submit(AuthController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (!email.contains('@')) {
      setState(() => _localError = 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _localError = 'Passwords do not match');
      return;
    }

    setState(() => _localError = null);
    await controller.register(email, password);
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
          padding: EdgeInsets.all(AiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AiSpacing.md),
              Text(
                'Create account',
                style:
                    Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AiColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ) ??
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: AiSpacing.sm),
              Text(
                'Join Barbcut in seconds',
                style:
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AiColors.textSecondary,
                    ) ??
                    const TextStyle(color: Colors.white70),
              ),
              SizedBox(height: AiSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  color: AiColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                  border: Border.all(
                    color: AiColors.neonCyan.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AiColors.neonCyan.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(AiSpacing.lg),
                child: Column(
                  children: [
                    // Email field
                    Container(
                      decoration: BoxDecoration(
                        color: AiColors.backgroundDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusMedium,
                        ),
                        border: Border.all(
                          color: AiColors.borderLight,
                          width: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.sm,
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AiColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          hintStyle: TextStyle(color: AiColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: AiColors.neonCyan,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(height: AiSpacing.md),
                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        color: AiColors.backgroundDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusMedium,
                        ),
                        border: Border.all(
                          color: AiColors.borderLight,
                          width: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.sm,
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AiColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: AiColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AiColors.sunsetCoral,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => _showPassword = !_showPassword),
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AiColors.neonCyan,
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(height: AiSpacing.md),
                    // Confirm password field
                    Container(
                      decoration: BoxDecoration(
                        color: AiColors.backgroundDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusMedium,
                        ),
                        border: Border.all(
                          color: AiColors.borderLight,
                          width: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.sm,
                      ),
                      child: TextField(
                        controller: _confirmController,
                        obscureText: !_showConfirm,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AiColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          hintStyle: TextStyle(color: AiColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.lock_reset,
                            color: AiColors.neonPurple,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => _showConfirm = !_showConfirm),
                            child: Icon(
                              _showConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AiColors.neonCyan,
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(height: AiSpacing.lg),
                    // Error message
                    if (_localError != null) ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AiColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusMedium,
                          ),
                          border: Border.all(
                            color: AiColors.danger.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        padding: EdgeInsets.all(AiSpacing.md),
                        child: Text(
                          _localError!,
                          style: TextStyle(
                            color: AiColors.danger,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: AiSpacing.md),
                    ],
                    // Submit button
                    if (controller.isLoading)
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AiColors.neonCyan,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      AiPrimaryButton(
                        label: 'Create account',
                        onPressed: () => _submit(controller),
                      ),
                    SizedBox(height: AiSpacing.md),
                    // Sign in link
                    TextButton(
                      onPressed: widget.onSwitchToLogin,
                      child: Text(
                        'Have an account? Sign in',
                        style: TextStyle(color: AiColors.neonCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

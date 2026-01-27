import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/auth_controller.dart';

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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Create account',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join Barbcut in seconds',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0.6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TDInput(
                        controller: _emailController,
                        hintText: 'Email address',
                        leftIcon: const Icon(Icons.mail_outline),
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      TDInput(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        leftIcon: const Icon(Icons.lock_outline),
                        inputType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 14),
                      TDInput(
                        controller: _confirmController,
                        hintText: 'Confirm password',
                        obscureText: true,
                        leftIcon: const Icon(Icons.lock_reset),
                        inputType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 20),
                      if (_localError != null) ...[
                        TDTag(
                          _localError!,
                          theme: TDTagTheme.danger,
                          shape: TDTagShape.round,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (controller.isLoading)
                        const TDLoading(size: TDLoadingSize.medium)
                      else
                        TDButton(
                          theme: TDButtonTheme.primary,
                          size: TDButtonSize.large,
                          isBlock: true,
                          onTap: () => _submit(controller),
                          text: 'Create account',
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onSwitchToLogin,
                        child: const Text('Have an account? Sign in'),
                      ),
                    ],
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

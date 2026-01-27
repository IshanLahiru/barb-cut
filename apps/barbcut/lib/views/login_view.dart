import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../controllers/auth_controller.dart';

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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to continue',
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
                          text: 'Sign in',
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onSwitchToRegister,
                        child: const Text('Create an account'),
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

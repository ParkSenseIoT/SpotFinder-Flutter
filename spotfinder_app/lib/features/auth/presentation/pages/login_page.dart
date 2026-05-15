import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    context.read<AuthBloc>().add(AuthSignInRequested(email: email, password: password));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          _showError(state.errorMessage!);
        }
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_tethering, color: AppColors.primaryNeon, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Driver Login',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Secure uplink to SpotFinder',
                  style: TextStyle(color: AppColors.textGray),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (p, n) => p.status != n.status,
                  builder: (context, state) {
                    if (state.status == AuthStatus.authenticating) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryNeon),
                      );
                    }
                    return NeonButton(text: 'Establish Connection', onPressed: _handleLogin);
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const Text(
                    'New operative? Initialize Profile',
                    style: TextStyle(
                      color: AppColors.primaryNeon,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

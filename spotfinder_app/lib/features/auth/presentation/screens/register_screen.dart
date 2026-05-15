import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'CAR_OWNER';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('All fields are required for operative initialization');
      return;
    }
    if (!email.contains('@')) {
      _showError('Please provide a valid email');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    final auth = context.read<AuthController>();
    final ok = await auth.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      requestedRole: _selectedRole,
    );
    if (!mounted) return;

    if (!ok) {
      _showError(auth.errorMessage ?? 'Registration failed');
      return;
    }

    // Auto-login after successful registration so the driver lands inside the app.
    final loggedIn = await auth.login(email, password);
    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Welcome to SpotFinder.')),
      );
    } else {
      _showError('Account created but auto-login failed. Please sign in.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orangeAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.wifi_tethering, color: AppColors.primaryNeon, size: 40),
              const SizedBox(height: 20),
              const Text(
                'Create Account',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildInputField('FIRST NAME', Icons.person_outline, _firstNameController),
              const SizedBox(height: 20),
              _buildInputField('LAST NAME', Icons.person_outline, _lastNameController),
              const SizedBox(height: 20),
              _buildInputField('EMAIL', Icons.email_outlined, _emailController),
              const SizedBox(height: 20),
              _buildInputField('PASSWORD (min 8)', Icons.lock_outline, _passwordController, isPassword: true),
              const SizedBox(height: 20),
              _buildRoleSelector(),
              const SizedBox(height: 40),
              NeonButton(
                text: isLoading ? 'Initializing...' : 'INITIALIZE REGISTRATION',
                onPressed: isLoading ? () {} : _handleRegistration,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryNeon, size: 20),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ROLE', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              isExpanded: true,
              dropdownColor: AppColors.surfaceDark,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'CAR_OWNER', child: Text('Driver (CAR_OWNER)')),
                DropdownMenuItem(value: 'ADMIN', child: Text('Parking Administrator (ADMIN)')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v ?? 'CAR_OWNER'),
            ),
          ),
        ),
      ],
    );
  }
}

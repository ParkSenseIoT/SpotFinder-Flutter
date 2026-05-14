import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import 'verification_screen.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validación Fase 1
    if (email.isEmpty || !email.contains('@')) {
      _showError("Please enter a valid Email Identifier");
      return;
    }
    if (password.isEmpty || password.length < 6) {
      _showError("Access Protocol must be at least 6 characters");
      return;
    }

    // Si todo es correcto, procedemos
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const VerificationScreen()),
    );
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_tethering, color: AppColors.primaryNeon, size: 60),
            const SizedBox(height: 20),
            const Text(
              "Driver Login",
              style: TextStyle(
                color: Colors.white, 
                fontSize: 24, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Secure uplink to SpotFinder",
              style: TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 40),
            _buildTextField("Email Identifier", Icons.alternate_email, _emailController),
            const SizedBox(height: 20),
            _buildTextField("Access Protocol", Icons.lock_outline, _passwordController, isPassword: true),
            const SizedBox(height: 30),
            
            NeonButton(
              text: "Establish Connection",
              onPressed: _handleLogin,
            ),

            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                "New operative? Initialize Profile",
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
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryNeon),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGray),
        filled: true,
        fillColor: AppColors.surfaceDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryNeon, width: 1),
        ),
      ),
    );
  }
}
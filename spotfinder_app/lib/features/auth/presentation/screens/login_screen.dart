import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import 'verification_screen.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            _buildTextField("Email Identifier", Icons.alternate_email),
            const SizedBox(height: 20),
            _buildTextField("Access Protocol", Icons.lock_outline, isPassword: true),
            const SizedBox(height: 30),
            
            // EL BOTÓN: Se eliminó el paréntesis sobrante que causaba el error de identifier
            NeonButton(
              text: "Establish Connection",
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const VerificationScreen()),
                );
              },
            ),

            const SizedBox(height: 20),
            
            // Link para Registro para completar el flujo
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

  Widget _buildTextField(String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
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
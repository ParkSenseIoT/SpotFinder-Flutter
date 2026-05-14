import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../screens/main_navigation_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.wifi_tethering, color: AppColors.primaryNeon, size: 40),
            const SizedBox(height: 20),
            const Text("Create Account", 
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildInputField("FULL NAME", Icons.person_outline),
            const SizedBox(height: 20),
            _buildInputField("CORPORATE EMAIL", Icons.email_outlined),
            const SizedBox(height: 20),
            _buildInputField("PHONE NUMBER", Icons.phone_android_outlined),
            const SizedBox(height: 40),
            NeonButton(
  text: "INITIALIZE REGISTRATION", 
  onPressed: () {
    // 1. Aquí iría la lógica para guardar FULL NAME, EMAIL y PHONE
    // 2. Navegamos al Dashboard eliminando el historial anterior
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false, // Esto evita que el usuario regrese al registro con el botón "atrás"
    );
  },
),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryNeon, size: 20),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart'; // Importa el nuevo widget

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          const Icon(Icons.security, color: AppColors.primaryNeon, size: 50),
          const Text("Verify Your Identity", 
            style: TextStyle(color: Colors.white, fontSize: 22)),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "We've sent a 6-digit synchronization code to your email", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          const Spacer(), // Empuja el contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: NeonButton(
              text: "Verify Identity", 
              onPressed: () {
                // Lógica de navegación
              },
            ),
          ),
        ],
      ),
    );
  }
}
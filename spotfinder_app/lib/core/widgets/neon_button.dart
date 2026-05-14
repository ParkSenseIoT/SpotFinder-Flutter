import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NeonButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // Actualización para evitar el error de 'withOpacity' depreciado
              color: AppColors.primaryNeon.withValues(alpha: 0.3), 
              blurRadius: 10,
            )
          ],
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppColors.primaryNeon, Color(0xFF00B8D4)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black, // O el color que prefieras para el texto
              fontWeight: FontWeight.bold, 
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
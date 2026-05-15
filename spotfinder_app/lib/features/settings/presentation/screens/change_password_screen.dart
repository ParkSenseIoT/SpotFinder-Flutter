import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/change_password_controller.dart';

/// Form for the driver to change their own password. Requires the current
/// password for verification (hits `POST /users/{userId}/change-password`).
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Sesión no encontrada.',
              style: TextStyle(color: AppColors.textGray)),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordController(userId: user.id),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  final _currentCtl = TextEditingController();
  final _newCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  @override
  void dispose() {
    _currentCtl.dispose();
    _newCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ChangePasswordController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cambiar contraseña',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por seguridad, ingresa primero tu contraseña actual. '
                'La nueva debe tener al menos 8 caracteres.',
                style: TextStyle(
                    color: AppColors.textGray, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 24),
              const _Label('Contraseña actual'),
              const SizedBox(height: 6),
              _PasswordField(
                controller: _currentCtl,
                onChanged: c.setCurrentPassword,
                obscured: !_showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
                enabled: !c.isSaving,
              ),
              const SizedBox(height: 16),
              const _Label('Nueva contraseña'),
              const SizedBox(height: 6),
              _PasswordField(
                controller: _newCtl,
                onChanged: c.setNewPassword,
                obscured: !_showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                enabled: !c.isSaving,
              ),
              const SizedBox(height: 16),
              const _Label('Confirmar nueva contraseña'),
              const SizedBox(height: 6),
              _PasswordField(
                controller: _confirmCtl,
                onChanged: c.setConfirmPassword,
                obscured: !_showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
                enabled: !c.isSaving,
              ),
              if (c.errorMessage != null) ...[
                const SizedBox(height: 18),
                _ErrorBox(message: c.errorMessage!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isSaving ? null : () => _onSave(context, c),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        AppColors.primaryNeon.withOpacity(0.25),
                    disabledForegroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: c.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.black))
                      : const Text(
                          'Actualizar contraseña',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave(
      BuildContext context, ChangePasswordController c) async {
    final ok = await c.save();
    if (!ok || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF22C55E),
        content: Text('Contraseña actualizada'),
      ),
    );
    Navigator.pop(context);
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textGray,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.onChanged,
    required this.obscured,
    required this.onToggle,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool obscured;
  final VoidCallback onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscured,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppColors.primaryNeon, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textGray,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryNeon),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

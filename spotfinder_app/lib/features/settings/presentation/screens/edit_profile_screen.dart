import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/edit_profile_controller.dart';

/// Lets the driver edit their first and last name. Email is read-only.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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

    final firstLast = _splitName(user.fullName);
    return ChangeNotifierProvider(
      create: (_) => EditProfileController(
        userId: user.id,
        initialFirstName: firstLast.$1,
        initialLastName: firstLast.$2,
      ),
      child: const _EditProfileView(),
    );
  }

  (String, String) _splitName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return ('', '');
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late final TextEditingController _firstCtl;
  late final TextEditingController _lastCtl;

  @override
  void initState() {
    super.initState();
    final c = context.read<EditProfileController>();
    _firstCtl = TextEditingController(text: c.firstName);
    _lastCtl = TextEditingController(text: c.lastName);
  }

  @override
  void dispose() {
    _firstCtl.dispose();
    _lastCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<EditProfileController>();
    final user = context.watch<AuthController>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Editar perfil',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Nombre'),
              const SizedBox(height: 6),
              _Field(
                controller: _firstCtl,
                hint: 'Tu nombre',
                onChanged: c.setFirstName,
                icon: Icons.person_outline,
                enabled: !c.isSaving,
              ),
              const SizedBox(height: 16),
              _Label('Apellido'),
              const SizedBox(height: 6),
              _Field(
                controller: _lastCtl,
                hint: 'Tu apellido',
                onChanged: c.setLastName,
                icon: Icons.person_outline,
                enabled: !c.isSaving,
              ),
              const SizedBox(height: 16),
              _Label('Correo electrónico'),
              const SizedBox(height: 6),
              _ReadOnlyField(value: user?.email ?? ''),
              const SizedBox(height: 4),
              const Text(
                'El correo electrónico no se puede modificar.',
                style: TextStyle(color: AppColors.textGray, fontSize: 11),
              ),
              if (c.errorMessage != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.errorMessage!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (c.isDirty && c.isValid && !c.isSaving)
                      ? () => _onSave(context, c)
                      : null,
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
                          'Guardar cambios',
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

  Future<void> _onSave(BuildContext context, EditProfileController c) async {
    final ok = await c.save();
    if (!ok || !context.mounted) return;

    final updated = c.updatedUser;
    if (updated != null) {
      context.read<AuthController>().updateCachedUser(updated);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF22C55E),
        content: Text('Perfil actualizado'),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.icon,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGray),
        prefixIcon: Icon(icon, color: AppColors.primaryNeon, size: 20),
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.alternate_email,
              color: AppColors.textGray, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textGray, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.lock_outline,
              color: AppColors.textGray, size: 16),
        ],
      ),
    );
  }
}

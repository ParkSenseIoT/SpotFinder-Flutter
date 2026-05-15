import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/notification_type.dart';
import '../controllers/notification_preferences_controller.dart';

/// Lets the driver toggle which notification types are delivered.
///
/// `EMERGENCY_ALERT` is rendered as a locked-on row — per spec, emergency
/// pushes always fire and ignore preferences.
class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Inicia sesión para configurar tus notificaciones.',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
          NotificationPreferencesController(userId: user.id)..load(),
      child: const _PreferencesView(),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationPreferencesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Preferencias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _buildBody(context, controller),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationPreferencesController c) {
    if (c.isLoading && c.preferences.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryNeon),
      );
    }

    return Column(
      children: [
        if (c.errorMessage != null) _ErrorBanner(message: c.errorMessage!),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Elige qué notificaciones quieres recibir. La alerta de '
                  'emergencia siempre permanece activa por seguridad.',
                  style: TextStyle(color: AppColors.textGray, fontSize: 13),
                ),
              ),
              ...NotificationType.configurable.map((type) {
                final enabled = c.preferences[type] ?? true;
                return _PreferenceTile(
                  type: type,
                  enabled: enabled,
                  isSaving: c.isSaving,
                  onChanged: type.isMandatory
                      ? null
                      : (v) async {
                          final ok = await c.setEnabled(type, v);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(c.errorMessage ??
                                    'No se pudieron guardar los cambios.'),
                              ),
                            );
                          }
                        },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.type,
    required this.enabled,
    required this.isSaving,
    required this.onChanged,
  });

  final NotificationType type;
  final bool enabled;
  final bool isSaving;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final mandatory = type.isMandatory;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: mandatory
              ? const Color(0xFFEF4444).withOpacity(0.45)
              : Colors.white12,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: type.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, color: type.accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (mandatory)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Siempre activa',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  type.description,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: AppColors.primaryNeon,
            onChanged: isSaving ? null : onChanged,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 10),
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

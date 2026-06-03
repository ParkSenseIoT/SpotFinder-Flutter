import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../find_my_car/presentation/screens/find_my_car_screen.dart';
import '../../../notifications/presentation/screens/notification_preferences_screen.dart';
import '../../../premium_services/presentation/screens/premium_services_screen.dart';
import '../../../reservations/presentation/screens/reservations_screen.dart';
import '../../../vehicles/presentation/screens/vehicles_screen.dart';
import '../../../wallet/presentation/screens/wallet_pass_screen.dart';
import '../widgets/premium_upgrade_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'legal_screen.dart';

/// Driver-facing Settings tab. Replaces the previous inline panel inside
/// `MainNavigationScreen` with a proper screen composed of sections.
///
/// Layout (top → bottom):
///   1. Profile header (avatar + name + email + plan badge)
///   2. Premium upgrade card (CTA → feature/premium, placeholder for now)
///   3. Account section: Edit profile, Change password, Vehicles
///   4. Activity section: Payment history, Session history
///   5. Preferences section: Notification preferences, Language, Theme
///   6. Support section: Help, Contact, Report a problem
///   7. Legal section: Terms, Privacy
///   8. About + version
///   9. Log out
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Inicia sesión para ver tu configuración.',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        top: !showAppBar,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            if (!showAppBar)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        color: AppColors.primaryNeon, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            ProfileHeader(user: user, plan: 'Free'),

            PremiumUpgradeCard(
              onTap: () => _showComingSoon(
                context,
                title: 'Premium',
                message:
                    'El flujo de suscripción Premium estará disponible pronto. '
                    'Podrás registrar tu método de pago (Yape, Visa, Mastercard) '
                    'y elegir entre los planes mensual y anual.',
              ),
            ),

            SettingsSection(
              title: 'Cuenta',
              children: [
                SettingsTile(
                  icon: Icons.edit_outlined,
                  label: 'Editar perfil',
                  subtitle: 'Cambia tu nombre y apellido',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.lock_outline,
                  label: 'Cambiar contraseña',
                  subtitle: 'Actualiza la contraseña de tu cuenta',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.directions_car_outlined,
                  label: 'Mis vehículos',
                  subtitle: 'Placas registradas para reconocimiento',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.bookmark_border,
                  label: 'Mis reservas',
                  subtitle: 'Reserva espacios con anticipación',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReservationsScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.my_location,
                  label: 'Find My Car',
                  subtitle: 'Localiza tu vehículo en el estacionamiento',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FindMyCarScreen()),
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: 'Actividad',
              children: [
                SettingsTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Historial de pagos',
                  subtitle: 'Tus pagos anteriores',
                  onTap: () => _showFromTab(context,
                      message: 'Encuentra tu historial en la pestaña Payments.'),
                ),
                SettingsTile(
                  icon: Icons.qr_code_2_outlined,
                  label: 'Pase digital',
                  subtitle: 'Google Wallet con tu sesión activa',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletPassScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Servicios Premium',
                  subtitle: 'Lavado, detailing y entrega de combustible',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PremiumServicesScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.history,
                  label: 'Historial de sesiones',
                  subtitle: 'Estancias pasadas en estacionamientos',
                  onTap: () => _showComingSoon(
                    context,
                    title: 'Historial de sesiones',
                    message:
                        'Pronto podrás revisar el detalle de todas tus '
                        'sesiones pasadas: ingreso, salida, espacio y duración.',
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: 'Preferencias',
              children: [
                SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Notificaciones',
                  subtitle: 'Elige qué alertas quieres recibir',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationPreferencesScreen(),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.language,
                  label: 'Idioma',
                  trailingText: 'Español (PE)',
                  onTap: () => _showComingSoon(
                    context,
                    title: 'Idioma',
                    message:
                        'Por ahora SpotFinder está disponible en español '
                        'peruano. Próximamente añadiremos más idiomas.',
                  ),
                ),
                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Tema',
                  trailingText: 'Oscuro',
                  onTap: () => _showComingSoon(
                    context,
                    title: 'Tema',
                    message:
                        'El modo oscuro está optimizado para uso dentro del '
                        'vehículo. El modo claro llegará en una futura versión.',
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: 'Soporte',
              children: [
                SettingsTile(
                  icon: Icons.help_outline,
                  label: 'Centro de ayuda',
                  subtitle: 'Preguntas frecuentes y guía rápida',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.mail_outline,
                  label: 'Contactar soporte',
                  subtitle: 'soporte@spotfinder.pe',
                  onTap: () => _showContactSupport(context),
                ),
                SettingsTile(
                  icon: Icons.bug_report_outlined,
                  label: 'Reportar un problema',
                  onTap: () => _showComingSoon(
                    context,
                    title: 'Reportar un problema',
                    message:
                        'Estamos preparando un formulario para reportar '
                        'incidencias directamente desde la app. Mientras '
                        'tanto, escríbenos a soporte@spotfinder.pe.',
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: 'Legal',
              children: [
                SettingsTile(
                  icon: Icons.description_outlined,
                  label: 'Términos y condiciones',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalScreen(kind: LegalKind.terms),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.shield_outlined,
                  label: 'Política de privacidad',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LegalScreen(kind: LegalKind.privacy),
                    ),
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: 'Acerca de',
              children: [
                SettingsTile(
                  icon: Icons.info_outline,
                  label: 'Acerca de SpotFinder',
                  trailingText: 'v${AboutScreen.appVersion}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: const Color(0xFFEF4444).withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _confirmLogout(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Seguro que quieres cerrar sesión? Tendrás que volver a iniciar para usar la app.',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await context.read<AuthController>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showComingSoon(BuildContext context,
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.schedule, color: AppColors.primaryNeon),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(title, style: const TextStyle(color: Colors.white))),
          ],
        ),
        content: Text(message,
            style: const TextStyle(color: AppColors.textGray, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido',
                style: TextStyle(color: AppColors.primaryNeon)),
          ),
        ],
      ),
    );
  }

  void _showFromTab(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mail_outline, color: AppColors.primaryNeon),
            SizedBox(width: 8),
            Text('Soporte', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correo: soporte@spotfinder.pe',
                style: TextStyle(color: Colors.white)),
            SizedBox(height: 6),
            Text('WhatsApp: +51 999 000 111',
                style: TextStyle(color: Colors.white)),
            SizedBox(height: 6),
            Text('Horario: lunes a domingo, 8am-10pm',
                style: TextStyle(color: AppColors.textGray)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: AppColors.primaryNeon)),
          ),
        ],
      ),
    );
  }
}

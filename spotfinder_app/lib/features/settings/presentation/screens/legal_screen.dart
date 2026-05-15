import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Static legal text screen — used for both Terms and Privacy by passing
/// a different `kind`. Keeps the copy local since it's read-only and rarely
/// changes; a real product would fetch from a remote CMS.
enum LegalKind { terms, privacy }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});

  final LegalKind kind;

  @override
  Widget build(BuildContext context) {
    final terms = kind == LegalKind.terms;
    final title = terms ? 'Términos y condiciones' : 'Política de privacidad';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: terms ? _termsBlocks() : _privacyBlocks(),
          ),
        ),
      ),
    );
  }

  List<Widget> _termsBlocks() {
    return const [
      _Section(
        title: '1. Aceptación',
        body:
            'Al usar SpotFinder aceptas estos Términos. Si no estás de acuerdo, '
            'desinstala la aplicación.',
      ),
      _Section(
        title: '2. Uso del servicio',
        body:
            'SpotFinder facilita el acceso, la búsqueda de espacios y el pago '
            'del estacionamiento en centros comerciales asociados. El servicio '
            'depende de la disponibilidad de la red, sensores y barreras '
            'instalados en cada local.',
      ),
      _Section(
        title: '3. Cuenta',
        body:
            'Eres responsable de mantener la confidencialidad de tu '
            'contraseña y de toda la actividad que ocurra bajo tu cuenta. '
            'Notifica de inmediato cualquier uso no autorizado.',
      ),
      _Section(
        title: '4. Pagos',
        body:
            'Los pagos se procesan mediante Culqi. El monto final se calcula '
            'por el tiempo total de estancia según la tarifa publicada en cada '
            'centro comercial. La emisión de comprobantes electrónicos está a '
            'cargo del operador del estacionamiento.',
      ),
      _Section(
        title: '5. Limitación de responsabilidad',
        body:
            'SpotFinder no se responsabiliza por daños al vehículo, robos o '
            'incidentes ocurridos dentro del estacionamiento — esa '
            'responsabilidad recae en el operador del establecimiento.',
      ),
      _Section(
        title: '6. Cambios',
        body:
            'Podemos actualizar estos Términos. Te avisaremos dentro de la '
            'aplicación cuando haya cambios relevantes.',
      ),
    ];
  }

  List<Widget> _privacyBlocks() {
    return const [
      _Section(
        title: 'Datos que recopilamos',
        body:
            'Nombre, correo electrónico, contraseña (encriptada), placas '
            'vehiculares registradas, historial de sesiones y pagos, y el '
            'token de notificaciones push del dispositivo.',
      ),
      _Section(
        title: 'Cómo los usamos',
        body:
            'Para autenticarte, abrir la barrera con reconocimiento de placa, '
            'cobrar el estacionamiento, enviarte notificaciones operativas '
            '(ingreso, pago pendiente, emergencias) y mejorar el servicio.',
      ),
      _Section(
        title: 'Con quién los compartimos',
        body:
            'Con Culqi para procesar pagos, Firebase Cloud Messaging para '
            'enviar notificaciones, y el operador del estacionamiento para '
            'validar el ingreso. Nunca vendemos tu información personal a '
            'terceros.',
      ),
      _Section(
        title: 'Tus derechos',
        body:
            'Puedes solicitar la corrección o eliminación de tus datos '
            'escribiendo a privacidad@spotfinder.pe. Para borrar tu cuenta '
            'completa, contacta a soporte y eliminaremos todos los datos '
            'asociados, salvo los que la ley nos exige conservar.',
      ),
      _Section(
        title: 'Seguridad',
        body:
            'Tu contraseña se guarda con BCrypt. Las llamadas a nuestro '
            'backend usan HTTPS. El JWT de sesión se guarda en almacenamiento '
            'seguro del sistema operativo de tu dispositivo.',
      ),
    ];
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryNeon,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Static "About SpotFinder" screen. App version, mission line, credits.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Acerca de',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_parking,
                  color: AppColors.primaryNeon,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SpotFinder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Intelligent Smart City Access',
                style: TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
              const SizedBox(height: 32),
              _infoRow('Versión', '$appVersion ($buildNumber)'),
              _infoRow('Plataforma', 'Flutter'),
              _infoRow('Desarrollado por', 'ParkSense IoT'),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'SpotFinder es una plataforma IoT que digitaliza el ingreso, '
                  'la búsqueda de espacios y los pagos en estacionamientos de '
                  'centros comerciales en Lima. Sensores en cada espacio, '
                  'reconocimiento automático de placas y pagos con Yape o '
                  'tarjeta — sin colas, sin tickets físicos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '© ${DateTime.now().year} ParkSense IoT. Todos los derechos reservados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGray.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

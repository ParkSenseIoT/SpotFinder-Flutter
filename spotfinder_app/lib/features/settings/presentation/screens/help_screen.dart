import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Static help / FAQ screen. The Q&A list is local for now; a real
/// help center would fetch from a CMS.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    _FaqEntry(
      question: '¿Cómo ingreso al estacionamiento?',
      answer:
          'El sistema reconoce automáticamente tu placa al pasar por la '
          'barrera. Solo necesitas tener tu vehículo registrado en la app.',
    ),
    _FaqEntry(
      question: '¿Cómo pago mi estacionamiento?',
      answer:
          'Ve a la pestaña Payments. Verás el monto en vivo y podrás pagar '
          'con Yape, tarjeta de crédito o débito antes de salir.',
    ),
    _FaqEntry(
      question: '¿Qué pasa si olvido pagar antes de salir?',
      answer:
          'Recibirás una notificación con un enlace de pago. La barrera de '
          'salida no abrirá hasta que completes el pago.',
    ),
    _FaqEntry(
      question: '¿Cómo encuentro mi auto?',
      answer:
          'En la pestaña My Stay (próximamente) verás el código del espacio '
          'donde se estacionó tu vehículo. También en Payments mientras la '
          'sesión esté activa.',
    ),
    _FaqEntry(
      question: '¿Puedo registrar más de un vehículo?',
      answer:
          'Sí. Desde Settings → Mis vehículos puedes agregar varias placas '
          'a tu cuenta.',
    ),
    _FaqEntry(
      question: '¿Qué incluye el plan Premium?',
      answer:
          'Pase digital en Google Wallet, servicio de lavado de auto a '
          'demanda y reservas anticipadas de espacios.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ayuda y soporte',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: Text(
                'Preguntas frecuentes',
                style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
            ),
            ..._faqs.map((f) => _FaqTile(entry: f)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryNeon.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.support_agent,
                          color: AppColors.primaryNeon, size: 22),
                      SizedBox(width: 10),
                      Text(
                        '¿Necesitas más ayuda?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escríbenos a soporte@spotfinder.pe o WhatsApp '
                    '+51 999 000 111 (lunes a domingo, 8am-10pm).',
                    style: TextStyle(
                        color: AppColors.textGray, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqEntry {
  final String question;
  final String answer;
  const _FaqEntry({required this.question, required this.answer});
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.entry});
  final _FaqEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primaryNeon,
          collapsedIconColor: AppColors.textGray,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Text(
            entry.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                entry.answer,
                style: const TextStyle(
                    color: AppColors.textGray, fontSize: 13, height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

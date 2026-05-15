import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Mirrors `com.spotfinderbackend.notifications.domain.model.valueobjects.NotificationType`.
///
/// The wire format is the enum name in UPPER_SNAKE_CASE (`ENTRY_CONFIRMED`, etc.).
enum NotificationType {
  entryConfirmed,
  paymentReminder,
  paymentSuccess,
  emergencyAlert,
  sessionEnd,
  paymentFailed,
  unknown;

  String get apiValue {
    switch (this) {
      case NotificationType.entryConfirmed:
        return 'ENTRY_CONFIRMED';
      case NotificationType.paymentReminder:
        return 'PAYMENT_REMINDER';
      case NotificationType.paymentSuccess:
        return 'PAYMENT_SUCCESS';
      case NotificationType.emergencyAlert:
        return 'EMERGENCY_ALERT';
      case NotificationType.sessionEnd:
        return 'SESSION_END';
      case NotificationType.paymentFailed:
        return 'PAYMENT_FAILED';
      case NotificationType.unknown:
        return 'UNKNOWN';
    }
  }

  static NotificationType fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ENTRY_CONFIRMED':
        return NotificationType.entryConfirmed;
      case 'PAYMENT_REMINDER':
        return NotificationType.paymentReminder;
      case 'PAYMENT_SUCCESS':
        return NotificationType.paymentSuccess;
      case 'EMERGENCY_ALERT':
        return NotificationType.emergencyAlert;
      case 'SESSION_END':
        return NotificationType.sessionEnd;
      case 'PAYMENT_FAILED':
        return NotificationType.paymentFailed;
      default:
        return NotificationType.unknown;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.entryConfirmed:
        return 'Ingreso confirmado';
      case NotificationType.paymentReminder:
        return 'Recordatorio de pago';
      case NotificationType.paymentSuccess:
        return 'Pago exitoso';
      case NotificationType.emergencyAlert:
        return 'Alerta de emergencia';
      case NotificationType.sessionEnd:
        return 'Fin de sesión';
      case NotificationType.paymentFailed:
        return 'Pago fallido';
      case NotificationType.unknown:
        return 'Notificación';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.entryConfirmed:
        return 'Cuando tu vehículo es identificado al entrar al estacionamiento.';
      case NotificationType.paymentReminder:
        return 'Antes de salir, si aún tienes un pago pendiente.';
      case NotificationType.paymentSuccess:
        return 'Cuando tu pago se procesa correctamente.';
      case NotificationType.emergencyAlert:
        return 'Alertas de evacuación. No se puede desactivar.';
      case NotificationType.sessionEnd:
        return 'Cuando tu sesión de estacionamiento termina.';
      case NotificationType.paymentFailed:
        return 'Si tu pago fue rechazado o falló.';
      case NotificationType.unknown:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.entryConfirmed:
        return Icons.login;
      case NotificationType.paymentReminder:
        return Icons.access_time;
      case NotificationType.paymentSuccess:
        return Icons.check_circle_outline;
      case NotificationType.emergencyAlert:
        return Icons.warning_amber;
      case NotificationType.sessionEnd:
        return Icons.exit_to_app;
      case NotificationType.paymentFailed:
        return Icons.error_outline;
      case NotificationType.unknown:
        return Icons.notifications_outlined;
    }
  }

  /// Color used for the icon background / accent on the tile.
  Color get accentColor {
    switch (this) {
      case NotificationType.entryConfirmed:
        return const Color(0xFF22C55E);
      case NotificationType.paymentReminder:
        return const Color(0xFFFF9100);
      case NotificationType.paymentSuccess:
        return const Color(0xFF22C55E);
      case NotificationType.emergencyAlert:
        return const Color(0xFFEF4444);
      case NotificationType.sessionEnd:
        return AppColors.primaryNeon;
      case NotificationType.paymentFailed:
        return const Color(0xFFEF4444);
      case NotificationType.unknown:
        return AppColors.textGray;
    }
  }

  /// True for [emergencyAlert], whose preference cannot be disabled per spec.
  bool get isMandatory => this == NotificationType.emergencyAlert;

  /// Configurable preferences shown in the preferences screen.
  /// Excludes [unknown] and keeps [emergencyAlert] (rendered as locked-on).
  static const List<NotificationType> configurable = [
    NotificationType.entryConfirmed,
    NotificationType.paymentReminder,
    NotificationType.paymentSuccess,
    NotificationType.paymentFailed,
    NotificationType.sessionEnd,
    NotificationType.emergencyAlert,
  ];
}

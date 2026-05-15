import 'payment_method.dart';
import 'payment_status.dart';

/// A persisted payment record. Matches `PaymentResource`.
class PaymentEntity {
  final int id;
  final int sessionId;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId;
  final String? receiptUrl;
  final DateTime? paidAt;
  final String? duration;
  final int hoursCharged;

  const PaymentEntity({
    required this.id,
    required this.sessionId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.hoursCharged,
    this.transactionId,
    this.receiptUrl,
    this.paidAt,
    this.duration,
  });

  String get formattedAmount =>
      '${currency == 'PEN' ? 'S/' : currency} ${amount.toStringAsFixed(2)}';
}

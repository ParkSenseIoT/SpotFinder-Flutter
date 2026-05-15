import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.sessionId,
    required super.amount,
    required super.currency,
    required super.paymentMethod,
    required super.status,
    required super.hoursCharged,
    super.transactionId,
    super.receiptUrl,
    super.paidAt,
    super.duration,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: (json['id'] as num).toInt(),
      sessionId: (json['sessionId'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'PEN').toString(),
      paymentMethod: PaymentMethod.fromApi(json['paymentMethod'] as String?),
      status: PaymentStatus.fromApi(json['status'] as String?),
      transactionId: json['transactionId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()),
      duration: json['duration'] as String?,
      hoursCharged: (json['hoursCharged'] as num?)?.toInt() ?? 0,
    );
  }
}

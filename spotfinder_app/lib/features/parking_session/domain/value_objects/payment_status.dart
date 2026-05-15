enum PaymentStatus {
  pending,
  paid,
  unpaid,
  unknown;

  static PaymentStatus fromString(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'PENDING':
        return PaymentStatus.pending;
      case 'PAID':
        return PaymentStatus.paid;
      case 'UNPAID':
        return PaymentStatus.unpaid;
      default:
        return PaymentStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isSettled => this == PaymentStatus.paid;
}

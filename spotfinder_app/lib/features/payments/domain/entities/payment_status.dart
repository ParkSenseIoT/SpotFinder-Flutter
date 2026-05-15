/// Mirror of the backend `PaymentTransactionStatus` enum.
enum PaymentStatus {
  pending,
  completed,
  failed;

  static PaymentStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'COMPLETED':
        return PaymentStatus.completed;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'PENDING':
      default:
        return PaymentStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case PaymentStatus.completed:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }
}

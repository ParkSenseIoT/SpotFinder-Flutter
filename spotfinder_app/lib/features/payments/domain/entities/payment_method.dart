/// Mirror of the backend `PaymentMethod` enum.
enum PaymentMethod {
  yape('YAPE', 'Yape', 'assets/yape.png'),
  creditCard('CREDIT_CARD', 'Credit Card', null),
  debitCard('DEBIT_CARD', 'Debit Card', null);

  const PaymentMethod(this.apiValue, this.label, this.iconAsset);

  /// Wire-format value sent to the backend (matches the Java enum names).
  final String apiValue;
  final String label;
  final String? iconAsset;

  static PaymentMethod fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'YAPE':
        return PaymentMethod.yape;
      case 'CREDIT_CARD':
        return PaymentMethod.creditCard;
      case 'DEBIT_CARD':
        return PaymentMethod.debitCard;
      default:
        return PaymentMethod.creditCard;
    }
  }
}

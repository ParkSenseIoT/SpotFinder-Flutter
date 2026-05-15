/// Calculated fee for a vehicle session. Matches `ParkingFeeResource`.
class ParkingFeeEntity {
  final double amount;
  final String duration; // pre-formatted "Xh Ymin"
  final double ratePerHour;
  final int hoursCharged;
  final String currency;

  const ParkingFeeEntity({
    required this.amount,
    required this.duration,
    required this.ratePerHour,
    required this.hoursCharged,
    required this.currency,
  });

  factory ParkingFeeEntity.empty() => const ParkingFeeEntity(
        amount: 0,
        duration: '0h 0min',
        ratePerHour: 0,
        hoursCharged: 0,
        currency: 'PEN',
      );

  /// "S/ 15.00"
  String get formattedAmount => '${_currencySymbol()} ${amount.toStringAsFixed(2)}';

  String _currencySymbol() {
    switch (currency) {
      case 'PEN':
        return 'S/';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }
}

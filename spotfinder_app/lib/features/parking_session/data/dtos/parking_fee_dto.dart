class ParkingFeeDto {
  const ParkingFeeDto({
    required this.amount,
    required this.duration,
    required this.ratePerHour,
    required this.hoursCharged,
    required this.currency,
  });

  final double amount;
  final String duration;
  final double ratePerHour;
  final int hoursCharged;
  final String currency;

  factory ParkingFeeDto.fromJson(Map<String, dynamic> json) {
    return ParkingFeeDto(
      amount: (json['amount'] as num).toDouble(),
      duration: json['duration'] as String? ?? '00:00:00',
      ratePerHour: (json['ratePerHour'] as num).toDouble(),
      hoursCharged: (json['hoursCharged'] as num).toInt(),
      currency: json['currency'] as String? ?? 'PEN',
    );
  }
}

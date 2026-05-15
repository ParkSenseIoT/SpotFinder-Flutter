import 'package:equatable/equatable.dart';

class ParkingFee extends Equatable {
  const ParkingFee({
    required this.amount,
    required this.duration,
    required this.ratePerHour,
    required this.hoursCharged,
    required this.currency,
  });

  final double amount;
  final Duration duration;
  final double ratePerHour;
  final int hoursCharged;
  final String currency;

  @override
  List<Object?> get props => [amount, duration, ratePerHour, hoursCharged, currency];
}

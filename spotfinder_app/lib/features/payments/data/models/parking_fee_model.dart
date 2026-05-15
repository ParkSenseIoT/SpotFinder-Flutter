import '../../domain/entities/parking_fee_entity.dart';

class ParkingFeeModel extends ParkingFeeEntity {
  const ParkingFeeModel({
    required super.amount,
    required super.duration,
    required super.ratePerHour,
    required super.hoursCharged,
    required super.currency,
  });

  factory ParkingFeeModel.fromJson(Map<String, dynamic> json) {
    return ParkingFeeModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] ?? '0h 0min').toString(),
      ratePerHour: (json['ratePerHour'] as num?)?.toDouble() ?? 0,
      hoursCharged: (json['hoursCharged'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] ?? 'PEN').toString(),
    );
  }
}

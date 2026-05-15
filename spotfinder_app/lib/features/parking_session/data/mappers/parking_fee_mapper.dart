import '../../domain/entities/parking_fee.dart';
import '../dtos/parking_fee_dto.dart';

class ParkingFeeMapper {
  const ParkingFeeMapper._();

  static ParkingFee toEntity(ParkingFeeDto dto) {
    return ParkingFee(
      amount: dto.amount,
      duration: _parseDuration(dto.duration),
      ratePerHour: dto.ratePerHour,
      hoursCharged: dto.hoursCharged,
      currency: dto.currency,
    );
  }

  static Duration _parseDuration(String raw) {
    final parts = raw.split(':');
    if (parts.length != 3) return Duration.zero;
    return Duration(
      hours: int.tryParse(parts[0]) ?? 0,
      minutes: int.tryParse(parts[1]) ?? 0,
      seconds: int.tryParse(parts[2]) ?? 0,
    );
  }
}

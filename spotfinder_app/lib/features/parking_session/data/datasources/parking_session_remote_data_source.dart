import '../dtos/parking_fee_dto.dart';
import '../dtos/parking_session_dto.dart';

abstract class ParkingSessionRemoteDataSource {
  Future<ParkingSessionDto?> getActive(int userId);

  Future<ParkingSessionDto> getById(int sessionId);

  Future<List<ParkingSessionDto>> getHistory(int userId);

  Future<void> end(int sessionId);

  Future<ParkingFeeDto> calculateFee(int sessionId);
}

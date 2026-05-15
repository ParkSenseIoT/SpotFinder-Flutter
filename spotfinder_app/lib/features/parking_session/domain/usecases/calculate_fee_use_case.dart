import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/parking_fee.dart';
import '../repositories/parking_session_repository.dart';

class CalculateFeeUseCase implements UseCase<ParkingFee, int> {
  CalculateFeeUseCase(this._repository);

  final ParkingSessionRepository _repository;

  @override
  Future<Either<Failure, ParkingFee>> call(int sessionId) => _repository.calculateFee(sessionId);
}

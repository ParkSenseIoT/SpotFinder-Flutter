import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/parking_session_repository.dart';

class EndSessionUseCase implements UseCase<Unit, int> {
  EndSessionUseCase(this._repository);

  final ParkingSessionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int sessionId) => _repository.endSession(sessionId);
}

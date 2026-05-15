import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/parking_session.dart';
import '../repositories/parking_session_repository.dart';

class GetSessionHistoryUseCase implements UseCase<List<ParkingSession>, int> {
  GetSessionHistoryUseCase(this._repository);

  final ParkingSessionRepository _repository;

  @override
  Future<Either<Failure, List<ParkingSession>>> call(int userId) {
    return _repository.getSessionHistory(userId);
  }
}

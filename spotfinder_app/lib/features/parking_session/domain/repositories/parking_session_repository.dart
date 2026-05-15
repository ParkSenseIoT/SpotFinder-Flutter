import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/parking_fee.dart';
import '../entities/parking_session.dart';

abstract class ParkingSessionRepository {
  Future<Either<Failure, ParkingSession?>> getActiveSession(int userId);

  Future<Either<Failure, ParkingSession>> getSessionById(int sessionId);

  Future<Either<Failure, List<ParkingSession>>> getSessionHistory(int userId);

  Future<Either<Failure, Unit>> endSession(int sessionId);

  Future<Either<Failure, ParkingFee>> calculateFee(int sessionId);
}

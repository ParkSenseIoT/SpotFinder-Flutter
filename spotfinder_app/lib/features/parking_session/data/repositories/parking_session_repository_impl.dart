import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/dio_exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/parking_fee.dart';
import '../../domain/entities/parking_session.dart';
import '../../domain/repositories/parking_session_repository.dart';
import '../datasources/parking_session_remote_data_source.dart';
import '../mappers/parking_fee_mapper.dart';
import '../mappers/parking_session_mapper.dart';

class ParkingSessionRepositoryImpl implements ParkingSessionRepository {
  ParkingSessionRepositoryImpl(this._remote);

  final ParkingSessionRemoteDataSource _remote;

  @override
  Future<Either<Failure, ParkingSession?>> getActiveSession(int userId) async {
    try {
      final dto = await _remote.getActive(userId);
      return Right(dto == null ? null : ParkingSessionMapper.toEntity(dto));
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSession>> getSessionById(int sessionId) async {
    try {
      final dto = await _remote.getById(sessionId);
      return Right(ParkingSessionMapper.toEntity(dto));
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSession>>> getSessionHistory(int userId) async {
    try {
      final dtos = await _remote.getHistory(userId);
      final sessions = dtos.map(ParkingSessionMapper.toEntity).toList()
        ..sort((a, b) => b.entryTimestamp.compareTo(a.entryTimestamp));
      return Right(sessions);
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> endSession(int sessionId) async {
    try {
      await _remote.end(sessionId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingFee>> calculateFee(int sessionId) async {
    try {
      final dto = await _remote.calculateFee(sessionId);
      return Right(ParkingFeeMapper.toEntity(dto));
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

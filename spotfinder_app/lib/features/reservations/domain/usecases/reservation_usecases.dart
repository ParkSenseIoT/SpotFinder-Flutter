import '../../data/repositories/reservation_repository_impl.dart';
import '../entities/reservation_entity.dart';

class ListActiveReservationsUseCase {
  ListActiveReservationsUseCase(this.repository);
  final ReservationRepository repository;
  Future<List<ReservationEntity>> execute(int userId) => repository.listActive(userId);
}

class ListReservationHistoryUseCase {
  ListReservationHistoryUseCase(this.repository);
  final ReservationRepository repository;
  Future<List<ReservationEntity>> execute(int userId) => repository.listHistory(userId);
}

class CreateReservationUseCase {
  CreateReservationUseCase(this.repository);
  final ReservationRepository repository;

  Future<ReservationEntity> execute({
    required int userId,
    required int slotId,
    DateTime? reservedFrom,
    int? gracePeriodMinutes,
  }) =>
      repository.create(
        userId: userId,
        slotId: slotId,
        reservedFrom: reservedFrom,
        gracePeriodMinutes: gracePeriodMinutes,
      );
}

class CancelReservationUseCase {
  CancelReservationUseCase(this.repository);
  final ReservationRepository repository;

  Future<ReservationEntity> execute({required int reservationId, String? reason}) =>
      repository.cancel(reservationId: reservationId, reason: reason);
}

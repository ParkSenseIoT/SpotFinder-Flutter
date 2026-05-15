import '../../data/repositories/payment_repository_impl.dart';
import '../entities/active_session_entity.dart';
import '../entities/parking_fee_entity.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_method.dart';

class GetActiveSessionUseCase {
  GetActiveSessionUseCase(this.repository);
  final PaymentRepository repository;

  Future<ActiveSessionEntity?> execute(int userId) => repository.getActiveSession(userId);
}

class CalculateFeeUseCase {
  CalculateFeeUseCase(this.repository);
  final PaymentRepository repository;

  Future<ParkingFeeEntity> execute(int sessionId) => repository.calculateFee(sessionId);
}

class InitiatePaymentUseCase {
  InitiatePaymentUseCase(this.repository);
  final PaymentRepository repository;

  Future<PaymentEntity> execute({
    required int sessionId,
    required PaymentMethod method,
    required String token,
  }) =>
      repository.initiatePayment(sessionId: sessionId, method: method, token: token);
}

class GetPaymentHistoryUseCase {
  GetPaymentHistoryUseCase(this.repository);
  final PaymentRepository repository;

  Future<List<PaymentEntity>> execute(int userId) => repository.getHistory(userId);
}

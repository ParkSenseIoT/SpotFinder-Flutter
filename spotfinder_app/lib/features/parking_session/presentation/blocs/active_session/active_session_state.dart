import 'package:equatable/equatable.dart';

import '../../../domain/entities/parking_fee.dart';
import '../../../domain/entities/parking_session.dart';

enum ActiveSessionStatus { initial, loading, success, empty, failure, ending, ended }

class ActiveSessionState extends Equatable {
  const ActiveSessionState({
    this.status = ActiveSessionStatus.initial,
    this.session,
    this.fee,
    this.errorMessage,
  });

  final ActiveSessionStatus status;
  final ParkingSession? session;
  final ParkingFee? fee;
  final String? errorMessage;

  ActiveSessionState copyWith({
    ActiveSessionStatus? status,
    ParkingSession? session,
    ParkingFee? fee,
    String? errorMessage,
    bool clearSession = false,
    bool clearFee = false,
    bool clearError = false,
  }) {
    return ActiveSessionState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      fee: clearFee ? null : fee ?? this.fee,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, fee, errorMessage];
}

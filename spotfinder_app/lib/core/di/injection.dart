import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../config/app_config.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/restore_session_use_case.dart';
import '../../features/auth/domain/usecases/sign_in_use_case.dart';
import '../../features/auth/domain/usecases/sign_out_use_case.dart';
import '../../features/auth/domain/usecases/sign_up_use_case.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/parking_session/data/datasources/parking_session_remote_data_source.dart';
import '../../features/parking_session/data/datasources/parking_session_remote_data_source_impl.dart';
import '../../features/parking_session/data/repositories/parking_session_repository_impl.dart';
import '../../features/parking_session/domain/repositories/parking_session_repository.dart';
import '../../features/parking_session/domain/usecases/calculate_fee_use_case.dart';
import '../../features/parking_session/domain/usecases/end_session_use_case.dart';
import '../../features/parking_session/domain/usecases/get_active_session_use_case.dart';
import '../../features/parking_session/domain/usecases/get_session_by_id_use_case.dart';
import '../../features/parking_session/domain/usecases/get_session_history_use_case.dart';
import '../../features/parking_session/presentation/blocs/active_session/active_session_bloc.dart';
import '../network/api_client.dart';
import '../storage/secure_session_storage.dart';
import '../storage/session_storage.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({AppConfig config = AppConfig.dev}) async {
  // Config
  getIt.registerSingleton<AppConfig>(config);

  // Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<SessionStorage>(() => SecureSessionStorage(getIt()));

  // Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient.create(config: getIt(), sessionStorage: getIt()),
  );

  // Auth — data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      sessionStorage: getIt(),
    ),
  );

  // Auth — domain
  getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(getIt()));
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton<RestoreSessionUseCase>(() => RestoreSessionUseCase(getIt()));

  // Auth — bloc (singleton — app-wide auth state)
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(
        signIn: getIt(),
        signUp: getIt(),
        signOut: getIt(),
        restoreSession: getIt(),
      ));

  // Parking session — data
  getIt.registerLazySingleton<ParkingSessionRemoteDataSource>(
    () => ParkingSessionRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ParkingSessionRepository>(
    () => ParkingSessionRepositoryImpl(getIt()),
  );

  // Parking session — domain
  getIt.registerLazySingleton<GetActiveSessionUseCase>(() => GetActiveSessionUseCase(getIt()));
  getIt.registerLazySingleton<GetSessionByIdUseCase>(() => GetSessionByIdUseCase(getIt()));
  getIt.registerLazySingleton<GetSessionHistoryUseCase>(() => GetSessionHistoryUseCase(getIt()));
  getIt.registerLazySingleton<EndSessionUseCase>(() => EndSessionUseCase(getIt()));
  getIt.registerLazySingleton<CalculateFeeUseCase>(() => CalculateFeeUseCase(getIt()));

  // Parking session — bloc (singleton — active session is global)
  getIt.registerLazySingleton<ActiveSessionBloc>(() => ActiveSessionBloc(
        getActiveSession: getIt(),
        calculateFee: getIt(),
        endSession: getIt(),
      ));
}

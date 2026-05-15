import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../storage/session_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  factory ApiClient.create({
    required AppConfig config,
    required SessionStorage sessionStorage,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(sessionStorage),
      LoggingInterceptor(),
    ]);
    return ApiClient(dio);
  }
}

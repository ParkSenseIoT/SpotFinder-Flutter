import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Singleton wrapper around Dio that:
///   - points to the SpotFinder backend
///   - automatically attaches `Authorization: Bearer <jwt>` when available
///   - throws a typed [ApiException] on HTTP errors so the UI layer doesn't
///     need to know about Dio internals.
class ApiClient {
  ApiClient._(this._dio);

  static ApiClient? _instance;
  factory ApiClient() => _instance ??= _build();

  static ApiClient _build() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    final storage = TokenStorage();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    return ApiClient._(dio);
  }

  final Dio _dio;
  Dio get raw => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get<T>(path, queryParameters: query);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> post<T>(String path, {Object? body}) async {
    try {
      return await _dio.post<T>(path, data: body);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> put<T>(String path, {Object? body}) async {
    try {
      return await _dio.put<T>(path, data: body);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {Object? body}) async {
    try {
      return await _dio.patch<T>(path, data: body);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

/// Translates a [DioException] to a stable shape the UI can show to the user.
class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.body});

  final int? statusCode;
  final String message;
  final dynamic body;

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String message;
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else {
      message = _defaultMessage(status, e);
    }
    return ApiException(statusCode: status, message: message, body: data);
  }

  static String _defaultMessage(int? status, DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'No se pudo contactar al servidor (timeout).';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sin conexión al servidor SpotFinder.';
    }
    switch (status) {
      case 400:
        return 'Datos inválidos.';
      case 401:
        return 'Credenciales incorrectas.';
      case 403:
        return 'Acceso denegado.';
      case 404:
        return 'Recurso no encontrado.';
      case 409:
        return 'Conflicto (ya existe un registro).';
      case 422:
        return 'No se pudo procesar la solicitud.';
      default:
        return 'Error inesperado del servidor (${status ?? '?'}).';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

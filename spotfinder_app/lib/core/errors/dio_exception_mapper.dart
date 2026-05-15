import 'package:dio/dio.dart';

import 'failure.dart';

class DioExceptionMapper {
  const DioExceptionMapper._();

  static Failure map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Unable to reach the server');
      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Invalid SSL certificate');
      case DioExceptionType.badResponse:
        return _mapStatusCode(error);
      case DioExceptionType.unknown:
        return UnknownFailure(error.message ?? 'Unknown network error');
    }
  }

  static Failure _mapStatusCode(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    final message = _extractMessage(body) ?? error.message ?? 'Request failed';

    switch (status) {
      case 400:
        return ValidationFailure(message);
      case 401:
        return UnauthorizedFailure(message);
      case 403:
        return UnauthorizedFailure(message);
      case 404:
        return NotFoundFailure(message);
      case 409:
        return ConflictFailure(message);
      default:
        return ServerFailure(message, statusCode: status);
    }
  }

  static String? _extractMessage(dynamic body) {
    if (body is String && body.isNotEmpty) return body;
    if (body is Map<String, dynamic>) {
      return body['message']?.toString() ?? body['error']?.toString();
    }
    return null;
  }
}

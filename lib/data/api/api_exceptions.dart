import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        if (statusCode == 429) {
          return ApiException(
            'API rate limit reached (10 req/min). Please wait a moment.',
            statusCode: 429,
          );
        } else if (statusCode == 403) {
          return ApiException('Invalid API Key or access restricted.', statusCode: 403);
        } else if (statusCode == 404) {
          return ApiException('Requested resource not found.', statusCode: 404);
        }
        return ApiException(
          dioError.response?.data?['message'] ?? 'Server error occurred ($statusCode)',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return ApiException('No internet connection. Please try again.');

      default:
        return ApiException('An unexpected error occurred. Please try again.');
    }
  }

  @override
  String toString() => message;
}

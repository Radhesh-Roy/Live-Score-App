import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';

class DioClient {
  late final Dio _dio;
  int _requestsAvailable = 10;
  int _secondsToReset = 0;

  int get requestsAvailable => _requestsAvailable;
  int get secondsToReset => _secondsToReset;

  DioClient({String? apiToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'X-Auth-Token': apiToken ?? ApiConstants.defaultApiToken,
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('[DIO] Request: ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final available = response.headers.value('X-RequestsAvailable');
          final reset = response.headers.value('X-RequestCounter-Reset');
          if (available != null) {
            _requestsAvailable = int.tryParse(available) ?? _requestsAvailable;
          }
          if (reset != null) {
            _secondsToReset = int.tryParse(reset) ?? _secondsToReset;
          }

          if (kDebugMode) {
            print('[DIO] Response: ${response.statusCode} | Available reqs: $_requestsAvailable');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('[DIO] Error: ${e.message} (${e.response?.statusCode})');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

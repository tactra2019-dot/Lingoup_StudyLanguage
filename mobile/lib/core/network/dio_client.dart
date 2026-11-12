import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LogInterceptor(
    requestBody: false,
    responseBody: false,
    logPrint: (obj) => null, // silent in release
  ));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref ref;
  final _storage = const FlutterSecureStorage();

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired - could trigger logout here
    }
    handler.next(err);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';

  static ApiException fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data?['detail'];
    final message = detail?.toString() ??
        switch (statusCode) {
          400 => 'Bad request',
          401 => 'Unauthorized. Please log in again.',
          403 => 'Forbidden',
          404 => 'Not found',
          422 => 'Validation error',
          500 => 'Server error. Please try again later.',
          _ => 'Network error. Please check your connection.',
        };
    return ApiException(message, statusCode: statusCode);
  }
}

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(message: 'Kết nối quá hạn, thử lại sau');
      case DioExceptionType.connectionError:
        return const ApiException(message: 'Không có kết nối mạng');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final statusCode = e.response?.statusCode;
        if (statusCode == 423 &&
            data is Map &&
            data['code'] == 'ACCOUNT_LOCKED') {
          return AccountLockedException(
            message: _parseMessage(data) ?? 'Tài khoản đã bị khóa.',
            lockedReason: data['locked_reason'] as String?,
            lockedUntil: data['locked_until'] as String?,
            hasPendingAppeal: data['has_pending_appeal'] as bool? ?? false,
            statusCode: statusCode,
          );
        }
        return ApiException(
          message: _parseMessage(data) ?? 'Có lỗi xảy ra',
          statusCode: statusCode,
        );
      default:
        return const ApiException(message: 'Có lỗi xảy ra, thử lại sau');
    }
  }

  static String? _parseMessage(dynamic data) {
    if (data is Map) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }

  @override
  String toString() => message;
}

class AccountLockedException extends ApiException {
  final String? lockedReason;
  final String? lockedUntil;
  final bool hasPendingAppeal;

  const AccountLockedException({
    required super.message,
    required this.lockedReason,
    required this.lockedUntil,
    required this.hasPendingAppeal,
    super.statusCode,
  });
}

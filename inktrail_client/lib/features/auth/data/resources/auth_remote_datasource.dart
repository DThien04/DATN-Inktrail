import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<String> forgotPassword({required String email});
  Future<String> verifyResetOtp({required String email, required String otp});
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<void> logout();
  Future<String> submitLockAppeal({
    required String email,
    required String password,
    required String reason,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  const AuthRemoteDatasourceImpl(this._dio, this._tokenStorage);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      await _tokenStorage.saveTokens(
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );

      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );

      await _tokenStorage.saveTokens(
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );

      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return response.data['message'] as String? ?? 'Đã gửi mã OTP';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-reset-otp',
        data: {'email': email, 'otp': otp},
      );

      return response.data['message'] as String? ?? 'OTP hợp lệ';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
      );

      return response.data['message'] as String? ?? 'Đặt lại mật khẩu thành công';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    await _tokenStorage.clearTokens();

    if (refreshToken == null || refreshToken.isEmpty) {
      return;
    }

    try {
      await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
    } on DioException catch (_) {
    }
  }

  @override
  Future<String> submitLockAppeal({
    required String email,
    required String password,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/lock-appeal',
        data: {
          'email': email,
          'password': password,
          'reason': reason,
        },
      );

      final data = response.data;
      if (data is Map && data['appeal'] is Map) {
        return 'Đã gửi khiếu nại. Quản trị viên sẽ phản hồi sớm.';
      }
      return 'Đã gửi khiếu nại.';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

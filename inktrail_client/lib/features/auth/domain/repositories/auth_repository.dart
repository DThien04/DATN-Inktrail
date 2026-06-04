import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> register({
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

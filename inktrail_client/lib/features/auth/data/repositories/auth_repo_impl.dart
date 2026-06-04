import 'package:ink_trail_client/features/auth/data/resources/auth_remote_datasource.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepoImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  const AuthRepoImpl(this._datasource);

  @override
  Future<UserEntity> login({required String email, required String password}) =>
      _datasource.login(email: email, password: password);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) => _datasource.register(
    email: email,
    password: password,
    displayName: displayName,
  );

  @override
  Future<String> forgotPassword({required String email}) =>
      _datasource.forgotPassword(email: email);

  @override
  Future<String> verifyResetOtp({required String email, required String otp}) =>
      _datasource.verifyResetOtp(email: email, otp: otp);

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _datasource.resetPassword(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<String> submitLockAppeal({
    required String email,
    required String password,
    required String reason,
  }) => _datasource.submitLockAppeal(
        email: email,
        password: password,
        reason: reason,
      );
}

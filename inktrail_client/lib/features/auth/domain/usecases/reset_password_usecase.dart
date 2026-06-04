import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository _repo;
  const ResetPasswordUsecase(this._repo);

  Future<String> call({
    required String email,
    required String otp,
    required String newPassword,
  }) => _repo.resetPassword(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );
}

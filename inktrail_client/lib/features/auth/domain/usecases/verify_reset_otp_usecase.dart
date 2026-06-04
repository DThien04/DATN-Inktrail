import '../repositories/auth_repository.dart';

class VerifyResetOtpUsecase {
  final AuthRepository _repo;
  const VerifyResetOtpUsecase(this._repo);

  Future<String> call({required String email, required String otp}) =>
      _repo.verifyResetOtp(email: email, otp: otp);
}

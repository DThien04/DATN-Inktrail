import '../repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository _repo;
  const ForgotPasswordUsecase(this._repo);

  Future<String> call({required String email}) =>
      _repo.forgotPassword(email: email);
}

import '../repositories/auth_repository.dart';

class SubmitLockAppealUsecase {
  final AuthRepository _repo;

  const SubmitLockAppealUsecase(this._repo);

  Future<String> call({
    required String email,
    required String password,
    required String reason,
  }) => _repo.submitLockAppeal(
        email: email,
        password: password,
        reason: reason,
      );
}

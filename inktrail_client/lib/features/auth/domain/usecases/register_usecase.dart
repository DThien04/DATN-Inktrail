import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repo;
  const RegisterUsecase(this._repo);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
  }) => _repo.register(
    email: email,
    password: password,
    displayName: displayName,
  );
}

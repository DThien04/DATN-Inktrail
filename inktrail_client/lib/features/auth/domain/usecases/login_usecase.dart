import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repo;
  const LoginUsecase(this._repo);

  Future<UserEntity> call({required String email, required String password}) =>
      _repo.login(email: email, password: password);
}

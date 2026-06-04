import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';

class DeleteMyAvatarUsecase {
  final ProfileRepository _repo;

  const DeleteMyAvatarUsecase(this._repo);

  Future<ProfileEntity> call() => _repo.deleteMyAvatar();
}

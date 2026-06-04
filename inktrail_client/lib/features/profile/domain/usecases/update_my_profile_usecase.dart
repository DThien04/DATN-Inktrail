import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';

class UpdateMyProfileUsecase {
  final ProfileRepository _repo;

  const UpdateMyProfileUsecase(this._repo);

  Future<ProfileEntity> call({
    required String displayName,
    required String bio,
  }) => _repo.updateMyProfile(displayName: displayName, bio: bio);
}

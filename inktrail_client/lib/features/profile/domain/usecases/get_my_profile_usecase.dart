import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';

class GetMyProfileUsecase {
  final ProfileRepository _repo;

  const GetMyProfileUsecase(this._repo);

  Future<ProfileEntity> call() => _repo.getMyProfile();
}

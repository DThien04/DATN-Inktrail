import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';

class UploadMyAvatarUsecase {
  final ProfileRepository _repo;

  const UploadMyAvatarUsecase(this._repo);

  Future<ProfileEntity> call({
    required List<int> avatarBytes,
    required String fileName,
    required String mimeType,
  }) => _repo.uploadMyAvatar(
    avatarBytes: avatarBytes,
    fileName: fileName,
    mimeType: mimeType,
  );
}

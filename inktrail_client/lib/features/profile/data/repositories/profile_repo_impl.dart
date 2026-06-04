import 'package:ink_trail_client/features/profile/data/resources/profile_remote_datasource.dart';
import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepoImpl implements ProfileRepository {
  final ProfileRemoteDatasource _datasource;

  const ProfileRepoImpl(this._datasource);

  @override
  Future<ProfileEntity> getMyProfile() => _datasource.getMyProfile();

  @override
  Future<ProfileEntity> updateMyProfile({
    required String displayName,
    required String bio,
  }) => _datasource.updateMyProfile(displayName: displayName, bio: bio);

  @override
  Future<ProfileEntity> uploadMyAvatar({
    required List<int> avatarBytes,
    required String fileName,
    required String mimeType,
  }) => _datasource.uploadMyAvatar(
    avatarBytes: avatarBytes,
    fileName: fileName,
    mimeType: mimeType,
  );

  @override
  Future<ProfileEntity> deleteMyAvatar() => _datasource.deleteMyAvatar();

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _datasource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

  @override
  Future<AuthorProfileEntity> getAuthorProfile({
    required String authorId,
  }) =>
      _datasource.getAuthorProfile(authorId: authorId);

  @override
  Future<List<AuthorStoryEntity>> getAuthorStories({
    required String authorId,
  }) =>
      _datasource.getAuthorStories(authorId: authorId);

  @override
  Future<AuthorFollowResultEntity> setAuthorFollow({
    required String authorId,
    required bool follow,
    required bool fallbackFollowing,
    required int fallbackFollowerCount,
  }) =>
      _datasource.setAuthorFollow(
        authorId: authorId,
        follow: follow,
        fallbackFollowing: fallbackFollowing,
        fallbackFollowerCount: fallbackFollowerCount,
      );

  @override
  Future<List<FollowedAuthorEntity>> getFollowedAuthors() =>
      _datasource.getFollowedAuthors();

  @override
  Future<List<FollowedAuthorEntity>> getFollowers() =>
      _datasource.getFollowers();
}

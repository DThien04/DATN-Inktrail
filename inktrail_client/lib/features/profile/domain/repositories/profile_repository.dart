import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getMyProfile();
  Future<ProfileEntity> updateMyProfile({
    required String displayName,
    required String bio,
  });
  Future<ProfileEntity> uploadMyAvatar({
    required List<int> avatarBytes,
    required String fileName,
    required String mimeType,
  });
  Future<ProfileEntity> deleteMyAvatar();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<AuthorProfileEntity> getAuthorProfile({required String authorId});

  Future<List<AuthorStoryEntity>> getAuthorStories({required String authorId});

  Future<AuthorFollowResultEntity> setAuthorFollow({
    required String authorId,
    required bool follow,
    required bool fallbackFollowing,
    required int fallbackFollowerCount,
  });

  Future<List<FollowedAuthorEntity>> getFollowedAuthors();
  Future<List<FollowedAuthorEntity>> getFollowers();
}

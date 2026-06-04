import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';

class GetAuthorProfileUsecase {
  final ProfileRepository _repository;

  const GetAuthorProfileUsecase(this._repository);

  Future<AuthorProfileEntity> call({required String authorId}) {
    return _repository.getAuthorProfile(authorId: authorId);
  }
}

class GetAuthorStoriesUsecase {
  final ProfileRepository _repository;

  const GetAuthorStoriesUsecase(this._repository);

  Future<List<AuthorStoryEntity>> call({required String authorId}) {
    return _repository.getAuthorStories(authorId: authorId);
  }
}

class SetAuthorFollowUsecase {
  final ProfileRepository _repository;

  const SetAuthorFollowUsecase(this._repository);

  Future<AuthorFollowResultEntity> call({
    required String authorId,
    required bool follow,
    required bool fallbackFollowing,
    required int fallbackFollowerCount,
  }) {
    return _repository.setAuthorFollow(
      authorId: authorId,
      follow: follow,
      fallbackFollowing: fallbackFollowing,
      fallbackFollowerCount: fallbackFollowerCount,
    );
  }
}

class GetFollowedAuthorsUsecase {
  final ProfileRepository _repository;

  const GetFollowedAuthorsUsecase(this._repository);

  Future<List<FollowedAuthorEntity>> call() {
    return _repository.getFollowedAuthors();
  }
}

class GetFollowersUsecase {
  final ProfileRepository _repository;

  const GetFollowersUsecase(this._repository);

  Future<List<FollowedAuthorEntity>> call() {
    return _repository.getFollowers();
  }
}

class ChangePasswordUsecase {
  final ProfileRepository _repository;

  const ChangePasswordUsecase(this._repository);

  Future<void> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

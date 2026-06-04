import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';
import 'package:ink_trail_client/features/story_management/domain/repositories/story_management_repository.dart';

class GetMyStoriesUsecase {
  final StoryManagementRepository _repository;

  const GetMyStoriesUsecase(this._repository);

  Future<List<MyStoryEntity>> call({String? status}) {
    return _repository.getMyStories(status: status);
  }
}

class CreateMyStoryUsecase {
  final StoryManagementRepository _repository;

  const CreateMyStoryUsecase(this._repository);

  Future<MyStoryEntity> call({
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) {
    return _repository.createMyStory(
      title: title,
      description: description,
      status: status,
      tags: tags,
      coverBytes: coverBytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}

class UpdateMyStoryUsecase {
  final StoryManagementRepository _repository;

  const UpdateMyStoryUsecase(this._repository);

  Future<MyStoryEntity> call({
    required String storyId,
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) {
    return _repository.updateMyStory(
      storyId: storyId,
      title: title,
      description: description,
      status: status,
      tags: tags,
      coverBytes: coverBytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}

class DeleteMyStoryUsecase {
  final StoryManagementRepository _repository;

  const DeleteMyStoryUsecase(this._repository);

  Future<void> call({required String storyId}) {
    return _repository.deleteMyStory(storyId: storyId);
  }
}

class UpdateMyStoryStatusUsecase {
  final StoryManagementRepository _repository;

  const UpdateMyStoryStatusUsecase(this._repository);

  Future<MyStoryEntity> call({
    required String storyId,
    required String status,
  }) {
    return _repository.updateMyStoryStatus(
      storyId: storyId,
      status: status,
    );
  }
}

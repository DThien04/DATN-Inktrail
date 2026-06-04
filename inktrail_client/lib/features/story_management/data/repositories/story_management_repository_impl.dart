import 'package:ink_trail_client/features/story_management/data/resources/story_management_remote_datasource.dart';
import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';
import 'package:ink_trail_client/features/story_management/domain/repositories/story_management_repository.dart';

class StoryManagementRepositoryImpl implements StoryManagementRepository {
  final StoryManagementRemoteDatasource _datasource;

  const StoryManagementRepositoryImpl(this._datasource);

  @override
  Future<List<MyStoryEntity>> getMyStories({String? status}) =>
      _datasource.getMyStories(status: status);

  @override
  Future<MyStoryEntity> createMyStory({
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) => _datasource.createMyStory(
    title: title,
    description: description,
    status: status,
    tags: tags,
    coverBytes: coverBytes,
    fileName: fileName,
    mimeType: mimeType,
  );

  @override
  Future<MyStoryEntity> updateMyStory({
    required String storyId,
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) => _datasource.updateMyStory(
    storyId: storyId,
    title: title,
    description: description,
    status: status,
    tags: tags,
    coverBytes: coverBytes,
    fileName: fileName,
    mimeType: mimeType,
  );

  @override
  Future<MyStoryEntity> updateMyStoryStatus({
    required String storyId,
    required String status,
  }) => _datasource.updateMyStoryStatus(
    storyId: storyId,
    status: status,
  );

  @override
  Future<void> deleteMyStory({required String storyId}) =>
      _datasource.deleteMyStory(storyId: storyId);
}

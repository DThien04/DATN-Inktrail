import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';

abstract class StoryManagementRepository {
  Future<List<MyStoryEntity>> getMyStories({String? status});

  Future<MyStoryEntity> createMyStory({
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  });

  Future<MyStoryEntity> updateMyStory({
    required String storyId,
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  });

  Future<MyStoryEntity> updateMyStoryStatus({
    required String storyId,
    required String status,
  });

  Future<void> deleteMyStory({required String storyId});
}

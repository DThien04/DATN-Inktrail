import 'package:ink_trail_client/features/chapter_management/domain/entities/my_story_chapter_entity.dart';

abstract class ChapterManagementRepository {
  Future<List<MyStoryChapterEntity>> getMyStoryChapters({
    required String storyId,
  });

  Future<MyStoryChapterEntity> createMyStoryChapter({
    required String storyId,
    required int chapterNumber,
    required String title,
    required String content,
  });

  Future<MyStoryChapterEntity> updateMyStoryChapter({
    required String chapterId,
    required int chapterNumber,
    required String title,
    required String content,
  });

  Future<MyStoryChapterEntity> publishMyStoryChapter({required String chapterId});

  Future<MyStoryChapterEntity> unpublishMyStoryChapter({
    required String chapterId,
  });

  Future<void> deleteMyStoryChapter({required String chapterId});
}

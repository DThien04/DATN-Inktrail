import 'package:ink_trail_client/features/chapter_management/domain/entities/my_story_chapter_entity.dart';
import 'package:ink_trail_client/features/chapter_management/domain/repositories/chapter_management_repository.dart';
import 'package:ink_trail_client/features/chapter_management/data/resources/chapter_management_remote_datasource.dart';

class ChapterManagementRepositoryImpl implements ChapterManagementRepository {
  final ChapterManagementRemoteDatasource _datasource;

  const ChapterManagementRepositoryImpl(this._datasource);

  @override
  Future<List<MyStoryChapterEntity>> getMyStoryChapters({
    required String storyId,
  }) => _datasource.getMyStoryChapters(storyId: storyId);

  @override
  Future<MyStoryChapterEntity> createMyStoryChapter({
    required String storyId,
    required int chapterNumber,
    required String title,
    required String content,
  }) => _datasource.createMyStoryChapter(
    storyId: storyId,
    chapterNumber: chapterNumber,
    title: title,
    content: content,
  );

  @override
  Future<MyStoryChapterEntity> updateMyStoryChapter({
    required String chapterId,
    required int chapterNumber,
    required String title,
    required String content,
  }) => _datasource.updateMyStoryChapter(
    chapterId: chapterId,
    chapterNumber: chapterNumber,
    title: title,
    content: content,
  );

  @override
  Future<MyStoryChapterEntity> publishMyStoryChapter({
    required String chapterId,
  }) => _datasource.publishMyStoryChapter(chapterId: chapterId);

  @override
  Future<MyStoryChapterEntity> unpublishMyStoryChapter({
    required String chapterId,
  }) => _datasource.unpublishMyStoryChapter(chapterId: chapterId);

  @override
  Future<void> deleteMyStoryChapter({required String chapterId}) =>
      _datasource.deleteMyStoryChapter(chapterId: chapterId);
}

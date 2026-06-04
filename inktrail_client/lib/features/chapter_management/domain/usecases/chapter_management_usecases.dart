import 'package:ink_trail_client/features/chapter_management/domain/entities/my_story_chapter_entity.dart';
import 'package:ink_trail_client/features/chapter_management/domain/repositories/chapter_management_repository.dart';

class GetMyStoryChaptersUsecase {
  final ChapterManagementRepository _repository;

  const GetMyStoryChaptersUsecase(this._repository);

  Future<List<MyStoryChapterEntity>> call({required String storyId}) {
    return _repository.getMyStoryChapters(storyId: storyId);
  }
}

class CreateMyStoryChapterUsecase {
  final ChapterManagementRepository _repository;

  const CreateMyStoryChapterUsecase(this._repository);

  Future<MyStoryChapterEntity> call({
    required String storyId,
    required int chapterNumber,
    required String title,
    required String content,
  }) {
    return _repository.createMyStoryChapter(
      storyId: storyId,
      chapterNumber: chapterNumber,
      title: title,
      content: content,
    );
  }
}

class UpdateMyStoryChapterUsecase {
  final ChapterManagementRepository _repository;

  const UpdateMyStoryChapterUsecase(this._repository);

  Future<MyStoryChapterEntity> call({
    required String chapterId,
    required int chapterNumber,
    required String title,
    required String content,
  }) {
    return _repository.updateMyStoryChapter(
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      title: title,
      content: content,
    );
  }
}

class PublishMyStoryChapterUsecase {
  final ChapterManagementRepository _repository;

  const PublishMyStoryChapterUsecase(this._repository);

  Future<MyStoryChapterEntity> call({required String chapterId}) {
    return _repository.publishMyStoryChapter(chapterId: chapterId);
  }
}

class UnpublishMyStoryChapterUsecase {
  final ChapterManagementRepository _repository;

  const UnpublishMyStoryChapterUsecase(this._repository);

  Future<MyStoryChapterEntity> call({required String chapterId}) {
    return _repository.unpublishMyStoryChapter(chapterId: chapterId);
  }
}

class DeleteMyStoryChapterUsecase {
  final ChapterManagementRepository _repository;

  const DeleteMyStoryChapterUsecase(this._repository);

  Future<void> call({required String chapterId}) {
    return _repository.deleteMyStoryChapter(chapterId: chapterId);
  }
}

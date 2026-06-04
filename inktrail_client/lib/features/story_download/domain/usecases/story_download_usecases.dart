import 'package:ink_trail_client/core/local/offline_repository.dart';
import 'package:ink_trail_client/features/story_download/domain/entities/story_download_chapter_entity.dart';

class GetDownloadedStoryChapterIdsUsecase {
  final OfflineRepository _repository;

  const GetDownloadedStoryChapterIdsUsecase(this._repository);

  Future<Set<String>> call(String storyId) {
    return _repository.getDownloadedChapterIds(storyId);
  }
}

class DownloadStoryChapterUsecase {
  final OfflineRepository _repository;

  const DownloadStoryChapterUsecase(this._repository);

  Future<void> call({
    required String storyId,
    required String storyTitle,
    required String storySlug,
    required String storyAuthor,
    required String storyCoverUrl,
    required StoryDownloadChapterEntity chapter,
  }) {
    return _repository.saveDownloadedChapterContent(
      storyId: storyId,
      storyTitle: storyTitle,
      storySlug: storySlug,
      storyAuthor: storyAuthor,
      storyCoverUrl: storyCoverUrl,
      chapter: DownloadedChapterContentPayload(
        chapterId: chapter.id,
        chapterNumber: chapter.number,
        chapterTitle: chapter.title,
        paragraphs: chapter.paragraphs,
      ),
    );
  }
}

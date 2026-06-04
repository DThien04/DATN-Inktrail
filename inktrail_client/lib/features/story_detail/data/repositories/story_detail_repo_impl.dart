import 'package:ink_trail_client/features/story_detail/data/resources/story_detail_remote_datasource.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/highlighted_chapter_comment_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/remote_reading_progress_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_chapter_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_rating_review_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_suggestion_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class StoryDetailRepoImpl implements StoryDetailRepository {
  final StoryDetailRemoteDatasource _datasource;

  const StoryDetailRepoImpl(this._datasource);

  @override
  Future<StoryDetailInfoEntity> getStoryDetail({required String slug}) =>
      _datasource.getStoryDetail(slug: slug);

  @override
  Future<List<StoryDetailChapterEntity>> getChapters({
    required String storyId,
  }) =>
      _datasource.getChapters(storyId: storyId);

  @override
  Future<RemoteReadingProgressEntity?> getRemoteReadingProgress({
    required String storyId,
  }) =>
      _datasource.getRemoteReadingProgress(storyId: storyId);

  @override
  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  }) =>
      _datasource.saveRemoteReadingProgress(
        storyId: storyId,
        chapterIndex: chapterIndex,
        lastPosition: lastPosition,
      );

  @override
  Future<StoryRatingsEntity> getStoryRatings({
    required String storyId,
  }) =>
      _datasource.getStoryRatings(storyId: storyId);

  @override
  Future<void> submitStoryRating({
    required String storyId,
    required int score,
    required String content,
  }) =>
      _datasource.submitStoryRating(
        storyId: storyId,
        score: score,
        content: content,
      );

  @override
  Future<List<HighlightedChapterCommentEntity>> getHighlightedComments({
    required String storyId,
  }) =>
      _datasource.getHighlightedComments(storyId: storyId);

  @override
  Future<List<StorySuggestionEntity>> getSimilarStories({
    required String storyId,
    int limit = 10,
  }) =>
      _datasource.getSimilarStories(storyId: storyId, limit: limit);

  @override
  Future<List<StorySuggestionEntity>> getRecommendedStories({
    required String storyId,
    int limit = 12,
  }) =>
      _datasource.getRecommendedStories(storyId: storyId, limit: limit);

  @override
  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  }) =>
      _datasource.reportStory(
        storyId: storyId,
        reason: reason,
        description: description,
      );
}

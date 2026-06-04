import 'package:ink_trail_client/features/story_detail/domain/entities/highlighted_chapter_comment_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/remote_reading_progress_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_chapter_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_rating_review_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_suggestion_entity.dart';

abstract class StoryDetailRepository {
  Future<StoryDetailInfoEntity> getStoryDetail({required String slug});

  Future<List<StoryDetailChapterEntity>> getChapters({
    required String storyId,
  });

  Future<RemoteReadingProgressEntity?> getRemoteReadingProgress({
    required String storyId,
  });

  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  });

  Future<StoryRatingsEntity> getStoryRatings({
    required String storyId,
  });

  Future<void> submitStoryRating({
    required String storyId,
    required int score,
    required String content,
  });

  Future<List<HighlightedChapterCommentEntity>> getHighlightedComments({
    required String storyId,
  });

  Future<List<StorySuggestionEntity>> getSimilarStories({
    required String storyId,
    int limit = 10,
  });

  Future<List<StorySuggestionEntity>> getRecommendedStories({
    required String storyId,
    int limit = 12,
  });

  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  });
}

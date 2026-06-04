import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart'
    as story_detail_info;
import 'package:ink_trail_client/features/story_detail/domain/entities/story_rating_review_entity.dart'
    as story_detail_rating;
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';
import 'package:ink_trail_client/features/story_rating/domain/entities/story_rating_entity.dart';
import 'package:ink_trail_client/features/story_rating/domain/repositories/story_rating_repository.dart';

class StoryRatingRepositoryImpl implements StoryRatingRepository {
  final StoryDetailRepository _storyDetailRepository;

  const StoryRatingRepositoryImpl(this._storyDetailRepository);

  @override
  Future<StoryRatingsEntity> getStoryRatings({required String storyId}) async {
    final ratings = await _storyDetailRepository.getStoryRatings(
      storyId: storyId,
    );
    return StoryRatingsEntity(
      averageRating: ratings.averageRating,
      ratingCount: ratings.ratingCount,
      myRating: _mapMyRating(ratings.myRating),
      reviews: ratings.reviews.map(_mapReview).toList(),
    );
  }

  @override
  Future<void> submitStoryRating({
    required String storyId,
    required int score,
    required String content,
  }) {
    return _storyDetailRepository.submitStoryRating(
      storyId: storyId,
      score: score,
      content: content,
    );
  }

  StoryRatingMyRatingEntity? _mapMyRating(
    story_detail_info.StoryMyRatingEntity? myRating,
  ) {
    if (myRating == null) return null;
    return StoryRatingMyRatingEntity(
      score: myRating.score,
      content: myRating.content,
      editCount: myRating.editCount,
      canEdit: myRating.canEdit,
      createdAt: myRating.createdAt,
      updatedAt: myRating.updatedAt,
    );
  }

  StoryRatingReviewEntity _mapReview(
    story_detail_rating.StoryRatingReviewEntity review,
  ) {
    return StoryRatingReviewEntity(
      id: review.id,
      author: review.author,
      score: review.score,
      content: review.content,
      createdAt: review.createdAt,
    );
  }
}

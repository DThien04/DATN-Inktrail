import 'package:ink_trail_client/features/story_detail/data/models/story_detail_info_model.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_rating_review_entity.dart';

class StoryRatingReviewModel extends StoryRatingReviewEntity {
  const StoryRatingReviewModel({
    required super.id,
    required super.author,
    required super.score,
    required super.content,
    required super.createdAt,
  });

  factory StoryRatingReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final score = (json['score'] as num?)?.toInt() ?? 5;

    return StoryRatingReviewModel(
      id: (json['id'] as String? ?? '').trim(),
      author: (user['display_name'] as String? ??
              user['displayName'] as String? ??
              'Người dùng')
          .trim(),
      score: score.clamp(1, 5).toInt(),
      content: (json['content'] as String? ?? '').trim(),
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      ),
    );
  }
}

class StoryRatingsModel extends StoryRatingsEntity {
  const StoryRatingsModel({
    required super.averageRating,
    required super.ratingCount,
    required super.myRating,
    required super.reviews,
  });

  factory StoryRatingsModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final myRatingJson = json['my_rating'] as Map<String, dynamic>?;

    return StoryRatingsModel(
      averageRating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      myRating:
          myRatingJson == null ? null : StoryMyRatingModel.fromJson(myRatingJson),
      reviews: rawItems
          .whereType<Map<String, dynamic>>()
          .map(StoryRatingReviewModel.fromJson)
          .toList(),
    );
  }
}

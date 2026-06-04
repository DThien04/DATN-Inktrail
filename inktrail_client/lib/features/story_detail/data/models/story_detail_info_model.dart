import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';

class StoryDetailInfoModel extends StoryDetailInfoEntity {
  const StoryDetailInfoModel({
    super.storyId,
    required super.likeCount,
    required super.readCount,
    required super.rating,
    required super.ratingCount,
    required super.myRating,
    required super.description,
    required super.category,
    required super.tags,
    required super.authorId,
    required super.authorBio,
    required super.authorStoryCount,
  });

  factory StoryDetailInfoModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? const {};
    final myRatingJson = json['my_rating'] as Map<String, dynamic>?;
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['name'] as String? ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return StoryDetailInfoModel(
      storyId: (json['id'] as String? ?? '').trim().isEmpty
          ? null
          : (json['id'] as String).trim(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      myRating:
          myRatingJson == null ? null : StoryMyRatingModel.fromJson(myRatingJson),
      description: (json['description'] as String? ?? '').trim(),
      category: tags.isEmpty ? 'Khác' : tags.take(2).join(' · '),
      tags: tags,
      authorId: (author['id'] as String? ?? '').trim(),
      authorBio: (author['bio'] as String? ?? '').trim(),
      authorStoryCount: (author['story_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class StoryMyRatingModel extends StoryMyRatingEntity {
  const StoryMyRatingModel({
    required super.score,
    required super.content,
    required super.editCount,
    required super.canEdit,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoryMyRatingModel.fromJson(Map<String, dynamic> json) {
    return StoryMyRatingModel(
      score: ((json['score'] as num?)?.toInt() ?? 5).clamp(1, 5).toInt(),
      content: (json['content'] as String? ?? '').trim(),
      editCount: (json['edit_count'] as num?)?.toInt() ?? 0,
      canEdit: json['can_edit'] as bool? ?? false,
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      ),
      updatedAt: DateTime.tryParse(
        (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      ),
    );
  }
}

import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';

class MyStoryModel extends MyStoryEntity {
  const MyStoryModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    required super.coverUrl,
    required super.status,
    required super.moderationStatus,
    required super.moderationCheckedAt,
    required super.moderationReason,
    required super.moderationConfidence,
    required super.moderationCategories,
    required super.readCount,
    required super.likeCount,
    required super.chapterCount,
    required super.rating,
    required super.ratingCount,
    required super.tags,
    required super.updatedAt,
  });

  factory MyStoryModel.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['name'] as String? ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final moderationCategories =
        (json['moderation_categories'] as List<dynamic>? ?? const [])
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();

    return MyStoryModel(
      id: (json['id'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      slug: (json['slug'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      coverUrl: (json['cover_url'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? 'draft').trim(),
      moderationStatus:
          (json['moderation_status'] as String? ?? 'pending').trim(),
      moderationCheckedAt: DateTime.tryParse(
        (json['moderation_checked_at'] as String? ?? '').trim(),
      ),
      moderationReason: (json['moderation_reason'] as String? ?? '').trim(),
      moderationConfidence: (json['moderation_confidence'] as num?)?.toDouble(),
      moderationCategories: moderationCategories,
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      chapterCount: (json['chapter_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      tags: tags,
      updatedAt: DateTime.tryParse(
        (json['updated_at'] as String? ?? '').trim(),
      ),
    );
  }
}

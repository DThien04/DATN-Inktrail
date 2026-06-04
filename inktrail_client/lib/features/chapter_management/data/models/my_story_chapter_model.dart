import 'package:ink_trail_client/features/chapter_management/domain/entities/my_story_chapter_entity.dart';

class MyStoryChapterModel extends MyStoryChapterEntity {
  const MyStoryChapterModel({
    required super.id,
    required super.chapterNumber,
    required super.title,
    required super.content,
    required super.status,
    required super.moderationStatus,
    required super.moderationReason,
    required super.moderationCategories,
    required super.likeCount,
    required super.commentCount,
    required super.updatedAt,
  });

  factory MyStoryChapterModel.fromJson(Map<String, dynamic> json) {
    return MyStoryChapterModel(
      id: (json['id'] as String? ?? '').trim(),
      chapterNumber: (json['chapter_number'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String? ?? '').trim(),
      content: (json['content'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? 'draft').trim(),
      moderationStatus:
          (json['moderation_status'] as String? ?? 'pending').trim(),
      moderationReason: (json['moderation_reason'] as String? ?? '').trim(),
      moderationCategories:
          (json['moderation_categories'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(
        (json['updated_at'] as String? ?? '').trim(),
      ),
    );
  }
}

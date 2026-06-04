import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_chapter_entity.dart';

class StoryDetailChapterModel extends StoryDetailChapterEntity {
  const StoryDetailChapterModel({
    required super.id,
    required super.number,
    required super.title,
    required super.paragraphs,
    required super.likeCount,
    required super.commentCount,
    required super.isLiked,
  });

  factory StoryDetailChapterModel.fromJson(Map<String, dynamic> json) {
    final chapterNumber = (json['chapter_number'] as num?)?.toInt() ?? 0;
    final title = (json['title'] as String? ?? '').trim();
    final content = (json['content'] as String? ?? '').trim();
    final paragraphs = content
        .split(RegExp(r'\r?\n\s*\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return StoryDetailChapterModel(
      id: (json['id'] as String? ?? '').trim(),
      number: chapterNumber <= 0 ? 1 : chapterNumber,
      title: title.isEmpty ? 'Chương $chapterNumber' : title,
      paragraphs:
          paragraphs.isEmpty ? const ['Chưa có nội dung'] : paragraphs,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}

import 'package:ink_trail_client/features/story_detail/domain/entities/story_suggestion_entity.dart';

class StorySuggestionModel extends StorySuggestionEntity {
  const StorySuggestionModel({
    required super.id,
    required super.slug,
    required super.title,
    required super.description,
    required super.author,
    required super.coverUrl,
    required super.category,
    required super.readCount,
    required super.likeCount,
    required super.chapterCount,
    required super.isLiked,
    required super.tags,
  });

  factory StorySuggestionModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? const {};
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((tag) => (tag['name'] as String? ?? '').trim())
        .where((name) => name.isNotEmpty)
        .toList();

    return StorySuggestionModel(
      id: (json['id'] as String? ?? '').trim(),
      slug: (json['slug'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      author: (author['display_name'] as String? ?? 'Ẩn danh').trim(),
      coverUrl: (json['cover_url'] as String? ?? '').trim(),
      category: tags.isEmpty ? 'Khác' : tags.take(2).join(' · '),
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      chapterCount: (json['chapter_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      tags: tags,
    );
  }
}

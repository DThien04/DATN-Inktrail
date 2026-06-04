import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class SearchStoryModel extends StoryEntity {
  const SearchStoryModel({
    required super.id,
    required super.slug,
    required super.title,
    super.description = '',
    required super.author,
    required super.coverUrl,
    required super.category,
    required super.rating,
    required super.totalChapters,
    required super.readCount,
    required super.likeCount,
    required super.isLiked,
    required super.tags,
    super.isFeatured,
  });

  factory SearchStoryModel.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['name'] as String? ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final author =
        ((json['author'] as Map<String, dynamic>?)?['display_name'] as String?)
                ?.trim() ??
            'Đang cập nhật';

    return SearchStoryModel(
      id: (json['id'] as String? ?? '').trim(),
      slug: (json['slug'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      author: author,
      coverUrl: (json['cover_url'] as String? ?? '').trim(),
      category: tags.isEmpty ? 'Khác' : tags.take(2).join(' · '),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalChapters: (json['chapter_count'] as num?)?.toInt() ?? 0,
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      tags: tags,
    );
  }
}

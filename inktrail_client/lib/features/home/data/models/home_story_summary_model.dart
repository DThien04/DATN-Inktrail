import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class HomeStorySummaryModel extends StoryEntity {
  const HomeStorySummaryModel({
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

  factory HomeStorySummaryModel.fromJson(
    Map<String, dynamic> json, {
    bool isFeatured = false,
  }) {
    final author = json['author'] as Map<String, dynamic>? ?? const {};
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String? ?? '')
        .where((item) => item.isNotEmpty)
        .toList();

    return HomeStorySummaryModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      author: author['display_name'] as String? ?? 'Ẩn danh',
      coverUrl: json['cover_url'] as String? ?? '',
      category: tags.isEmpty ? 'Khác' : tags.take(2).join(' · '),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalChapters: json['chapter_count'] as int? ?? 0,
      readCount: json['read_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      tags: tags,
      isFeatured: isFeatured,
    );
  }
}


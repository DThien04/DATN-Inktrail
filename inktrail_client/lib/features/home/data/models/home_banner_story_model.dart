import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class HomeBannerStoryModel extends StoryEntity {
  const HomeBannerStoryModel({
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

  factory HomeBannerStoryModel.fromJson(Map<String, dynamic> json) {
    final story = json['story'] as Map<String, dynamic>? ?? const {};
    final author = story['author'] as Map<String, dynamic>? ?? const {};
    final bannerImageUrl = (json['banner_image_url'] as String? ?? '').trim();
    final updatedAt = (json['updated_at'] as String? ?? '').trim();
    final coverUrl = (story['cover_url'] as String? ?? '').trim();
    final tags = (story['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String? ?? '')
        .where((item) => item.isNotEmpty)
        .toList();

    return HomeBannerStoryModel(
      id: story['id'] as String? ?? '',
      slug: story['slug'] as String? ?? '',
      title: story['title'] as String? ?? '',
      description: story['description'] as String? ?? '',
      author: author['display_name'] as String? ?? 'Ẩn danh',
      coverUrl: bannerImageUrl.isNotEmpty
          ? _withCacheBuster(bannerImageUrl, updatedAt)
          : coverUrl,
      category: tags.isEmpty ? 'Khác' : tags.take(2).join(' · '),
      rating: (story['rating'] as num?)?.toDouble() ?? 0,
      totalChapters: story['chapter_count'] as int? ?? 0,
      readCount: story['read_count'] as int? ?? 0,
      likeCount: story['like_count'] as int? ?? 0,
      isLiked: story['is_liked'] as bool? ?? false,
      tags: tags,
      isFeatured: true,
    );
  }

  static String _withCacheBuster(String url, String updatedAt) {
    if (url.isEmpty || updatedAt.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=${Uri.encodeComponent(updatedAt)}';
  }
}


import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';

class AuthorProfileModel extends AuthorProfileEntity {
  const AuthorProfileModel({
    required super.id,
    required super.displayName,
    required super.bio,
    required super.avatarUrl,
    required super.storyCount,
    required super.followerCount,
    required super.isFollowing,
  });

  factory AuthorProfileModel.fromJson(Map<String, dynamic> json) {
    return AuthorProfileModel(
      id: (json['id'] as String? ?? '').trim(),
      displayName: (json['display_name'] as String? ?? '').trim(),
      bio: (json['bio'] as String? ?? '').trim(),
      avatarUrl: (json['avatar_url'] as String? ?? '').trim(),
      storyCount: (json['story_count'] as num?)?.toInt() ?? 0,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }
}

class AuthorStoryModel extends AuthorStoryEntity {
  const AuthorStoryModel({
    required super.id,
    required super.slug,
    required super.title,
    required super.description,
    required super.author,
    required super.coverUrl,
    required super.tags,
    required super.chapterCount,
    required super.readCount,
    required super.likeCount,
    required super.rating,
  });

  factory AuthorStoryModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>? ?? const {};
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['name'] as String? ?? '').trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return AuthorStoryModel(
      id: (json['id'] as String? ?? '').trim(),
      slug: (json['slug'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      author: (authorJson['display_name'] as String? ?? 'Tác giả').trim(),
      coverUrl: (json['cover_url'] as String? ?? '').trim(),
      tags: tags,
      chapterCount: (json['chapter_count'] as num?)?.toInt() ?? 0,
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AuthorFollowResultModel extends AuthorFollowResultEntity {
  const AuthorFollowResultModel({
    required super.isFollowing,
    required super.followerCount,
  });

  factory AuthorFollowResultModel.fromJson(
    Map<String, dynamic> json, {
    required bool fallbackFollowing,
    required int fallbackFollowerCount,
  }) {
    return AuthorFollowResultModel(
      isFollowing: json['is_following'] as bool? ?? fallbackFollowing,
      followerCount:
          (json['follower_count'] as num?)?.toInt() ?? fallbackFollowerCount,
    );
  }
}

class FollowedAuthorModel extends FollowedAuthorEntity {
  const FollowedAuthorModel({
    required super.id,
    required super.displayName,
    required super.avatarUrl,
    required super.bio,
    required super.storyCount,
    required super.followerCount,
  });

  factory FollowedAuthorModel.fromJson(Map<String, dynamic> json) {
    return FollowedAuthorModel(
      id: (json['id'] as String? ?? '').trim(),
      displayName: (json['display_name'] as String? ?? 'Tác giả').trim(),
      avatarUrl: (json['avatar_url'] as String? ?? '').trim(),
      bio: (json['bio'] as String? ?? '').trim(),
      storyCount: (json['story_count'] as num?)?.toInt() ?? 0,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
    );
  }
}

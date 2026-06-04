import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class AuthorProfileEntity {
  final String id;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final int storyCount;
  final int followerCount;
  final bool isFollowing;

  const AuthorProfileEntity({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.storyCount,
    required this.followerCount,
    required this.isFollowing,
  });
}

class AuthorStoryEntity {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String author;
  final String coverUrl;
  final List<String> tags;
  final int chapterCount;
  final int readCount;
  final int likeCount;
  final double rating;

  const AuthorStoryEntity({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.author,
    required this.coverUrl,
    required this.tags,
    required this.chapterCount,
    required this.readCount,
    required this.likeCount,
    required this.rating,
  });

  StoryEntity toStoryEntity() {
    return StoryEntity(
      id: id,
      slug: slug,
      title: title,
      description: description,
      author: author,
      coverUrl: coverUrl,
      category: tags.isNotEmpty ? tags.first : '',
      rating: rating,
      totalChapters: chapterCount,
      readCount: readCount,
      likeCount: likeCount,
      tags: tags,
    );
  }
}

class AuthorFollowResultEntity {
  final bool isFollowing;
  final int followerCount;

  const AuthorFollowResultEntity({
    required this.isFollowing,
    required this.followerCount,
  });
}

class FollowedAuthorEntity {
  final String id;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final int storyCount;
  final int followerCount;

  const FollowedAuthorEntity({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.storyCount,
    required this.followerCount,
  });
}

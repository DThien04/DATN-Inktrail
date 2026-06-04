import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.role,
    super.storiesReadCount,
    super.followingAuthorCount,
    super.followerCount,
    super.favoriteCount,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    displayName: json['display_name'] as String,
    avatarUrl: json['avatar_url'] as String?,
    bio: json['bio'] as String?,
    role: json['role'] as String? ?? 'reader',
    storiesReadCount: json['stories_read_count'] as int? ?? 0,
    followingAuthorCount: json['following_author_count'] as int? ?? 0,
    followerCount: json['follower_count'] as int? ?? 0,
    favoriteCount: json['favorite_count'] as int? ?? 0,
  );
}

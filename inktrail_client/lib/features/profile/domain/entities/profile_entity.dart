class ProfileEntity {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final int storiesReadCount;
  final int followingAuthorCount;
  final int followerCount;
  final int favoriteCount;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.role,
    this.storiesReadCount = 0,
    this.followingAuthorCount = 0,
    this.followerCount = 0,
    this.favoriteCount = 0,
  });
}

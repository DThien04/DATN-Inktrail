class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.role = UserRole.reader,
  });
}

enum UserRole { reader, author, admin }

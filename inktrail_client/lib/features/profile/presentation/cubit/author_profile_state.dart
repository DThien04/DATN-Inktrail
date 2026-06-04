import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';

class AuthorProfileState {
  final bool isLoading;
  final bool isSubmittingFollow;
  final String? errorMessage;
  final AuthorProfileEntity authorProfile;
  final List<AuthorStoryEntity> stories;

  const AuthorProfileState({
    this.isLoading = false,
    this.isSubmittingFollow = false,
    this.errorMessage,
    required this.authorProfile,
    this.stories = const <AuthorStoryEntity>[],
  });

  factory AuthorProfileState.initial({
    required String authorId,
    required String initialName,
    required String initialBio,
    required int? initialStoryCount,
  }) {
    return AuthorProfileState(
      authorProfile: AuthorProfileEntity(
        id: authorId,
        displayName: initialName.trim(),
        bio: initialBio.trim(),
        avatarUrl: '',
        storyCount: initialStoryCount ?? 0,
        followerCount: 0,
        isFollowing: false,
      ),
    );
  }

  AuthorProfileState copyWith({
    bool? isLoading,
    bool? isSubmittingFollow,
    Object? errorMessage = _sentinel,
    AuthorProfileEntity? authorProfile,
    List<AuthorStoryEntity>? stories,
  }) {
    return AuthorProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSubmittingFollow: isSubmittingFollow ?? this.isSubmittingFollow,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      authorProfile: authorProfile ?? this.authorProfile,
      stories: stories ?? this.stories,
    );
  }
}

const Object _sentinel = Object();

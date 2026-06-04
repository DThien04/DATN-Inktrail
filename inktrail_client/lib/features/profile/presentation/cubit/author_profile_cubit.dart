import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/profile_author_usecases.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/author_profile_state.dart';

class AuthorProfileSeed {
  final String authorId;
  final String initialName;
  final String initialBio;
  final int? initialStoryCount;

  const AuthorProfileSeed({
    required this.authorId,
    this.initialName = '',
    this.initialBio = '',
    this.initialStoryCount,
  });
}

class AuthorProfileCubit extends Cubit<AuthorProfileState> {
  final GetAuthorProfileUsecase _getAuthorProfile;
  final GetAuthorStoriesUsecase _getAuthorStories;
  final SetAuthorFollowUsecase _setAuthorFollow;
  final String _authorId;

  AuthorProfileCubit({
    required AuthorProfileSeed seed,
    required GetAuthorProfileUsecase getAuthorProfile,
    required GetAuthorStoriesUsecase getAuthorStories,
    required SetAuthorFollowUsecase setAuthorFollow,
  }) : _authorId = seed.authorId,
       _getAuthorProfile = getAuthorProfile,
       _getAuthorStories = getAuthorStories,
       _setAuthorFollow = setAuthorFollow,
       super(
         AuthorProfileState.initial(
           authorId: seed.authorId,
           initialName: seed.initialName,
           initialBio: seed.initialBio,
           initialStoryCount: seed.initialStoryCount,
         ),
       );

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final responses = await Future.wait([
        _getAuthorProfile(authorId: _authorId),
        _getAuthorStories(authorId: _authorId),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: null,
          authorProfile: responses[0] as AuthorProfileEntity,
          stories: responses[1] as List<AuthorStoryEntity>,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tải thông tin người dùng lúc này.',
        ),
      );
    }
  }

  Future<bool> setFollow({required bool follow}) async {
    if (state.isSubmittingFollow) return false;
    emit(state.copyWith(isSubmittingFollow: true, errorMessage: null));

    try {
      final result = await _setAuthorFollow(
        authorId: _authorId,
        follow: follow,
        fallbackFollowing: state.authorProfile.isFollowing,
        fallbackFollowerCount: state.authorProfile.followerCount,
      );

      emit(
        state.copyWith(
          isSubmittingFollow: false,
          authorProfile: AuthorProfileEntity(
            id: state.authorProfile.id,
            displayName: state.authorProfile.displayName,
            bio: state.authorProfile.bio,
            avatarUrl: state.authorProfile.avatarUrl,
            storyCount: state.authorProfile.storyCount,
            followerCount: result.followerCount,
            isFollowing: result.isFollowing,
          ),
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSubmittingFollow: false,
          errorMessage: 'Không thể cập nhật theo dõi người dùng lúc này.',
        ),
      );
      return false;
    }
  }
}

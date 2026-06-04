import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/profile_author_usecases.dart';

import 'profile_relations_state.dart';

class ProfileRelationsCubit extends Cubit<ProfileRelationsState> {
  final GetFollowersUsecase _getFollowers;
  final GetFollowedAuthorsUsecase _getFollowedAuthors;
  final SetAuthorFollowUsecase _setAuthorFollow;

  ProfileRelationsCubit({
    required GetFollowersUsecase getFollowers,
    required GetFollowedAuthorsUsecase getFollowedAuthors,
    required SetAuthorFollowUsecase setAuthorFollow,
  }) : _getFollowers = getFollowers,
       _getFollowedAuthors = getFollowedAuthors,
       _setAuthorFollow = setAuthorFollow,
       super(const ProfileRelationsState());

  Future<void> loadFollowers() async {
    emit(
      state.copyWith(
        status: ProfileRelationsStatus.loading,
        type: ProfileRelationType.followers,
        users: const [],
        clearError: true,
        clearBusyUserId: true,
      ),
    );

    try {
      final users = await _getFollowers();
      emit(
        state.copyWith(
          status: ProfileRelationsStatus.success,
          type: ProfileRelationType.followers,
          users: users,
          clearError: true,
          clearBusyUserId: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileRelationsStatus.failure,
          type: ProfileRelationType.followers,
          users: const [],
          errorMessage: 'Không thể tải danh sách người theo dõi lúc này.',
          clearBusyUserId: true,
        ),
      );
    }
  }

  Future<void> loadFollowing() async {
    emit(
      state.copyWith(
        status: ProfileRelationsStatus.loading,
        type: ProfileRelationType.following,
        users: const [],
        clearError: true,
        clearBusyUserId: true,
      ),
    );

    try {
      final users = await _getFollowedAuthors();
      emit(
        state.copyWith(
          status: ProfileRelationsStatus.success,
          type: ProfileRelationType.following,
          users: users,
          clearError: true,
          clearBusyUserId: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileRelationsStatus.failure,
          type: ProfileRelationType.following,
          users: const [],
          errorMessage: 'Không thể tải danh sách đang theo dõi lúc này.',
          clearBusyUserId: true,
        ),
      );
    }
  }

  Future<bool> unfollow(FollowedAuthorEntity user) async {
    if (state.busyUserId != null) return false;

    emit(state.copyWith(busyUserId: user.id));

    try {
      await _setAuthorFollow(
        authorId: user.id,
        follow: false,
        fallbackFollowing: false,
        fallbackFollowerCount: user.followerCount,
      );

      final updatedUsers = state.users.where((item) => item.id != user.id).toList();
      emit(
        state.copyWith(
          status: ProfileRelationsStatus.success,
          users: updatedUsers,
          clearBusyUserId: true,
          clearError: true,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileRelationsStatus.success,
          errorMessage: 'Không thể hủy theo dõi lúc này.',
          clearBusyUserId: true,
        ),
      );
      return false;
    }
  }
}

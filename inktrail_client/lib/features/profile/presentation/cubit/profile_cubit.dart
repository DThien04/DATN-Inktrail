import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/delete_my_avatar_usecase.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/upload_my_avatar_usecase.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/update_my_profile_usecase.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetMyProfileUsecase _getMyProfile;
  final UpdateMyProfileUsecase _updateMyProfile;
  final UploadMyAvatarUsecase _uploadMyAvatar;
  final DeleteMyAvatarUsecase _deleteMyAvatar;

  ProfileCubit({
    required GetMyProfileUsecase getMyProfile,
    required UpdateMyProfileUsecase updateMyProfile,
    required UploadMyAvatarUsecase uploadMyAvatar,
    required DeleteMyAvatarUsecase deleteMyAvatar,
  }) : _getMyProfile = getMyProfile,
       _updateMyProfile = updateMyProfile,
       _uploadMyAvatar = uploadMyAvatar,
       _deleteMyAvatar = deleteMyAvatar,
       super(const ProfileState());

  Future<void> fetchMyProfile() async {
    if (isClosed) return;
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    try {
      final profile = await _getMyProfile();
      if (isClosed) return;
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<ProfileEntity?> updateProfile({
    required String displayName,
    required String bio,
  }) async {
    if (isClosed) return null;
    emit(state.copyWith(status: ProfileStatus.saving, errorMessage: null));
    try {
      final profile = await _updateMyProfile(displayName: displayName, bio: bio);
      if (isClosed) return null;
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
      return profile;
    } catch (e) {
      if (isClosed) return null;
      emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()),
      );
      return null;
    }
  }

  Future<ProfileEntity?> uploadAvatar({
    required List<int> avatarBytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (isClosed) return null;
    emit(state.copyWith(status: ProfileStatus.uploadingAvatar, errorMessage: null));
    try {
      final profile = await _uploadMyAvatar(
        avatarBytes: avatarBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      if (isClosed) return null;
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
      return profile;
    } catch (e) {
      if (isClosed) return null;
      emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()),
      );
      return null;
    }
  }

  Future<ProfileEntity?> deleteAvatar() async {
    if (isClosed) return null;
    emit(state.copyWith(status: ProfileStatus.uploadingAvatar, errorMessage: null));
    try {
      final profile = await _deleteMyAvatar();
      if (isClosed) return null;
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
      return profile;
    } catch (e) {
      if (isClosed) return null;
      emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()),
      );
      return null;
    }
  }
}

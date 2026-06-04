import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure, saving, uploadingAvatar }

class ProfileState {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    errorMessage: errorMessage,
  );
}

import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';

enum ProfileRelationsStatus { initial, loading, success, failure }

enum ProfileRelationType { followers, following }

class ProfileRelationsState {
  final ProfileRelationsStatus status;
  final ProfileRelationType type;
  final List<FollowedAuthorEntity> users;
  final String? errorMessage;
  final String? busyUserId;

  const ProfileRelationsState({
    this.status = ProfileRelationsStatus.initial,
    this.type = ProfileRelationType.following,
    this.users = const [],
    this.errorMessage,
    this.busyUserId,
  });

  ProfileRelationsState copyWith({
    ProfileRelationsStatus? status,
    ProfileRelationType? type,
    List<FollowedAuthorEntity>? users,
    String? errorMessage,
    bool clearError = false,
    String? busyUserId,
    bool clearBusyUserId = false,
  }) {
    return ProfileRelationsState(
      status: status ?? this.status,
      type: type ?? this.type,
      users: users ?? this.users,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      busyUserId: clearBusyUserId ? null : (busyUserId ?? this.busyUserId),
    );
  }
}

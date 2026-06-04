import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';

enum ProfileAdminBroadcastsStatus { initial, loading, success, failure }

class ProfileAdminBroadcastsState {
  final ProfileAdminBroadcastsStatus status;
  final List<HomeInboxItemEntity> items;
  final int unreadCount;
  final bool isMarkingAll;
  final String? errorMessage;

  const ProfileAdminBroadcastsState({
    this.status = ProfileAdminBroadcastsStatus.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.isMarkingAll = false,
    this.errorMessage,
  });

  bool get isLoading => status == ProfileAdminBroadcastsStatus.loading;

  ProfileAdminBroadcastsState copyWith({
    ProfileAdminBroadcastsStatus? status,
    List<HomeInboxItemEntity>? items,
    int? unreadCount,
    bool? isMarkingAll,
    Object? errorMessage = _sentinel,
  }) {
    return ProfileAdminBroadcastsState(
      status: status ?? this.status,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isMarkingAll: isMarkingAll ?? this.isMarkingAll,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_list_utils.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_payload_mapper.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_inbox_items_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_unread_notifications_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/mark_home_notifications_read_usecase.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'home_notifications_state.dart';

class HomeNotificationsCubit extends Cubit<HomeNotificationsState> {
  final GetHomeUnreadNotificationsUsecase _getUnreadCount;
  final GetHomeInboxItemsUsecase _getInboxItems;
  final MarkHomeNotificationsReadUsecase _markNotificationsRead;
  final GetHomeNotificationSocketBaseUrlUsecase _getSocketBaseUrl;
  final TokenStorage _tokenStorage;
  io.Socket? _socket;

  /// Trong lúc [loadInbox] đang await API, socket vẫn có thể bắn `notification:new`.
  /// Ghi đè state khi load xong sẽ làm mất các bản ghi đó — buffer rồi merge sau.
  bool _inboxLoadInFlight = false;
  final List<Map<String, dynamic>> _notificationBufferDuringInboxLoad =
      <Map<String, dynamic>>[];

  HomeNotificationsCubit({
    required GetHomeUnreadNotificationsUsecase getUnreadCount,
    required GetHomeInboxItemsUsecase getInboxItems,
    required MarkHomeNotificationsReadUsecase markNotificationsRead,
    required GetHomeNotificationSocketBaseUrlUsecase getSocketBaseUrl,
    required TokenStorage tokenStorage,
  }) : _getUnreadCount = getUnreadCount,
       _getInboxItems = getInboxItems,
       _markNotificationsRead = markNotificationsRead,
       _getSocketBaseUrl = getSocketBaseUrl,
       _tokenStorage = tokenStorage,
       super(const HomeNotificationsState()) {
    unawaited(connectRealtime());
  }

  Future<void> connectRealtime() async {
    if (_socket != null) {
      if (!(_socket!.connected)) {
        _socket!.connect();
      }
      return;
    }
    final socketUrl = _getSocketBaseUrl();
    if (socketUrl == null) return;
    final accessToken = await _tokenStorage.getAccessToken();
    if (isClosed) return;
    if (accessToken == null || accessToken.isEmpty) return;

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth(<String, dynamic>{'token': 'Bearer $accessToken'})
          .build(),
    );

    socket.on('notification:new', _handleRealtimeNotification);
    socket.onConnectError((_) {
      if (isClosed) return;
      socket.dispose();
      if (identical(_socket, socket)) {
        _socket = null;
      }
    });
    socket.connect();
    _socket = socket;
  }

  void _handleRealtimeNotification(dynamic payload) {
    if (isClosed || payload is! Map) return;
    final map = Map<String, dynamic>.from(payload);
    final item = homeInboxItemFromNotificationJson(map);
    if (_inboxLoadInFlight) {
      _bufferNotificationMap(map);
      return;
    }
    _emitWithMergedItem(item);
  }

  void _bufferNotificationMap(Map<String, dynamic> map) {
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      _notificationBufferDuringInboxLoad.add(map);
      return;
    }
    final idx = _notificationBufferDuringInboxLoad.indexWhere(
      (m) => m['id']?.toString() == id,
    );
    if (idx >= 0) {
      _notificationBufferDuringInboxLoad[idx] = map;
    } else {
      _notificationBufferDuringInboxLoad.add(map);
    }
  }

  void _emitWithMergedItem(HomeInboxItemEntity item) {
    final items = upsertHomeInboxItem(state.items, item);
    final unreadCount = countPrivateUnreadHomeInboxItems(items);

    emit(
      state.copyWith(
        status: state.status == HomeNotificationsStatus.initial
            ? HomeNotificationsStatus.success
            : state.status,
        items: items,
        unreadCount: unreadCount,
        errorMessage: null,
      ),
    );
  }

  List<HomeInboxItemEntity> _mergeBufferedMapsInto(
    List<HomeInboxItemEntity> base,
  ) {
    if (_notificationBufferDuringInboxLoad.isEmpty) {
      return List<HomeInboxItemEntity>.from(base);
    }
    var merged = List<HomeInboxItemEntity>.from(base);
    for (final map in List<Map<String, dynamic>>.from(
      _notificationBufferDuringInboxLoad,
    )) {
      final item = homeInboxItemFromNotificationJson(map);
      merged = upsertHomeInboxItem(merged, item);
    }
    _notificationBufferDuringInboxLoad.clear();
    return merged;
  }

  Future<void> loadUnreadCount() async {
    try {
      await connectRealtime();
      final unreadCount = await _getUnreadCount();
      emit(state.copyWith(unreadCount: unreadCount, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> loadInbox() async {
    _inboxLoadInFlight = true;
    _notificationBufferDuringInboxLoad.clear();
    emit(
      state.copyWith(
        status: HomeNotificationsStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      await connectRealtime();
      final items = await _getInboxItems();
      var merged = List<HomeInboxItemEntity>.from(items);
      while (_notificationBufferDuringInboxLoad.isNotEmpty) {
        merged = _mergeBufferedMapsInto(merged);
      }
      emit(
        state.copyWith(
          status: HomeNotificationsStatus.success,
          items: merged,
          unreadCount: countPrivateUnreadHomeInboxItems(merged),
          errorMessage: null,
        ),
      );
    } catch (e) {
      var merged = List<HomeInboxItemEntity>.from(state.items);
      while (_notificationBufferDuringInboxLoad.isNotEmpty) {
        merged = _mergeBufferedMapsInto(merged);
      }
      emit(
        state.copyWith(
          status: HomeNotificationsStatus.failure,
          items: merged,
          unreadCount: countPrivateUnreadHomeInboxItems(merged),
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _inboxLoadInFlight = false;
    }
  }

  Future<void> markAllAsRead() async {
    if (state.isMarkingAll) return;
    final unreadPrivate =
        state.items.where((item) => item.isPrivate && item.isUnread);
    if (unreadPrivate.isEmpty) return;

    emit(state.copyWith(isMarkingAll: true));
    try {
      await _markNotificationsRead.markAll();
      final items = state.items
          .map((item) => item.isPrivate ? item.copyWith(isUnread: false) : item)
          .toList();
      emit(
        state.copyWith(
          items: items,
          unreadCount: 0,
          isMarkingAll: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isMarkingAll: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> markItemAsRead(int index) async {
    if (index < 0 || index >= state.items.length) return false;
    final item = state.items[index];
    if (!item.isPrivate || !item.isUnread || item.id == null) return true;

    final optimisticItems = List.of(state.items);
    optimisticItems[index] = item.copyWith(isUnread: false);
    emit(
      state.copyWith(
        items: optimisticItems,
        unreadCount: (state.unreadCount - 1).clamp(0, 999).toInt(),
      ),
    );

    try {
      await _markNotificationsRead.markOne(item.id!);
      return true;
    } catch (e) {
      final rollbackItems = List.of(state.items);
      rollbackItems[index] = item;
      emit(
        state.copyWith(
          items: rollbackItems,
          unreadCount: state.unreadCount + 1,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> markItemAsReadById(String notificationId) async {
    final id = notificationId.trim();
    if (id.isEmpty) return false;
    final index = state.items.indexWhere((item) => (item.id ?? '') == id);
    if (index < 0) return false;
    return markItemAsRead(index);
  }

  @override
  Future<void> close() {
    _socket?.off('notification:new');
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}

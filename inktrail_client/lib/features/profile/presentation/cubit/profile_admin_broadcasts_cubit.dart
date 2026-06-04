import 'dart:convert';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_list_utils.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_payload_mapper.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_unread_notifications_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_public_admin_broadcast_log_items_usecase.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'profile_admin_broadcasts_state.dart';

class ProfileAdminBroadcastsCubit extends Cubit<ProfileAdminBroadcastsState> {
  final GetPublicAdminBroadcastLogItemsUsecase _getItems;
  final GetHomeNotificationSocketBaseUrlUsecase _getSocketBaseUrl;
  final TokenStorage _tokenStorage;
  final FlutterSecureStorage _storage;
  io.Socket? _socket;

  static const String _readIdsKey = 'admin_broadcasts_read_ids';
  static const int _maxReadIds = 250;

  ProfileAdminBroadcastsCubit({
    required GetPublicAdminBroadcastLogItemsUsecase getItems,
    required GetHomeNotificationSocketBaseUrlUsecase getSocketBaseUrl,
    required TokenStorage tokenStorage,
    required FlutterSecureStorage storage,
  })  : _getItems = getItems,
        _getSocketBaseUrl = getSocketBaseUrl,
        _tokenStorage = tokenStorage,
        _storage = storage,
        super(const ProfileAdminBroadcastsState());

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

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );
    if (accessToken != null && accessToken.isNotEmpty) {
      socket.auth = <String, dynamic>{'token': 'Bearer $accessToken'};
    }
    socket.on('admin-broadcast:new', _handleAdminBroadcastRealtime);
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
    if ((item.type ?? '').trim() != 'admin_message') return;
    unawaited(_mergeRealtimeAdminMessage(item));
  }

  void _handleAdminBroadcastRealtime(dynamic payload) {
    if (isClosed || payload is! Map) return;
    final map = Map<String, dynamic>.from(payload);
    final item = homeInboxItemFromPublicAdminBroadcastLogJson(map);
    unawaited(_mergeRealtimeAdminMessage(item));
  }

  Future<void> _mergeRealtimeAdminMessage(HomeInboxItemEntity incoming) async {
    final id = (incoming.id ?? '').trim();
    if (id.isEmpty) return;
    final readIds = await _getReadIds();
    final isUnread = !readIds.contains(id);
    final next = incoming.copyWith(isUnread: isUnread, isPrivate: false);
    final items = upsertHomeInboxItem(
      state.items,
      next,
      sortByNewest: true,
    );
    final unreadCount = countUnreadHomeInboxItems(items);

    emit(
      state.copyWith(
        status: state.status == ProfileAdminBroadcastsStatus.initial
            ? ProfileAdminBroadcastsStatus.success
            : state.status,
        items: items,
        unreadCount: unreadCount,
        errorMessage: null,
      ),
    );
  }

  Future<Set<String>> _getReadIds() async {
    final raw = await _storage.read(key: _readIdsKey);
    if (raw == null || raw.trim().isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>{};
      return decoded.map((e) => e?.toString() ?? '').where((e) => e.trim().isNotEmpty).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _setReadIds(Set<String> ids) async {
    final trimmed = ids.where((e) => e.trim().isNotEmpty).toList();
    final limited = trimmed.length > _maxReadIds
        ? trimmed.sublist(trimmed.length - _maxReadIds)
        : trimmed;
    await _storage.write(key: _readIdsKey, value: jsonEncode(limited));
  }

  Future<void> load() async {
    unawaited(connectRealtime());
    emit(
      state.copyWith(
        status: ProfileAdminBroadcastsStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final readIds = await _getReadIds();
      final items = await _getItems();
      final mapped = items
          .map((item) {
            final id = (item.id ?? '').trim();
            final isUnread = id.isEmpty ? true : !readIds.contains(id);
            return item.copyWith(isUnread: isUnread);
          })
          .toList();
      final unreadCount = countUnreadHomeInboxItems(mapped);
      emit(
        state.copyWith(
          status: ProfileAdminBroadcastsStatus.success,
          items: mapped,
          unreadCount: unreadCount,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileAdminBroadcastsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (state.isMarkingAll) return;
    final unread = state.items.where((item) => item.isUnread);
    if (unread.isEmpty) return;
    emit(state.copyWith(isMarkingAll: true));
    try {
      final readIds = await _getReadIds();
      for (final item in state.items) {
        final id = (item.id ?? '').trim();
        if (id.isNotEmpty) readIds.add(id);
      }
      await _setReadIds(readIds);
      final items = state.items.map((item) => item.copyWith(isUnread: false)).toList();
      emit(
        state.copyWith(
          items: items,
          unreadCount: 0,
          isMarkingAll: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isMarkingAll: false, errorMessage: e.toString()));
    }
  }

  Future<void> markItemAsRead(int index) async {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    if (!item.isUnread) return;
    final nextItems = List<HomeInboxItemEntity>.from(state.items);
    nextItems[index] = item.copyWith(isUnread: false);
    final unreadCount = countUnreadHomeInboxItems(nextItems);
    emit(state.copyWith(items: nextItems, unreadCount: unreadCount));
    try {
      final id = (item.id ?? '').trim();
      if (id.isEmpty) return;
      final readIds = await _getReadIds();
      if (readIds.add(id)) {
        await _setReadIds(readIds);
      }
    } catch (_) {
      // no-op
    }
  }

  @override
  Future<void> close() {
    _socket?.off('notification:new');
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}

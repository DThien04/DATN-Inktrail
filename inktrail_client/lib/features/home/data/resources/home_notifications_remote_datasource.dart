import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/core/network/socket_base_url.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/features/home/data/models/home_inbox_item_model.dart';

abstract class HomeNotificationsRemoteDatasource {
  String? get socketBaseUrl;
  Future<int> getUnreadCount();
  Future<List<HomeInboxItemModel>> getInboxItems();
  Future<List<HomeInboxItemModel>> getPublicAdminBroadcastLogItems();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String notificationId);
  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  });
}

class HomeNotificationsRemoteDatasourceImpl
    implements HomeNotificationsRemoteDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  const HomeNotificationsRemoteDatasourceImpl(this._dio, this._tokenStorage);

  @override
  String? get socketBaseUrl => socketBaseUrlFromApiBase(_dio.options.baseUrl);

  @override
  Future<int> getUnreadCount() async {
    if (!await _tokenStorage.hasToken()) return 0;
    try {
      final response = await _dio.get('/notifications/me/unread-count');
      final json = response.data as Map<String, dynamic>? ?? const {};
      return (json['unread_count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMyNotificationRows() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return const [];
    final notificationResponse = await _dio.get(
      '/notifications/me',
      queryParameters: <String, dynamic>{'limit': 100},
    );
    final notificationJson =
        notificationResponse.data as Map<String, dynamic>? ?? const {};
    final rows = notificationJson['items'] as List<dynamic>? ?? const [];
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Future<List<HomeInboxItemModel>> getInboxItems() async {
    try {
      final announcementResponse = await _dio.get('/announcements');
      final announcementRows =
          announcementResponse.data as List<dynamic>? ?? const [];

      final notificationRows = await _fetchMyNotificationRows();

      final items = <HomeInboxItemModel>[
        ...notificationRows.map(HomeInboxItemModel.fromNotificationJson),
        ...announcementRows
            .whereType<Map<String, dynamic>>()
            .map(HomeInboxItemModel.fromAnnouncementJson),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return items;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<HomeInboxItemModel>> getPublicAdminBroadcastLogItems() async {
    try {
      final response = await _dio.get(
        '/notifications/public/admin-broadcasts',
        queryParameters: <String, dynamic>{'limit': 50},
      );
      final json = response.data as Map<String, dynamic>? ?? const {};
      final rows = json['items'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(HomeInboxItemModel.fromPublicAdminBroadcastLogJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/me/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  }) async {
    try {
      await _dio.post(
        '/reports/cases/$caseId/appeal',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

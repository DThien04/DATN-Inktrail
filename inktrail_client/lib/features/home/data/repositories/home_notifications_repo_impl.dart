import 'package:ink_trail_client/features/home/data/resources/home_notifications_remote_datasource.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_notifications_repository.dart';

class HomeNotificationsRepoImpl implements HomeNotificationsRepository {
  final HomeNotificationsRemoteDatasource _datasource;

  const HomeNotificationsRepoImpl(this._datasource);

  @override
  String? get socketBaseUrl => _datasource.socketBaseUrl;

  @override
  Future<int> getUnreadCount() => _datasource.getUnreadCount();

  @override
  Future<List<HomeInboxItemEntity>> getInboxItems() =>
      _datasource.getInboxItems();

  @override
  Future<List<HomeInboxItemEntity>> getPublicAdminBroadcastLogItems() =>
      _datasource.getPublicAdminBroadcastLogItems();

  @override
  Future<void> markAllAsRead() => _datasource.markAllAsRead();

  @override
  Future<void> markAsRead(String notificationId) =>
      _datasource.markAsRead(notificationId);

  @override
  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  }) =>
      _datasource.submitReportAppeal(caseId: caseId, reason: reason);
}

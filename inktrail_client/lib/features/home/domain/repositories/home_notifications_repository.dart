import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';

abstract class HomeNotificationsRepository {
  String? get socketBaseUrl;
  Future<int> getUnreadCount();
  Future<List<HomeInboxItemEntity>> getInboxItems();
  Future<List<HomeInboxItemEntity>> getPublicAdminBroadcastLogItems();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String notificationId);
  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  });
}

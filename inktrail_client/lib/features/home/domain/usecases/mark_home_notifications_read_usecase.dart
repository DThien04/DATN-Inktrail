import 'package:ink_trail_client/features/home/domain/repositories/home_notifications_repository.dart';

class MarkHomeNotificationsReadUsecase {
  final HomeNotificationsRepository _repository;

  const MarkHomeNotificationsReadUsecase(this._repository);

  Future<void> markAll() => _repository.markAllAsRead();

  Future<void> markOne(String notificationId) =>
      _repository.markAsRead(notificationId);
}

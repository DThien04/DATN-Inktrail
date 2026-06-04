import 'package:ink_trail_client/features/home/domain/repositories/home_notifications_repository.dart';

class GetHomeUnreadNotificationsUsecase {
  final HomeNotificationsRepository _repository;

  const GetHomeUnreadNotificationsUsecase(this._repository);

  Future<int> call() => _repository.getUnreadCount();
}

class GetHomeNotificationSocketBaseUrlUsecase {
  final HomeNotificationsRepository _repository;

  const GetHomeNotificationSocketBaseUrlUsecase(this._repository);

  String? call() => _repository.socketBaseUrl;
}

import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_notifications_repository.dart';

class GetPublicAdminBroadcastLogItemsUsecase {
  final HomeNotificationsRepository _repository;

  const GetPublicAdminBroadcastLogItemsUsecase(this._repository);

  Future<List<HomeInboxItemEntity>> call() =>
      _repository.getPublicAdminBroadcastLogItems();
}

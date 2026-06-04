import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';

List<HomeInboxItemEntity> upsertHomeInboxItem(
  List<HomeInboxItemEntity> items,
  HomeInboxItemEntity incoming, {
  bool sortByNewest = false,
}) {
  final exists = items.any((item) => item.id == incoming.id);
  final nextItems = exists
      ? items
          .map((item) => item.id == incoming.id ? incoming : item)
          .toList()
      : <HomeInboxItemEntity>[incoming, ...items];

  if (sortByNewest) {
    nextItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return nextItems;
}

int countPrivateUnreadHomeInboxItems(List<HomeInboxItemEntity> items) {
  return items.where((item) => item.isPrivate && item.isUnread).length;
}

int countUnreadHomeInboxItems(List<HomeInboxItemEntity> items) {
  return items.where((item) => item.isUnread).length;
}

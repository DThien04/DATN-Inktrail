import 'dart:convert';

import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

HomeInboxItemEntity homeInboxItemFromNotificationJson(
  Map<String, dynamic> json,
) {
  final createdAt =
      DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now();
  final type = (json['type'] as String? ?? '').trim();
  final linkUrl = (json['link_url'] as String? ?? '').trim();
  final rawMeta = json['meta'];
  final meta = rawMeta is Map
      ? Map<String, dynamic>.from(rawMeta)
      : const <String, dynamic>{};
  final storyJson = json['story'] as Map<String, dynamic>?;
  final chapterJson = json['chapter'] as Map<String, dynamic>?;
  final actorJson = json['actor'] as Map<String, dynamic>?;

  String? authorId = meta['author_id'] as String?;
  String authorName = (meta['author_name'] as String? ?? '').trim();
  if ((authorId == null || authorId.isEmpty) && linkUrl.startsWith('/profile/')) {
    authorId = linkUrl.replaceFirst('/profile/', '').trim();
  }
  if (authorName.isEmpty) {
    authorName = (actorJson?['display_name'] as String? ?? '').trim();
  }

  return HomeInboxItemEntity(
    id: json['id'] as String?,
    type: type,
    title: _normalizeUtf8Text((json['title'] as String? ?? '').trim()),
    body: _normalizeUtf8Text((json['body'] as String? ?? '').trim()),
    timeLabel: _formatRelativeTime(createdAt),
    isUnread: !(json['is_read'] as bool? ?? false),
    isPrivate: true,
    createdAt: createdAt,
    authorId: authorId,
    authorName: authorName,
    chapterId: (chapterJson?['id'] as String? ?? '').trim().isEmpty
        ? null
        : (chapterJson?['id'] as String).trim(),
    linkUrl: linkUrl.isEmpty ? null : linkUrl,
    story: storyJson == null ? null : _storyFromNotificationJson(storyJson, actorJson),
    meta: meta,
  );
}

HomeInboxItemEntity homeInboxItemFromPublicAdminBroadcastLogJson(
  Map<String, dynamic> json,
) {
  final createdAt =
      DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now();
  return HomeInboxItemEntity(
    id: json['id'] as String?,
    type: 'admin_message',
    title: _normalizeUtf8Text((json['title'] as String? ?? '').trim()),
    body: _normalizeUtf8Text((json['body'] as String? ?? '').trim()),
    timeLabel: _formatRelativeTime(createdAt),
    isUnread: false,
    isPrivate: false,
    createdAt: createdAt,
    meta: const {},
  );
}

HomeInboxItemEntity homeInboxItemFromAnnouncementJson(
  Map<String, dynamic> json,
) {
  final createdAt =
      DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now();
  return HomeInboxItemEntity(
    id: json['id'] as String?,
    title: _normalizeUtf8Text((json['title'] as String? ?? '').trim()),
    body: _normalizeUtf8Text((json['body'] as String? ?? '').trim()),
    timeLabel: _formatRelativeTime(createdAt),
    isUnread: false,
    isPrivate: false,
    createdAt: createdAt,
    linkUrl: (json['link_url'] as String?)?.trim(),
    meta: const {},
  );
}

StoryEntity _storyFromNotificationJson(
  Map<String, dynamic> storyJson,
  Map<String, dynamic>? actorJson,
) {
  return StoryEntity(
    id: (storyJson['id'] as String? ?? '').trim(),
    slug: (storyJson['slug'] as String? ?? '').trim(),
    title: (storyJson['title'] as String? ?? '').trim(),
    description: '',
    author: (actorJson?['display_name'] as String? ?? 'Tác giả').trim(),
    coverUrl: (storyJson['cover_url'] as String? ?? '').trim(),
    category: '',
    rating: 0,
    totalChapters: 0,
    readCount: 0,
    tags: const [],
  );
}

String _formatRelativeTime(DateTime input) {
  final time = input.toLocal();
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays == 1) return 'Hôm qua';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return '${time.day}/${time.month}/${time.year}';
}

String _normalizeUtf8Text(String input) {
  if (input.isEmpty) return input;
  final looksBroken =
      input.contains('Ã') ||
      input.contains('Â') ||
      input.contains('â€™') ||
      input.contains('ð');
  if (!looksBroken) return input;
  try {
    return utf8.decode(latin1.encode(input));
  } catch (_) {
    return input;
  }
}

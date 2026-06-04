import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class HomeInboxItemEntity {
  final String? id;
  final String? type;
  final String title;
  final String body;
  final String timeLabel;
  final bool isUnread;
  final bool isPrivate;
  final DateTime createdAt;
  final String? authorId;
  final String authorName;
  final String? chapterId;
  final String? linkUrl;
  final StoryEntity? story;
  final Map<String, dynamic> meta;

  const HomeInboxItemEntity({
    this.id,
    this.type,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isUnread,
    required this.isPrivate,
    required this.createdAt,
    this.authorId,
    this.authorName = '',
    this.chapterId,
    this.linkUrl,
    this.story,
    this.meta = const {},
  });

  HomeInboxItemEntity copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? timeLabel,
    bool? isUnread,
    bool? isPrivate,
    DateTime? createdAt,
    String? authorId,
    String? authorName,
    String? chapterId,
    String? linkUrl,
    StoryEntity? story,
    Map<String, dynamic>? meta,
  }) {
    return HomeInboxItemEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timeLabel: timeLabel ?? this.timeLabel,
      isUnread: isUnread ?? this.isUnread,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      chapterId: chapterId ?? this.chapterId,
      linkUrl: linkUrl ?? this.linkUrl,
      story: story ?? this.story,
      meta: meta ?? this.meta,
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/navigation/app_router.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/report/presentation/models/report_notification_detail_data.dart';
import 'package:ink_trail_client/features/report/presentation/pages/report_notification_detail_page.dart';
import 'package:ink_trail_client/features/profile/presentation/pages/profile_admin_broadcasts_page.dart';
import 'package:ink_trail_client/features/profile/presentation/utils/profile_navigation.dart';
import 'package:ink_trail_client/features/story_detail/presentation/pages/story_detail_page.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static HomeInboxItemEntity? _pendingPushItem;
  static bool _isShellReady = false;

  static void markShellReady() {
    _isShellReady = true;
    unawaited(flushPendingPushNavigation());
  }

  static void markShellNotReady() {
    _isShellReady = false;
  }

  static Future<void> flushPendingPushNavigation() async {
    if (!_isShellReady) return;
    final item = _pendingPushItem;
    if (item == null) return;
    _pendingPushItem = null;
    await openInboxItem(item);
  }

  static Future<void> openPushPayload({
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) async {
    final item = _buildInboxItemFromPushPayload(
      data: data,
      title: title,
      body: body,
    );
    if (item == null) return;

    if (!_isShellReady) {
      _pendingPushItem = item;
      return;
    }

    await openInboxItem(item);
  }

  static Future<void> openInboxItem(
    HomeInboxItemEntity item, {
    BuildContext? context,
  }) async {
    final navigationContext = context ?? AppRouter.navigatorKey.currentContext;
    if (navigationContext == null) return;

    final reportDetail = _buildReportNotificationDetail(item);
    if (reportDetail != null) {
      await Navigator.of(
        navigationContext,
        rootNavigator: true,
      ).push(
        MaterialPageRoute<void>(
          builder: (_) => ReportNotificationDetailPage(data: reportDetail),
        ),
      );
      return;
    }

    if ((item.type ?? '').trim() == 'admin_message') {
      await Navigator.of(
        navigationContext,
        rootNavigator: true,
      ).push(
        MaterialPageRoute<void>(
          builder: (_) => const ProfileAdminBroadcastsPage(),
        ),
      );
      return;
    }

    final destination = _parseInboxDestination(item);
    if (destination == null) return;

    if (destination.profileUserId != null) {
      await openUserProfile(
        navigationContext,
        userId: destination.profileUserId!,
        initialName: item.authorName.isEmpty ? null : item.authorName,
      );
      return;
    }

    if (destination.storySlug != null) {
      final story = _buildStoryEntityForNotification(
        item,
        storySlug: destination.storySlug!,
      );
      await Navigator.of(
        navigationContext,
        rootNavigator: true,
      ).push(
        MaterialPageRoute<void>(
          builder: (_) => StoryDetailPage(
            story: story,
            initialOpenChapterId: destination.chapterId ?? '',
          ),
        ),
      );
    }
  }

  static HomeInboxItemEntity? _buildInboxItemFromPushPayload({
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    final meta = _coercePushMeta(data['meta']);
    final linkUrl = _asTrimmedString(data['link_url']);
    final type = _asTrimmedString(data['type']);
    final storyId = _asTrimmedString(data['story_id']);
    final storySlug = _asTrimmedString(data['story_slug']);
    final chapterId = _asTrimmedString(data['chapter_id']);
    final notificationTitle = (title ?? '').trim();
    final notificationBody = (body ?? '').trim();

    if (type.isEmpty &&
        linkUrl.isEmpty &&
        storyId.isEmpty &&
        chapterId.isEmpty &&
        meta.isEmpty) {
      return null;
    }

    final authorIdRaw = _asTrimmedString(meta['author_id']);

    return HomeInboxItemEntity(
      id: _nullableTrimmedString(data['id']),
      type: type.isEmpty ? null : type,
      title: notificationTitle.isEmpty ? 'Thông báo mới' : notificationTitle,
      body: notificationBody,
      timeLabel: 'Vừa xong',
      isUnread: false,
      isPrivate: true,
      createdAt: DateTime.now(),
      authorId: authorIdRaw.isEmpty ? null : authorIdRaw,
      authorName: _asTrimmedString(meta['author_name']),
      chapterId: chapterId.isEmpty ? null : chapterId,
      linkUrl: linkUrl.isEmpty ? null : linkUrl,
      meta: <String, dynamic>{
        ...meta,
        if (storyId.isNotEmpty && !meta.containsKey('story_id')) 'story_id': storyId,
        if (storySlug.isNotEmpty && !meta.containsKey('story_slug'))
          'story_slug': storySlug,
        if (chapterId.isNotEmpty && !meta.containsKey('chapter_id'))
          'chapter_id': chapterId,
      },
    );
  }

  static ReportNotificationDetailData? _buildReportNotificationDetail(
    HomeInboxItemEntity item,
  ) {
    final t = (item.type ?? '').trim();
    if (t == 'story_published' || t == 'chapter_published') {
      return null;
    }

    final hasReportMeta = item.meta.containsKey('case_id') ||
        item.meta.containsKey('report_type') ||
        item.meta.containsKey('resolution_action') ||
        item.meta.containsKey('appeal_status') ||
        item.meta.containsKey('audience');
    if (!hasReportMeta) return null;

    final reportType = ((item.meta['report_type'] as String?) ??
            (item.meta['target_type'] as String?) ??
            'story')
        .trim();
    final moderationStatus =
        (item.meta['moderation_status'] as String? ?? '').trim();
    final resolutionAction = ((item.meta['resolution_action'] as String?) ??
            (moderationStatus == 'rejected' ? 'comment_rejected' : 'ignored'))
        .trim();
    final audience = (item.meta['audience'] as String? ?? '').trim();

    return ReportNotificationDetailData(
      title: item.title,
      body: item.body,
      timeLabel: item.timeLabel,
      createdAt: item.createdAt,
      reportType: reportType.isEmpty ? 'story' : reportType,
      resolutionAction:
          resolutionAction.isEmpty ? 'ignored' : resolutionAction,
      audience: audience.isEmpty ? 'owner' : audience,
      caseId: (item.meta['case_id'] as String? ?? '').trim().isEmpty
          ? null
          : (item.meta['case_id'] as String).trim(),
      appealStatus: (item.meta['appeal_status'] as String? ?? '').trim().isEmpty
          ? null
          : (item.meta['appeal_status'] as String).trim(),
      storyTitle: (item.meta['story_title'] as String? ?? '').trim().isEmpty
          ? item.story?.title
          : (item.meta['story_title'] as String).trim(),
      chapterTitle:
          (item.meta['chapter_title'] as String? ?? '').trim().isEmpty
              ? null
              : (item.meta['chapter_title'] as String).trim(),
      chapterNumber: item.meta['chapter_number'] is num
          ? (item.meta['chapter_number'] as num).toInt()
          : null,
      moderatedBy: (item.meta['moderated_by'] as String? ?? '').trim().isEmpty
          ? null
          : (item.meta['moderated_by'] as String).trim(),
      commentPreview: (item.meta['comment_preview'] as String? ?? '').trim().isEmpty
          ? null
          : (item.meta['comment_preview'] as String).trim(),
      story: item.story,
    );
  }

  static _InboxDestination? _parseInboxDestination(HomeInboxItemEntity item) {
    final raw = (item.linkUrl ?? '').trim();
    if (raw.isNotEmpty) {
      final destination = _parseDestinationFromPath(raw);
      if (destination != null) return destination;
    }

    final fallbackStorySlug = _asTrimmedString(item.meta['story_slug']);
    if (fallbackStorySlug.isNotEmpty) {
      final fromMeta = _asTrimmedString(item.meta['chapter_id']);
      final fromItem = (item.chapterId ?? '').trim();
      final coercedChapterId =
          fromMeta.isNotEmpty ? fromMeta : fromItem;
      return _InboxDestination(
        storySlug: fallbackStorySlug,
        chapterId: coercedChapterId.isEmpty ? null : coercedChapterId,
      );
    }

    return null;
  }

  static _InboxDestination? _parseDestinationFromPath(String rawPath) {
    final uri = Uri.tryParse(rawPath);
    final path = (uri?.path.isNotEmpty == true ? uri!.path : rawPath).trim();
    final segments = path
        .split('/')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty) return null;

    if (segments.length >= 2 && segments[0] == 'profile') {
      return _InboxDestination(profileUserId: segments[1]);
    }

    if (segments.length >= 2 && segments[0] == 'stories') {
      final slug = segments[1];
      String? chapterId;
      if (segments.length >= 4 && segments[2] == 'chapters') {
        chapterId = segments[3];
      }
      return _InboxDestination(storySlug: slug, chapterId: chapterId);
    }

    return null;
  }

  static String _asTrimmedString(Object? value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  static String? _nullableTrimmedString(Object? value) {
    final s = _asTrimmedString(value);
    return s.isEmpty ? null : s;
  }

  static Map<String, dynamic> _coercePushMeta(Object? raw) {
    if (raw == null) return {};
    if (raw is Map) {
      return Map<String, dynamic>.from(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(
            decoded.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      } catch (_) {}
    }
    return {};
  }

  static StoryEntity _buildStoryEntityForNotification(
    HomeInboxItemEntity item, {
    required String storySlug,
  }) {
    final story = item.story;
    if (story != null) {
      return StoryEntity(
        id: story.id,
        slug: story.slug.isEmpty ? storySlug : story.slug,
        title: story.title,
        description: story.description,
        author: story.author,
        coverUrl: story.coverUrl,
        category: story.category,
        rating: story.rating,
        totalChapters: story.totalChapters,
        readCount: story.readCount,
        likeCount: story.likeCount,
        isLiked: story.isLiked,
        tags: story.tags,
        isFeatured: story.isFeatured,
      );
    }

    final metaTitle = _asTrimmedString(item.meta['story_title']);
    return StoryEntity(
      id: _asTrimmedString(item.meta['story_id']),
      slug: storySlug,
      title: metaTitle.isEmpty ? item.title.trim() : metaTitle,
      description: '',
      author: item.authorName.trim().isEmpty ? 'Tác giả' : item.authorName.trim(),
      coverUrl: '',
      category: '',
      rating: 0,
      totalChapters: 0,
      readCount: 0,
      likeCount: 0,
      isLiked: false,
      tags: const <String>[],
      isFeatured: false,
    );
  }
}

class _InboxDestination {
  final String? profileUserId;
  final String? storySlug;
  final String? chapterId;

  const _InboxDestination({
    this.profileUserId,
    this.storySlug,
    this.chapterId,
  });
}

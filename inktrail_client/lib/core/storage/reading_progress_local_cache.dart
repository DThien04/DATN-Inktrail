import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReadingProgressCacheEntry {
  final String storyId;
  final int chapterIndex;
  final int? lastPosition;
  final DateTime updatedAt;
  final String storyTitle;
  final String storyCoverUrl;
  final String storySlug;

  const ReadingProgressCacheEntry({
    required this.storyId,
    required this.chapterIndex,
    this.lastPosition,
    required this.updatedAt,
    this.storyTitle = '',
    this.storyCoverUrl = '',
    this.storySlug = '',
  });
}

class ReadingProgressLocalCache {
  static const _storage = FlutterSecureStorage();
  static const _keyPrefix = 'reading_progress:';

  String _keyForStory(String storyId) => '$_keyPrefix$storyId';

  String _extractStoryId(String key) => key.replaceFirst(_keyPrefix, '');

  Future<ReadingProgressCacheEntry?> getProgress(String storyId) async {
    final raw = await _storage.read(key: _keyForStory(storyId));
    if (raw == null || raw.isEmpty) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final index = data['chapter_index'];
      final lastPosition = data['last_position'];
      final updatedAtRaw = data['updated_at'];
      if (index is! int || index < 0 || updatedAtRaw is! String) return null;

      final updatedAt = DateTime.tryParse(updatedAtRaw);
      if (updatedAt == null) return null;

      return ReadingProgressCacheEntry(
        storyId: storyId,
        chapterIndex: index,
        lastPosition: lastPosition is int && lastPosition >= 0
            ? (lastPosition > 100 ? 100 : lastPosition)
            : null,
        updatedAt: updatedAt,
        storyTitle: (data['story_title'] as String? ?? '').trim(),
        storyCoverUrl: (data['story_cover_url'] as String? ?? '').trim(),
        storySlug: (data['story_slug'] as String? ?? '').trim(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<int?> getLastChapterIndex(String storyId) async {
    final progress = await getProgress(storyId);
    return progress?.chapterIndex;
  }

  Future<void> saveLastChapterIndex({
    required String storyId,
    required int chapterIndex,
    int? lastPosition,
    DateTime? updatedAt,
    String? storyTitle,
    String? storyCoverUrl,
    String? storySlug,
  }) async {
    if (chapterIndex < 0) return;

    final existing = await getProgress(storyId);
    final payload = jsonEncode({
      'chapter_index': chapterIndex,
      'last_position':
          (lastPosition != null && lastPosition >= 0)
              ? (lastPosition > 100 ? 100 : lastPosition)
              : existing?.lastPosition,
      'updated_at': (updatedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'story_title': (storyTitle ?? existing?.storyTitle ?? '').trim(),
      'story_cover_url': (storyCoverUrl ?? existing?.storyCoverUrl ?? '').trim(),
      'story_slug': (storySlug ?? existing?.storySlug ?? '').trim(),
    });

    await _storage.write(key: _keyForStory(storyId), value: payload);
  }

  Future<List<ReadingProgressCacheEntry>> getAllProgress() async {
    final all = await _storage.readAll();
    final entries = <ReadingProgressCacheEntry>[];

    for (final item in all.entries) {
      if (!item.key.startsWith(_keyPrefix)) continue;
      final storyId = _extractStoryId(item.key);
      if (storyId.isEmpty) continue;
      final progress = await getProgress(storyId);
      if (progress != null) {
        entries.add(progress);
      }
    }

    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }
}

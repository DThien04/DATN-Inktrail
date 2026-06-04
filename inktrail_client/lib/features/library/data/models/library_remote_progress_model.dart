import 'package:ink_trail_client/features/library/domain/entities/library_remote_progress_entity.dart';

class LibraryRemoteProgressModel extends LibraryRemoteProgressEntity {
  const LibraryRemoteProgressModel({
    required super.storyId,
    required super.lastChapterIndex,
    required super.lastPosition,
    required super.updatedAt,
    required super.storyTitle,
    required super.storySlug,
    required super.coverUrl,
  });

  factory LibraryRemoteProgressModel.fromJson(Map<String, dynamic> json) {
    final story = json['story'] as Map<String, dynamic>? ?? const {};
    final updatedAtRaw = (json['updated_at'] as String? ?? '').trim();
    final updatedAt = DateTime.tryParse(updatedAtRaw)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return LibraryRemoteProgressModel(
      storyId: (json['story_id'] as String? ?? '').trim(),
      lastChapterIndex: (json['last_chapter_index'] as num?)?.toInt() ?? 0,
      lastPosition: _normalizeScrollPercent(
        (json['last_position'] as num?)?.toInt(),
      ),
      updatedAt: updatedAt,
      storyTitle: (story['title'] as String? ?? '').trim(),
      storySlug: (story['slug'] as String? ?? '').trim(),
      coverUrl: (story['cover_url'] as String? ?? '').trim(),
    );
  }
}

int? _normalizeScrollPercent(int? value) {
  if (value == null || value < 0) return null;
  if (value > 100) return 100;
  return value;
}

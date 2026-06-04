import 'package:ink_trail_client/features/story_detail/domain/entities/remote_reading_progress_entity.dart';

class RemoteReadingProgressModel extends RemoteReadingProgressEntity {
  const RemoteReadingProgressModel({
    required super.chapterIndex,
    required super.lastPosition,
    required super.updatedAt,
  });

  factory RemoteReadingProgressModel.fromJson(Map<String, dynamic> json) {
    final rawIndex = json['last_chapter_index'];
    final rawLastPosition = json['last_position'];
    final rawUpdatedAt = json['updated_at'];
    final parsedUpdatedAt =
        rawUpdatedAt is String ? DateTime.tryParse(rawUpdatedAt) : null;

    if (rawIndex is! int || parsedUpdatedAt == null) {
      throw const FormatException('Invalid reading progress payload');
    }

    return RemoteReadingProgressModel(
      chapterIndex: rawIndex,
      lastPosition: rawLastPosition is int && rawLastPosition >= 0
          ? rawLastPosition.clamp(0, 100).toInt()
          : null,
      updatedAt: parsedUpdatedAt,
    );
  }
}

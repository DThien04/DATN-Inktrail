class RemoteReadingProgressEntity {
  final int chapterIndex;
  final int? lastPosition;
  final DateTime updatedAt;

  const RemoteReadingProgressEntity({
    required this.chapterIndex,
    required this.lastPosition,
    required this.updatedAt,
  });
}

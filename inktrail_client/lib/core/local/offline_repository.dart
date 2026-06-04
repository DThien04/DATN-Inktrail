import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'offline_db.dart';

class DownloadedStoryLocal {
  final String storyId;
  final String title;
  final String slug;
  final String author;
  final String coverUrl;
  final int downloadedChapterCount;
  final int totalBytes;
  final DateTime latestDownloadedAt;

  const DownloadedStoryLocal({
    required this.storyId,
    required this.title,
    required this.slug,
    required this.author,
    required this.coverUrl,
    required this.downloadedChapterCount,
    required this.totalBytes,
    required this.latestDownloadedAt,
  });
}

class DownloadedChapterLocal {
  final String chapterId;
  final String storyId;
  final int chapterNumber;
  final String title;
  final String status;
  final String? filePath;
  final int? sizeBytes;
  final String? contentHash;
  final DateTime? downloadedAt;
  final DateTime updatedAt;

  const DownloadedChapterLocal({
    required this.chapterId,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    required this.status,
    this.filePath,
    this.sizeBytes,
    this.contentHash,
    this.downloadedAt,
    required this.updatedAt,
  });
}

class ParsedDownloadedChapterLocal {
  final String chapterId;
  final int chapterNumber;
  final String chapterTitle;
  final List<String> paragraphs;

  const ParsedDownloadedChapterLocal({
    required this.chapterId,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.paragraphs,
  });
}

class DownloadedChapterContentPayload {
  final String chapterId;
  final int chapterNumber;
  final String chapterTitle;
  final List<String> paragraphs;

  const DownloadedChapterContentPayload({
    required this.chapterId,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.paragraphs,
  });
}

class OfflineRepository {
  final OfflineDb _db;

  const OfflineRepository(this._db);

  Future<void> upsertStory({
    required String storyId,
    required String title,
    String slug = '',
    String author = '',
    String coverUrl = '',
    DateTime? updatedAt,
  }) async {
    await _db.into(_db.storiesOffline).insertOnConflictUpdate(
      StoriesOfflineCompanion(
        storyId: Value(storyId),
        title: Value(title),
        slug: Value(slug),
        author: Value(author),
        coverUrl: Value(coverUrl),
        updatedAt: Value((updatedAt ?? DateTime.now()).toUtc()),
      ),
    );
  }

  Future<void> upsertDownloadedChapter({
    required String chapterId,
    required String storyId,
    required int chapterNumber,
    required String title,
    required String filePath,
    int? sizeBytes,
    String? contentHash,
    DateTime? downloadedAt,
    DateTime? updatedAt,
  }) async {
    await _db.into(_db.chaptersOffline).insertOnConflictUpdate(
      ChaptersOfflineCompanion(
        chapterId: Value(chapterId),
        storyId: Value(storyId),
        chapterNumber: Value(chapterNumber),
        title: Value(title),
        status: const Value('done'),
        filePath: Value(filePath),
        sizeBytes: Value(sizeBytes),
        contentHash: Value(contentHash),
        downloadedAt: Value((downloadedAt ?? DateTime.now()).toUtc()),
        updatedAt: Value((updatedAt ?? DateTime.now()).toUtc()),
      ),
    );
  }

  Future<List<DownloadedStoryLocal>> getDownloadedStories() async {
    final doneChapters = await ( _db.select(_db.chaptersOffline)
          ..where((t) => t.status.equals('done'))
          ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)]))
        .get();

    if (doneChapters.isEmpty) return const [];

    final byStory = <String, List<dynamic>>{};
    for (final chapter in doneChapters) {
      byStory.putIfAbsent(chapter.storyId, () => []).add(chapter);
    }

    final storyIds = byStory.keys.toList();
    final storyRows = await (_db.select(_db.storiesOffline)
          ..where((t) => t.storyId.isIn(storyIds)))
        .get();
    final storyMap = {for (final story in storyRows) story.storyId: story};

    final result = <DownloadedStoryLocal>[];
    for (final storyId in storyIds) {
      final chapters = byStory[storyId]!;
      final firstChapter = chapters.first;
      final story = storyMap[storyId];
      final latestDownloadedAt = (firstChapter.downloadedAt as DateTime?) ??
          (firstChapter.updatedAt as DateTime?) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

      var totalBytes = 0;
      for (final chapter in chapters) {
        totalBytes += (chapter.sizeBytes as int?) ?? 0;
      }

      result.add(
        DownloadedStoryLocal(
          storyId: storyId,
          title: story?.title ?? 'Truyện không xác định',
          slug: story?.slug ?? '',
          author: story?.author ?? '',
          coverUrl: story?.coverUrl ?? '',
          downloadedChapterCount: chapters.length,
          totalBytes: totalBytes,
          latestDownloadedAt: latestDownloadedAt,
        ),
      );
    }

    return result;
  }

  Future<List<DownloadedChapterLocal>> getDownloadedChapters(String storyId) async {
    final rows = await (_db.select(_db.chaptersOffline)
          ..where((t) => t.storyId.equals(storyId) & t.status.equals('done'))
          ..orderBy([(t) => OrderingTerm.asc(t.chapterNumber)]))
        .get();

    return rows
        .map(
          (row) => DownloadedChapterLocal(
            chapterId: row.chapterId,
            storyId: row.storyId,
            chapterNumber: row.chapterNumber,
            title: row.title,
            status: row.status,
            filePath: row.filePath,
            sizeBytes: row.sizeBytes,
            contentHash: row.contentHash,
            downloadedAt: row.downloadedAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Future<Set<String>> getDownloadedChapterIds(String storyId) async {
    final chapters = await getDownloadedChapters(storyId);
    return chapters
        .map((item) => item.chapterId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> deleteDownloadedChapter(String chapterId) async {
    final row = await (_db.select(_db.chaptersOffline)
          ..where((t) => t.chapterId.equals(chapterId)))
        .getSingleOrNull();
    if (row == null) return;

    final path = row.filePath;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await (_db.delete(_db.chaptersOffline)
          ..where((t) => t.chapterId.equals(chapterId)))
        .go();
  }

  Future<ParsedDownloadedChapterLocal?> readDownloadedChapter(
    DownloadedChapterLocal chapter,
  ) async {
    final path = chapter.filePath;
    if (path == null || path.trim().isEmpty) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    final rawText = await file.readAsString();
    final raw = jsonDecode(rawText);
    if (raw is! Map<String, dynamic>) return null;

    final chapterId = (raw['chapter_id'] as String? ?? chapter.chapterId).trim();
    final chapterNumber =
        (raw['chapter_number'] as num?)?.toInt() ?? chapter.chapterNumber;
    final chapterTitle = (raw['chapter_title'] as String? ?? chapter.title).trim();

    final rawParagraphs = raw['paragraphs'];
    final paragraphs = rawParagraphs is List
        ? rawParagraphs
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : const <String>[];

    return ParsedDownloadedChapterLocal(
      chapterId: chapterId,
      chapterNumber: chapterNumber <= 0 ? 1 : chapterNumber,
      chapterTitle:
          chapterTitle.isEmpty ? 'Chuong ${chapter.chapterNumber}' : chapterTitle,
      paragraphs: paragraphs.isEmpty ? const ['Chua co noi dung'] : paragraphs,
    );
  }

  Future<void> saveDownloadedChapterContent({
    required String storyId,
    required String storyTitle,
    required String storySlug,
    required String storyAuthor,
    required String storyCoverUrl,
    required DownloadedChapterContentPayload chapter,
    DateTime? now,
  }) async {
    final effectiveNow = (now ?? DateTime.now()).toUtc();

    await upsertStory(
      storyId: storyId,
      title: storyTitle,
      slug: storySlug,
      author: storyAuthor,
      coverUrl: storyCoverUrl,
      updatedAt: effectiveNow,
    );

    final appDir = await getApplicationDocumentsDirectory();
    final chaptersDir = Directory(
      p.join(appDir.path, 'offline', 'chapters', storyId),
    );
    if (!await chaptersDir.exists()) {
      await chaptersDir.create(recursive: true);
    }

    final payload = jsonEncode({
      'story_id': storyId,
      'story_title': storyTitle,
      'chapter_id': chapter.chapterId,
      'chapter_number': chapter.chapterNumber,
      'chapter_title': chapter.chapterTitle,
      'paragraphs': chapter.paragraphs,
      'downloaded_at': effectiveNow.toIso8601String(),
    });

    final filePath = p.join(chaptersDir.path, '${chapter.chapterId}.json');
    final file = File(filePath);
    await file.writeAsString(payload);
    final sizeBytes = await file.length();

    await upsertDownloadedChapter(
      chapterId: chapter.chapterId,
      storyId: storyId,
      chapterNumber: chapter.chapterNumber,
      title: chapter.chapterTitle,
      filePath: filePath,
      sizeBytes: sizeBytes,
      downloadedAt: effectiveNow,
      updatedAt: effectiveNow,
    );
  }
}

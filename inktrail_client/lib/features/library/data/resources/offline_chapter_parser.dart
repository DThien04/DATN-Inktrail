import 'dart:convert';
import 'dart:io';

import 'package:ink_trail_client/core/local/offline_repository.dart';

class OfflineChapterParsedData {
  final String chapterId;
  final int chapterNumber;
  final String chapterTitle;
  final List<String> paragraphs;

  const OfflineChapterParsedData({
    required this.chapterId,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.paragraphs,
  });
}

class OfflineChapterParser {
  const OfflineChapterParser();

  Future<OfflineChapterParsedData?> parse(DownloadedChapterLocal chapter) async {
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
    final chapterTitle =
        (raw['chapter_title'] as String? ?? chapter.title).trim();

    final rawParagraphs = raw['paragraphs'];
    final paragraphs = rawParagraphs is List
        ? rawParagraphs
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : const <String>[];

    return OfflineChapterParsedData(
      chapterId: chapterId,
      chapterNumber: chapterNumber <= 0 ? 1 : chapterNumber,
      chapterTitle:
          chapterTitle.isEmpty ? 'Chuong ${chapter.chapterNumber}' : chapterTitle,
      paragraphs: paragraphs.isEmpty ? const ['Chua co noi dung'] : paragraphs,
    );
  }
}

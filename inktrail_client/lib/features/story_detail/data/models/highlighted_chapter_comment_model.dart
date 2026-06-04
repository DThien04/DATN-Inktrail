import 'package:ink_trail_client/features/story_detail/domain/entities/highlighted_chapter_comment_entity.dart';

class HighlightedChapterCommentModel extends HighlightedChapterCommentEntity {
  const HighlightedChapterCommentModel({
    required super.author,
    required super.content,
    required super.meta,
    required super.chapterLabel,
  });

  factory HighlightedChapterCommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final chapter = json['chapter'] as Map<String, dynamic>? ?? const {};
    final author = (user['display_name'] ??
            user['displayName'] ??
            user['email'] ??
            '')
        .toString()
        .trim();
    final createdAt =
        DateTime.tryParse((json['created_at'] ?? '').toString()) ??
            DateTime.now();
    final chapterNumber = (chapter['chapter_number'] as num?)?.toInt();
    final chapterTitle = (chapter['title'] ?? '').toString().trim();

    return HighlightedChapterCommentModel(
      author: author.isEmpty ? 'Người dùng' : author,
      content: (json['content'] ?? '').toString().trim(),
      meta: _formatCommentTime(createdAt),
      chapterLabel: _formatChapterLabel(
        chapterNumber: chapterNumber,
        chapterTitle: chapterTitle,
      ),
    );
  }

  static String _formatChapterLabel({
    required int? chapterNumber,
    required String chapterTitle,
  }) {
    final numberLabel = chapterNumber == null ? '' : 'Chương $chapterNumber';
    if (numberLabel.isEmpty) {
      return chapterTitle.isEmpty ? 'Bình luận nổi bật' : chapterTitle;
    }
    return chapterTitle.isEmpty ? numberLabel : '$numberLabel · $chapterTitle';
  }

  static String _formatCommentTime(DateTime input) {
    final time = input.toLocal();
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${time.day}/${time.month}/${time.year}';
  }
}

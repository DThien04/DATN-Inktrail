import 'package:ink_trail_client/features/reader/domain/entities/reader_comment_entity.dart';
import 'package:ink_trail_client/features/reader/presentation/mappers/reader_comment_payload_mapper.dart';
import 'package:ink_trail_client/features/reader/presentation/utils/reader_comment_utils.dart';

class ReaderChapter {
  final String id;
  final int number;
  final String title;
  final List<String> paragraphs;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const ReaderChapter({
    this.id = '',
    required this.number,
    required this.title,
    required this.paragraphs,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
}

class ReaderSessionResult {
  final int chapterIndex;
  final int? lastScrollPercent;
  final Map<String, bool> chapterLikeStates;
  final Map<String, int> chapterLikeCounts;
  final Map<String, int> chapterCommentCounts;
  final String? chapterHiddenMessage;

  const ReaderSessionResult({
    required this.chapterIndex,
    this.lastScrollPercent,
    required this.chapterLikeStates,
    required this.chapterLikeCounts,
    required this.chapterCommentCounts,
    this.chapterHiddenMessage,
  });
}

class ReaderCommentView {
  final String id;
  final String? storyId;
  final String? chapterId;
  final String? parentId;
  final String userId;
  final String author;
  final String content;
  final int likeCount;
  final bool isLiked;
  final String timeText;
  final int timestampOrder;
  final bool isHighlighted;
  final bool isMine;
  final String moderationStatus;
  final String? moderationReason;

  const ReaderCommentView({
    this.id = '',
    this.storyId,
    this.chapterId,
    this.parentId,
    this.userId = '',
    required this.author,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    required this.timeText,
    required this.timestampOrder,
    this.isHighlighted = false,
    this.isMine = false,
    this.moderationStatus = 'approved',
    this.moderationReason,
  });

  bool get isPending => moderationStatus == 'pending';
  bool get isApproved => moderationStatus == 'approved';
  bool get isRejected => moderationStatus == 'rejected';
  bool get isReply => (parentId ?? '').isNotEmpty;

  factory ReaderCommentView.fromEntity(
    ReaderCommentEntity entity, {
    String currentUserId = '',
  }) {
    return ReaderCommentView(
      id: entity.id,
      storyId: entity.storyId,
      chapterId: entity.chapterId,
      parentId: entity.parentId,
      userId: entity.userId,
      author: entity.author.isEmpty
          ? 'Người dùng'
          : entity.author,
      content: entity.content,
      likeCount: entity.likeCount,
      isLiked: entity.isLiked,
      timeText: formatReaderCommentTime(entity.createdAt),
      timestampOrder: entity.createdAt?.millisecondsSinceEpoch ?? 0,
      isHighlighted: entity.isHighlighted,
      isMine: entity.isMine ||
          (currentUserId.isNotEmpty && entity.userId == currentUserId),
      moderationStatus: entity.moderationStatus,
      moderationReason: entity.moderationReason,
    );
  }

  static ReaderCommentView? tryFromChapterCommentJson(
    dynamic raw, {
    String currentUserId = '',
  }) {
    final entity = readerCommentEntityFromPayload(raw);
    if (entity == null) return null;
    return ReaderCommentView.fromEntity(entity, currentUserId: currentUserId);
  }

  ReaderCommentView copyWith({
    int? likeCount,
    bool? isLiked,
    String? content,
    String? timeText,
    int? timestampOrder,
    bool? isHighlighted,
    bool? isMine,
    String? parentId,
    String? moderationStatus,
    String? moderationReason,
  }) {
    return ReaderCommentView(
      id: id,
      storyId: storyId,
      chapterId: chapterId,
      parentId: parentId ?? this.parentId,
      userId: userId,
      author: author,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      timeText: timeText ?? this.timeText,
      timestampOrder: timestampOrder ?? this.timestampOrder,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isMine: isMine ?? this.isMine,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationReason: moderationReason ?? this.moderationReason,
    );
  }
}

List<ReaderCommentView> mergeReaderCommentViews(
  List<ReaderCommentView> items,
  ReaderCommentView incoming,
) {
  final existingIndex = items.indexWhere((item) => item.id == incoming.id);
  if (existingIndex >= 0) {
    final updatedItems = List<ReaderCommentView>.from(items);
    updatedItems[existingIndex] = incoming;
    return updatedItems;
  }
  return <ReaderCommentView>[incoming, ...items];
}

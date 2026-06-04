import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';

String formatReaderCommentTime(DateTime? createdAt) {
  if (createdAt == null) return 'Vừa xong';

  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inSeconds < 60) return 'Vừa xong';
  if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
  if (difference.inHours < 24) return '${difference.inHours} giờ trước';
  if (difference.inDays == 1) return 'Hôm qua';
  if (difference.inDays < 7) return '${difference.inDays} ngày trước';
  return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}

void showReaderCommentMessage(
  BuildContext context,
  String message, {
  bool isSuccess = false,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isSuccess ? const Color(0xFF2E7D32) : const Color(0xFF323232),
          content: Text(message),
        ),
      );
    return;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final topInset = MediaQuery.of(context).padding.top;
      return Positioned(
        top: topInset + 12,
        left: 16,
        right: 16,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSuccess ? const Color(0xFF2E7D32) : const Color(0xFF323232),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 2, milliseconds: 200)).then((_) {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

String extractReaderCommentErrorMessage(Object error) {
  if (error is ApiException && error.message.trim().isNotEmpty) {
    return sanitizeReaderCommentErrorMessage(error.message.trim());
  }
  return 'Không thể xử lý bình luận lúc này.';
}

String sanitizeReaderCommentErrorMessage(String message) {
  final lowered = message.toLowerCase();
  if (lowered.contains('invalid `tx.') ||
      lowered.contains('invocation in') ||
      lowered.contains('prisma') ||
      lowered.contains('query engine')) {
    return 'Hệ thống bình luận đang bận, vui lòng thử lại sau.';
  }
  if (lowered.contains('already reported') ||
      lowered.contains('already_reported') ||
      lowered.contains('da bao cao')) {
    if (lowered.contains('chuong')) {
      return 'Bạn đã báo cáo chương này rồi.';
    }
    return 'Bạn đã báo cáo bình luận này rồi.';
  }
  if (lowered.contains('cannot report your own comment') ||
      lowered.contains('own comment') ||
      lowered.contains('khong the bao cao binh luan cua chinh minh')) {
    return 'Bạn không thể báo cáo bình luận của chính mình.';
  }
  if (lowered.contains('binh luan da bi go boi quan tri vien') ||
      lowered.contains('binh luan da bi go') ||
      lowered.contains('comment has been removed') ||
      lowered.contains('comment was removed')) {
    return 'Bình luận này đã bị gỡ.';
  }
  if (lowered.contains('bao cao chuong cua chinh minh') ||
      lowered.contains('own chapter')) {
    return 'Bạn không thể báo cáo chương của chính mình.';
  }
  if (lowered.contains('chuong da bi an boi quan tri vien') ||
      lowered.contains('chapter has been hidden') ||
      lowered.contains('chapter was hidden')) {
    return 'Chương này đã bị ẩn.';
  }
  if (lowered.contains('vui long nhap mo ta') ||
      lowered.contains('thieu mo ta')) {
    return 'Vui lòng nhập mô tả báo cáo.';
  }

  return message;
}

bool isReaderCommentHiddenError(Object error) {
  final candidates = <String>[];

  if (error is ApiException && error.message.trim().isNotEmpty) {
    candidates.add(error.message.trim());
  }

  return candidates.any((raw) {
    final lowered = raw.toLowerCase();
    return lowered.contains('binh luan da bi go boi quan tri vien') ||
        lowered.contains('binh luan da bi go') ||
        lowered.contains('comment has been removed') ||
        lowered.contains('comment was removed');
  });
}

bool isReaderChapterHiddenError(Object error) {
  final candidates = <String>[];

  if (error is ApiException && error.message.trim().isNotEmpty) {
    candidates.add(error.message.trim());
  }

  return candidates.any((raw) {
    final lowered = raw.toLowerCase();
    return lowered.contains('chuong da bi an boi quan tri vien') ||
        lowered.contains('chapter has been hidden') ||
        lowered.contains('chapter was hidden');
  });
}

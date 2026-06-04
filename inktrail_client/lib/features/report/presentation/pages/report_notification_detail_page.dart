import 'package:flutter/material.dart';
import 'package:ink_trail_client/features/report/presentation/models/report_notification_detail_data.dart';
import 'package:ink_trail_client/features/report/presentation/pages/report_appeal_sheet.dart';

class ReportNotificationDetailPage extends StatefulWidget {
  final ReportNotificationDetailData data;

  const ReportNotificationDetailPage({
    super.key,
    required this.data,
  });

  @override
  State<ReportNotificationDetailPage> createState() =>
      _ReportNotificationDetailPageState();
}

class _ReportNotificationDetailPageState
    extends State<ReportNotificationDetailPage> {
  bool _appealSubmittedInSession = false;

  ReportNotificationDetailData get data => widget.data;

  bool get _isReporterAudience => data.audience == 'reporter';

  bool get _canAppeal {
    if (_isReporterAudience) return false;
    if (_appealSubmittedInSession) return false;
    if ((data.caseId ?? '').trim().isEmpty) return false;
    if ((data.appealStatus ?? '').trim().isNotEmpty) return false;
    return data.resolutionAction == 'comment_removed' ||
        data.resolutionAction == 'chapter_hidden' ||
        data.resolutionAction == 'story_hidden';
  }

  String get _titleText {
    switch (data.resolutionAction) {
      case 'comment_rejected':
        return 'Bình luận của bạn không được đăng';
      case 'comment_removed':
        return _isReporterAudience
            ? 'Bình luận đã được gỡ'
            : 'Bình luận của bạn đã bị gỡ';
      case 'chapter_hidden':
        return _isReporterAudience
            ? 'Chương đã được ẩn'
            : 'Chương của bạn đã bị ẩn';
      case 'story_hidden':
        return _isReporterAudience
            ? 'Truyện đã được ẩn'
            : 'Truyện của bạn đã bị ẩn';
      default:
        return 'Báo cáo đã được xem xét';
    }
  }

  String get _summaryText {
    switch (data.resolutionAction) {
      case 'comment_rejected':
        return 'Nội dung này chưa đáp ứng tiêu chuẩn cộng đồng nên không được hiển thị.';
      case 'comment_removed':
        return _isReporterAudience
            ? 'Quản trị viên đã xác nhận phản ánh và gỡ bình luận khỏi hệ thống.'
            : 'Bình luận của bạn đã bị gỡ sau khi được quản trị viên xem xét.';
      case 'chapter_hidden':
        return _isReporterAudience
            ? 'Chương này đã được ẩn khỏi khu vực hiển thị công khai.'
            : 'Chương của bạn đã bị ẩn khỏi khu vực hiển thị công khai.';
      case 'story_hidden':
        return _isReporterAudience
            ? 'Truyện này hiện không còn hiển thị công khai trên InkTrail.'
            : 'Truyện của bạn hiện không còn hiển thị công khai trên InkTrail.';
      default:
        return 'Sau khi kiểm tra, quản trị viên giữ nguyên trạng thái hiện tại của nội dung.';
    }
  }

  String get _targetText {
    switch (data.reportType) {
      case 'chapter_comment':
        if (data.resolutionAction == 'comment_rejected') {
          return 'Bình luận của bạn';
        }
        final chapterPart = data.chapterNumber != null
            ? 'Bình luận ở chương ${data.chapterNumber}'
            : 'Bình luận chương';
        return (data.storyTitle ?? '').trim().isEmpty
            ? chapterPart
            : '$chapterPart • ${data.storyTitle}';
      case 'chapter':
        final chapterPart = _chapterLabel;
        return (data.storyTitle ?? '').trim().isEmpty
            ? chapterPart
            : '$chapterPart • ${data.storyTitle}';
      default:
        return data.storyTitle ?? 'Truyện';
    }
  }

  String get _statusText {
    switch (data.resolutionAction) {
      case 'comment_rejected':
        return 'Không đăng';
      case 'comment_removed':
        return 'Gỡ bình luận';
      case 'chapter_hidden':
        return 'Ẩn chương';
      case 'story_hidden':
        return 'Ẩn truyện';
      default:
        return 'Bỏ qua';
    }
  }

  String get _processedTimeText {
    final date = data.createdAt;
    return '${data.timeLabel} • ${date.day}/${date.month}/${date.year}';
  }

  String get _chapterLabel {
    final title = (data.chapterTitle ?? '').trim();
    if (data.chapterNumber != null && title.isNotEmpty) {
      return 'Chương ${data.chapterNumber}: $title';
    }
    if (data.chapterNumber != null) return 'Chương ${data.chapterNumber}';
    return title.isEmpty ? 'Chương' : title;
  }

  String get _footerText {
    if (_isReporterAudience) {
      return 'Cảm ơn bạn đã gửi báo cáo. Những phản ánh rõ ràng giúp đội ngũ quản trị xử lý nhanh và chính xác hơn.';
    }
    return 'Nếu bạn cho rằng quyết định này chưa chính xác, bạn có thể gửi kháng nghị để quản trị viên xem xét lại.';
  }

  Future<void> _showAppealSheet(BuildContext pageContext) async {
    final messenger = ScaffoldMessenger.maybeOf(pageContext);
    final result = await showModalBottomSheet<ReportAppealSheetResult>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Theme.of(pageContext).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReportAppealSheet(caseId: data.caseId!.trim()),
    );

    if (!pageContext.mounted || messenger == null || result == null) return;

    if (result.isSuccess) {
      setState(() => _appealSubmittedInSession = true);
    }

    messenger.showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: scheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Chi tiết xử lý',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Text(
              _titleText,
              style: TextStyle(
                fontSize: 30,
                height: 1.16,
                fontWeight: FontWeight.w900,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            _BodyText(_summaryText),
            const SizedBox(height: 24),
            _ContentSection(
              title: 'Nội dung liên quan',
              children: [
                _DetailLine(label: 'Đối tượng', value: _targetText),
                if ((data.commentPreview ?? '').trim().isNotEmpty)
                  _DetailLine(
                    label: 'Bình luận',
                    value: data.commentPreview!.trim(),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _ContentSection(
              title: 'Kết quả xử lý',
              children: [
                _DetailLine(label: 'Cách xử lý', value: _statusText),
                _DetailLine(label: 'Thời điểm', value: _processedTimeText),
                if ((data.moderatedBy ?? '').trim().isNotEmpty)
                  _DetailLine(
                    label: 'Người xử lý',
                    value: data.moderatedBy!.trim(),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _ContentSection(
              title: 'Thông báo gốc',
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                _BodyText(data.body),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              _footerText,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.6,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (_canAppeal) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAppealSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF241B15),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Gửi kháng nghị',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ] else if (_appealSubmittedInSession ||
                (data.appealStatus ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Kháng nghị đã được ghi nhận.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC4773B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ContentSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: scheme.onSurface,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: scheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.5,
        height: 1.58,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

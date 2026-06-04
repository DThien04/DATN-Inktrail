import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Về ứng dụng'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'InkTrail',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phiên bản v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'InkTrail là nền tảng đọc và sáng tác truyện theo chương, '
                    'nơi người dùng có thể theo dõi tác giả, lưu tiến độ đọc, '
                    'đánh giá truyện và tương tác qua bình luận.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _AboutBlock(
              title: 'Những gì bạn có thể làm',
              lines: const [
                '• Khám phá truyện theo tag và đề xuất.',
                '• Đọc liên tục, nhớ tiến độ và tải offline.',
                '• Tạo truyện, quản lý chương, xuất bản nội dung.',
                '• Đánh giá và báo cáo nội dung không phù hợp.',
              ],
            ),
            const SizedBox(height: 10),
            _AboutBlock(
              title: 'Nguyên tắc cộng đồng',
              lines: const [
                '• Tôn trọng người đọc và người viết.',
                '• Không đăng nội dung sao chép hoặc gây hại.',
                '• Báo cáo đúng mục đích để giữ môi trường lành mạnh.',
              ],
            ),
            const SizedBox(height: 10),
            _AboutBlock(
              title: 'Liên hệ hỗ trợ',
              lines: const [
                '• Email: support@inktrail.app',
                '• Phản hồi trong ứng dụng: mục Thông báo hệ thống.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _AboutBlock({
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


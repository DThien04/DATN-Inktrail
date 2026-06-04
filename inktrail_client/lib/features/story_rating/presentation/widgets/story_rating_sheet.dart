import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/story_rating/presentation/cubit/story_rating_cubit.dart';
import 'package:ink_trail_client/features/story_rating/presentation/cubit/story_rating_state.dart';

class StoryRatingSheet extends StatefulWidget {
  const StoryRatingSheet({super.key});

  @override
  State<StoryRatingSheet> createState() => _StoryRatingSheetState();
}

class _StoryRatingSheetState extends State<StoryRatingSheet> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryRatingCubit, StoryRatingState>(
      listenWhen: (previous, current) =>
          previous.messageVersion != current.messageVersion ||
          previous.draftContent != current.draftContent,
      listener: (context, state) {
        if (_contentController.text != state.draftContent) {
          _contentController.value = TextEditingValue(
            text: state.draftContent,
            selection: TextSelection.collapsed(offset: state.draftContent.length),
          );
        }

        final message = state.message;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message.text),
          ),
        );
        context.read<StoryRatingCubit>().clearMessage();
      },
      child: BlocBuilder<StoryRatingCubit, StoryRatingState>(
        builder: (context, state) {
          final scheme = Theme.of(context).colorScheme;
          final rating = state.averageRating.clamp(0.0, 5.0).toDouble();
          if (_contentController.text != state.draftContent) {
            _contentController.value = TextEditingValue(
              text: state.draftContent,
              selection: TextSelection.collapsed(offset: state.draftContent.length),
            );
          }

          return SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đánh giá truyện',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(
                            context.read<StoryRatingCubit>().buildResult(),
                          ),
                          icon: Icon(Icons.close_rounded, color: scheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _starRow(score: rating),
                              const SizedBox(height: 4),
                              Text('${state.ratingCount} đánh giá'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: !state.isAuthenticated
                        ? _buildLoginHintCard(context)
                        : state.myRating == null
                        ? _buildEditor(
                            context: context,
                            state: state,
                            title: 'Tạo đánh giá của bạn',
                            subtitle:
                                'Bạn chưa đánh giá truyện này. Hãy chọn số sao.',
                            buttonLabel: 'Gửi đánh giá',
                          )
                        : state.isEditing
                        ? _buildEditor(
                            context: context,
                            state: state,
                            title: 'Sửa đánh giá của bạn',
                            subtitle: 'Bạn chỉ có thể sửa đúng một lần.',
                            buttonLabel: 'Lưu chỉnh sửa',
                            onCancel: () =>
                                context.read<StoryRatingCubit>().cancelEditing(),
                          )
                        : _buildMyRatingCard(context, state),
                  ),
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFC4773B),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            itemCount: state.reviews.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (_, index) {
                              final review = state.reviews[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: scheme.outlineVariant),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: scheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            review.author.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: scheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.author,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: scheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                review.timeLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: scheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _starRow(score: review.score.toDouble(), size: 14),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      review.content,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginHintCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đăng nhập để đánh giá truyện và lưu nhận xét của bạn.',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRatingCard(BuildContext context, StoryRatingState state) {
    final scheme = Theme.of(context).colorScheme;
    final mine = state.myRating!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Đánh giá của bạn',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              _starRow(score: mine.score.toDouble(), size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(mine.content, style: TextStyle(color: scheme.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                mine.updatedAt != null
                    ? 'Cập nhật ${_formatTimeLabel(mine.updatedAt)}'
                    : 'Đã gửi đánh giá',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              if (mine.canEdit)
                TextButton(
                  onPressed: () => context.read<StoryRatingCubit>().startEditing(),
                  child: const Text('Sửa đánh giá'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditor({
    required BuildContext context,
    required StoryRatingState state,
    required String title,
    required String subtitle,
    required String buttonLabel,
    VoidCallback? onCancel,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final content = state.draftContent.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: List<Widget>.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.read<StoryRatingCubit>().setDraftScore(value),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                    icon: Icon(
                      value <= state.draftScore
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: value <= state.draftScore
                          ? const Color(0xFFF2B74A)
                          : const Color(0xFFD9CBBE),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Text(
                '${state.draftScore}/5',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          TextField(
            controller: _contentController,
            minLines: 3,
            maxLines: 5,
            onChanged: (value) =>
                context.read<StoryRatingCubit>().setDraftContent(value),
            style: TextStyle(color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Viết cảm nhận của bạn về truyện này...',
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              hintStyle: TextStyle(color: scheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFC4773B)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${content.length}/1000',
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (onCancel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: (state.isSubmitting || content.isEmpty)
                      ? null
                      : () => context.read<StoryRatingCubit>().submitRating(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4773B),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: scheme.brightness == Brightness.dark
                        ? scheme.surfaceContainerHighest
                        : const Color(0xFFD8C8B9),
                    disabledForegroundColor: scheme.brightness == Brightness.dark
                        ? scheme.onSurfaceVariant.withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starRow({required double score, double size = 16}) {
    final full = score.floor().clamp(0, 5);
    final hasHalf = score - full >= 0.5 && full < 5;
    final empty = 5 - full - (hasHalf ? 1 : 0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < full; i++)
          Icon(Icons.star_rounded, size: size, color: const Color(0xFFF2B74A)),
        if (hasHalf)
          Icon(
            Icons.star_half_rounded,
            size: size,
            color: const Color(0xFFF2B74A),
          ),
        for (var i = 0; i < empty; i++)
          Icon(
            Icons.star_border_rounded,
            size: size,
            color: const Color(0xFFD9CBBE),
          ),
      ],
    );
  }

  String _formatTimeLabel(DateTime? value) {
    if (value == null) return 'vừa xong';
    final now = DateTime.now().toUtc();
    final diff = now.difference(value.toUtc());
    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${value.day}/${value.month}/${value.year}';
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/features/chapter_management/domain/entities/my_story_chapter_entity.dart';
import 'package:ink_trail_client/features/chapter_management/presentation/cubit/my_story_details_cubit.dart';
import 'package:ink_trail_client/features/chapter_management/presentation/cubit/my_story_details_state.dart';
import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';

class MyStoryDetailsPage extends StatelessWidget {
  final MyStoryEntity story;

  const MyStoryDetailsPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyStoryDetailsCubit>()..load(story.id),
      child: _MyStoryDetailsView(story: story),
    );
  }
}

class _MyStoryDetailsView extends StatefulWidget {
  final MyStoryEntity story;
  const _MyStoryDetailsView({required this.story});

  @override
  State<_MyStoryDetailsView> createState() => _MyStoryDetailsViewState();
}

class _MyStoryDetailsViewState extends State<_MyStoryDetailsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final cubit = context.read<MyStoryDetailsCubit>();
      final hasPending = cubit.state.chapters.any(
        (chapter) => chapter.moderationStatus == 'pending',
      );
      if (!hasPending || cubit.state.isLoading || cubit.state.isSaving) return;
      cubit.load(widget.story.id, silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openChapterEditor({MyStoryChapterEntity? chapter}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MyStoryDetailsCubit>(),
          child: _ChapterEditorPage(storyId: widget.story.id, chapter: chapter),
        ),
      ),
    );
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String actionLabel,
    bool danger = false,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: danger ? const Color(0xFFC25B47) : const Color(0xFFC4773A),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return accepted == true;
  }

  Future<void> _handleChapterAction({
    required MyStoryChapterEntity chapter,
    required String action,
  }) async {
    final cubit = context.read<MyStoryDetailsCubit>();
    String title;
    String body;
    String actionLabel;
    bool danger = false;
    if (action == 'publish') {
      title = 'Xuất bản chương';
      body = 'Chương "${chapter.title}" sẽ được xuất bản và quét AI trong nền. Tiếp tục?';
      actionLabel = 'Xuất bản';
    } else if (action == 'unpublish') {
      title = 'Đưa về nháp';
      body = 'Chương "${chapter.title}" sẽ được đưa về bản nháp và ẩn khỏi độc giả.';
      actionLabel = 'Về nháp';
    } else {
      title = 'Xóa chương';
      body = 'Xóa "${chapter.title}"? Hành động này không thể hoàn tác.';
      actionLabel = 'Xóa';
      danger = true;
    }

    final ok = await _confirmAction(
      title: title,
      message: body,
      actionLabel: actionLabel,
      danger: danger,
    );
    if (!ok || !mounted) return;

    String? error;
    if (action == 'publish') {
      error = await cubit.publishChapter(storyId: widget.story.id, chapterId: chapter.id);
    } else if (action == 'unpublish') {
      error = await cubit.unpublishChapter(storyId: widget.story.id, chapterId: chapter.id);
    } else {
      error = await cubit.deleteChapter(storyId: widget.story.id, chapterId: chapter.id);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          error ??
              (action == 'publish'
                  ? 'Đã gửi chương để duyệt. Bạn kiểm tra lại sau ít phút nhé.'
                  : action == 'unpublish'
                      ? 'Chương đã được đưa về bản nháp.'
                      : 'Đã xóa chương "${chapter.title}".'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Chi tiết truyện',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
      body: BlocBuilder<MyStoryDetailsCubit, MyStoryDetailsState>(
        builder: (context, state) {
          final chapterCount = state.chapters.length;
          return RefreshIndicator(
            onRefresh: () => context.read<MyStoryDetailsCubit>().load(story.id),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StoryHeaderCard(story: story, chapterCount: chapterCount),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant, width: 0.5),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: scheme.onSecondaryContainer,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelColor: scheme.onSurfaceVariant,
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Chương'),
                      Tab(text: 'Giới thiệu'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 560,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ChapterTab(
                        isLoading: state.isLoading,
                        isSaving: state.isSaving,
                        chapters: state.chapters,
                        onAdd: () => _openChapterEditor(),
                        onEdit: (chapter) => _openChapterEditor(chapter: chapter),
                        onAction: _handleChapterAction,
                      ),
                      _InfoTab(story: story),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StoryHeaderCard extends StatelessWidget {
  final MyStoryEntity story;
  final int chapterCount;
  const _StoryHeaderCard({required this.story, required this.chapterCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badge = _storyBadge(context, story);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 112,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFC4956A), Color(0xFF8B5E3C)],
              ),
            ),
            child: Stack(
              children: const [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x885F3F28),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                    child: SizedBox(width: 8),
                  ),
                ),
                Center(child: Icon(Icons.menu_book_outlined, color: Colors.white, size: 30)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Chip(
                  label: badge.label,
                  backgroundColor: badge.background,
                  foregroundColor: badge.foreground,
                ),
                const SizedBox(height: 6),
                Text(
                  story.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  story.description.isEmpty ? 'Chưa có mô tả.' : story.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Stat(icon: Icons.remove_red_eye_outlined, value: '${story.readCount}'),
                    _Stat(icon: Icons.favorite_border_rounded, value: '${story.likeCount}'),
                    _Stat(icon: Icons.star_outline_rounded, value: '${story.ratingCount}'),
                    _Stat(icon: Icons.menu_book_outlined, value: '$chapterCount'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTab extends StatelessWidget {
  final bool isLoading;
  final bool isSaving;
  final List<MyStoryChapterEntity> chapters;
  final VoidCallback onAdd;
  final ValueChanged<MyStoryChapterEntity> onEdit;
  final Future<void> Function({
    required MyStoryChapterEntity chapter,
    required String action,
  })
  onAction;

  const _ChapterTab({
    required this.isLoading,
    required this.isSaving,
    required this.chapters,
    required this.onAdd,
    required this.onEdit,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    void showBlocked(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách chương',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${chapters.length} chương hiện có',
                    style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm chương'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary,
                  side: BorderSide(color: scheme.outlineVariant),
                  backgroundColor: scheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4773A)))
              : chapters.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 34, color: Color(0xFFD4C9BC)),
                          SizedBox(height: 10),
                          Text(
                            'Chua có chương nào.',
                            style: TextStyle(
                              color: Color(0xFF8E8279),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tạo chương đầu tiên để bắt đầu phát triển câu chuyện.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFB1A59A), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: chapters.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        final isPublished = chapter.status == 'published';
                        final canRepublish = chapter.moderationStatus != 'rejected' && chapter.moderationStatus != 'failed';
                        final statusChip = _chapterStatusChip(context, chapter);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outlineVariant),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: scheme.outlineVariant),
                                      color: scheme.surfaceContainerHigh,
                                    ),
                                    child: Text(
                                      '${chapter.chapterNumber}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chương ${chapter.chapterNumber}: ${chapter.title}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _ChapterMetaStat(
                                              icon: Icons.remove_red_eye_outlined,
                                              value: '--',
                                            ),
                                            const SizedBox(width: 10),
                                            _ChapterMetaStat(
                                              icon: Icons.favorite_border_rounded,
                                              value: '${chapter.likeCount}',
                                            ),
                                            const SizedBox(width: 10),
                                            _ChapterMetaStat(
                                              icon: Icons.chat_bubble_outline_rounded,
                                              value: '${chapter.commentCount}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _Chip(
                                    label: statusChip.label,
                                    backgroundColor: statusChip.background,
                                    foregroundColor: statusChip.foreground,
                                  ),
                                ],
                              ),
                              if (chapter.moderationReason.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.errorContainer.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: scheme.outlineVariant),
                                  ),
                                  child: Text(
                                    chapter.moderationReason,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onErrorContainer,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              const Divider(height: 1, thickness: 0.6, color: Color(0xFFECE3D8)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 14,
                                        color: Color(0xFF9B8F84),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(chapter.updatedAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9B8F84),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  _ChapterActionIcon(
                                    icon: isPublished ? Icons.undo_rounded : Icons.publish_outlined,
                                    onTap: () {
                                      if (isSaving) return;
                                      if (!isPublished && !canRepublish) {
                                        showBlocked('Chương đang bị từ chối. Hãy chỉnh sửa nội dung trước khi xuất bản lại.');
                                        return;
                                      }
                                      onAction(
                                        chapter: chapter,
                                        action: isPublished ? 'unpublish' : 'publish',
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _ChapterActionIcon(
                                    icon: Icons.edit_outlined,
                                    onTap: () {
                                      if (isSaving) return;
                                      if (isPublished) {
                                        showBlocked('Chương đã xuất bản, hãy đưa về bản nháp trước khi chỉnh sửa.');
                                        return;
                                      }
                                      onEdit(chapter);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _ChapterActionIcon(
                                    icon: Icons.delete_outline_rounded,
                                    foreground: scheme.onErrorContainer,
                                    background: scheme.errorContainer.withValues(alpha: 0.55),
                                    border: scheme.outlineVariant,
                                    onTap: isSaving
                                        ? null
                                        : () => onAction(chapter: chapter, action: 'delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  final MyStoryEntity story;
  const _InfoTab({required this.story});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mô tả truyện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                story.description.isEmpty ? 'Chưa có mô tả.' : story.description,
                style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _infoRow(context, 'Tags', story.tags.isEmpty ? '--' : story.tags.join(', ')),
              _infoRow(context, 'Tags', story.tags.isEmpty ? '--' : story.tags.join(', ')),
              _infoRow(context, 'Chế độ', story.status == 'published' ? 'Công khai' : 'Bản nháp'),
              _infoRow(context, 'Cập nhật', _formatDate(story.updatedAt)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Text(value, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _ChapterEditorPage extends StatefulWidget {
  final String storyId;
  final MyStoryChapterEntity? chapter;
  const _ChapterEditorPage({required this.storyId, required this.chapter});

  @override
  State<_ChapterEditorPage> createState() => _ChapterEditorPageState();
}

class _ChapterEditorPageState extends State<_ChapterEditorPage> {
  static const int _minChapterWords = 500;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _error;

  bool get _isEditing => widget.chapter != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapter?.title ?? '');
    _contentController = TextEditingController(text: widget.chapter?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() => _error = 'Tiêu đề và nội dung không được để trống.');
      return;
    }
    final wordCount = content.split(RegExp(r'\s+')).where((item) => item.isNotEmpty).length;
    if (wordCount < _minChapterWords) {
      setState(() => _error = 'Nội dung chương phải có ít nhất $_minChapterWords từ.');
      return;
    }

    final cubit = context.read<MyStoryDetailsCubit>();
    String? message;
    if (_isEditing) {
      message = await cubit.updateChapter(
        storyId: widget.storyId,
        chapterId: widget.chapter!.id,
        chapterNumber: widget.chapter!.chapterNumber,
        title: title,
        content: content,
      );
    } else {
      final chapterNumber = cubit.nextChapterNumber();
      message = await cubit.createChapter(
        storyId: widget.storyId,
        chapterNumber: chapterNumber,
        title: title,
        content: content,
      );
    }
    if (!mounted) return;
    if (message != null) {
      setState(() => _error = message);
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_isEditing ? 'Đã cập nhật chương.' : 'Đã tạo chương mới.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyStoryDetailsCubit, MyStoryDetailsState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final chapterNumber = _isEditing
            ? widget.chapter!.chapterNumber
            : context.read<MyStoryDetailsCubit>().nextChapterNumber();
        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              _isEditing ? 'Sửa chương' : 'Thêm chương',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      'Chương $chapterNumber',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B6542),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _titleController, decoration: _input('Tiêu đề chương')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    minLines: 16,
                    maxLines: null,
                    decoration: _input('Nội dung chương'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: Color(0xFFC25B47))),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: state.isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC4773A),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isEditing ? 'Lưu chương' : 'Tạo chương'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE6DCCF))),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  const _Chip({required this.label, required this.backgroundColor, required this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: foregroundColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _Stat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8E0D5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF9E8D80)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF7F746B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

({String label, Color background, Color foreground}) _storyBadge(BuildContext context, MyStoryEntity story) {
  final scheme = Theme.of(context).colorScheme;
  if (story.moderationStatus == 'pending') {
    return (
      label: 'Đang duyệt',
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
    );
  }
  if (story.moderationStatus == 'rejected' || story.moderationStatus == 'failed') {
    return (
      label: 'Cần chỉnh sửa',
      background: scheme.errorContainer,
      foreground: scheme.onErrorContainer,
    );
  }
  if (story.status == 'published') {
    return (
      label: 'Đã xuất bản',
      background: scheme.primaryContainer,
      foreground: scheme.onPrimaryContainer,
    );
  }
  return (
    label: 'Bản nháp',
    background: scheme.surfaceContainerHigh,
    foreground: scheme.onSurfaceVariant,
  );
}

String _formatDate(DateTime? value) {
  if (value == null) return '--/--/----';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

class _ChapterMetaStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ChapterMetaStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9E8D80)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F746B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChapterActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? foreground;
  final Color? background;
  final Color? border;

  const _ChapterActionIcon({
    required this.icon,
    required this.onTap,
    this.foreground,
    this.background,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveForeground = foreground ?? scheme.onSecondaryContainer;
    final effectiveBackground = background ?? scheme.secondaryContainer;
    final effectiveBorder = border ?? scheme.outlineVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 30,
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: effectiveBorder, width: 0.5),
        ),
        child: Icon(icon, size: 16, color: effectiveForeground),
      ),
    );
  }
}

({String label, Color background, Color foreground}) _chapterStatusChip(
  BuildContext context,
  MyStoryChapterEntity chapter,
) {
  final scheme = Theme.of(context).colorScheme;
  if (chapter.moderationStatus == 'pending' && chapter.status == 'published') {
    return (
      label: 'Đang duyệt',
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
    );
  }
  if (chapter.moderationStatus == 'rejected') {
    return (
      label: 'Cần chỉnh sửa',
      background: scheme.errorContainer,
      foreground: scheme.onErrorContainer,
    );
  }
  if (chapter.status == 'published') {
    return (
      label: 'Công khai',
      background: scheme.primaryContainer,
      foreground: scheme.onPrimaryContainer,
    );
  }
  return (
    label: 'Nháp',
    background: scheme.surfaceContainerHigh,
    foreground: scheme.onSurfaceVariant,
  );
}






import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/features/chapter_management/presentation/pages/my_story_details_page.dart';
import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';
import 'package:ink_trail_client/features/story_management/presentation/cubit/my_author_stories_cubit.dart';
import 'package:ink_trail_client/features/story_management/presentation/cubit/my_author_stories_state.dart';

class MyAuthorStoriesPage extends StatelessWidget {
  final String authorId;
  final String authorName;

  const MyAuthorStoriesPage({
    super.key,
    required this.authorId,
    required this.authorName,
  });

  Future<void> _openEditor(
    BuildContext context, {
    MyStoryEntity? story,
    String? forcedStatus,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<MyAuthorStoriesCubit>(),
        child: _StoryEditorSheet(
          story: story,
          forcedStatus: forcedStatus,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MyStoryEntity story) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa truyện'),
        content: Text('Xóa "${story.title}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC25B47)),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final message = await context.read<MyAuthorStoriesCubit>().deleteStory(story);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message ?? 'Đã xóa truyện "${story.title}".'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (_) => sl<MyAuthorStoriesCubit>()..load(),
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Truyện của tôi',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            elevation: 10,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tạo truyện'),
          ),
        ),
        body: _StoriesBody(
          openEditor: _openEditor,
          confirmDelete: _confirmDelete,
        ),
      ),
    );
  }
}

enum _StoryFilter { all, draft, published, pending, rejected }

class _StoriesBody extends StatefulWidget {
  final Future<void> Function(
    BuildContext context, {
    MyStoryEntity? story,
    String? forcedStatus,
  }) openEditor;
  final Future<void> Function(BuildContext context, MyStoryEntity story) confirmDelete;

  const _StoriesBody({
    required this.openEditor,
    required this.confirmDelete,
  });

  @override
  State<_StoriesBody> createState() => _StoriesBodyState();
}

class _StoriesBodyState extends State<_StoriesBody> {
  _StoryFilter _filter = _StoryFilter.all;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final cubit = context.read<MyAuthorStoriesCubit>();
      final hasPending = cubit.state.stories.any(
        (story) => story.moderationStatus == 'pending',
      );
      if (!hasPending || cubit.state.isLoading || cubit.state.isSaving) return;
      cubit.load(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAuthorStoriesCubit, MyAuthorStoriesState>(
      builder: (context, state) {
        final filteredStories = _filterStories(state.stories, _filter);
        return RefreshIndicator(
          onRefresh: () => context.read<MyAuthorStoriesCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              _FilterChips(
                filter: _filter,
                onChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 12),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFC4773B)),
                  ),
                )
              else if (state.errorMessage != null && state.stories.isEmpty)
                _MessageCard(
                  message: state.errorMessage!,
                  actionLabel: 'Thử lại',
                  onAction: () => context.read<MyAuthorStoriesCubit>().load(),
                )
              else if (state.stories.isEmpty)
                _InfoCard(
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 44, color: Color(0xFFD4C9BC)),
                      const SizedBox(height: 8),
                      const Text(
                        'Viết thêm truyện mới nào~',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Color(0xFFC8B9AA), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => widget.openEditor(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFC4773A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        child: const Text('Tạo truyện mới'),
                      ),
                    ],
                  ),
                )
              else if (filteredStories.isEmpty)
                _InfoCard(
                  child: Text(
                    'Không có truyện nào phù hợp với bộ lọc hiện tại.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...filteredStories.map(
                  (story) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoryCard(
                      story: story,
                      isDeleting: state.deletingStoryId == story.id,
                      onOpenDetails: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MyStoryDetailsPage(story: story),
                        ),
                      ),
                      onEdit: () => widget.openEditor(context, story: story),
                      onDelete: () => widget.confirmDelete(context, story),
                      onPublish: story.status == 'draft'
                          ? () => widget.openEditor(
                                context,
                                story: story,
                                forcedStatus: 'published',
                              )
                          : null,
                      onUnpublish: story.status == 'published'
                          ? () => widget.openEditor(
                                context,
                                story: story,
                                forcedStatus: 'draft',
                              )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

List<MyStoryEntity> _filterStories(List<MyStoryEntity> stories, _StoryFilter filter) {
  switch (filter) {
    case _StoryFilter.draft:
      return stories.where((story) => story.status == 'draft').toList();
    case _StoryFilter.published:
      return stories.where((story) => story.status == 'published').toList();
    case _StoryFilter.pending:
      return stories.where((story) => story.moderationStatus == 'pending').toList();
    case _StoryFilter.rejected:
      return stories.where((story) => story.moderationStatus == 'rejected').toList();
    case _StoryFilter.all:
      return stories;
  }
}


class _FilterChips extends StatelessWidget {
  final _StoryFilter filter;
  final ValueChanged<_StoryFilter> onChanged;

  const _FilterChips({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <({String label, _StoryFilter value})>[
      (label: 'Tất cả', value: _StoryFilter.all),
      (label: 'Bản nháp', value: _StoryFilter.draft),
      (label: 'Đang phát hành', value: _StoryFilter.published),
      (label: 'Đang duyệt', value: _StoryFilter.pending),
      (label: 'Cần chỉnh sửa', value: _StoryFilter.rejected),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_StoryFilter>(
          value: filter,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurfaceVariant),
          iconEnabledColor: scheme.onSurfaceVariant,
          hint: Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Bộ lọc', style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<_StoryFilter>(
                  value: item.value,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageCard({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _StoryCard extends StatelessWidget {
  final MyStoryEntity story;
  final bool isDeleting;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onUnpublish;

  const _StoryCard({
    required this.story,
    required this.isDeleting,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
    this.onUnpublish,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowModeration = story.status == 'published' || story.moderationStatus == 'rejected' || story.moderationStatus == 'failed';
    final isPendingModeration = story.moderationStatus == 'pending';
    void showBlocked(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
    }
    final primaryBadge = _primaryStoryBadge(context, story);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onOpenDetails,
      child: _InfoCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniBookCover(coverUrl: story.coverUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            story.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: primaryBadge.label,
                          backgroundColor: primaryBadge.background,
                          foregroundColor: primaryBadge.foreground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      story.description.isEmpty ? 'Chưa có mô tả.' : story.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InlineStat(icon: Icons.visibility_outlined, value: '${story.readCount}'),
                        const SizedBox(width: 12),
                        _InlineStat(icon: Icons.favorite_border_rounded, value: '${story.likeCount}'),
                        const SizedBox(width: 12),
                        _InlineStat(icon: Icons.star_outline_rounded, value: '${story.ratingCount}'),
                        const SizedBox(width: 12),
                        _InlineStat(icon: Icons.menu_book_outlined, value: '${story.chapterCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (shouldShowModeration && story.moderationReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            _WarningBox(text: story.moderationReason),
          ],
          const SizedBox(height: 10),
          if (shouldShowModeration && story.moderationCategories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: story.moderationCategories
                  .map(
                    (category) => _Chip(
                      label: category,
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 0.5, color: scheme.outlineVariant),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    story.updatedAt == null ? '--/--/----' : _formatDate(story.updatedAt!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    child: onPublish != null
                        ? _ActionButton(
                            label: 'Xuất bản',
                            icon: Icons.send_outlined,
                            onTap: () {
                              if (story.moderationStatus == 'rejected' || story.moderationStatus == 'failed') {
                                showBlocked('Truyện đang bị từ chối. Hãy chỉnh sửa nội dung trước khi xuất bản lại.');
                                return;
                              }
                              onPublish!();
                            },
                            foreground: scheme.onSecondaryContainer,
                            border: scheme.outlineVariant,
                            background: scheme.secondaryContainer,
                          )
                        : onUnpublish != null
                            ? _ActionButton(
                                label: 'Về nháp',
                                icon: Icons.undo_rounded,
                                onTap: onUnpublish!,
                                background: scheme.secondaryContainer,
                                foreground: scheme.onSecondaryContainer,
                                border: scheme.outlineVariant,
                              )
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 6),
                  _IconActionButton(
                    icon: Icons.edit_outlined,
                    onTap: () {
                      if (isPendingModeration) {
                        showBlocked('Truyện đang chờ duyệt, chưa thể chỉnh sửa lúc này.');
                        return;
                      }
                      if (story.status == 'published') {
                        showBlocked('Truyện đã xuất bản, hãy đưa về bản nháp trước khi chỉnh sửa.');
                        return;
                      }
                      onEdit();
                    },
                    background: scheme.surfaceContainerHigh,
                    foreground: scheme.onSurfaceVariant,
                    border: scheme.outlineVariant,
                  ),
                  const SizedBox(width: 6),
                  _IconActionButton(
                    icon: isDeleting ? Icons.hourglass_top_rounded : Icons.delete_outline_rounded,
                    onTap: (isDeleting || isPendingModeration) ? null : onDelete,
                    background: scheme.errorContainer.withValues(alpha: 0.55),
                    foreground: scheme.onErrorContainer,
                    border: scheme.outlineVariant,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InlineStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
class _StoryEditorSheet extends StatefulWidget {
  final MyStoryEntity? story;
  final String? forcedStatus;

  const _StoryEditorSheet({this.story, this.forcedStatus});

  @override
  State<_StoryEditorSheet> createState() => _StoryEditorSheetState();
}

class _StoryEditorSheetState extends State<_StoryEditorSheet> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late String _status;
  Uint8List? _coverPreviewBytes;
  String? _coverFileName;
  String? _coverMimeType;
  String? _errorMessage;
  bool _isPickingCover = false;

  bool get _isEditing => widget.story != null;
  bool get _publishFlow => widget.forcedStatus == 'published';
  bool get _draftFlow => widget.forcedStatus == 'draft';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.story?.title ?? '');
    _descriptionController = TextEditingController(text: widget.story?.description ?? '');
    _tagsController = TextEditingController(text: (widget.story?.tags ?? const []).join(', '));
    _status = widget.forcedStatus ?? widget.story?.status ?? 'draft';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final tags = _parseTagNames(_tagsController.text);
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Tiêu đề truyện không được để trống.');
      return;
    }

    setState(() => _errorMessage = null);
    final cubit = context.read<MyAuthorStoriesCubit>();
    final message = _draftFlow && _isEditing
        ? await cubit.updateStoryStatus(
            storyId: widget.story!.id,
            status: 'draft',
          )
        : _isEditing
            ? await cubit.updateStory(
                storyId: widget.story!.id,
                title: title,
                description: description,
                status: _status,
                tags: tags,
                coverBytes: _coverPreviewBytes,
                fileName: _coverFileName,
                mimeType: _coverMimeType,
              )
            : await cubit.createStory(
                title: title,
                description: description,
                status: _status,
                tags: tags,
                coverBytes: _coverPreviewBytes,
                fileName: _coverFileName,
                mimeType: _coverMimeType,
              );

    if (!mounted) return;
    if (message != null) {
      setState(() => _errorMessage = message);
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_successMessage()),
      ),
    );
  }

  String _successMessage() {
    if (_draftFlow) return 'Truyện đã được chuyển về bản nháp.';
    if (_publishFlow) return 'Đã gửi xuất bản. Truyện sẽ được duyệt trong nền.';
    return _isEditing ? 'Đã cập nhật truyện.' : 'Đã tạo truyện mới.';
  }

  Future<void> _pickCover() async {
    if (_isPickingCover) return;
    _isPickingCover = true;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 86,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;
      setState(() {
        _coverPreviewBytes = bytes;
        _coverFileName = file.name.isEmpty ? 'story-cover.jpg' : file.name;
        _coverMimeType = _guessMimeType(_coverFileName!);
        _errorMessage = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.code == 'already_active'
            ? 'Trình chọn ảnh đang mở. Hãy đóng lại rồi thử lại.'
            : 'Không thể mở thư viện ảnh lúc này.';
      });
    } finally {
      _isPickingCover = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return BlocBuilder<MyAuthorStoriesCubit, MyAuthorStoriesState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _sheetTitle(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sheetDescription(),
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Ảnh bìa'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: state.isSaving || _isPickingCover ? null : _pickCover,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 188,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildCoverPreview(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Tiêu đề truyện'),
                  const SizedBox(height: 6),
                  TextField(controller: _titleController, decoration: _inputDecoration('Ví dụ: Sương mù cuối ngõ')),
                  const SizedBox(height: 14),
                  const _FieldLabel('Mô tả'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: _inputDecoration('Tóm tắt ngắn về truyện của bạn'),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Tags'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _tagsController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: _inputDecoration('Ví dụ: cưới trước yêu sau, học đường, chữa lành'),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nhập tag cách nhau bằng dấu phẩy.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBox(message: _errorMessage!),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: state.isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_primaryButtonLabel(), style: const TextStyle(fontWeight: FontWeight.w700)),
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

  String _sheetTitle() => _draftFlow
      ? 'Đưa truyện về bản nháp'
      : _publishFlow
          ? 'Xuất bản truyện'
          : _isEditing
              ? 'Sửa truyện'
              : 'Tạo truyện mới';

  String _sheetDescription() => _draftFlow
      ? 'Truyện sẽ quay về trạng thái bản nháp và không còn hiển thị công khai.'
      : _publishFlow
          ? 'Truyện sẽ được gửi sang bước duyệt sau khi lưu.'
          : 'Cập nhật tiêu đề, mô tả và ảnh bìa của truyện.';

  String _primaryButtonLabel() => _draftFlow
      ? 'Xác nhận về nháp'
      : _publishFlow
          ? 'Lưu và xuất bản'
          : _isEditing
              ? 'Lưu thay đổi'
              : 'Tạo truyện';

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.2),
        ),
      );

  Widget _buildCoverPreview() {
    if (_coverPreviewBytes != null) return Image.memory(_coverPreviewBytes!, fit: BoxFit.cover);
    if ((widget.story?.coverUrl ?? '').isNotEmpty) return Image.network(widget.story!.coverUrl, fit: BoxFit.cover);
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            'Thêm ảnh bìa cho truyện',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseTagNames(String raw) {
    final unique = <String, String>{};
    for (final part in raw.split(RegExp(r'[\n,]'))) {
      final normalized = part.trim();
      if (normalized.isEmpty) continue;
      final key = normalized.toLowerCase();
      unique.putIfAbsent(key, () => normalized);
    }
    return unique.values.toList();
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  const _Chip({required this.label, required this.backgroundColor, required this.foregroundColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foregroundColor)),
      );
}

class _MiniBookCover extends StatelessWidget {
  final String coverUrl;
  const _MiniBookCover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    if (coverUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(coverUrl, width: 76, height: 102, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 76,
      height: 102,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC4956A), Color(0xFF8B5E3C)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF8A603F),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
          ),
          const Expanded(
            child: Center(
              child: Icon(Icons.menu_book_outlined, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;
  final Color border;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.background,
    required this.foreground,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: foreground, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final Color border;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.foreground,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Icon(icon, size: 15, color: foreground),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String text;
  const _WarningBox({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            height: 1.45,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      );
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

({String label, Color background, Color foreground}) _primaryStoryBadge(BuildContext context, MyStoryEntity story) {
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

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _guessMimeType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

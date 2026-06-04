import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/auth/auth_gate.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/author_profile_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/author_profile_state.dart';
import 'package:ink_trail_client/features/story_detail/presentation/pages/story_detail_page.dart';

class AuthorProfilePage extends StatefulWidget {
  final String authorId;
  final String initialName;
  final String initialBio;
  final int? initialStoryCount;

  const AuthorProfilePage({
    super.key,
    required this.authorId,
    this.initialName = '',
    this.initialBio = '',
    this.initialStoryCount,
  });

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage> {
  Future<void> _toggleFollow(AuthorProfileState state) async {
    if (state.isSubmittingFollow) return;
    if (!await AuthGate.requireAuth(context)) return;
    if (!mounted) return;

    if (state.authorProfile.isFollowing) {
      final confirmed = await _confirmUnfollow();
      if (!mounted) return;
      if (!confirmed) return;
    }

    final success = await context.read<AuthorProfileCubit>().setFollow(
      follow: !state.authorProfile.isFollowing,
    );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Không thể cập nhật theo dõi người dùng lúc này.'),
        ),
      );
    }
  }

  Future<bool> _confirmUnfollow() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy theo dõi'),
        content: const Text('Bạn có chắc muốn hủy theo dõi người dùng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _openStory(AuthorStoryEntity story) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDetailPage(story: story.toStoryEntity()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (_) => sl<AuthorProfileCubit>(
        param1: AuthorProfileSeed(
          authorId: widget.authorId,
          initialName: widget.initialName,
          initialBio: widget.initialBio,
          initialStoryCount: widget.initialStoryCount,
        ),
      )..load(),
      child: BlocBuilder<AuthorProfileCubit, AuthorProfileState>(
        builder: (context, state) {
          final cubit = context.read<AuthorProfileCubit>();
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Người dùng',
                style: TextStyle(color: scheme.onSurface),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              iconTheme: IconThemeData(color: scheme.onSurface),
            ),
            body: RefreshIndicator(
              color: const Color(0xFFC4773B),
              onRefresh: cubit.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildHeaderCard(state),
                  const SizedBox(height: 16),
                  Text(
                    'Tác phẩm đã đăng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 56),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFFC4773B)),
                      ),
                    )
                  else if (state.errorMessage != null)
                    _AuthorInfoBox(
                      message: state.errorMessage!,
                      actionLabel: 'Thử lại',
                      onTap: cubit.load,
                    )
                  else if (state.stories.isEmpty)
                    const _AuthorInfoBox(
                      message: 'Người dùng này chưa có tác phẩm công khai nào.',
                    )
                  else
                    ...state.stories.map(
                      (story) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AuthorStoryCard(
                          story: story,
                          onTap: () => _openStory(story),
                        ),
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

  Widget _buildHeaderCard(AuthorProfileState state) {
    final scheme = Theme.of(context).colorScheme;
    final author = state.authorProfile;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: scheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.surface, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
              child: author.avatarUrl.isNotEmpty
                  ? Image.network(
                      author.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _avatarFallback(author.displayName),
                    )
                  : _avatarFallback(author.displayName),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            author.displayName.isEmpty ? 'Người dùng' : author.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              'Hồ sơ người dùng',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Tác phẩm',
                  value: '${author.storyCount}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  label: 'Người theo dõi',
                  value: '${author.followerCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            author.bio.isEmpty ? 'Người dùng này chưa cập nhật phần giới thiệu.' : author.bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSubmittingFollow ? null : () => _toggleFollow(state),
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    author.isFollowing ? scheme.surfaceContainerHighest : const Color(0xFFC4773B),
                foregroundColor: author.isFollowing ? scheme.onSurface : Colors.white,
                disabledBackgroundColor: scheme.surfaceContainerHighest,
                disabledForegroundColor: scheme.onSurfaceVariant,
                side: author.isFollowing ? BorderSide(color: scheme.outlineVariant) : BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (author.isFollowing) ...[
                    Icon(Icons.check_rounded, size: 18, color: scheme.onSurface),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    author.isFollowing ? 'Đang theo dõi' : 'Theo dõi người dùng',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String displayName) {
    return Center(
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xFFC4773B),
        ),
      ),
    );
  }
}

class _AuthorStoryCard extends StatelessWidget {
  final AuthorStoryEntity story;
  final VoidCallback onTap;

  const _AuthorStoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 86,
                  height: 122,
                  child: story.coverUrl.isNotEmpty
                      ? Image.network(
                          story.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _coverFallback(context),
                        )
                      : _coverFallback(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.28,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story.description.isEmpty ? 'Chưa có mô tả cho tác phẩm này.' : story.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaBadge(label: '${story.chapterCount} chương'),
                        _MetaBadge(label: '${_formatCompactCount(story.readCount)} lượt đọc'),
                        _MetaBadge(
                          label: story.rating.toStringAsFixed(1),
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFE6B450),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (story.tags.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              story.tags.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Color(0xFFC4773B),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverFallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFFC4773B),
        size: 34,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const _MetaBadge({
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: iconColor ?? scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorInfoBox extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onTap;

  const _AuthorInfoBox({
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onTap!.call(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC4773B),
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatCompactCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return count.toString();
}

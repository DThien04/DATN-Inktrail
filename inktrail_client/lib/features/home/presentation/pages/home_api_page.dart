import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/notifications/notification_navigation_service.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_state.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/home/presentation/bloc/home/home_api_cubit.dart';
import 'package:ink_trail_client/features/home/presentation/bloc/home/home_api_state.dart';
import 'package:ink_trail_client/features/home/presentation/bloc/notifications/home_notifications_cubit.dart';
import 'package:ink_trail_client/features/home/presentation/bloc/notifications/home_notifications_state.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/home/presentation/widgets/monthly_ranking_pager.dart';
import 'package:ink_trail_client/features/home/presentation/widgets/story_horizontal_list.dart';
import 'package:ink_trail_client/features/search/presentation/pages/search_page.dart';
import 'package:ink_trail_client/features/story_detail/presentation/pages/story_detail_page.dart';

import '../widgets/category_tab_bar.dart';

class HomeApiPage extends StatelessWidget {
  const HomeApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = sl<AuthCubit>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (_) => sl<HomeApiCubit>()..loadHome()),
      ],
      child: const _HomeApiView(),
    );
  }
}

class _HomeApiView extends StatefulWidget {
  const _HomeApiView();

  @override
  State<_HomeApiView> createState() => _HomeApiViewState();
}

class _HomeApiViewState extends State<_HomeApiView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      context.read<HomeApiCubit>().loadMoreStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<HomeApiCubit, HomeApiState>(
          builder: (context, state) {
            if (state.status == HomeApiStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFC4773B)),
              );
            }
            if (state.status == HomeApiStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
              );
            }

            final hasContent =
                state.monthlyRankingStories.isNotEmpty ||
                state.hotStories.isNotEmpty ||
                state.newStories.isNotEmpty;

            return RefreshIndicator(
              color: const Color(0xFFC4773B),
              onRefresh: () => context.read<HomeApiCubit>().loadHome(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSearchBar(context)),
                  if (hasContent) ...[
                    if (state.monthlyRankingStories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MonthlyRankingPager(
                            stories: state.monthlyRankingStories,
                            onTap: (story) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StoryDetailPage(story: story),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CategoryTabBar(
                          categories: state.categories,
                          selected: state.selectedCategory,
                          onSelect: (category) => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchPage(
                                showLeading: true,
                                initialTagName: category == 'Tất cả'
                                    ? null
                                    : category,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (state.hotStories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: StoryHorizontalList(
                            title: 'Đang hot',
                            stories: state.hotStories,
                            onReachEnd: () =>
                                context.read<HomeApiCubit>().loadMoreStories(),
                            onTap: (story) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StoryDetailPage(story: story),
                              ),
                            ),
                            onSeeMore: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SearchPage(showLeading: true),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (state.newStories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _StoryVerticalList(
                            title: 'Mới cập nhật',
                            stories: state.newStories,
                            onTap: (story) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StoryDetailPage(story: story),
                              ),
                            ),
                            onSeeMore: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SearchPage(showLeading: true),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ] else
                    SliverToBoxAdapter(child: _buildEmptyHomeState(context)),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFC4773B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final scheme = Theme.of(context).colorScheme;
                  final name = authState.user?.displayName;
                  return Text(
                    name == null || name.isEmpty ? 'Chào buổi sáng,' : 'Chào, $name',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  );
                },
              ),
              Text(
                'Đọc gì hôm nay?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final user = authState.user;
              final avatarUrl = user?.avatarUrl;
              final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

              return Row(
                children: [
                  _NotificationBellButton(
                    onTap: () => _showNotificationsSheet(context),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFC4773B),
                    backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                    child: hasAvatar
                        ? null
                        : const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SearchPage(showLeading: true),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: scheme.onSurfaceVariant),
              SizedBox(width: 10),
              Text(
                'Tìm truyện, tác giả...',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHomeState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          _buildEmptyCard(
            title: 'Chưa có truyện nổi bật',
            subtitle: 'Dữ liệu sẽ hiển thị tại đây khi backend trả về.',
          ),
          const SizedBox(height: 12),
          _buildEmptyCard(
            title: 'Bảng xếp hạng tháng này',
            subtitle: 'Hiện chưa có dữ liệu xếp hạng trong tháng.',
          ),
          const SizedBox(height: 12),
          _buildEmptyCard(
            title: 'Mới cập nhật',
            subtitle: 'Khi có chương mới, bạn sẽ thấy ở đây.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.read<HomeApiCubit>().loadHome(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC4773B),
                side: const BorderSide(color: Color(0xFFC4773B)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tải lại dữ liệu'),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEmptyCard({required String title, required String subtitle}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationsSheet(BuildContext context) async {
    final selectedItem = await showGeneralDialog<HomeInboxItemEntity>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'notifications',
      barrierColor: Colors.black.withValues(alpha: 0.14),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => const _NotificationsPopup(),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

    if (!mounted || selectedItem == null) return;
    await NotificationNavigationService.openInboxItem(selectedItem);
  }
}

class _StoryVerticalList extends StatelessWidget {
  final String title;
  final List<StoryEntity> stories;
  final void Function(StoryEntity story) onTap;
  final VoidCallback onSeeMore;

  const _StoryVerticalList({
    required this.title,
    required this.stories,
    required this.onTap,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSeeMore,
                child: const Text(
                  'Xem thêm',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC4773B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ListView.separated(
            itemCount: stories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) => _StoryVerticalCard(
              story: stories[index],
              onTap: () => onTap(stories[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryVerticalCard extends StatelessWidget {
  final StoryEntity story;
  final VoidCallback onTap;

  const _StoryVerticalCard({
    required this.story,
    required this.onTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _safeExcerpt(String raw, {int maxChars = 120}) {
    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '';
    if (normalized.length <= maxChars) return normalized;
    return '${normalized.substring(0, maxChars).trimRight()}…';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 72,
                height: 96,
                color: scheme.surfaceContainerHighest,
                child: story.coverUrl.trim().isEmpty
                    ? const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFC4773B),
                      )
                    : Image.network(
                        story.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFFC4773B),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 14,
                        color: Color(0xFFB09E90),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(story.readCount),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          story.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _safeExcerpt(
                      story.description.trim().isEmpty
                          ? 'Chưa có mô tả.'
                          : story.description,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationBellButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationBellButtonBody(onTap: onTap);
  }
}

class _NotificationBellButtonBody extends StatefulWidget {
  final VoidCallback onTap;

  const _NotificationBellButtonBody({required this.onTap});

  @override
  State<_NotificationBellButtonBody> createState() =>
      _NotificationBellButtonBodyState();
}

class _NotificationBellButtonBodyState
    extends State<_NotificationBellButtonBody> {
  late final HomeNotificationsCubit _notificationsCubit;

  @override
  void initState() {
    super.initState();
    _notificationsCubit = sl<HomeNotificationsCubit>()
      ..loadUnreadCount();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<HomeNotificationsCubit, HomeNotificationsState>(
      bloc: _notificationsCubit,
      builder: (context, state) {
        final unreadCount = state.unreadCount;
        return GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8574A),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: scheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _NotificationsPopup extends StatefulWidget {
  const _NotificationsPopup();

  @override
  State<_NotificationsPopup> createState() => _NotificationsPopupState();
}

class _NotificationsPopupState extends State<_NotificationsPopup> {
  late final HomeNotificationsCubit _notificationsCubit;

  @override
  void initState() {
    super.initState();
    _notificationsCubit = sl<HomeNotificationsCubit>()..loadInbox();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleTapItem(int index) async {
    final items = _notificationsCubit.state.items;
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    await _notificationsCubit.markItemAsRead(index);
    if (!mounted) return;
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeNotificationsCubit, HomeNotificationsState>(
      bloc: _notificationsCubit,
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final items = state.items;
        final unreadCount = state.unreadCount;
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 74, 16, 16),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 304,
                  constraints: const BoxConstraints(maxHeight: 392),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: scheme.outlineVariant),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NotificationsPopupHeader(
                          unreadCount: unreadCount,
                          isMarkingAll: state.isMarkingAll,
                          onMarkAllAsRead: _notificationsCubit.markAllAsRead,
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: state.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 34),
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFC4773B),
                                    ),
                                  ),
                                )
                              : items.isEmpty
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 28),
                                      child: Text(
                                        'Chưa có thông báo nào.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : _NotificationsList(
                                      items: items,
                                      onTapItem: _handleTapItem,
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsPopupHeader extends StatelessWidget {
  final int unreadCount;
  final bool isMarkingAll;
  final VoidCallback onMarkAllAsRead;

  const _NotificationsPopupHeader({
    required this.unreadCount,
    required this.isMarkingAll,
    required this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$unreadCount mới',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: unreadCount == 0 || isMarkingAll
                  ? null
                  : onMarkAllAsRead,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
              ),
              child: Text(
                'Đọc tất cả',
                style: TextStyle(color: scheme.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<HomeInboxItemEntity> items;
  final void Function(int index) onTapItem;

  const _NotificationsList({
    required this.items,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onTapItem(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: item.isUnread
                  ? scheme.surfaceContainerHighest
                  : scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    _iconForNotificationType(item.type ?? ''),
                    size: 16,
                    color: item.isUnread
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          if (item.isUnread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD8574A),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.38,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.timeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

IconData _iconForNotificationType(String type) {
  switch (type) {
    case 'chapter_liked':
      return Icons.auto_stories_outlined;
    case 'chapter_commented':
      return Icons.chat_bubble_outline_rounded;
    case 'chapter_published':
      return Icons.menu_book_rounded;
    case 'story_published':
      return Icons.library_books_outlined;
    case 'system':
      return Icons.person_add_alt_1_rounded;
    default:
      return Icons.notifications_active_outlined;
  }
}

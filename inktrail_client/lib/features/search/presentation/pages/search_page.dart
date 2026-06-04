import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/search/presentation/cubit/search_cubit.dart';
import 'package:ink_trail_client/features/search/presentation/cubit/search_state.dart';
import 'package:ink_trail_client/features/story_detail/presentation/pages/story_detail_page.dart';

class SearchPage extends StatefulWidget {
  final bool showLeading;
  final String initialQuery;
  final String? initialTagName;

  const SearchPage({
    super.key,
    this.showLeading = false,
    this.initialQuery = '',
    this.initialTagName,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchCubit _searchCubit;
  late final TextEditingController _searchController;
  Timer? _debounce;

  String _selectedSort = 'updated';

  static const _sortOptions = [
    _SortOption(value: 'updated', label: 'Mới cập nhật'),
    _SortOption(value: 'newest', label: 'Mới thêm'),
    _SortOption(value: 'title', label: 'Tên A-Z'),
  ];

  // Cover placeholder gradients for story cards
  static const _coverGradients = [
    [Color(0xFFD4B896), Color(0xFFB8906A)],
    [Color(0xFFB8C8D4), Color(0xFF7A99AA)],
    [Color(0xFFD4C4B8), Color(0xFFB8A898)],
    [Color(0xFFC8D4B8), Color(0xFF8AA870)],
    [Color(0xFFD4B8C8), Color(0xFFAA7898)],
  ];

  @override
  void initState() {
    super.initState();
    _searchCubit = sl<SearchCubit>();
    _searchController = TextEditingController(text: widget.initialQuery);
    unawaited(
      _searchCubit.loadInitial(
        query: widget.initialQuery,
        initialTagName: widget.initialTagName,
        sort: _selectedSort,
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  void _cancelDebounce() {
    _debounce?.cancel();
    _debounce = null;
  }

  void _onQueryChanged(String _) {
    setState(() {});
    _cancelDebounce();
    _debounce = Timer(
      const Duration(milliseconds: 320),
      _searchStories,
    );
  }

  Future<void> _searchStories({bool immediate = false}) async {
    if (immediate) {
      _cancelDebounce();
    }
    await _searchCubit.search(
      query: _searchController.text,
      sort: _selectedSort,
      immediate: immediate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: _searchCubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, SearchState state) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              if (widget.showLeading) ...[
                _SmallIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tìm kiếm',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Khám phá kho truyện',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSearchInput(),
          const SizedBox(height: 14),
          _buildSortRow(),
          const SizedBox(height: 10),
          _buildTagRow(state),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              onSubmitted: (_) => _searchStories(immediate: true),
              style: TextStyle(fontSize: 13, color: scheme.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Tìm truyện, tác giả...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _cancelDebounce();
                _searchController.clear();
                setState(() {});
                _searchStories(immediate: true);
              },
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SẮP XẾP',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sortOptions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, index) {
              final item = _sortOptions[index];
              final active = item.value == _selectedSort;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSort = item.value);
                  _searchStories(immediate: true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(
                      colors: [Color(0xFFD4895A), Color(0xFFC07238)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: active ? null : scheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active
                          ? Colors.transparent
                          : scheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagRow(SearchState state) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAGS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        if (state.isLoadingTags)
          const SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFD4895A),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.tagFilters.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, index) {
                final isAll = index == 0;
                final active = isAll
                    ? state.selectedTagId == null
                    : state.tagFilters[index - 1].id == state.selectedTagId;
                final label = isAll ? 'Tất cả' : '#${state.tagFilters[index - 1].name}';

                return GestureDetector(
                  onTap: () {
                    _searchCubit.selectTagFilter(
                      isAll ? null : state.tagFilters[index - 1].id,
                    );
                    _searchStories(immediate: true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? scheme.surfaceContainerHighest
                          : scheme.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(SearchState state) {
    if (state.isLoadingResults) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4895A)),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8D8D8D)),
          ),
        ),
      );
    }

    if (!state.hasSearched) return const _SearchPlaceholder();
    if (state.results.isEmpty) return const _SearchEmptyState();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Text(
                '${state.results.length} kết quả',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                state.selectedTagId == null
                    ? 'Tất cả tag'
                    : 'Đã lọc theo tag',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final story = state.results[index];
              return _StoryCard(
                story: story,
                gradientColors:
                _coverGradients[index % _coverGradients.length],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryDetailPage(story: story),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Story Card ───────────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final StoryEntity story;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.gradientColors,
    required this.onTap,
  });

  /// Returns a badge config (label, bg, text color) for well-known tags.
  _TagBadgeData? _badgeForTag(String tag) {
    final normalized = tag.toLowerCase();
    if (normalized == 'he' || normalized == 'hết') {
      return _TagBadgeData(
        label: 'HE',
        bg: const Color(0xFFEDF3F0),
        fg: const Color(0xFF4A8A6A),
      );
    }
    if (normalized == 'be') {
      return _TagBadgeData(
        label: 'BE',
        bg: const Color(0xFFFDF0EE),
        fg: const Color(0xFFC06050),
      );
    }
    if (normalized == 'hoàn') {
      return _TagBadgeData(
        label: 'Hoàn',
        bg: const Color(0xFFEDF3F0),
        fg: const Color(0xFF4A8A6A),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final specialTags = <_TagBadgeData>[];
    final normalTags = <String>[];

    for (final tag in story.tags.take(4)) {
      final badge = _badgeForTag(tag);
      if (badge != null) {
        specialTags.add(badge);
      } else {
        normalTags.add(tag);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              width: 72,
              height: 98,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: story.coverUrl.isEmpty
                    ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                image: story.coverUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(story.coverUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: story.coverUrl.isEmpty
                  ? const Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white70,
                  size: 26,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            // Info
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
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.author,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    story.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      // Normal hashtag tags
                      ...normalTags.take(2).map(
                            (tag) => _TagPill(
                          label: '#$tag',
                          bg: scheme.surfaceContainerHighest,
                          fg: scheme.primary,
                        ),
                      ),
                      // Special status badges
                      ...specialTags.map(
                            (b) => _TagPill(label: b.label, bg: b.bg, fg: b.fg),
                      ),
                    ],
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

class _TagPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _TagPill({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TagBadgeData {
  final String label;
  final Color bg;
  final Color fg;
  const _TagBadgeData({required this.label, required this.bg, required this.fg});
}

// ─── Small Icon Button ────────────────────────────────────────────────────────

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Icon(icon, size: 15, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

// ─── Empty / Placeholder States ───────────────────────────────────────────────

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                size: 32,
                color: Color(0xFFD4895A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bắt đầu tìm kiếm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nhập tên truyện, tác giả hoặc chọn tag để khám phá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6DB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 30,
                color: Color(0xFFD4895A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có kết quả phù hợp',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C140E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thử đổi từ khóa hoặc chọn tag khác để tìm thêm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFFA08878),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption {
  final String value;
  final String label;
  const _SortOption({required this.value, required this.label});
}


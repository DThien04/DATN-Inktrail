import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/search/presentation/pages/search_page.dart';
import 'package:ink_trail_client/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:ink_trail_client/features/tags/presentation/cubit/tags_state.dart';

// ---------------------------------------------------------------------------
// Color palette — 7 ramps cycling by index
// ---------------------------------------------------------------------------
const List<_TagColor> _kTagColors = [
  _TagColor(bg: Color(0xFFFAECE7), border: Color(0xFFF0997B), fg: Color(0xFF993C1D)), // coral
  _TagColor(bg: Color(0xFFE1F5EE), border: Color(0xFF5DCAA5), fg: Color(0xFF0F6E56)), // teal
  _TagColor(bg: Color(0xFFEEEDFE), border: Color(0xFFAFA9EC), fg: Color(0xFF3C3489)), // purple
  _TagColor(bg: Color(0xFFFAEEDA), border: Color(0xFFEF9F27), fg: Color(0xFF854F0B)), // amber
  _TagColor(bg: Color(0xFFFBEAF0), border: Color(0xFFED93B1), fg: Color(0xFF72243E)), // pink
  _TagColor(bg: Color(0xFFE6F1FB), border: Color(0xFF85B7EB), fg: Color(0xFF0C447C)), // blue
  _TagColor(bg: Color(0xFFF1EFE8), border: Color(0xFFB4B2A9), fg: Color(0xFF444441)), // gray
];

class _TagColor {
  final Color bg;
  final Color border;
  final Color fg;
  const _TagColor({required this.bg, required this.border, required this.fg});
}

Color _blend(Color a, Color b, double t) {
  final tt = t.clamp(0.0, 1.0);
  return Color.fromARGB(
    255,
    ((a.r + (b.r - a.r) * tt) * 255.0).round(),
    ((a.g + (b.g - a.g) * tt) * 255.0).round(),
    ((a.b + (b.b - a.b) * tt) * 255.0).round(),
  );
}

_TagColor _colorForIndex(BuildContext context, int index) {
  final scheme = Theme.of(context).colorScheme;
  final brightness = Theme.of(context).brightness;
  if (brightness != Brightness.dark) {
    return _kTagColors[index % _kTagColors.length];
  }

  final accents = <Color>[
    scheme.primary,
    scheme.secondary,
    scheme.tertiary,
    scheme.error,
    scheme.primaryContainer,
    scheme.secondaryContainer,
    scheme.tertiaryContainer,
  ];
  final accent = accents[index % accents.length];

  final bg = _blend(scheme.surface, accent, 0.18);
  final border = accent.withValues(alpha: 0.65);
  final fg = _blend(scheme.onSurface, accent, 0.55);

  return _TagColor(bg: bg, border: border, fg: fg);
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TagsCubit>()..load(),
      child: const _TagsPageView(),
    );
  }
}

class _TagsPageView extends StatefulWidget {
  const _TagsPageView();

  @override
  State<_TagsPageView> createState() => _TagsPageViewState();
}

class _TagsPageViewState extends State<_TagsPageView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      context.read<TagsCubit>().setQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearchWithTag(TagFilterEntity tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(
          showLeading: true,
          initialTagName: tag.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagsCubit, TagsState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final sections = state.groupedSections;
        final ungroupedTags = state.ungroupedTags;
        final hasAnyTags = sections.isNotEmpty || ungroupedTags.isNotEmpty;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: _SearchBox(controller: _searchController),
                ),

                // Group chips (horizontal scroll)
                if (!state.isLoading && sections.isNotEmpty)
                  _GroupChipBar(
                    sections: sections,
                    selectedId: state.selectedSectionId,
                    onSelect: (id) => context.read<TagsCubit>().selectSection(id),
                  ),

                // Thin divider below chips
                if (!state.isLoading && sections.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                  ),

                // Body
                Expanded(
                  child: state.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: scheme.primary,
                          ),
                        )
                      : state.errorMessage != null
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  'Không tải được danh sách tag. Vui lòng kiểm tra kết nối và thử lại.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                      : !hasAnyTags
                      ? Center(
                          child: Text(
                            'Chưa có tag.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: () => context.read<TagsCubit>().refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Active section tags
                          if (sections.isNotEmpty)
                            Builder(builder: (context) {
                              final panel = sections.firstWhere(
                                    (s) => s.id == state.selectedSectionId,
                                orElse: () => sections.first,
                              );
                              final sorted = [...panel.tags]
                                ..sort((a, b) {
                                  final c = b.storyCount.compareTo(a.storyCount);
                                  if (c != 0) return c;
                                  return a.name.compareTo(b.name);
                                });
                              return _TagSection2(
                                label: 'Tags trong nhóm',
                                tags: sorted,
                                colorOffset: 0,
                                onTapTag: _openSearchWithTag,
                              );
                            }),

                          // Ungrouped tags
                          if (ungroupedTags.isNotEmpty)
                            _TagSection2(
                              label: sections.isNotEmpty ? 'Không có nhóm' : 'Tất cả tag',
                              tags: ungroupedTags,
                              colorOffset: 2,
                              onTapTag: _openSearchWithTag,
                            ),
                        ],
                      ),
                    ),
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

// ---------------------------------------------------------------------------
// Group chip bar
// ---------------------------------------------------------------------------
class _GroupChipBar extends StatelessWidget {
  final List<TagSection> sections;
  final String? selectedId;
  final void Function(String) onSelect;

  const _GroupChipBar({
    required this.sections,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final section = sections[i];
          final selected = section.id == selectedId;
          return _GroupChip(
            label: section.title,
            selected: selected,
            onTap: () => onSelect(section.id),
            scheme: scheme,
          );
        },
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.55),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tag section (label + wrap grid)
// ---------------------------------------------------------------------------
class _TagSection2 extends StatelessWidget {
  final String label;
  final List<TagFilterEntity> tags;
  final int colorOffset;
  final void Function(TagFilterEntity) onTapTag;

  const _TagSection2({
    required this.label,
    required this.tags,
    required this.colorOffset,
    required this.onTapTag,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label — small uppercase
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.08 * 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < tags.length; i++)
                _TagPill(
                  label: '#${tags[i].name}',
                  color: _colorForIndex(context, i + colorOffset),
                  onTap: () => onTapTag(tags[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Colored tag pill
// ---------------------------------------------------------------------------
class _TagPill extends StatelessWidget {
  final String label;
  final _TagColor color;
  final VoidCallback onTap;

  const _TagPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: color.bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.border, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color.fg,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search box (unchanged logic, minor style tweak)
// ---------------------------------------------------------------------------
class _SearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 15, color: scheme.onSurface),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: 'Tìm theo tag...',
        hintStyle: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search_rounded, size: 22, color: scheme.onSurfaceVariant),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          onPressed: controller.clear,
          icon: Icon(Icons.close_rounded, size: 20, color: scheme.onSurfaceVariant),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.85), width: 1.5),
        ),
      ),
    );
  }
}

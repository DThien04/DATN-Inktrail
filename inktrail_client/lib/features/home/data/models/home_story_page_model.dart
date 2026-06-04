import 'package:ink_trail_client/features/home/data/models/home_story_summary_model.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_story_page_entity.dart';

class HomeStoryPageModel extends HomeStoryPageEntity {
  const HomeStoryPageModel({
    required super.items,
    required super.page,
    required super.limit,
    required super.hasMore,
    required super.nextPage,
  });

  factory HomeStoryPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? const {};
    return HomeStoryPageModel(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(HomeStorySummaryModel.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList(),
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      limit: (pagination['limit'] as num?)?.toInt() ?? 20,
      hasMore: pagination['has_more'] as bool? ?? false,
      nextPage: (pagination['next_page'] as num?)?.toInt(),
    );
  }
}

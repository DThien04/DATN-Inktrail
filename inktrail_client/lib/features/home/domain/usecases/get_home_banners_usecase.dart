import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';

class GetHomeBannersUsecase {
  final HomeRepository _repository;

  const GetHomeBannersUsecase(this._repository);

  Future<List<StoryEntity>> call() => _repository.getHomeBanners();
}

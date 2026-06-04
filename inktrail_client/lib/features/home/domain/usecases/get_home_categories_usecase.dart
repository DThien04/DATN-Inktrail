import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';

class GetHomeCategoriesUsecase {
  final HomeRepository _repository;

  const GetHomeCategoriesUsecase(this._repository);

  Future<List<String>> call() => _repository.getTagNames();
}

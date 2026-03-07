import '../entities/style_entity.dart';
import '../repositories/home_repository.dart';

class GetCachedStylesUseCase {
  final HomeRepository repository;

  GetCachedStylesUseCase(this.repository);

  Future<(List<StyleEntity>, List<StyleEntity>)?> call() {
    return repository.getCachedStyles();
  }
}

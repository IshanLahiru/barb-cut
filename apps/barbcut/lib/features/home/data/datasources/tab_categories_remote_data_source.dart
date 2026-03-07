import '../../domain/entities/tab_category_entity.dart';

abstract class TabCategoriesRemoteDataSource {
  Stream<List<TabCategoryEntity>> watchTabCategories();
}

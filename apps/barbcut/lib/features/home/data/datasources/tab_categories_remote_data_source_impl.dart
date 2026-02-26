import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/tab_category_entity.dart';
import 'tab_categories_remote_data_source.dart';

class TabCategoriesRemoteDataSourceImpl implements TabCategoriesRemoteDataSource {
  TabCategoriesRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<TabCategoryEntity>> watchTabCategories() {
    return _firestore
        .collection('tabCategories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return TabCategoryEntity(
                title: data['title']?.toString() ?? 'Tab',
                type: data['type']?.toString() ?? '',
              );
            })
            .toList());
  }
}

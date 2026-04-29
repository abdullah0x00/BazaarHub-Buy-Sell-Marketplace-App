import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> streamCategories() {
    return _db.collection('categories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection('categories').orderBy('order').get();
    return snapshot.docs.map((doc) => CategoryModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db.collection('categories').add(category.toJson());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection('categories').doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    // Also delete or orphan subcategories? For now, just delete.
    await _db.collection('categories').doc(id).delete();
  }
}

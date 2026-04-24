import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<ProductModel> _mockProducts = ProductModel.mockProducts();

  Future<List<ProductModel>> getProducts({String? category}) async {
    try {
      Query query = _db.collection('products').where('isActive', isEqualTo: true);
      
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty && (category == null || category == 'All')) {
        return _mockProducts.where((p) => !p.isFlashSale && p.rating < 4.8).toList();
      }
      
      return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    } catch (e) {
      return _mockProducts.where((p) => !p.isFlashSale && p.rating < 4.8).toList();
    }
  }

  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    final snapshot = await _db.collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .get();
    return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<List<ProductModel>> getFlashSaleProducts() async {
    final snapshot = await _db.collection('products')
        .where('isFlashSale', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .get();
    
    if (snapshot.docs.isEmpty) {
      return _mockProducts.where((p) => p.isFlashSale).toList();
    }
    return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<List<ProductModel>> getRecommendedProducts() async {
    final snapshot = await _db.collection('products')
        .where('rating', isGreaterThanOrEqualTo: 4.8)
        .where('isActive', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return _mockProducts.where((p) => p.rating >= 4.8).toList();
    }
    return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    
    // For real search in Firestore, usually we'd use Algolia/Elasticsearch
    // or fetch and filter client-side for small datasets.
    final snapshot = await _db.collection('products').get();
    final all = snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    
    final results = all.where((p) {
      return p.title.toLowerCase().contains(q) || 
             p.category.toLowerCase().contains(q) || 
             p.description.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
       return _mockProducts.where((p) => p.title.toLowerCase().contains(q)).toList();
    }
    return results;
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (doc.exists) return _productFromDoc(doc);
    
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<ProductModel> addProduct(ProductModel p) async {
    final docRef = _db.collection('products').doc();
    final newProduct = p.copyWith(id: docRef.id);
    await docRef.set(newProduct.toJson());
    return newProduct;
  }

  Future<ProductModel> updateProduct(ProductModel p) async {
    await _db.collection('products').doc(p.id).update(p.toJson());
    return p;
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Future<List<ReviewModel>> getProductReviews(String id) async => ReviewModel.mockReviews(id);

  ProductModel _productFromDoc(DocumentSnapshot doc) {
    return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<ProductModel> _mockProducts = ProductModel.mockProducts();

  /// Get all active products for buyers
  Future<List<ProductModel>> getProducts({String? category}) async {
    try {
      // 1. Get blocked sellers to filter them out
      final blockedSellersSnapshot = await _db.collection('users')
          .where('isBlocked', isEqualTo: true)
          .where('role', isEqualTo: 'seller')
          .get();
      final blockedSellerIds = blockedSellersSnapshot.docs.map((doc) => doc.id).toSet();

      // 2. Query only approved and active products
      Query query = _db.collection('products')
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: 'approved');
          
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      
      final snapshot = await query.get();
      List<ProductModel> realProducts = snapshot.docs
          .map((doc) => _productFromDoc(doc))
          .where((p) => !blockedSellerIds.contains(p.sellerId)) // Filter out products from blocked sellers
          .toList();

      List<ProductModel> filteredMocks = _mockProducts;
      if (category != null && category != 'All') {
        filteredMocks = _mockProducts.where((p) => p.category == category).toList();
      }

      final all = [...realProducts, ...filteredMocks];
      return all.where((p) => p.coverImage.isNotEmpty).toList();
    } catch (e) {
      List<ProductModel> filteredMocks = _mockProducts;
      if (category != null && category != 'All') {
        filteredMocks = _mockProducts.where((p) => p.category == category).toList();
      }
      return filteredMocks.where((p) => p.coverImage.isNotEmpty).toList();
    }
  }

  /// Get ALL products for Admin
  Future<List<ProductModel>> getAllProductsAdmin() async {
    try {
      final snapshot = await _db.collection('products').get();
      List<ProductModel> realProducts = snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
      
      // Combine with mocks for variety in demo, but usually admin only manages real ones
      return [...realProducts, ..._mockProducts];
    } catch (e) {
      return _mockProducts;
    }
  }

  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    try {
      final snapshot = await _db.collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getFlashSaleProducts() async {
    try {
      final snapshot = await _db.collection('products')
          .where('isFlashSale', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();
      
      List<ProductModel> real = snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
      List<ProductModel> mocks = _mockProducts.where((p) => p.isFlashSale).toList();
      
      final all = [...real, ...mocks];
      return all.where((p) => p.coverImage.isNotEmpty).toList();
    } catch (e) {
      return _mockProducts.where((p) => p.isFlashSale && p.coverImage.isNotEmpty).toList();
    }
  }

  Future<List<ProductModel>> getRecommendedProducts() async {
    try {
      final snapshot = await _db.collection('products')
          .where('rating', isGreaterThanOrEqualTo: 4.8)
          .where('isActive', isEqualTo: true)
          .get();

      List<ProductModel> real = snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
      List<ProductModel> mocks = _mockProducts.where((p) => p.rating >= 4.8).toList();
      
      final all = [...real, ...mocks];
      return all.where((p) => p.coverImage.isNotEmpty).toList();
    } catch (e) {
      return _mockProducts.where((p) => p.rating >= 4.8 && p.coverImage.isNotEmpty).toList();
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    
    final all = await getProducts();
    return all.where((p) {
      return p.title.toLowerCase().contains(q) || 
             p.category.toLowerCase().contains(q) || 
             p.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _db.collection('products').doc(id).get();
      if (doc.exists) return _productFromDoc(doc);
      
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    return getProducts();
  }

  Future<ProductModel> addProduct(ProductModel p) async {
    final docRef = _db.collection('products').doc();
    // New products are 'pending' by default when added by a seller
    final newProduct = p.copyWith(
      id: docRef.id,
      status: ProductStatus.pending,
    );
    await docRef.set(newProduct.toJson());
    
    // Add notification for Admin
    await _db.collection('notifications').add({
      'userId': 'admin', // Global admin notification
      'title': 'New Product Approval Request',
      'body': '${p.sellerName} added a new product: ${p.title}',
      'type': 'product_approval',
      'productId': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    
    return newProduct;
  }

  Future<void> updateProductStatus(String productId, ProductStatus status) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (doc.exists) {
      final product = _productFromDoc(doc);
      await _db.collection('products').doc(productId).update({'status': status.name});
      
      // Notify Seller
      await _db.collection('notifications').add({
        'userId': product.sellerId,
        'title': status == ProductStatus.approved ? 'Product Approved!' : 'Product Rejected',
        'body': 'Your product "${product.title}" has been ${status.name} by the admin.',
        'type': 'product_status',
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  Future<List<ProductModel>> getPendingProducts() async {
    final snapshot = await _db.collection('products')
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
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

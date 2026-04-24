import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<ProductModel> _allProducts = ProductModel.mockProducts();

  Future<List<ProductModel>> getProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (category == null || category.isEmpty || category == 'All') {
      // Return products that are NOT flash sale and NOT high-rated (recommended)
      // to avoid duplicates on the home screen sections.
      return _allProducts.where((p) => !p.isFlashSale && p.rating < 4.8).toList();
    }

    final target = category.trim().toLowerCase();
    return _allProducts.where((p) => p.category.toLowerCase() == target).toList();
  }

  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    return _allProducts.where((p) => p.sellerId == sellerId).toList();
  }

  Future<List<ProductModel>> getFlashSaleProducts() async {
    return _allProducts.where((p) => p.isFlashSale).toList();
  }

  Future<List<ProductModel>> getRecommendedProducts() async {
    // Only high rated items
    return _allProducts.where((p) => p.rating >= 4.8).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final q = query.toLowerCase();
    return _allProducts.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    return _allProducts;
  }

  // Dummy methods for compilation
  Future<ProductModel> addProduct(ProductModel p) async => p;
  Future<ProductModel> updateProduct(ProductModel p) async => p;
  Future<void> deleteProduct(String id) async {}
  Future<List<ReviewModel>> getProductReviews(String id) async => ReviewModel.mockReviews(id);
}

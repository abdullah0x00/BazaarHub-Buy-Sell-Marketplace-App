import '../models/product_model.dart';
import '../models/review_model.dart';

/// Simulated product service (replace with real API in production)
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // Initialize with a wider range of products directly
  final List<ProductModel> _products = ProductModel.mockProducts();

  Future<List<ProductModel>> getProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // If no category, return all active products for the home page
    if (category == null || category.isEmpty) {
      return _products.where((p) => p.isActive).toList();
    }

    final target = category.trim().toLowerCase();
    
    // Exact match or contains for categories
    return _products.where((p) {
      return p.isActive && (p.category.toLowerCase() == target || p.category.toLowerCase().contains(target));
    }).toList();
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get flash sale products
  Future<List<ProductModel>> getFlashSaleProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.isActive && p.isFlashSale).toList();
  }

  /// Get recommended products
  Future<List<ProductModel>> getRecommendedProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Products with high rating are recommended
    return _products.where((p) => p.isActive && p.rating >= 4.5).toList();
  }

  /// Get products by seller
  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.sellerId == sellerId).toList();
  }

  /// Search products by query
  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.isActive &&
              (p.title.toLowerCase().contains(q) ||
                  p.description.toLowerCase().contains(q) ||
                  p.category.toLowerCase().contains(q)),
        )
        .toList();
  }

  /// Add a new product
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _products.add(product);
    return product;
  }

  /// Update an existing product
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) _products[idx] = product;
    return product;
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _products.removeWhere((p) => p.id == productId);
  }

  /// Toggle product active status
  Future<void> toggleProductStatus(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(
        isActive: !_products[idx].isActive,
      );
    }
  }

  /// Get all products (admin)
  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products;
  }

  /// Get reviews for a product
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ReviewModel.mockReviews(productId);
  }
}

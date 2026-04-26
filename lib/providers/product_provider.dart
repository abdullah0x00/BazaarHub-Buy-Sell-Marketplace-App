import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// Product state management using Provider
class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _sellerProducts = [];
  List<ProductModel> _flashSale = [];
  List<ProductModel> _recommended = [];
  List<ProductModel> _searchResults = [];
  final List<String> _wishlist = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  List<ProductModel> get sellerProducts => _sellerProducts;
  List<ProductModel> get flashSale => _flashSale;
  List<ProductModel> get recommended => _recommended;
  List<ProductModel> get searchResults => _searchResults;
  List<String> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isWishlistEmpty => _wishlist.isEmpty;

  /// Load seller specific products
  Future<void> loadSellerProducts(String sellerId) async {
    _setLoading(true);
    try {
      _sellerProducts = await _service.getSellerProducts(sellerId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Load home page data
  Future<void> loadHomeData() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _service.getFlashSaleProducts(),
        _service.getRecommendedProducts(),
        _service.getProducts(),
      ]);
      _flashSale = results[0];
      _recommended = results[1];
      _products = results[2];
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Load products by category
  Future<void> loadByCategory(String category) async {
    _setLoading(true);
    try {
      _products = await _service.getProducts(category: category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Search products
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      _searchResults = await _service.searchProducts(query);
    } finally {
      _setLoading(false);
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    return _service.getProductById(id);
  }

  /// Toggle wishlist
  void toggleWishlist(String productId) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    notifyListeners();
  }

  bool isWishlisted(String productId) => _wishlist.contains(productId);

  /// Get wishlist products
  List<ProductModel> get wishlistProducts {
    return _products.where((p) => _wishlist.contains(p.id)).toList();
  }

  /// Add product (seller)
  Future<bool> addProduct(ProductModel product) async {
    try {
      final added = await _service.addProduct(product);
      _products.insert(0, added);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Update product (seller)
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final updated = await _service.updateProduct(product);
      final idx = _products.indexWhere((p) => p.id == updated.id);
      if (idx != -1) _products[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Delete product (seller/admin)
  Future<bool> deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

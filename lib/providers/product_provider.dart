import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/cloudinary_service.dart';
import '../services/home_service.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

/// Product state management using Provider
class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  final CloudinaryService _cloudinary = CloudinaryService();

  List<ProductModel> _products = [];
  List<ProductModel> _sellerProducts = [];
  List<ProductModel> _flashSale = [];
  List<ProductModel> _recommended = [];
  List<ProductModel> _searchResults = [];
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<String> _wishlist = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  List<ProductModel> get sellerProducts => _sellerProducts;
  List<ProductModel> get flashSale => _flashSale;
  List<ProductModel> get recommended => _recommended;
  List<ProductModel> get searchResults => _searchResults;
  List<BannerModel> get banners => _banners;
  List<CategoryModel> get categories => _categories;
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
        HomeService().getBanners(),
        HomeService().getCategories(),
      ]);
      _flashSale = results[0] as List<ProductModel>;
      _recommended = results[1] as List<ProductModel>;
      _products = results[2] as List<ProductModel>;
      _banners = results[3] as List<BannerModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Add product with Cloudinary images
  Future<bool> addProduct(ProductModel product, List<File> imageFiles) async {
    _setLoading(true);
    try {
      // 1. Upload to Cloudinary
      final urls = await _cloudinary.uploadMultipleImages(imageFiles);
      if (urls.isEmpty) throw Exception('Failed to upload images to Cloudinary');

      // 2. Save to Firestore
      final productWithImages = product.copyWith(images: urls);
      final added = await _service.addProduct(productWithImages);
      
      // Don't add to public _products yet, only seller's private list
      _sellerProducts.insert(0, added);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update product with optional new images
  Future<bool> updateProduct(ProductModel product, {List<File>? newImageFiles}) async {
    _setLoading(true);
    try {
      List<String> finalUrls = product.images;

      // If new images provided, upload them
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        final uploaded = await _cloudinary.uploadMultipleImages(newImageFiles);
        if (uploaded.isNotEmpty) finalUrls = uploaded;
      }

      final updatedProduct = product.copyWith(images: finalUrls);
      await _service.updateProduct(updatedProduct);
      
      // Update local state
      final idx = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (idx != -1) _products[idx] = updatedProduct;
      
      final sIdx = _sellerProducts.indexWhere((p) => p.id == updatedProduct.id);
      if (sIdx != -1) _sellerProducts[sIdx] = updatedProduct;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Other existing methods...
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

  Future<bool> deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _sellerProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> loadWishlist(String userId) async {
    try {
      _wishlist = await _service.getWishlist(userId);
      notifyListeners();
    } catch (e) {
      debugPrint("Wishlist Load Error: $e");
    }
  }

  void toggleWishlist(String productId, String? userId) async {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    notifyListeners();

    // Sync to Firestore if logged in
    if (userId != null) {
      await _service.updateWishlist(userId, _wishlist);
    }
  }

  bool isWishlisted(String productId) => _wishlist.contains(productId);

  /// Get wishlist products
  List<ProductModel> get wishlistProducts {
    return _products.where((p) => _wishlist.contains(p.id)).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

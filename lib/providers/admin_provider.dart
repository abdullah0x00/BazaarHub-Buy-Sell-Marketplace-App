import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import '../services/cloudinary_service.dart';
import '../services/log_service.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

/// Provider for admin-specific functionality
class AdminProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final LogService _logService = LogService();
  final CategoryService _categoryService = CategoryService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<UserModel> _pendingSellers = [];
  List<ProductModel> _pendingProducts = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<UserModel> get pendingSellers => _pendingSellers;
  List<ProductModel> get pendingProducts => _pendingProducts;
  List<CategoryModel> get categories => _categories;
  
  int get totalBuyers => _users.where((u) => u.role == UserRole.buyer).length;
  int get totalSellers => _users.where((u) => u.role == UserRole.seller).length;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all admin data
  Future<void> loadDashboardData() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _authService.getAllUsers(),
        _productService.getAllProductsAdmin(),
        _orderService.getAllOrders(),
        _authService.getPendingSellers(),
        _productService.getPendingProducts(),
        _categoryService.getCategories(),
      ]);

      _users = List<UserModel>.from(results[0] as Iterable);
      _products = List<ProductModel>.from(results[1] as Iterable);
      _orders = List<OrderModel>.from(results[2] as Iterable);
      _pendingSellers = List<UserModel>.from(results[3] as Iterable);
      _pendingProducts = List<ProductModel>.from(results[4] as Iterable);
      _categories = List<CategoryModel>.from(results[5] as Iterable);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Manage Users
  Future<bool> toggleUserBlock(String userId, {String? adminName, String? adminId}) async {
    try {
      await _authService.toggleBlockUser(userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final isBlocking = !_users[idx].isBlocked;
        _users[idx] = _users[idx].copyWith(isBlocked: isBlocking);
        
        await _logService.logEvent(
          action: isBlocking ? 'User Blocked' : 'User Unblocked',
          details: '${_users[idx].name} (${_users[idx].email}) was ${isBlocking ? 'blocked' : 'unblocked'}.',
          type: 'user',
          targetId: userId,
          adminId: adminId ?? 'system',
          adminName: adminName ?? 'System',
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> approveSeller(String userId, {String? adminName, String? adminId}) async {
    try {
      await _authService.approveSeller(userId);
      _pendingSellers.removeWhere((u) => u.id == userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isApprovedSeller: true);
        
        await _logService.logEvent(
          action: 'Seller Approved',
          details: 'Seller request for ${_users[idx].name} was approved.',
          type: 'user',
          targetId: userId,
          adminId: adminId ?? 'system',
          adminName: adminName ?? 'System',
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Manage Products
  Future<bool> addProduct(ProductModel product, List<File> imageFiles) async {
    _setLoading(true);
    try {
      // 1. Upload to Cloudinary
      final urls = await _cloudinaryService.uploadMultipleImages(imageFiles);
      if (urls.isEmpty) throw Exception('Image upload failed');

      // 2. Add to Firestore
      final newProduct = product.copyWith(images: urls);
      final added = await _productService.addProduct(newProduct);
      
      _products.insert(0, added);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProduct(ProductModel product, {List<File>? newImages}) async {
    _setLoading(true);
    try {
      List<String> finalUrls = product.images;

      // 1. If new images picked, upload them
      if (newImages != null && newImages.isNotEmpty) {
        final uploaded = await _cloudinaryService.uploadMultipleImages(newImages);
        if (uploaded.isNotEmpty) finalUrls = uploaded;
      }

      // 2. Update in Firestore
      final updated = product.copyWith(images: finalUrls);
      await _productService.updateProduct(updated);
      
      final idx = _products.indexWhere((p) => p.id == updated.id);
      if (idx != -1) _products[idx] = updated;
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _pendingProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> approveProduct(String productId, {String? adminName, String? adminId}) async {
    try {
      await _productService.updateProductStatus(productId, ProductStatus.approved);
      final prod = _pendingProducts.firstWhere((p) => p.id == productId, orElse: () => _products.firstWhere((p) => p.id == productId));
      
      _pendingProducts.removeWhere((p) => p.id == productId);
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(status: ProductStatus.approved);
      }

      await _logService.logEvent(
        action: 'Product Approved',
        details: 'Product "${prod.title}" by ${prod.sellerName} was approved.',
        type: 'product',
        targetId: productId,
        adminId: adminId ?? 'system',
        adminName: adminName ?? 'System',
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> rejectProduct(String productId, {String? adminName, String? adminId}) async {
    try {
      await _productService.updateProductStatus(productId, ProductStatus.rejected);
      final prod = _pendingProducts.firstWhere((p) => p.id == productId, orElse: () => _products.firstWhere((p) => p.id == productId));

      _pendingProducts.removeWhere((p) => p.id == productId);
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(status: ProductStatus.rejected);
      }

      await _logService.logEvent(
        action: 'Product Rejected',
        details: 'Product "${prod.title}" by ${prod.sellerName} was rejected.',
        type: 'product',
        targetId: productId,
        adminId: adminId ?? 'system',
        adminName: adminName ?? 'System',
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> updateAdminProfile(UserModel admin) async {
    try {
      await _authService.updateProfile(admin);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Manage Categories
  Future<bool> addCategory(CategoryModel category) async {
    try {
      await _categoryService.addCategory(category);
      await loadDashboardData();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _categoryService.updateCategory(category);
      await loadDashboardData();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      await loadDashboardData();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> seedDefaultCategories() async {
    if (_categories.isNotEmpty) return;
    
    final defaults = [
      {'name': 'Electronics', 'icon': '📱', 'subs': ['Mobile', 'Laptops', 'Accessories']},
      {'name': 'Fashion', 'icon': '👗', 'subs': ['Men', 'Women', 'Kids']},
      {'name': 'Home', 'icon': '🏠', 'subs': ['Furniture', 'Decor', 'Kitchen']},
      {'name': 'Pharmacy', 'icon': '💊', 'subs': ['Medicines', 'Personal Care', 'First Aid']},
    ];

    for (var i = 0; i < defaults.length; i++) {
      final main = defaults[i];
      final mainId = await _db.collection('categories').add({
        'name': main['name'],
        'icon': main['icon'],
        'order': i,
        'parentId': null,
      });

      final subs = main['subs'] as List<String>;
      for (var j = 0; j < subs.length; j++) {
        await _db.collection('categories').add({
          'name': subs[j],
          'icon': '🔹',
          'order': j,
          'parentId': mainId.id,
        });
      }
    }
    await loadDashboardData();
  }

  /// Manage Orders
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, status);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = updatedOrder;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<Map<String, dynamic>> getPlatformAnalytics() async {
    try {
      return await _orderService.getGlobalAnalytics();
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

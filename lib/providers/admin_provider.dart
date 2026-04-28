import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import '../services/cloudinary_service.dart';
import '../services/log_service.dart';

/// Provider for admin-specific functionality
class AdminProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final LogService _logService = LogService();

  List<UserModel> _users = [];
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<UserModel> _pendingSellers = [];
  List<ProductModel> _pendingProducts = [];

  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<UserModel> get pendingSellers => _pendingSellers;
  List<ProductModel> get pendingProducts => _pendingProducts;
  
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
      ]);

      _users = results[0] as List<UserModel>;
      _products = results[1] as List<ProductModel>;
      _orders = results[2] as List<OrderModel>;
      _pendingSellers = results[3] as List<UserModel>;
      _pendingProducts = results[4] as List<ProductModel>;

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

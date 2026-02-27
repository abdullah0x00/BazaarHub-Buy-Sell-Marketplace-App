import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';

/// Provider for admin-specific functionality
class AdminProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  List<UserModel> _users = [];
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<UserModel> _pendingSellers = [];

  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<UserModel> get pendingSellers => _pendingSellers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all admin data
  Future<void> loadDashboardData() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _authService.getAllUsers(),
        _productService.getAllProducts(),
        _orderService.getAllOrders(),
        _authService.getPendingSellers(),
      ]);

      _users = results[0] as List<UserModel>;
      _products = results[1] as List<ProductModel>;
      _orders = results[2] as List<OrderModel>;
      _pendingSellers = results[3] as List<UserModel>;

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle user block status
  Future<bool> toggleUserBlock(String userId) async {
    try {
      await _authService.toggleBlockUser(userId);
      // Update local state
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isBlocked: !_users[idx].isBlocked);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Approve seller application
  Future<bool> approveSeller(String userId) async {
    try {
      await _authService.approveSeller(userId);
      // Update local state
      _pendingSellers.removeWhere((u) => u.id == userId);

      // Update in main users list if present
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isApprovedSeller: true);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Delete product (Admin)
  Future<bool> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

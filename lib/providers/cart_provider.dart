import 'package:flutter/material.dart';
import '../models/product_model.dart';

/// Cart item wrapper
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

/// Cart state management using Provider
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // Getters
  Map<String, CartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  /// Total quantity of all items
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Subtotal before delivery fee
  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Delivery fee (free over PKR 5000)
  double get deliveryFee => subtotal >= 5000 ? 0.0 : 250.0;

  /// Grand total
  double get total => subtotal + deliveryFee;

  /// Check if product is in cart
  bool isInCart(String productId) => _items.containsKey(productId);

  /// Get quantity for a product
  int getQuantity(String productId) => _items[productId]?.quantity ?? 0;

  /// Add item to cart
  void addItem(ProductModel product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Already in cart, increase quantity
      final current = _items[product.id]!.quantity;
      final newQty = current + quantity;
      if (newQty > product.stock) return; // Don't exceed stock
      _items[product.id]!.quantity = newQty;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  /// Remove item from cart
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Increase item quantity
  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity < item.product.stock) {
        item.quantity++;
        notifyListeners();
      }
    }
  }

  /// Decrease item quantity
  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get cart as list
  List<CartItem> get cartList => _items.values.toList();

  /// Convert to order items format
  List<Map<String, dynamic>> toOrderItems() {
    return _items.values
        .map((item) => {
              'product': item.product,
              'quantity': item.quantity,
            })
        .toList();
  }
}

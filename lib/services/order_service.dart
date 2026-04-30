import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import 'notification_service.dart';
import 'product_service.dart';

/// Firebase Firestore order service
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// Place a new order to Firestore
  Future<OrderModel> placeOrder({
    required String buyerId,
    required String buyerName,
    required List<Map<String, dynamic>> cartItems,
    required String paymentMethod,
    required String shippingAddress,
    required double deliveryFee,
  }) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Your cart is empty');
      }

      double subtotal = 0;
      final Set<String> sellerIdsSet = {};
      
      final items = cartItems.map((item) {
        final product = item['product'] as ProductModel;
        final quantity = item['quantity'] as int;
        subtotal += product.price * quantity;
        sellerIdsSet.add(product.sellerId);
        
        return OrderItem(
          productId: product.id,
          productTitle: product.title,
          productImage: product.coverImage,
          price: product.price,
          quantity: quantity,
          sellerId: product.sellerId,
          sellerName: product.sellerName,
        );
      }).toList();

      final docRef = _db.collection('orders').doc();
      
      // Calculate Platform Fee (e.g., 3%)
      final platformFee = subtotal * 0.03;

      final order = OrderModel(
        id: docRef.id,
        buyerId: buyerId,
        buyerName: buyerName,
        items: items,
        sellerIds: sellerIdsSet.toList(),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
        total: subtotal + deliveryFee + platformFee,
        status: OrderStatus.pending,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      );

      // --- STOCK UPDATE LOGIC ---
      // Use a batch to update both the order and product stock atomically
      final batch = _db.batch();
      
      // 1. Add the order
      batch.set(docRef, order.toJson());
      
      // 2. Decrement stock only for real Firestore products.
      // Demo/mock products do not have documents, and batch.update fails
      // with not-found when the target document is missing.
      for (var item in cartItems) {
        final product = item['product'] as ProductModel;
        final qty = item['quantity'] as int;
        
        final productRef = _db.collection('products').doc(product.id);
        final productDoc = await productRef.get();
        if (productDoc.exists) {
          batch.update(productRef, {
            'stock': FieldValue.increment(-qty),
          });
        }
      }

      await batch.commit();
      await _tryCreateOrderPlacedNotifications(order);
      return order;
    } catch (e) {
      debugPrint("Place Order Error: $e");
      rethrow;
    }
  }

  /// Get buyer orders from Firestore
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    try {
      debugPrint("Fetching orders for buyer: $buyerId");
      final snapshot = await _db.collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();
          
      return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint("Get Buyer Orders Error: $e");
      // If index is missing, it will print a URL in the console. 
      // Falling back to un-ordered query to show data at least.
      try {
        final snapshot = await _db.collection('orders')
            .where('buyerId', isEqualTo: buyerId)
            .get();
        final orders = snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      } catch (e2) {
        debugPrint("Fallback Get Buyer Orders Error: $e2");
        return [];
      }
    }
  }

  /// Get seller orders from Firestore
  Future<List<OrderModel>> getSellerOrders(String sellerId) async {
    try {
      debugPrint("Fetching orders for seller: $sellerId");
      final orders = await _getSellerOrdersById(sellerId, ordered: true);
      final demoOrders = sellerId == ProductService.demoSellerId
          ? <OrderModel>[]
          : await _getSellerOrdersById(ProductService.demoSellerId, ordered: true);

      return _mergeAndSortOrders([...orders, ...demoOrders]);
    } catch (e) {
      debugPrint("Get Seller Orders Error: $e");
      try {
        final orders = await _getSellerOrdersById(sellerId, ordered: false);
        final demoOrders = sellerId == ProductService.demoSellerId
            ? <OrderModel>[]
            : await _getSellerOrdersById(ProductService.demoSellerId, ordered: false);

        return _mergeAndSortOrders([...orders, ...demoOrders]);
      } catch (e2) {
        debugPrint("Fallback Get Seller Orders Error: $e2");
        return [];
      }
    }
  }

  Future<List<OrderModel>> _getSellerOrdersById(String sellerId, {required bool ordered}) async {
    Query<Map<String, dynamic>> query = _db
        .collection('orders')
        .where('sellerIds', arrayContains: sellerId);

    if (ordered) {
      query = query.orderBy('createdAt', descending: true);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
  }

  List<OrderModel> _mergeAndSortOrders(List<OrderModel> orders) {
    final byId = <String, OrderModel>{};
    for (final order in orders) {
      byId[order.id] = order;
    }

    final merged = byId.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  /// Get all orders (admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _db.collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
          
      return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint("Get All Orders Error: $e");
      final snapshot = await _db.collection('orders').get();
      final orders = snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    }
  }

  /// Update order status in Firestore
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
    });
    
    final doc = await _db.collection('orders').doc(orderId).get();
    final order = OrderModel.fromJson(doc.data()!);
    await _tryCreateOrderStatusNotification(order);
    return order;
  }

  Future<void> _tryCreateOrderPlacedNotifications(OrderModel order) async {
    try {
      final orderLabel = _shortOrderId(order.id);
      await _notificationService.createNotification(
        userId: order.buyerId,
        title: 'Order placed',
        body: 'Your order #$orderLabel is pending confirmation.',
        type: 'order_pending',
        orderId: order.id,
        productId: order.items.isNotEmpty ? order.items.first.productId : null,
      );

      for (final sellerId in order.sellerIds.toSet()) {
        await _notificationService.createNotification(
          userId: sellerId,
          title: 'New order received',
          body: '${order.buyerName} placed order #$orderLabel.',
          type: 'order',
          orderId: order.id,
          productId: order.items.firstWhere(
            (item) => item.sellerId == sellerId,
            orElse: () => order.items.first,
          ).productId,
        );
      }
    } catch (e) {
      debugPrint('Create order notifications error: $e');
    }
  }

  Future<void> _tryCreateOrderStatusNotification(OrderModel order) async {
    try {
      final orderLabel = _shortOrderId(order.id);
      await _notificationService.createNotification(
        userId: order.buyerId,
        title: 'Order ${order.statusLabel}',
        body: 'Your order #$orderLabel is now ${order.statusLabel.toLowerCase()}.',
        type: 'order_${order.status.name}',
        orderId: order.id,
        productId: order.items.isNotEmpty ? order.items.first.productId : null,
      );
    } catch (e) {
      debugPrint('Create order status notification error: $e');
    }
  }

  String _shortOrderId(String orderId) {
    if (orderId.length <= 8) return orderId;
    return orderId.substring(0, 8).toUpperCase();
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Seller analytics data from Firestore (Real dynamic data)
  Future<Map<String, dynamic>> getSellerAnalytics(String sellerId) async {
    final sellerOrders = await getSellerOrders(sellerId);

    double totalRevenue = 0;
    int totalItemsSold = 0;

    // Data for charts
    Map<String, double> monthlyRevenue = {};
    Map<String, int> monthlyOrders = {};

    final List<String> last6Months = [];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i * 30));
      final monthKey = _monthName(date.month);
      last6Months.add(monthKey);
      monthlyRevenue[monthKey] = 0;
      monthlyOrders[monthKey] = 0;
    }

    for (final order in sellerOrders) {
      final monthKey = _monthName(order.createdAt.month);
      
      bool isMyOrder = false;
      for (final item in order.items) {
        if (item.sellerId == sellerId) {
          totalRevenue += item.subtotal;
          totalItemsSold += item.quantity;
          
          if (monthlyRevenue.containsKey(monthKey)) {
            monthlyRevenue[monthKey] = monthlyRevenue[monthKey]! + item.subtotal;
          }
          isMyOrder = true;
        }
      }
      
      if (isMyOrder && monthlyOrders.containsKey(monthKey)) {
        monthlyOrders[monthKey] = monthlyOrders[monthKey]! + 1;
      }
    }

    final List<Map<String, dynamic>> monthlyData = last6Months.map((m) {
      return {
        'month': m,
        'revenue': monthlyRevenue[m],
        'orders': monthlyOrders[m],
      };
    }).toList();

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': sellerOrders.length,
      'totalItemsSold': totalItemsSold,
      'pendingOrders': sellerOrders.where((o) => o.status == OrderStatus.pending).length,
      'monthlyData': monthlyData,
    };
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  /// Global platform analytics for Admin
  Future<Map<String, dynamic>> getGlobalAnalytics() async {
    final allOrders = await getAllOrders();
    
    double totalRevenue = 0;
    double totalPlatformFee = 0;
    int totalItemsSold = 0;
    Map<String, double> monthlyRevenue = {};

    final List<String> last6Months = [];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i * 30));
      final monthKey = _monthName(date.month);
      last6Months.add(monthKey);
      monthlyRevenue[monthKey] = 0;
    }

    for (final order in allOrders) {
      if (order.status == OrderStatus.cancelled) continue;
      
      totalRevenue += order.total;
      totalPlatformFee += order.platformFee;
      final monthKey = _monthName(order.createdAt.month);
      
      if (monthlyRevenue.containsKey(monthKey)) {
        monthlyRevenue[monthKey] = monthlyRevenue[monthKey]! + order.total;
      }

      for (final item in order.items) {
        totalItemsSold += item.quantity;
      }
    }

    final List<Map<String, dynamic>> monthlyData = last6Months.map((m) {
      return {
        'month': m,
        'revenue': monthlyRevenue[m],
      };
    }).toList();

    return {
      'totalRevenue': totalRevenue,
      'totalPlatformFee': totalPlatformFee,
      'totalOrders': allOrders.length,
      'totalItemsSold': totalItemsSold,
      'activeOrders': allOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length,
      'monthlyData': monthlyData,
    };
  }
}

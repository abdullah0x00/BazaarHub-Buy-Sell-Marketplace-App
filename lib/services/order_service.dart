import '../models/order_model.dart';
import '../models/product_model.dart';

/// Simulated order service
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<OrderModel> _orders = OrderModel.mockOrders();

  /// Place a new order
  Future<OrderModel> placeOrder({
    required String buyerId,
    required String buyerName,
    required List<Map<String, dynamic>> cartItems,
    required String paymentMethod,
    required String shippingAddress,
    required double deliveryFee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    double subtotal = 0;
    final items = cartItems.map((item) {
      final product = item['product'] as ProductModel;
      final quantity = item['quantity'] as int;
      subtotal += product.price * quantity;
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

    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      buyerId: buyerId,
      buyerName: buyerName,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      status: OrderStatus.pending,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
    );

    _orders.add(order);
    return order;
  }

  /// Get buyer orders
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders.where((o) => o.buyerId == buyerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get seller orders
  Future<List<OrderModel>> getSellerOrders(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders
        .where((o) => o.items.any((item) => item.sellerId == sellerId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get all orders (admin)
  Future<List<OrderModel>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Update order status
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: status);
      return _orders[idx];
    }
    throw Exception('Order not found');
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Seller analytics data
  Future<Map<String, dynamic>> getSellerAnalytics(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sellerOrders = await getSellerOrders(sellerId);

    double totalRevenue = 0;
    int totalItemsSold = 0;

    for (final order in sellerOrders) {
      for (final item in order.items) {
        if (item.sellerId == sellerId) {
          totalRevenue += item.subtotal;
          totalItemsSold += item.quantity;
        }
      }
    }

    // Monthly revenue data for chart
    final List<Map<String, dynamic>> monthlyData = List.generate(6, (i) {
      final month = DateTime.now().subtract(Duration(days: (5 - i) * 30));
      return {
        'month': _monthName(month.month),
        'revenue': (i + 1) * 25000.0 + (i * 5000),
        'orders': (i + 1) * 5 + i,
      };
    });

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': sellerOrders.length,
      'totalItemsSold': totalItemsSold,
      'pendingOrders':
          sellerOrders
              .where((o) => o.status == OrderStatus.pending)
              .length,
      'monthlyData': monthlyData,
    };
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

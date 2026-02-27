/// Order model representing a purchase transaction
library;

class OrderItem {
  final String productId;
  final String productTitle;
  final String productImage;
  final double price;
  final int quantity;
  final String sellerId;
  final String sellerName;

  const OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productTitle': productTitle,
        'productImage': productImage,
        'price': price,
        'quantity': quantity,
        'sellerId': sellerId,
        'sellerName': sellerName,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] ?? '',
        productTitle: json['productTitle'] ?? '',
        productImage: json['productImage'] ?? '',
        price: (json['price'] ?? 0.0).toDouble(),
        quantity: json['quantity'] ?? 1,
        sellerId: json['sellerId'] ?? '',
        sellerName: json['sellerName'] ?? '',
      );
}

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String paymentMethod;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
    this.estimatedDelivery,
    this.trackingNumber,
  });

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? trackingNumber,
    DateTime? estimatedDelivery,
  }) {
    return OrderModel(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      createdAt: createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  /// Generate mock orders for demo
  static List<OrderModel> mockOrders() {
    return [
      OrderModel(
        id: 'ORD-001',
        buyerId: 'buyer_1',
        buyerName: 'Sara Ali',
        items: [
          const OrderItem(
            productId: 'p1',
            productTitle: 'iPhone 15 Pro Max 256GB',
            productImage:
                'https://images.unsplash.com/photo-1696446702183-be8f5b85a397?w=400',
            price: 299999,
            quantity: 1,
            sellerId: 'seller_1',
            sellerName: 'Ahmed\'s Tech Store',
          ),
        ],
        subtotal: 299999,
        deliveryFee: 0,
        total: 299999,
        status: OrderStatus.delivered,
        paymentMethod: 'Credit Card',
        shippingAddress: 'House 12, Street 5, DHA Phase 2, Lahore',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        estimatedDelivery: DateTime.now().subtract(const Duration(days: 10)),
        trackingNumber: 'TCS-12345678',
      ),
      OrderModel(
        id: 'ORD-002',
        buyerId: 'buyer_1',
        buyerName: 'Sara Ali',
        items: [
          const OrderItem(
            productId: 'p3',
            productTitle: 'Nike Air Max 270 React',
            productImage:
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
            price: 18999,
            quantity: 2,
            sellerId: 'seller_1',
            sellerName: 'Ahmed\'s Tech Store',
          ),
        ],
        subtotal: 37998,
        deliveryFee: 200,
        total: 38198,
        status: OrderStatus.shipped,
        paymentMethod: 'Cash on Delivery',
        shippingAddress: 'House 12, Street 5, DHA Phase 2, Lahore',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
        trackingNumber: 'TCS-87654321',
      ),
      OrderModel(
        id: 'ORD-003',
        buyerId: 'buyer_1',
        buyerName: 'Sara Ali',
        items: [
          const OrderItem(
            productId: 'p4',
            productTitle: 'Sony WH-1000XM5 Headphones',
            productImage:
                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
            price: 54999,
            quantity: 1,
            sellerId: 'seller_1',
            sellerName: 'Ahmed\'s Tech Store',
          ),
        ],
        subtotal: 54999,
        deliveryFee: 0,
        total: 54999,
        status: OrderStatus.confirmed,
        paymentMethod: 'JazzCash',
        shippingAddress: 'House 12, Street 5, DHA Phase 2, Lahore',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      ),
      OrderModel(
        id: 'ORD-004',
        buyerId: 'buyer_2',
        buyerName: 'Zeeshan Malik',
        items: [
          const OrderItem(
            productId: 'v1',
            productTitle: 'Honda Civic RS 2024',
            productImage:
                'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=400',
            price: 9500000,
            quantity: 1,
            sellerId: 'seller_3',
            sellerName: 'Bilal Premium Wheels',
          ),
        ],
        subtotal: 9500000,
        deliveryFee: 5000,
        total: 9505000,
        status: OrderStatus.pending,
        paymentMethod: 'Bank Transfer',
        shippingAddress: 'Gulberg III, Lahore',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      OrderModel(
        id: 'ORD-005',
        buyerId: 'buyer_3',
        buyerName: 'Ayesha Khan',
        items: [
          const OrderItem(
            productId: 'f1',
            productTitle: 'Zinger Burger Pro Max',
            productImage:
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
            price: 850,
            quantity: 3,
            sellerId: 'seller_2',
            sellerName: 'Green Farm Organics',
          ),
        ],
        subtotal: 2550,
        deliveryFee: 150,
        total: 2700,
        status: OrderStatus.pending,
        paymentMethod: 'Cash on Delivery',
        shippingAddress: 'Johar Town, Lahore',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

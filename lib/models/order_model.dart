/// Order model representing a purchase transaction
library;

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> sellerIds; // Added for easier Firestore querying
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
    required this.sellerIds,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'buyerId': buyerId,
    'buyerName': buyerName,
    'items': items.map((i) => i.toJson()).toList(),
    'sellerIds': sellerIds,
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status.name,
    'paymentMethod': paymentMethod,
    'shippingAddress': shippingAddress,
    'createdAt': createdAt.toIso8601String(),
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'trackingNumber': trackingNumber,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
      sellerIds: List<String>.from(json['sellerIds'] ?? []),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => OrderStatus.pending),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      shippingAddress: json['shippingAddress'] ?? '',
      createdAt: parseDate(json['createdAt']),
      estimatedDelivery: json['estimatedDelivery'] != null ? parseDate(json['estimatedDelivery']) : null,
      trackingNumber: json['trackingNumber'],
    );
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
      sellerIds: sellerIds,
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

  static List<OrderModel> mockOrders() => [];
}

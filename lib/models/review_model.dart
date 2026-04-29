import 'package:cloud_firestore/cloud_firestore.dart';

/// Review & Rating model for products
class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final int helpfulCount;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    this.helpfulCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'images': images,
        'createdAt': createdAt.toIso8601String(),
        'helpfulCount': helpfulCount,
      };

  factory ReviewModel.fromJson(Map<String, dynamic> json, [String? id]) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ReviewModel(
      id: id ?? json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt: parseDate(json['createdAt']),
      helpfulCount: json['helpfulCount'] ?? 0,
    );
  }

  /// Mock reviews for demo
  static List<ReviewModel> mockReviews(String productId) {
    return [
      ReviewModel(
        id: 'r1',
        productId: productId,
        userId: 'buyer_2',
        userName: 'Muhammad Usman',
        rating: 5.0,
        comment:
            'Absolutely amazing product! Exactly as described, fast delivery, and packed very well. Highly recommend this seller!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        helpfulCount: 23,
      ),
      ReviewModel(
        id: 'r2',
        productId: productId,
        userId: 'buyer_3',
        userName: 'Fatima Malik',
        rating: 4.5,
        comment:
            'Great quality product. Minor packaging issue but the product itself is perfect. Will buy again.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        helpfulCount: 15,
      ),
      ReviewModel(
        id: 'r3',
        productId: productId,
        userId: 'buyer_4',
        userName: 'Ali Hassan',
        rating: 4.0,
        comment:
            'Good value for money. Delivery was a bit slow but product quality is excellent.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        helpfulCount: 8,
      ),
    ];
  }
}

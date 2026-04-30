import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? productId;
  final String? orderId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.productId,
    this.orderId,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      productId: json['productId'],
      orderId: json['orderId'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? productId,
    String? orderId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'productId': productId,
      'orderId': orderId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<List<NotificationModel>> getNotifications(String userId) async* {
    if (userId.isEmpty) {
      yield [];
      return;
    }

    // Try the optimized query with ordering first (requires Firestore composite index)
    try {
      yield* _db.collection('notifications')
          .where('userId', whereIn: [userId, 'admin'])
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      debugPrint('Primary notification query failed (missing index?), using fallback: $e');

      // Fallback: Query without orderBy and sort on client side
      // This doesn't require a composite index
      yield* _db.collection('notifications')
          .where('userId', whereIn: [userId, 'admin'])
          .snapshots()
          .map((snapshot) {
        final notifications = snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
            .toList();
        // Sort on client side
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return notifications;
      });
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _db.collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

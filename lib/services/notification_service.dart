import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? productId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.productId,
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
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getNotifications(String userId) {
    // Both specific userId and 'admin' notifications if user is admin
    return _db.collection('notifications')
        .where('userId', whereIn: [userId, 'admin'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
            .toList());
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

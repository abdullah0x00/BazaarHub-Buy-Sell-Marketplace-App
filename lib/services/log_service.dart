import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SystemLogModel {
  final String id;
  final String action;
  final String details;
  final String adminId;
  final String adminName;
  final String targetId;
  final DateTime timestamp;
  final String type; // 'user', 'product', 'order', 'auth'

  SystemLogModel({
    required this.id,
    required this.action,
    required this.details,
    required this.adminId,
    required this.adminName,
    required this.targetId,
    required this.timestamp,
    required this.type,
  });

  factory SystemLogModel.fromJson(Map<String, dynamic> json, String id) {
    return SystemLogModel(
      id: id,
      action: json['action'] ?? '',
      details: json['details'] ?? '',
      adminId: json['adminId'] ?? 'system',
      adminName: json['adminName'] ?? 'System',
      targetId: json['targetId'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: json['type'] ?? 'info',
    );
  }
}

class LogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> logEvent({
    required String action,
    required String details,
    String adminId = 'system',
    String adminName = 'System',
    String targetId = '',
    required String type,
  }) async {
    try {
      await _db.collection('system_logs').add({
        'action': action,
        'details': details,
        'adminId': adminId,
        'adminName': adminName,
        'targetId': targetId,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Logging Error: $e");
    }
  }

  Stream<List<SystemLogModel>> getSystemLogs() {
    return _db.collection('system_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SystemLogModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}

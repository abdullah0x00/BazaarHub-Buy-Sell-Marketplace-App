import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Follow a seller
  Future<void> followSeller(String userId, String sellerId) async {
    final batch = _db.batch();
    
    // 1. Add to user's following list
    final userFollowRef = _db.collection('users').doc(userId).collection('following').doc(sellerId);
    batch.set(userFollowRef, {
      'sellerId': sellerId,
      'followedAt': FieldValue.serverTimestamp(),
    });

    // 2. Add to seller's followers list
    final sellerFollowerRef = _db.collection('users').doc(sellerId).collection('followers').doc(userId);
    batch.set(sellerFollowerRef, {
      'userId': userId,
      'followedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Unfollow a seller
  Future<void> unfollowSeller(String userId, String sellerId) async {
    final batch = _db.batch();
    
    final userFollowRef = _db.collection('users').doc(userId).collection('following').doc(sellerId);
    batch.delete(userFollowRef);

    final sellerFollowerRef = _db.collection('users').doc(sellerId).collection('followers').doc(userId);
    batch.delete(sellerFollowerRef);

    await batch.commit();
  }

  /// Check if following
  Future<bool> isFollowing(String userId, String sellerId) async {
    final doc = await _db.collection('users').doc(userId).collection('following').doc(sellerId).get();
    return doc.exists;
  }

  /// Get all followers of a seller (to send notifications)
  Future<List<String>> getSellerFollowers(String sellerId) async {
    final snapshot = await _db.collection('users').doc(sellerId).collection('followers').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}

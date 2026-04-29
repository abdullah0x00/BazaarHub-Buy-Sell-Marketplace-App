import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> syncCart(String userId, List<Map<String, dynamic>> items) async {
    final cartData = items.map((item) => {
      'productId': (item['product'] as ProductModel).id,
      'quantity': item['quantity'],
    }).toList();

    await _db.collection('carts').doc(userId).set({
      'items': cartData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final doc = await _db.collection('carts').doc(userId).get();
    if (doc.exists) {
      return List<Map<String, dynamic>>.from(doc.data()?['items'] ?? []);
    }
    return [];
  }
}

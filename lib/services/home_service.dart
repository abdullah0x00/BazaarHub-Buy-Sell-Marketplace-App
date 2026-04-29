import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetQuery;
  final String type; // 'category', 'product', 'search'

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetQuery,
    required this.type,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json, String id) {
    return BannerModel(
      id: id,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      targetQuery: json['targetQuery'] ?? '',
      type: json['type'] ?? 'search',
    );
  }
}

class HomeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BannerModel>> getBanners() async {
    try {
      final snapshot = await _db.collection('banners').get();
      return snapshot.docs.map((doc) => BannerModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, String>>> getCategories() async {
    try {
      final snapshot = await _db.collection('categories').orderBy('order').get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name']?.toString() ?? '',
          'icon': data['icon']?.toString() ?? '📦',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

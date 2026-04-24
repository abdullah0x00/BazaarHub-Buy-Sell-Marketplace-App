library;

import 'package:flutter/foundation.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final bool isFlashSale;
  final DateTime createdAt;
  final Map<String, String>? specifications;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isFlashSale = false,
    required this.createdAt,
    this.specifications,
  });

  bool get inStock => stock > 0;
  
  double? get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
    }
    return null;
  }

  String get coverImage {
    if (images.isNotEmpty && images.first.isNotEmpty) {
      return images.first;
    }
    // Final safety fallback with unique seed
    return 'https://picsum.photos/seed/$id/500/500';
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    List<String>? images,
    String? category,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isActive,
    bool? isFlashSale,
    DateTime? createdAt,
    Map<String, String>? specifications,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      images: images ?? this.images,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      createdAt: createdAt ?? this.createdAt,
      specifications: specifications ?? this.specifications,
    );
  }

  static List<ProductModel> mockProducts() {
    List<ProductModel> products = [];
    
    // 1. High-Quality Unique Image Mapping
    final Map<String, String> itemImages = {
      // Electronics
      'iPhone 15 Pro': 'https://images.unsplash.com/photo-1696446702183-be8f5b85a397?w=500&fit=crop',
      'MacBook Air M2': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&fit=crop',
      'Sony Wireless Headphones': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&fit=crop',
      'Samsung Galaxy S23': 'https://images.unsplash.com/photo-1678911820864-e2c567c655d7?w=500&fit=crop',
      'Smart Watch Series 8': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&fit=crop',
      'Gaming Mouse RGB': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500&fit=crop',
      'Mechanical Keyboard': 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500&fit=crop',
      '4K LED Monitor': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500&fit=crop',
      'Power Bank 20000mAh': 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=500&fit=crop',
      'HD Web Camera': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500&fit=crop',

      // Fashion
      'Summer Floral Dress': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=500&fit=crop',
      'Men Casual T-Shirt': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500&fit=crop',
      'Slim Fit Denim Jeans': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500&fit=crop',
      'Leather Wallet Black': 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500&fit=crop',
      'Canvas Sneakers White': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500&fit=crop',
      'Winter Woolen Scarf': 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=500&fit=crop',
      'Designer Sunglasses': 'https://images.unsplash.com/photo-1511499767390-903390e6fbc1?w=500&fit=crop',
      'Classic Wrist Watch': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&fit=crop',
      'Leather Handbag': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&fit=crop',
      'Formal Office Shoes': 'https://images.unsplash.com/photo-1533279150534-a9ec71a0633b?w=500&fit=crop',

      // Home & Living
      'Scented Soy Candle': 'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=500&fit=crop',
      'Modern Table Lamp': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500&fit=crop',
      'Memory Foam Pillow': 'https://images.unsplash.com/photo-1520206111952-5ad74c60f4d7?w=500&fit=crop',
      'Cotton Bed Sheet Set': 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500&fit=crop',
      'Silent Wall Clock': 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=500&fit=crop',
      'Ceramic Indoor Plant Pot': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500&fit=crop',
      'Non-stick Frying Pan': 'https://images.unsplash.com/photo-1584990333911-5ed0ad9c7e9d?w=500&fit=crop',
      'Floral Shower Curtain': 'https://images.unsplash.com/photo-1600585154340-be6199f7a096?w=500&fit=crop',
      'Velvet Throw Blanket': 'https://images.unsplash.com/photo-1515155075601-23009d0cb6d4?w=500&fit=crop',
      'Kitchen Knife Set': 'https://images.unsplash.com/photo-1593618998160-e34014e67546?w=500&fit=crop',

      // Sports
      'Yoga Mat Anti-slip': 'https://images.unsplash.com/photo-1544111823-46037dd3c178?w=500&fit=crop',
      'Dumbbells Set 5kg': 'https://images.unsplash.com/photo-1583454110551-21f2fa2ec617?w=500&fit=crop',
      'Basketball Official Size': 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=500&fit=crop',
      'Football Premium': 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=500&fit=crop',
      'Badminton Racket Pro': 'https://images.unsplash.com/photo-1617083270725-6743ff76ffcc?w=500&fit=crop',
      'Sports Gym Bag': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&fit=crop',
      'Water Bottle Stainless Steel': 'https://images.unsplash.com/photo-1602143303412-f195816da396?w=500&fit=crop',
      'Skipping Rope Speed': 'https://images.unsplash.com/photo-1552346154-21d328109a27?w=500&fit=crop',
      'Resistance Bands Set': 'https://images.unsplash.com/photo-1598266663336-0371994cca3f?w=500&fit=crop',
      'Tennis Ball Pack': 'https://images.unsplash.com/photo-1592709823125-a1914b953a47?w=500&fit=crop',

      // Beauty
      'Matte Lipstick Red': 'https://images.unsplash.com/photo-1586776977607-310e9c725c37?w=500&fit=crop',
      'Moisturizing Face Cream': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&fit=crop',
      'Organic Face Mask': 'https://images.unsplash.com/photo-1596462502278-27bfaf43e218?w=500&fit=crop',
      'Perfume Eau De Toilette': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=500&fit=crop',
      'Makeup Brush Set': 'https://images.unsplash.com/photo-1522338255047-105573740a3c?w=500&fit=crop',
      'Hair Serum Silk': 'https://images.unsplash.com/photo-1537367667648-52e4b444ba07?w=500&fit=crop',
      'Sunscreen SPF 50': 'https://images.unsplash.com/photo-1556229167-da31d93933c0?w=500&fit=crop',
      'Eye Liner Waterproof': 'https://images.unsplash.com/photo-1597223557154-721c1cecc4b0?w=500&fit=crop',
      'Nail Polish Pastel': 'https://images.unsplash.com/photo-1604902396830-aca29e19b067?w=500&fit=crop',
      'Bath Bomb Lavender': 'https://images.unsplash.com/photo-1547043736-b2247cb34b01?w=500&fit=crop',

      // Books
      'Mystery Thriller Novel': 'https://images.unsplash.com/photo-1544947950-fac0720738f7?w=500&fit=crop',
      'Sci-Fi Adventure Book': 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?w=500&fit=crop',
      'Modern Poetry Collection': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&fit=crop',
      'Business Success Guide': 'https://images.unsplash.com/photo-1507842217343-583f20270319?w=500&fit=crop',
      'Healthy Cooking Recipes': 'https://images.unsplash.com/photo-1543002588-d83cea6bea2b?w=500&fit=crop',
      'Historical Biography': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=500&fit=crop',
      'Kids Bedtime Stories': 'https://images.unsplash.com/photo-1497633762265-9d1792697a61?w=500&fit=crop',
      'Self Help Masterclass': 'https://images.unsplash.com/photo-1544947950-fac0720738f7?w=500&fit=crop',
      'World Atlas 2024': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&fit=crop',
      'Classic Literature Set': 'https://images.unsplash.com/photo-1507842217343-583f20270319?w=500&fit=crop',

      // Toys
      'Building Blocks Set': 'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?w=500&fit=crop',
      'Remote Control Racing Car': 'https://images.unsplash.com/photo-1596461404482-4efe4bb17886?w=500&fit=crop',
      'Stuffed Teddy Bear': 'https://images.unsplash.com/photo-1558060302-3c4ef497fb05?w=500&fit=crop',
      '1000 Piece Puzzle': 'https://images.unsplash.com/photo-1566576721346-d4a3b4ea30df?w=500&fit=crop',
      'Wooden Doll House': 'https://images.unsplash.com/photo-1566119114618-c71b4916b46e?w=500&fit=crop',
      'Action Figure Hero': 'https://images.unsplash.com/photo-1535572290543-8e0c4039865e?w=500&fit=crop',
      'Strategy Board Game': 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=500&fit=crop',
      'DIY Slime Kit': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&fit=crop',
      'Toy Musical Keyboard': 'https://images.unsplash.com/photo-1596461404482-4efe4bb17886?w=500&fit=crop',
      'Art and Craft Set': 'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?w=500&fit=crop',

      // Vehicles
      'Mountain Bike Pro': 'https://images.unsplash.com/photo-1532298229144-0ee0c9e9ad58?w=500&fit=crop',
      'Electric Scooter X': 'https://images.unsplash.com/photo-1558981403-c5f91cbba527?w=500&fit=crop',
      'Kids Tricycle Red': 'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=500&fit=crop',
      'Folding Bicycle Blue': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500&fit=crop',
      'Adult Commuter Scooter': 'https://images.unsplash.com/photo-1605348086202-0e9805988b16?w=500&fit=crop',
      'BMX Freestyle Bike': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500&fit=crop',
      'City Hybrid Bicycle': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500&fit=crop',
      'Maple Wood Skateboard': 'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=500&fit=crop',
      'Motorcycle Helmet': 'https://images.unsplash.com/photo-1558981403-c5f91cbba527?w=500&fit=crop',
      'Adjustable Elbow Pads': 'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=500&fit=crop',

      // Food
      'Pure Organic Honey': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&fit=crop',
      'Premium Basmati Rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&fit=crop',
      'Refreshing Green Tea': 'https://images.unsplash.com/photo-1564890369478-c89fe6d9c339?w=500&fit=crop',
      'Roasted Salted Cashews': 'https://images.unsplash.com/photo-1536628522851-1b7463ce97c1?w=500&fit=crop',
      'Extra Virgin Olive Oil': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&fit=crop',
      'Dark Artisan Chocolate': 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=500&fit=crop',
      'Fresh Roasted Coffee': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&fit=crop',
      'Healthy Fruit Granola': 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500&fit=crop',
      'Natural Almond Butter': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&fit=crop',
      'Fresh Seasonal Fruit': 'https://images.unsplash.com/photo-1523348830708-15d4a09cfac2?w=500&fit=crop',
      
      // Others
      'Gift Wrapping Box': 'https://images.unsplash.com/photo-1549465220-1d8c9ded9d4e?w=500&fit=crop',
      'Storage Organizer Bin': 'https://images.unsplash.com/photo-1591192850383-7d7a39e9b1d7?w=500&fit=crop',
      'Multi-purpose Desk Pad': 'https://images.unsplash.com/photo-1518455027359-f3f81390e188?w=500&fit=crop',
      'Adjustable Laptop Stand': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&fit=crop',
      'Travel Neck Pillow': 'https://images.unsplash.com/photo-1520116468816-95b69f847357?w=500&fit=crop',
      'Universal Cable Clips': 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500&fit=crop',
      'Portable Mini Fan': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500&fit=crop',
      'Key Finder Bluetooth': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&fit=crop',
      'Reusable Grocery Bag': 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=500&fit=crop',
      'Digital Luggage Scale': 'https://images.unsplash.com/photo-1591192850383-7d7a39e9b1d7?w=500&fit=crop',
    };

    final categoryData = {
      'Electronics': [
        'iPhone 15 Pro', 'MacBook Air M2', 'Sony Wireless Headphones', 'Samsung Galaxy S23', 
        'Smart Watch Series 8', 'Gaming Mouse RGB', 'Mechanical Keyboard', '4K LED Monitor', 
        'Power Bank 20000mAh', 'HD Web Camera'
      ],
      'Fashion': [
        'Summer Floral Dress', 'Men Casual T-Shirt', 'Slim Fit Denim Jeans', 'Leather Wallet Black', 
        'Canvas Sneakers White', 'Winter Woolen Scarf', 'Designer Sunglasses', 'Classic Wrist Watch', 
        'Leather Handbag', 'Formal Office Shoes'
      ],
      'Home & Living': [
        'Scented Soy Candle', 'Modern Table Lamp', 'Memory Foam Pillow', 'Cotton Bed Sheet Set', 
        'Silent Wall Clock', 'Ceramic Indoor Plant Pot', 'Non-stick Frying Pan', 'Floral Shower Curtain', 
        'Velvet Throw Blanket', 'Kitchen Knife Set'
      ],
      'Sports': [
        'Yoga Mat Anti-slip', 'Dumbbells Set 5kg', 'Basketball Official Size', 'Football Premium', 
        'Badminton Racket Pro', 'Sports Gym Bag', 'Water Bottle Stainless Steel', 'Skipping Rope Speed', 
        'Resistance Bands Set', 'Tennis Ball Pack'
      ],
      'Beauty': [
        'Matte Lipstick Red', 'Moisturizing Face Cream', 'Organic Face Mask', 'Perfume Eau De Toilette', 
        'Makeup Brush Set', 'Hair Serum Silk', 'Sunscreen SPF 50', 'Waterproof Eye Liner', 
        'Nail Polish Pastel', 'Aromatic Bath Bomb'
      ],
      'Books': [
        'Mystery Thriller Novel', 'Sci-Fi Adventure Book', 'Modern Poetry Collection', 'Business Success Guide', 
        'Healthy Cooking Recipes', 'Historical Biography', 'Kids Bedtime Stories', 'Self Help Masterclass', 
        'World Atlas 2024', 'Classic Literature Set'
      ],
      'Toys': [
        'Building Blocks Set', 'Remote Control Racing Car', 'Stuffed Teddy Bear', '1000 Piece Puzzle', 
        'Wooden Doll House', 'Action Figure Hero', 'Strategy Board Game', 'DIY Slime Kit', 
        'Toy Musical Keyboard', 'Art and Craft Set'
      ],
      'Vehicles': [
        'Mountain Bike Pro', 'Electric Scooter X', 'Kids Tricycle Red', 'Folding Bicycle Blue', 
        'Adult Commuter Scooter', 'BMX Freestyle Bike', 'City Hybrid Bicycle', 'Maple Wood Skateboard', 
        'Motorcycle Helmet', 'Adjustable Elbow Pads'
      ],
      'Food': [
        'Pure Organic Honey', 'Premium Basmati Rice', 'Refreshing Green Tea', 'Roasted Salted Cashews', 
        'Extra Virgin Olive Oil', 'Dark Artisan Chocolate', 'Fresh Roasted Coffee', 'Healthy Fruit Granola', 
        'Natural Almond Butter', 'Fresh Seasonal Fruit'
      ],
      'Others': [
        'Gift Wrapping Box', 'Storage Organizer Bin', 'Multi-purpose Desk Pad', 'Adjustable Laptop Stand', 
        'Travel Neck Pillow', 'Universal Cable Clips', 'Portable Mini Fan', 'Key Finder Bluetooth', 
        'Reusable Grocery Bag', 'Digital Luggage Scale'
      ],
    };

    categoryData.forEach((category, items) {
      for (int i = 0; i < items.length; i++) {
        final name = items[i];
        final uniqueId = 'prod_${category.toLowerCase().replaceAll(' ', '_')}_$i';
        
        final imageUrl = itemImages[name.trim()] ?? 'https://picsum.photos/seed/$uniqueId/500/500';
        
        if (kDebugMode) {
          if (!itemImages.containsKey(name.trim())) {
            print("WARNING: No exact image map found for '$name'. Using fallback.");
          } else {
            print("Mapped: $name -> $imageUrl");
          }
        }

        products.add(ProductModel(
          id: uniqueId,
          sellerId: 's1',
          sellerName: 'BazaarHub Official',
          title: name,
          description: 'High-quality $name designed for durability and performance. A top-rated product in the $category category.',
          price: (450 + (i * 200)).toDouble(),
          originalPrice: (750 + (i * 200)).toDouble(),
          images: [imageUrl],
          category: category,
          stock: 30 + (i * 2),
          rating: i < 3 ? 4.9 : (i < 6 ? 4.8 : 4.5), 
          isFlashSale: i < 3,
          createdAt: DateTime.now().subtract(Duration(days: i)),
        ));
      }
    });
    return products;
  }
}

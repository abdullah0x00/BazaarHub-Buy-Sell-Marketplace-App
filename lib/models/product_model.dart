/// Product model for marketplace listings
library;

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String description;
  final double price;
  final double? originalPrice; // For discount display
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

  /// Calculate discount percentage
  double? get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
    }
    return null;
  }

  /// Get first image or placeholder
  String get coverImage {
    if (images.isNotEmpty && images.first.startsWith('http')) return images.first;
    return 'https://images.unsplash.com/photo-1560393464-5c69a73c5770?w=400'; // High-quality default placeholder
  }

  /// Is product in stock
  bool get inStock => stock > 0;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'isFlashSale': isFlashSale,
      'createdAt': createdAt.toIso8601String(),
      'specifications': specifications,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      isFlashSale: json['isFlashSale'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'])
          : null,
    );
  }

  /// Generate mock products for demo
  static List<ProductModel> mockProducts() {
    List<ProductModel> products = [];

    // Categories to populate
    final categories = [
      'Electronics',
      'Fashion',
      'Home & Living',
      'Sports',
      'Beauty',
      'Books',
      'Toys',
      'Vehicles',
      'Food'
    ];

    for (var category in categories) {
      List<String> items = [];
      String seller = 'BazaarHub Global';
      double basePrice = 500.0;

      if (category == 'Food') {
        items = ['Organic Honey', 'Premium Basmati Rice', 'Organic Green Tea', 'Roasted Cashews', 'Pure Olive Oil', 'Dark Chocolate Bar', 'Gourmet Coffee Beans', 'Healthy Granola Mix', 'Natural Almond Butter', 'Fresh Fruit Basket'];
        seller = 'Fresh Mart';
        basePrice = 150.0;
      } else if (category == 'Vehicles') {
        items = ['Mountain Bike Pro', 'Electric Scooter X', 'Kids Tricycle', 'Folding Bicycle', 'Adult Commuter Scooter', 'Balance Bike for Kids', 'BMX Freestyle Bike', 'Hybrid City Bike', 'Skateboard Maple Wood', 'Protective Gear Set'];
        seller = 'Auto & Gear';
        basePrice = 2000.0;
      } else if (category == 'Electronics') {
        items = ['Wireless Earbuds', 'Smartphone Z Cloud', 'Smart Watch Series 5', 'Bluetooth Speaker', 'Gaming Mouse RGB', 'Mechanical Keyboard', 'Laptop Stand Aluminum', 'Power Bank 20000mAh', 'HD Web Camera', 'Noise Canceling Headphones'];
        basePrice = 1200.0;
      } else if (category == 'Fashion') {
        items = ['Cotton Slim Fit T-shirt', 'Denim Jacket Classic', 'Canvas Sneakers', 'Leather Wallet', 'Summer Floral Dress', 'Running Shorts', 'Knitted Winter Scarf', 'Polarized Sunglasses', 'Formal Leather Belt', 'Graphic Print Hoodie'];
        basePrice = 800.0;
      } else if (category == 'Home & Living') {
        items = ['Scented Soy Candle', 'Ceramic Table Lamp', 'Memory Foam Pillow', 'Cotton Bed Sheet Set', 'Wall Clock Modern', 'Indoor Plant Pot', 'Non-stick Frying Pan', 'Shower Curtain Floral', 'Velvet Throw Blanket', 'Kitchen Knife Set'];
        basePrice = 600.0;
      } else if (category == 'Sports') {
        items = ['Yoga Mat Anti-slip', 'Dumbbell Set 5kg', 'Basketball Official Size', 'Badminton Racket', 'Resistance Bands Set', 'Skipping Rope Pro', 'Sports Water Bottle', 'Gym Duffel Bag', 'Tennis Ball Pack', 'Football Champions League'];
        basePrice = 400.0;
      } else if (category == 'Beauty') {
        items = ['Matte Lipstick Red', 'Moisturizing Cream', 'Organic Face Mask', 'Perfume Eau De Toilette', 'Makeup Brush Set', 'Hair Serum Silk', 'Sunscreen SPF 50', 'Eye Liner Waterproof', 'Nail Polish Pastel', 'Bath Bomb Lavender'];
        basePrice = 300.0;
      } else if (category == 'Books') {
        items = ['The Great Mystery Novel', 'Modern Poetry Collection', 'Business Success Guide', 'Healthy Cooking Recipes', 'Historical Biography', 'Science Fiction Saga', 'Children\'s Bedtime Stories', 'Self-Help Masterclass', 'World Atlas 2024', 'Classic Literature Set'];
        basePrice = 250.0;
      } else if (category == 'Toys') {
        items = ['Building Blocks Set', 'Remote Control Car', 'Stuffed Teddy Bear', 'Puzzle 1000 Pieces', 'Dolls House Wooden', 'Action Figure Hero', 'Board Game Strategy', 'Slime Kit DIY', 'Musical Toy Keyboard', 'Art and Craft Set'];
        basePrice = 450.0;
      }

      for (int i = 0; i < items.length; i++) {
        products.add(
          ProductModel(
            id: '${category.toLowerCase().replaceAll(' ', '_')}_${i + 1}',
            sellerId: 'seller_${category.toLowerCase().substring(0, 3)}',
            sellerName: seller,
            title: items[i],
            description: 'Experience the best quality with our ${items[i]}. Perfectly designed for your needs and durably built to last.',
            price: (basePrice + (i * 100)).toDouble(),
            originalPrice: (basePrice + 200 + (i * 100)).toDouble(),
            images: [_getMockImage(category, i + 1)],
            category: category,
            stock: 20 + i,
            rating: 4.0 + (i % 5) / 5,
            reviewCount: 15 + (i * 10),
            isFlashSale: i % 4 == 0,
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );
      }
    }
    return products;
  }

  static String _getMockImage(String category, int index) {
    final Map<String, List<String>> categoryImages = {
      'Electronics': [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&q=80&w=400',
      ],
      'Fashion': [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1595777707802-51ca6f37b7d5?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&q=80&w=400',
      ],
      'Home & Living': [
        'https://images.unsplash.com/photo-1491554895235-0ac8ac844b3b?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1503387762519-52582b8b29b7?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1578500494198-246f612d03b3?auto=format&fit=crop&q=80&w=400',
      ],
      'Sports': [
        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1535743686920-55e06d675b0a?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1552346154-ff0a9b0d596d?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1449505278894-297fdb3edbc1?auto=format&fit=crop&q=80&w=400',
      ],
      'Beauty': [
        'https://images.unsplash.com/photo-1596462502278-27bfaf43e218?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1512207736139-c814b5c51c28?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1597318972826-6a3dc29c0eaa?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&q=80&w=400',
      ],
      'Books': [
        'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1507842217343-583f20270319?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1543002588-d83cea6bea2b?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&q=80&w=400',
      ],
      'Toys': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1596461404482-4efe4bb17886?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1595777707802-51ca6f37b7d5?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1566119114618-c71b4916b46e?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1566576721346-d4a3b4ea30df?auto=format&fit=crop&q=80&w=400',
      ],
      'Vehicles': [
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1558981403-c5f91cbba527?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1493238541991-81827fa6a0fa?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?auto=format&fit=crop&q=80&w=400',
      ],
      'Food': [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1567622646695-4655f4633775?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1476224203421-9ac3993c4c9b?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=400',
      ],
    };

    final List<String> urls = categoryImages[category] ?? [
      'https://images.unsplash.com/photo-1560393464-5c69a73c5770?auto=format&fit=crop&q=80&w=400'
    ];
    return urls[index % urls.length];
  }
}

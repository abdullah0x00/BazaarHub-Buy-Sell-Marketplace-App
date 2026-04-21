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
      'Electronics': ['1498417399914-77a67f2c0da3', '1511707171634-5f897ff02aa9', '1523275319445-537f13904940', '1505740420928-5e560c06d30e', '1527443224154-c4a3942d3acf'],
      'Fashion': ['1445204450373-1971cc097364', '1556906781-9a079e000490', '1539106642014-14838703080c', '1467043237213-65f2da53396f', '1523293182036-711dad1faff7'],
      'Home & Living': ['1484101402968-3d11defcd53c', '1586023492125-27b2c045efd7', '1513519245088-0e12902e5a38', '1556911227-8a17d43ef7f2', '1583847268964-b28dc2f51ac9'],
      'Sports': ['1517836357463-d25dfeac3438', '1534438327276-14e5300c3a48', '1544111823-46037dd3c178', '1461896836934-ffe607ba8211', '1517649763962-0c623066013b'],
      'Beauty': ['1594465919561-3a0553754e81', '1512496015851-a90fb38ba796', '1522335789203-aabd1fc54bc9', '1596462502278-27bfaf43e218', '1571781926291-c477ebfd024b'],
      'Books': ['1495446815901-a7297e633e8d', '1544947950-fac0720738f7', '1512820790803-83ca734da794', '1497633762265-9d1792697a61', '1521587760476-6c12a4b040da'],
      'Toys': ['1515488764276-beab7607c1e6', '1558060302-3c4ef497fb05', '1535572290543-8e0c4039865e', '1566576721346-d4a3b4ea30df', '1596461404482-4efe4bb17886'],
      'Vehicles': ['1494976388531-d1058494cdd8', '1503376780353-7e6692767b70', '1533473359331-0135ef1b58bf', '1558981403-c5f91cbba527', '1493238541991-81827fa6a0fa'],
      'Food': ['1504674900247-0877df9cc836', '1476224203421-9ac3993c4c9b', '1473093226795-af9932fe5856', '1567622646695-4655f4633775', '1565299624946-b28f40a0ae38'],
    };

    final List<String> ids = categoryImages[category] ?? ['1555066931-4365d14bab8c'];
    final String photoId = ids[index % ids.length];
    return 'https://images.unsplash.com/photo-$photoId?auto=format&fit=crop&q=80&w=400';
  }
}

library;

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
    return '';
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
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null ? (json['originalPrice'] as num).toDouble() : null,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? 'Others',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      isFlashSale: json['isFlashSale'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      specifications: json['specifications'] != null ? Map<String, String>.from(json['specifications']) : null,
    );
  }

  static List<ProductModel> mockProducts() {
    List<ProductModel> products = [];
    
    final Map<String, String> itemImages = {
      // Electronics
      'iPhone 15 Pro': 'https://images.unsplash.com/photo-1696446702183-be8f5b85a397?w=500&fit=crop',
      'MacBook Air M2': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&fit=crop',
      'Sony Headphones': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&fit=crop',
      'Samsung S23 Ultra': 'https://images.unsplash.com/photo-1678911820864-e2c567c655d7?w=500&fit=crop',
      'Apple Watch Series 9': 'https://images.unsplash.com/photo-1544117518-2b462fefbd1a?w=500&fit=crop',
      'Gaming Mouse RGB': 'https://images.unsplash.com/photo-1527814050087-379381547944?w=500&fit=crop',
      'Mechanical Keyboard': 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500&fit=crop',
      '4K LED Monitor': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500&fit=crop',
      'DSLR Camera Pro': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500&fit=crop',
      'Portable Speaker': 'https://images.unsplash.com/photo-1608156639585-34054e815958?w=500&fit=crop',

      // Fashion
      'Red Silk Dress': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=500&fit=crop',
      'Casual White T-Shirt': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500&fit=crop',
      'Blue Denim Jeans': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500&fit=crop',
      'Black Leather Jacket': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&fit=crop',
      'Sporty Running Shoes': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&fit=crop',
      'Grey Cotton Hoodie': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&fit=crop',
      'Premium Men Blazer': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500&fit=crop',
      'Leather Women Handbag': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&fit=crop',
      'Winter Woolen Scarf': 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=500&fit=crop',
      'RayBan Sunglasses': 'https://images.unsplash.com/photo-1511499767390-903390e6fbc1?w=500&fit=crop',

      // Home & Living
      'Lavender Scented Candle': 'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=500&fit=crop',
      'Modern Desk Lamp': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500&fit=crop',
      'Orthopedic Memory Pillow': 'https://images.unsplash.com/photo-1520206111952-5ad74c60f4d7?w=500&fit=crop',
      'White Ceramic Mug': 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=500&fit=crop',
      'Green Succulent Plant': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500&fit=crop',
      'Wooden Wall Clock': 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=500&fit=crop',
      'Luxury Curtain Set': 'https://images.unsplash.com/photo-1600585154340-be6199f7a096?w=500&fit=crop',
      'Non-stick Frying Pan': 'https://images.unsplash.com/photo-1584990333911-5ed0ad9c7e9d?w=500&fit=crop',
      'Soft Velvet Throw Blanket': 'https://images.unsplash.com/photo-1515155075601-23009d0cb6d4?w=500&fit=crop',
      'Professional Knife Set': 'https://images.unsplash.com/photo-1593618998160-e34014e67546?w=500&fit=crop',

      // Sports
      'Eco-friendly Yoga Mat': 'https://images.unsplash.com/photo-1544111823-46037dd3c178?w=500&fit=crop',
      'Iron Dumbbells 10kg': 'https://images.unsplash.com/photo-1583454110551-21f2fa2ec617?w=500&fit=crop',
      'Wilson Basketball': 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=500&fit=crop',
      'Professional Tennis Racket': 'https://images.unsplash.com/photo-1592709823125-a1914b953a47?w=500&fit=crop',
      'Adidas Football': 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=500&fit=crop',
      'Badminton Racket Set': 'https://images.unsplash.com/photo-1617083270725-6743ff76ffcc?w=500&fit=crop',
      'Speed Skipping Rope': 'https://images.unsplash.com/photo-1552346154-21d328109a27?w=500&fit=crop',
      'Steel Water Bottle': 'https://images.unsplash.com/photo-1602143303412-f195816da396?w=500&fit=crop',
      'Large Gym Duffle Bag': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&fit=crop',
      'Heavy Resistance Band': 'https://images.unsplash.com/photo-1598266663336-0371994cca3f?w=500&fit=crop',

      // Beauty
      'Classic Red Lipstick': 'https://images.unsplash.com/photo-1586776977607-310e9c725c37?w=500&fit=crop',
      'Hydrating Face Cream': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&fit=crop',
      'Aloe Vera Face Mask': 'https://images.unsplash.com/photo-1596462502278-27bfaf43e218?w=500&fit=crop',
      'Professional Makeup Brushes': 'https://images.unsplash.com/photo-1522338255047-105573740a3c?w=500&fit=crop',
      'Organic Essential Oil': 'https://images.unsplash.com/photo-1602928321679-560bb453f190?w=500&fit=crop',
      'Pastel Nail Polish': 'https://images.unsplash.com/photo-1604902396830-aca29e19b067?w=500&fit=crop',
      'Waterproof Eye Liner': 'https://images.unsplash.com/photo-1597223557154-721c1cecc4b0?w=500&fit=crop',
      'Sunscreen SPF 50': 'https://images.unsplash.com/photo-1556229167-da31d93933c0?w=500&fit=crop',
      'Silk Hair Serum': 'https://images.unsplash.com/photo-1537367667648-52e4b444ba07?w=500&fit=crop',
      'Premium French Perfume': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=500&fit=crop',

      // Books
      'Thriller Mystery Novel': 'https://images.unsplash.com/photo-1544947950-fac0720738f7?w=500&fit=crop',
      'Hardcover Sci-Fi Book': 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?w=500&fit=crop',
      'Healthy Recipe Book': 'https://images.unsplash.com/photo-1543002588-d83cea6bea2b?w=500&fit=crop',
      'World History Book': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=500&fit=crop',
      'Kids Bedtime Stories': 'https://images.unsplash.com/photo-1497633762265-9d1792697a61?w=500&fit=crop',
      'Famous Person Biography': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=500&fit=crop',
      'Poetry Collection': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&fit=crop',
      'Self Help Best Seller': 'https://images.unsplash.com/photo-1544947950-fac0720738f7?w=500&fit=crop',
      'World Atlas 2024': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&fit=crop',
      'Classic Literature Set': 'https://images.unsplash.com/photo-1507842217343-583f20270319?w=500&fit=crop',

      // Toys
      'Colorful Building Blocks': 'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?w=500&fit=crop',
      'Remote Control Car': 'https://images.unsplash.com/photo-1596461404482-4efe4bb17886?w=500&fit=crop',
      'Soft Stuffed Teddy Bear': 'https://images.unsplash.com/photo-1558060302-3c4ef497fb05?w=500&fit=crop',
      '1000 Piece Jigsaw Puzzle': 'https://images.unsplash.com/photo-1566576721346-d4a3b4ea30df?w=500&fit=crop',
      'Wooden Toy Kitchen': 'https://images.unsplash.com/photo-1566119114618-c71b4916b46e?w=500&fit=crop',
      'Super Hero Action Figure': 'https://images.unsplash.com/photo-1535572290543-8e0c4039865e?w=500&fit=crop',
      'Monopoly Board Game': 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=500&fit=crop',
      'DIY Colorful Slime Kit': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&fit=crop',
      'Toy Musical Keyboard': 'https://images.unsplash.com/photo-1596461404482-4efe4bb17886?w=500&fit=crop',
      'Kids Art and Craft Set': 'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?w=500&fit=crop',

      // Vehicles
      'Fast Electric Scooter': 'https://images.unsplash.com/photo-1558981403-c5f91cbba527?w=500&fit=crop',
      '21 Speed Mountain Bike': 'https://images.unsplash.com/photo-1532298229144-0ee0c9e9ad58?w=500&fit=crop',
      'Portable Folding Cycle': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500&fit=crop',
      'Pro Maple Skateboard': 'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=500&fit=crop',
      'Safety Motorcycle Helmet': 'https://images.unsplash.com/photo-1558981403-c5f91cbba527?w=500&fit=crop',
      'Protective Elbow Pads': 'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=500&fit=crop',
      'Lightweight City Cycle': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500&fit=crop',
      'Kids Red Tricycle': 'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=500&fit=crop',
      'Stunt Freestyle BMX': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500&fit=crop',
      'Foldable Adult Scooter': 'https://images.unsplash.com/photo-1605348086202-0e9805988b16?w=500&fit=crop',

      // Food
      'Pure Organic Honey': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&fit=crop',
      'Extra Long Basmati Rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&fit=crop',
      'Freshly Roasted Coffee': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&fit=crop',
      'Organic Green Tea': 'https://images.unsplash.com/photo-1564890369478-c89fe6d9c339?w=500&fit=crop',
      'Roasted Salted Almonds': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&fit=crop',
      'Dark Artisan Chocolate': 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=500&fit=crop',
      'Extra Virgin Olive Oil': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&fit=crop',
      'Healthy Fruit Granola': 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500&fit=crop',
      'Natural Creamy Butter': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&fit=crop',
      'Fresh Seasonal Mangoes': 'https://images.unsplash.com/photo-1523348830708-15d4a09cfac2?w=500&fit=crop',

      // Others
      'Decorative Gift Box': 'https://images.unsplash.com/photo-1549465220-1d8c9ded9d4e?w=500&fit=crop',
      'Plastic Storage Bin': 'https://images.unsplash.com/photo-1591192850383-7d7a39e9b1d7?w=500&fit=crop',
      'Desk Calendar 2024': 'https://images.unsplash.com/photo-1518455027359-f3f81390e188?w=500&fit=crop',
      'Insulated Metal Bottle': 'https://images.unsplash.com/photo-1602143303412-f195816da396?w=500&fit=crop',
      'Foam Travel Neck Pillow': 'https://images.unsplash.com/photo-1520116468816-95b69f847357?w=500&fit=crop',
      'Adhesive Cable Clips': 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500&fit=crop',
      'USB Portable Mini Fan': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500&fit=crop',
      'Wireless Key Finder': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&fit=crop',
      'Eco Reusable Grocery Bag': 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=500&fit=crop',
      'Compact Luggage Scale': 'https://images.unsplash.com/photo-1591192850383-7d7a39e9b1d7?w=500&fit=crop',
    };

    final categoryData = {
      'Electronics': ['iPhone 15 Pro', 'MacBook Air M2', 'Sony Headphones', 'Samsung S23 Ultra', 'Apple Watch Series 9', 'Gaming Mouse RGB', 'Mechanical Keyboard', '4K LED Monitor', 'DSLR Camera Pro', 'Portable Speaker'],
      'Fashion': ['Red Silk Dress', 'Casual White T-Shirt', 'Blue Denim Jeans', 'Black Leather Jacket', 'Sporty Running Shoes', 'Grey Cotton Hoodie', 'Premium Men Blazer', 'Leather Women Handbag', 'Winter Woolen Scarf', 'RayBan Sunglasses'],
      'Home & Living': ['Lavender Scented Candle', 'Modern Desk Lamp', 'Orthopedic Memory Pillow', 'White Ceramic Mug', 'Green Succulent Plant', 'Wooden Wall Clock', 'Luxury Curtain Set', 'Non-stick Frying Pan', 'Soft Velvet Throw Blanket', 'Professional Knife Set'],
      'Sports': ['Eco-friendly Yoga Mat', 'Iron Dumbbells 10kg', 'Wilson Basketball', 'Professional Tennis Racket', 'Adidas Football', 'Badminton Racket Set', 'Speed Skipping Rope', 'Steel Water Bottle', 'Large Gym Duffle Bag', 'Heavy Resistance Band'],
      'Beauty': ['Classic Red Lipstick', 'Hydrating Face Cream', 'Aloe Vera Face Mask', 'Professional Makeup Brushes', 'Organic Essential Oil', 'Pastel Nail Polish', 'Waterproof Eye Liner', 'Sunscreen SPF 50', 'Silk Hair Serum', 'Premium French Perfume'],
      'Books': ['Thriller Mystery Novel', 'Hardcover Sci-Fi Book', 'Healthy Recipe Book', 'World History Book', 'Kids Bedtime Stories', 'Famous Person Biography', 'Poetry Collection', 'Self Help Best Seller', 'World Atlas 2024', 'Classic Literature Set'],
      'Toys': ['Colorful Building Blocks', 'Remote Control Car', 'Soft Stuffed Teddy Bear', '1000 Piece Jigsaw Puzzle', 'Wooden Toy Kitchen', 'Super Hero Action Figure', 'Monopoly Board Game', 'DIY Colorful Slime Kit', 'Toy Musical Keyboard', 'Kids Art and Craft Set'],
      'Vehicles': ['Fast Electric Scooter', '21 Speed Mountain Bike', 'Portable Folding Cycle', 'Pro Maple Skateboard', 'Safety Motorcycle Helmet', 'Protective Elbow Pads', 'Lightweight City Cycle', 'Kids Red Tricycle', 'Stunt Freestyle BMX', 'Foldable Adult Scooter'],
      'Food': ['Pure Organic Honey', 'Extra Long Basmati Rice', 'Freshly Roasted Coffee', 'Organic Green Tea', 'Roasted Salted Almonds', 'Dark Artisan Chocolate', 'Extra Virgin Olive Oil', 'Healthy Fruit Granola', 'Natural Creamy Butter', 'Fresh Seasonal Mangoes'],
      'Others': ['Decorative Gift Box', 'Plastic Storage Bin', 'Desk Calendar 2024', 'Insulated Metal Bottle', 'Foam Travel Neck Pillow', 'Adhesive Cable Clips', 'USB Portable Mini Fan', 'Wireless Key Finder', 'Eco Reusable Grocery Bag', 'Compact Luggage Scale'],
    };

    categoryData.forEach((category, items) {
      for (int i = 0; i < items.length; i++) {
        final name = items[i];
        final uniqueId = 'prod_${category.toLowerCase().replaceAll(' ', '_')}_$i';
        final imageUrl = itemImages[name] ?? '';

        if (imageUrl.isNotEmpty) {
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
      }
    });
    return products;
  }
}

import '../models/product_model.dart';
import '../models/review_model.dart';

/// Simulated product service (replace with real API in production)
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<ProductModel> _products = [
    // 10 Distinct Food Products
    ProductModel(
      id: 'food_p1',
      sellerId: 's1',
      sellerName: 'Fresh Mart',
      title: 'Premium Basmati Rice',
      description:
          'Long grain aromatic basmati rice, perfect for biryani and pulao.',
      price: 450,
      originalPrice: 550,
      images: [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 100,
      rating: 4.8,
      reviewCount: 320,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p2',
      sellerId: 's1',
      sellerName: 'Fresh Mart',
      title: 'Organic Wild Honey',
      description: '100% pure and natural honey collected from wild flowers.',
      price: 850,
      originalPrice: 1100,
      images: [
        'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 45,
      rating: 4.9,
      reviewCount: 156,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p3',
      sellerId: 's2',
      sellerName: 'Daily Bake',
      title: 'Whole Wheat Bread',
      description:
          'Freshly baked healthy whole wheat bread with no preservatives.',
      price: 120,
      originalPrice: 150,
      images: [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 30,
      rating: 4.4,
      reviewCount: 89,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p4',
      sellerId: 's2',
      sellerName: 'Daily Bake',
      title: 'Double Choc Cookies',
      description: 'Rich chocolate cookies with melting chocolate chips.',
      price: 250,
      originalPrice: 320,
      images: [
        'https://images.unsplash.com/photo-1499636136210-654bd339b42c?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 20,
      rating: 4.6,
      reviewCount: 210,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p5',
      sellerId: 's3',
      sellerName: 'Dairy Fresh',
      title: 'Pure Desi Ghee',
      description: 'Traditional clarified butter made from cow milk.',
      price: 1200,
      originalPrice: 1450,
      images: [
        'https://images.unsplash.com/photo-1589927951682-10f7633659cf?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 50,
      rating: 4.7,
      reviewCount: 450,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p6',
      sellerId: 's1',
      sellerName: 'Fresh Mart',
      title: 'Red Kidney Beans',
      description: 'Nutritious high-protein red kidney beans (Lobia).',
      price: 180,
      originalPrice: 220,
      images: [
        'https://images.unsplash.com/photo-1585438058914-38379ba5188f?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 200,
      rating: 4.3,
      reviewCount: 67,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p7',
      sellerId: 's4',
      sellerName: 'Spice Route',
      title: 'Organic Turmeric',
      description: 'Pure organic turmeric powder with high curcumin content.',
      price: 350,
      originalPrice: 450,
      images: [
        'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 150,
      rating: 4.8,
      reviewCount: 134,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p8',
      sellerId: 's5',
      sellerName: 'Nutty Bites',
      title: 'Roasted Almonds',
      description: 'Premium salted and roasted California almonds.',
      price: 950,
      originalPrice: 1200,
      images: [
        'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 60,
      rating: 4.7,
      reviewCount: 88,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p9',
      sellerId: 's5',
      sellerName: 'Nutty Bites',
      title: 'Medjool Dates',
      description: 'Large, sweet and succulent Medjool dates.',
      price: 1500,
      originalPrice: 1800,
      images: [
        'https://images.unsplash.com/photo-1584288673736-2586730a8ed8?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 40,
      rating: 4.9,
      reviewCount: 230,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'food_p10',
      sellerId: 's6',
      sellerName: 'Green Farm',
      title: 'Olive Oil Extra Virgin',
      description: 'Cold pressed extra virgin olive oil for healthy cooking.',
      price: 2200,
      originalPrice: 2700,
      images: [
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=400'
      ],
      category: 'Food',
      stock: 25,
      rating: 4.8,
      reviewCount: 45,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ...ProductModel.mockProducts(),
    ProductModel(
      id: 'dummy_vehicle_1',
      sellerId: 'seller_1',
      sellerName: 'Auto Hub',
      title: 'Sporty Mountain Bike',
      description: 'High-performance mountain bike for all terrains.',
      price: 15000.0,
      originalPrice: 18000.0,
      images: [
        'https://images.unsplash.com/photo-1532298229144-0ee0c9e9ad58?auto=format&fit=crop&w=400'
      ],
      category: 'Vehicles',
      stock: 5,
      rating: 4.7,
      reviewCount: 20,
      isActive: true,
      isFlashSale: false,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'dummy_others_1',
      sellerId: 'seller_1',
      sellerName: 'Gift Shop',
      title: 'Custom Photo Frame',
      description: 'Elegant photo frame for your precious memories.',
      price: 350.0,
      originalPrice: 500.0,
      images: [
        'https://images.unsplash.com/photo-1544450173-047bb7db3522?auto=format&fit=crop&w=400'
      ],
      category: 'Others',
      stock: 30,
      rating: 4.5,
      reviewCount: 15,
      isActive: true,
      isFlashSale: false,
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<ProductModel>> getProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Default return for home page
    if (category == null || category.isEmpty) {
      return _products.where((p) => p.isActive).toList();
    }

    final target = category.trim().toLowerCase();

    // Special handling for Food to be 100% sure
    if (target == 'food') {
      return _products
          .where((p) => p.category == 'Food' || p.category == 'food')
          .toList();
    }

    return _products.where((p) {
      return p.isActive && p.category.toLowerCase() == target;
    }).toList();
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get flash sale products
  Future<List<ProductModel>> getFlashSaleProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.isActive && p.isFlashSale).toList();
  }

  /// Get recommended products
  Future<List<ProductModel>> getRecommendedProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.isActive && p.rating >= 4.5).toList();
  }

  /// Get products by seller
  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.sellerId == sellerId).toList();
  }

  /// Search products by query
  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.isActive &&
              (p.title.toLowerCase().contains(q) ||
                  p.description.toLowerCase().contains(q) ||
                  p.category.toLowerCase().contains(q)),
        )
        .toList();
  }

  /// Add a new product
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _products.add(product);
    return product;
  }

  /// Update an existing product
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) _products[idx] = product;
    return product;
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _products.removeWhere((p) => p.id == productId);
  }

  /// Toggle product active status
  Future<void> toggleProductStatus(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(
        isActive: !_products[idx].isActive,
      );
    }
  }

  /// Get all products (admin)
  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products;
  }

  /// Get reviews for a product
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ReviewModel.mockReviews(productId);
  }
}

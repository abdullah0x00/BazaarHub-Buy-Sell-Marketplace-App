import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/product_service.dart';
import '../../services/chat_service.dart';
import '../../services/follow_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _service = ProductService();
  ProductModel? _product;
  List<ReviewModel> _reviews = [];
  int _selectedImageIndex = 0;
  bool _loading = true;
  bool _isFollowing = false;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _service.getProductById(widget.productId);
    final reviews = await _service.getProductReviews(widget.productId);
    
    if (mounted) {
      setState(() {
        _product = p;
        _reviews = reviews;
      });
      
      if (_product != null) {
        final auth = context.read<AuthProvider>();
        if (auth.isLoggedIn) {
          final following = await FollowService().isFollowing(auth.currentUser!.id, _product!.sellerId);
          if (mounted) setState(() => _isFollowing = following);
        }
      }
      
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final followService = FollowService();
    if (_isFollowing) {
      await followService.unfollowSeller(auth.currentUser!.id, _product!.sellerId);
    } else {
      await followService.followSeller(auth.currentUser!.id, _product!.sellerId);
    }

    if (mounted) setState(() => _isFollowing = !_isFollowing);
  }

  void _addToCart() {
    if (_product == null) return;
    context.read<CartProvider>().addItem(_product!, quantity: _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product!.title} added to cart'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _buyNow() {
    if (_product == null) return;
    context.read<CartProvider>().addItem(_product!, quantity: _qty);
    Navigator.pushNamed(context, AppRoutes.checkout);
  }

  Future<void> _startChat() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    if (auth.currentUser!.id == _product!.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot chat with yourself")),
      );
      return;
    }

    final chatId = await ChatService().getOrCreateChat(
      buyerId: auth.currentUser!.id,
      sellerId: _product!.sellerId,
      buyerName: auth.currentUser!.name,
      sellerName: _product!.sellerName,
    );

    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatDetail,
        arguments: {
          'chatId': chatId,
          'otherUserName': _product!.sellerName,
          'otherUserId': _product!.sellerId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading product...'));
    }
    if (_product == null) {
      return const Scaffold(
        body: Center(child: Text('Product not found')),
      );
    }
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isWishlisted = productProvider.isWishlisted(_product!.id);
    final inCart = cart.isInCart(_product!.id);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // Image Gallery App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  final auth = context.read<AuthProvider>();
                  productProvider.toggleWishlist(_product!.id, auth.currentUser?.id);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Main image
                  PageView.builder(
                    itemCount: _product!.images.length,
                    onPageChanged: (i) =>
                        setState(() => _selectedImageIndex = i),
                    itemBuilder: (ctx, i) => Image.network(
                      _product!.images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.azureSurface,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: AppColors.azure,
                        ),
                      ),
                    ),
                  ),
                  // Image indicators
                  if (_product!.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _product!.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _selectedImageIndex ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _selectedImageIndex
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Flash sale badge
                  if (_product!.isFlashSale)
                    Positioned(
                      top: 60,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⚡ Flash Sale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Shop
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.azureSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _product!.category,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.azure,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.storefront_outlined,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _product!.sellerName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _toggleFollow,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(60, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _isFollowing ? AppColors.divider : AppColors.primary,
                            ),
                          ),
                        ),
                        child: Text(
                          _isFollowing ? 'Following' : '+ Follow',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isFollowing ? AppColors.textHint : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    _product!.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Rating
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < _product!.rating.floor()
                              ? Icons.star_rounded
                              : (i < _product!.rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded),
                          color: AppColors.warning,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_product!.rating} (${_product!.reviewCount} reviews)',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${_formatPrice(_product!.price)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (_product!.discountPercent != null) ...[
                        const SizedBox(width: 10),
                        if (_product!.originalPrice != null)
                          Text(
                            'PKR ${_formatPrice(_product!.originalPrice!)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${_product!.discountPercent!.toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _product!.inStock
                        ? '✅ In Stock (${_product!.stock} available)'
                        : '❌ Out of Stock',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: _product!.inStock
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Quantity
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _QuantitySelector(
                        quantity: _qty,
                        maxQty: _product!.stock,
                        onDecrement: () =>
                            setState(() => _qty = (_qty - 1).clamp(1, 99)),
                        onIncrement: () => setState(
                          () => _qty = (_qty + 1).clamp(1, _product!.stock),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  // Specifications
                  if (_product!.specifications != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _product!.specifications!.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final isLast =
                              entry.key == _product!.specifications!.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        entry.value.key,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.value.value,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews (${_reviews.length})',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.azure,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ..._reviews.take(2).map((r) => _ReviewItem(review: r)),
                  const SizedBox(height: 100), // Bottom padding for buttons
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.azureSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                onPressed: _startChat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: inCart ? 'Go to Cart' : 'Add to Cart',
                outlined: !inCart,
                onPressed: inCart
                    ? () => Navigator.pushNamed(context, AppRoutes.cart)
                    : _addToCart,
                icon: Icons.shopping_cart_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Buy Now',
                onPressed: _product!.inStock ? _buyNow : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.quantity,
    required this.maxQty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: quantity > 1 ? onDecrement : null,
            color: AppColors.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: quantity < maxQty ? onIncrement : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final ReviewModel review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.azureSurface,
                child: Text(
                  review.userName[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.warning,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(review.createdAt),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                'Helpful (${review.helpfulCount})',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state_widget.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final wishlistItems = products.wishlistProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Wishlist')),
      body: wishlistItems.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.favorite_outline,
              title: 'Wishlist is Empty',
              subtitle:
                  'Save your favourite products by tapping the heart icon.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (ctx, i) => ProductCard(product: wishlistItems[i]),
            ),
    );
  }
}

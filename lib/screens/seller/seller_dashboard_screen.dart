import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  Map<String, dynamic>? _analytics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().currentUser;

    if (user == null || user.isSeller != true) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.becomeSeller);
        }
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    final productProvider = context.read<ProductProvider>();
    if (user == null) return;
    
    setState(() => _loading = true);
    
    try {
      // 1. Fetch live analytics from Firebase
      final analytics = await OrderService().getSellerAnalytics(user.id);
      
      // 2. Fetch All Products for this Seller from Firebase
      await productProvider.loadSellerProducts(user.id);
      
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.sellerProducts;

    // 1. Not Logged In
    if (!auth.isLoggedIn) {
      return _buildLoginPrompt('Login Required', 'Please login to manage your shop.');
    }

    // 2. Pending Approval
    if (auth.currentUser?.isApprovedSeller == false) {
      return _buildPendingScreen();
    }

    // 3. Main Dashboard
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seller Center', style: TextStyle(color: Color(0xFFF4511E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Color(0xFFF4511E)),
            onPressed: _load,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingWidget(message: 'Syncing with Firebase...')
            : RefreshIndicator(
                color: const Color(0xFFF4511E),
                onRefresh: _load,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  auth.currentUser?.shopName ?? 'My Shop',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.addProduct,
                            ).then((_) => _load()),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'Add Product',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4511E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Stats Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _StatCard(
                            label: 'Total Revenue',
                            value: 'PKR ${_fmt(_analytics?['totalRevenue'] ?? 0)}',
                            icon: Icons.monetization_on_outlined,
                            color: AppColors.success,
                          ),
                          _StatCard(
                            label: 'Total Orders',
                            value: '${_analytics?['totalOrders'] ?? 0}',
                            icon: Icons.receipt_long_outlined,
                            color: AppColors.primary,
                          ),
                          _StatCard(
                            label: 'Products Listed',
                            value: '${products.length}',
                            icon: Icons.inventory_2_outlined,
                            color: AppColors.azure,
                          ),
                          _StatCard(
                            label: 'Pending Orders',
                            value: '${_analytics?['pendingOrders'] ?? 0}',
                            icon: Icons.pending_outlined,
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.bar_chart_rounded,
                            label: 'Analytics',
                            color: AppColors.azure,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.sellerAnalytics,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Orders',
                            color: AppColors.primary,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.sellerOrders,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: Icons.inventory_outlined,
                            label: 'Products',
                            color: AppColors.success,
                            onTap: _load,
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: Icons.campaign_outlined,
                            label: 'Promote',
                            color: AppColors.warning,
                            onTap: () => _showPromoteDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Products List (History)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Product Listings',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: _load,
                            child: const Text(
                              'Refresh All',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.azure,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (products.isEmpty)
                        const EmptyStateWidget(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Products Yet',
                          subtitle: 'Tap "Add Product" to start selling.',
                        )
                      else
                        ...products.map(
                          (p) => _SellerProductTile(
                            product: p,
                            onEdit: () => Navigator.pushNamed(
                              context,
                              AppRoutes.editProduct,
                              arguments: {'productId': p.id},
                            ).then((_) => _load()),
                            onDelete: () => _confirmDelete(context, p.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoginPrompt(String title, String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Login Now', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Approval Pending')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.orange),
              ),
              const SizedBox(height: 32),
              const Text(
                'Application Under Review',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank you for applying! Our admin team is reviewing your shop details. You will receive an email once your account is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ProductProvider>().deleteProduct(productId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
                _load();
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showPromoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🚀 Promote Your Products'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PromoOption(icon: '⚡', title: 'Flash Sale Slot', subtitle: 'Feature in Flash Sale for 6hrs', price: 'PKR 500'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  String _fmt(dynamic v) {
    final val = (v is num) ? v.toDouble() : 0.0;
    return val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: color, fontWeight: FontWeight.w500))]),
      ),
    ),
  );
}

class _SellerProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SellerProductTile({required this.product, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(product.coverImage, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.azureSurface, child: const Icon(Icons.image_outlined, color: AppColors.azure)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text('PKR ${product.price.toStringAsFixed(0)} • Stock: ${product.stock}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), color: AppColors.primary, onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete_outline, size: 18), color: AppColors.error, onPressed: onDelete),
    ]),
  );
}

class _PromoOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String price;
  const _PromoOption({required this.icon, required this.title, required this.subtitle, required this.price});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.azureSurface, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))])),
      Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
    ]),
  );
}

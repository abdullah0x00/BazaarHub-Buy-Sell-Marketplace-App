import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../widgets/loading_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  Future<void> _refreshData() async {
    await context.read<AdminProvider>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          if (admin.isLoading) {
            return const LoadingWidget(message: 'Updating Dashboard...');
          }

          if (admin.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text('Sync Error', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('${admin.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refreshData,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF1A237E),
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Overview Header
                  _buildHeader(admin),

                  const SizedBox(height: 32),
                  
                  const Text(
                    'Management Console',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Management Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _AdminCard(
                        title: 'User Control',
                        subtitle: 'Ban/Verify Users',
                        icon: Icons.manage_accounts,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.manageUsers),
                      ),
                      _AdminCard(
                        title: 'Inventory',
                        subtitle: 'Monitor Listings',
                        icon: Icons.inventory_2_rounded,
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.manageProducts),
                      ),
                      _AdminCard(
                        title: 'Order Tracking',
                        subtitle: 'Status & Logistics',
                        icon: Icons.local_shipping_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.manageOrders),
                      ),
                      _AdminCard(
                        title: 'Financials',
                        subtitle: 'Revenue & Growth',
                        icon: Icons.analytics_rounded,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminAnalytics),
                      ),
                      _AdminCard(
                        title: 'System Logs',
                        subtitle: 'Security Events',
                        icon: Icons.security_rounded,
                        color: Colors.red,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.systemLogs),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Pending Approvals Section
                  if (admin.pendingSellers.isNotEmpty) ...[
                    const Row(
                      children: [
                        Icon(Icons.pending_actions_rounded, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Verification Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...admin.pendingSellers.map((u) => _SellerRequestCard(
                      user: u,
                      onApprove: () {
                        final auth = context.read<AuthProvider>();
                        admin.approveSeller(
                          u.id, 
                          adminId: auth.currentUser?.id, 
                          adminName: auth.currentUser?.name
                        );
                      },
                    )),
                  ] else ...[
                    const _EmptyState(icon: Icons.check_circle_outline_rounded, title: 'No pending seller applications.'),
                  ],

                  const SizedBox(height: 32),

                  // Pending Products Section
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Product Approvals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (admin.pendingProducts.isNotEmpty) ...[
                    ...admin.pendingProducts.map((p) => _ProductApprovalCard(
                      product: p,
                      onApprove: () {
                        final auth = context.read<AuthProvider>();
                        admin.approveProduct(
                          p.id, 
                          adminId: auth.currentUser?.id, 
                          adminName: auth.currentUser?.name
                        );
                      },
                      onReject: () {
                        final auth = context.read<AuthProvider>();
                        admin.rejectProduct(
                          p.id, 
                          adminId: auth.currentUser?.id, 
                          adminName: auth.currentUser?.name
                        );
                      },
                    )),
                  ] else ...[
                    const _EmptyState(icon: Icons.inventory_2_outlined, title: 'No products waiting for approval.'),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AdminProvider admin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Overview', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('BazaarHub Management', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickStat(label: 'Buyers', value: '${admin.totalBuyers}', icon: Icons.person),
              _QuickStat(label: 'Sellers', value: '${admin.totalSellers}', icon: Icons.store),
              _QuickStat(label: 'Revenue', value: 'PKR ${_calculateRevenue(admin.orders)}', icon: Icons.monetization_on_rounded),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final admin = context.read<AdminProvider>().users.firstWhere((u) => u.role == UserRole.admin, orElse: () => UserModel(id: 'admin', name: 'Admin', email: 'admin@bazaarhub.com', createdAt: DateTime.now(), role: UserRole.admin));
    final nameCtrl = TextEditingController(text: admin.name);
    final emailCtrl = TextEditingController(text: admin.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), enabled: false),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = admin.copyWith(name: nameCtrl.text);
              await context.read<AdminProvider>().updateAdminProfile(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _calculateRevenue(List<OrderModel> orders) {
    double total = 0;
    for (var order in orders) {
      if (order.status != OrderStatus.cancelled) {
        total += order.total;
      }
    }
    if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}k';
    }
    return total.toStringAsFixed(0);
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _QuickStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Colors.white54, size: 20),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    ),
  );
}

class _SellerRequestCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onApprove;
  const _SellerRequestCard({required this.user, required this.onApprove});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF1A237E).withOpacity(0.1), 
          child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(user.shopName ?? 'New Store', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onApprove,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

class _ProductApprovalCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ProductApprovalCard({required this.product, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(product.coverImage, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('By ${product.sellerName}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text('PKR ${product.price}', style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(onPressed: onReject, icon: const Icon(Icons.close, color: Colors.red, size: 20)),
            IconButton(onPressed: onApprove, icon: const Icon(Icons.check, color: Colors.green, size: 20)),
          ],
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  const _EmptyState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 40),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    ),
  );
}

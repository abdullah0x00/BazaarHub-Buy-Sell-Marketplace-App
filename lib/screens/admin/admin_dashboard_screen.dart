import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<AdminProvider>().loadDashboardData();
      } catch (e) {
        debugPrint('AdminProvider not found: $e');
      }
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _goBack,
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          try {
            final admin = context.watch<AdminProvider>();

            if (admin.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
              onRefresh: _refreshData,
              color: const Color(0xFF1A237E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(admin),
                    if (admin.isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(
                        color: Color(0xFF1A237E),
                        backgroundColor: Color(0xFFE8ECF4),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Management Console',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                    if (admin.pendingSellers.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.pending_actions_rounded, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Verification Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
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
                                adminName: auth.currentUser?.name,
                              );
                            },
                          )),
                    ] else ...[
                      const _EmptyState(icon: Icons.check_circle_outline_rounded, title: 'No pending seller applications.'),
                    ],
                    const SizedBox(height: 32),
                    const Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Product Approvals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
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
                                adminName: auth.currentUser?.name,
                              );
                            },
                            onReject: () {
                              final auth = context.read<AuthProvider>();
                              admin.rejectProduct(
                                p.id,
                                adminId: auth.currentUser?.id,
                                adminName: auth.currentUser?.name,
                              );
                            },
                          )),
                    ] else ...[
                      const _EmptyState(icon: Icons.inventory_2_outlined, title: 'No products waiting for approval.'),
                    ],
                  ],
                ),
              ),
            );
          } catch (e, stack) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'ADMIN DASHBOARD ERROR:\n\n$e\n\n$stack',
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
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
    final auth = context.read<AuthProvider>();
    final admin = auth.currentUser!;
    final nameCtrl = TextEditingController(text: admin.name);
    final emailCtrl = TextEditingController(text: admin.email);
    final phoneCtrl = TextEditingController(text: admin.phone ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Color(0xFF1A237E)),
              const SizedBox(width: 8),
              const Text('Admin Profile'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1A237E),
                child: Text(
                  admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
                  style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);

                final updated = admin.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                );

                try {
                  // Update via AdminProvider
                  final success = await context.read<AdminProvider>().updateAdminProfile(updated);

                  if (success && context.mounted) {
                    // Also update AuthProvider so UI refreshes everywhere
                    await auth.refreshUser();

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (context.mounted) {
                    setDialogState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update profile'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    setDialogState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: isLoading ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ) : const Text('Update'),
            ),
          ],
        ),
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
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
          Text(title, style: const TextStyle(color: Color(0xFF1A1F36), fontWeight: FontWeight.bold, fontSize: 15)),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
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
  Widget build(BuildContext context) {
    final String initial = user.name.trim().isNotEmpty ? user.name.trim().characters.first.toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0x1A1A237E),
          child: Text(initial, style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
        ),
        title: Text(user.name.isNotEmpty ? user.name : 'Unknown User', style: const TextStyle(color: Color(0xFF1A1F36), fontWeight: FontWeight.bold)),
        subtitle: Text(user.shopName ?? 'New Store', style: const TextStyle(color: Color(0xFF6B7280))),
        trailing: ElevatedButton(
          onPressed: onApprove,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            minimumSize: const Size(84, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Approve'),
        ),
      ),
    );
  }
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
      border: Border.all(color: const Color(0xFFE8ECF4)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: product.coverImage.isNotEmpty
              ? Image.network(product.coverImage, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const SizedBox(width:50, height:50, child: Icon(Icons.image)))
              : const SizedBox(width: 50, height: 50, child: Icon(Icons.image)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product.title.isNotEmpty ? product.title : 'Unnamed Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('By ${product.sellerName}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text('PKR ${product.price}', style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
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
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey, size: 40),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

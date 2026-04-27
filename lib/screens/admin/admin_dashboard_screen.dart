import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          if (admin.isLoading && admin.users.isEmpty) {
            return const LoadingWidget(message: 'Syncing Admin Data...');
          }

          return RefreshIndicator(
            color: const Color(0xFF1A237E),
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Gradient
                  Container(
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
                        BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
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
                            _QuickStat(label: 'Total Revenue', value: 'PKR ${_calculateRevenue(admin.orders)}', icon: Icons.monetization_on_rounded),
                            _QuickStat(label: 'Active Users', value: '${admin.users.length}', icon: Icons.people),
                            _QuickStat(label: 'Live Orders', value: '${admin.orders.length}', icon: Icons.local_shipping),
                          ],
                        ),
                      ],
                    ),
                  ),

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
                        onTap: () => _showWIP(context),
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
                      onApprove: () => admin.approveSeller(u.id),
                    )),
                  ] else ...[
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 48),
                            SizedBox(height: 12),
                            Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('No pending seller applications.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
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

  void _showWIP(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module under construction by Admin Team.')),
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
      return (total / 1000).toStringAsFixed(1) + 'k';
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1), 
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

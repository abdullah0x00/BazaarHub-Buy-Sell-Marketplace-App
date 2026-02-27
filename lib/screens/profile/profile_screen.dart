import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // Display "User" instead of "Admin User" if that's the name
    final displayName =
        user?.name == 'Admin User' ? 'User' : (user?.name ?? 'Guest');
    final displayEmail = user?.email ?? 'user@bazaarhub.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Profile Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Profile DB look
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${displayEmail.split('@')[0]}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Shipping Address Section
                  _buildSectionTitle('Shipping Address'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.azureSurface,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on,
                              color: AppColors.azure),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Default Address',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              SizedBox(height: 4),
                              Text(
                                'House #123, Street 5, Blue Area, Islamabad, Pakistan',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preferences / Settings Section (Restored old items)
                  _buildSectionTitle('Preferences & Settings'),
                  _buildMenuCard([
                    _MenuItem(
                        Icons.person_outline,
                        'Edit Profile',
                        () => Navigator.pushNamed(
                            context, AppRoutes.editProfile)),
                    _MenuItem(
                        Icons.receipt_long_outlined,
                        'My Orders',
                        () => Navigator.pushNamed(
                            context, AppRoutes.orderHistory)),
                    _MenuItem(Icons.favorite_outline, 'My Wishlist',
                        () => Navigator.pushNamed(context, AppRoutes.wishlist)),
                    _MenuItem(
                        Icons.notifications_none,
                        'Notifications',
                        () => Navigator.pushNamed(
                            context, AppRoutes.notifications)),
                    _MenuItem(Icons.settings_outlined, 'General Settings',
                        () => Navigator.pushNamed(context, AppRoutes.settings)),
                  ]),

                  const SizedBox(height: 20),

                  // Seller Section (Always accessible if not already a seller)
                  _buildSectionTitle('Seller Center'),
                  _buildMenuCard([
                    if (user?.isSeller == true) ...[
                      _MenuItem(
                          Icons.dashboard_outlined,
                          'Seller Dashboard',
                          () => Navigator.pushNamed(
                              context, AppRoutes.sellerDashboard)),
                      _MenuItem(
                          Icons.bar_chart,
                          'Sales Analytics',
                          () => Navigator.pushNamed(
                              context, AppRoutes.sellerAnalytics)),
                    ] else
                      _MenuItem(
                          Icons.storefront_outlined,
                          'Become a Seller',
                          () => Navigator.pushNamed(
                              context, AppRoutes.becomeSeller)),
                  ]),

                  // Admin Section (Restored for Admin users)
                  if (user?.isAdmin == true) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('Admin Panel'),
                    _buildMenuCard([
                      _MenuItem(
                          Icons.admin_panel_settings_outlined,
                          'Admin Dashboard',
                          () => Navigator.pushNamed(
                              context, AppRoutes.adminDashboard)),
                    ]),
                  ],

                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _confirmLogout(context, auth),
                      icon:
                          const Icon(Icons.logout, size: 18, color: Colors.red),
                      label: const Text('Logout',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, size: 22, color: AppColors.primary),
                title: Text(item.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right,
                    size: 18, color: Colors.grey),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (entry.key < items.length - 1)
                const Divider(height: 1, color: AppColors.divider, indent: 50),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  _MenuItem(this.icon, this.label, this.onTap);
}

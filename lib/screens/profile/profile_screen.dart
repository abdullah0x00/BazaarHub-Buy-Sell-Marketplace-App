import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.label, this.onTap);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateImage() async {
    final auth = context.read<AuthProvider>();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (image != null) {
        final success = await auth.updateProfilePicture(File(image.path));
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated!'), backgroundColor: AppColors.success),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(auth.error ?? 'Upload failed'), backgroundColor: AppColors.error),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final displayName = user?.name == 'Admin User' ? 'User' : (user?.name ?? 'Guest');
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
                  // Avatar with Clickable Camera
                  GestureDetector(
                    onTap: auth.isLoading ? null : _updateImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 4),
                          ),
                          child: ClipOval(
                            child: auth.isLoading 
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : user?.avatar != null && user!.avatar!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: user.avatar!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                                    errorWidget: (context, url, error) => _buildAvatarPlaceholder(displayName),
                                  )
                                : _buildAvatarPlaceholder(displayName),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.primary),
                          ),
                        ),
                      ],
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
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editAddress),
                    child: Container(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Default Address',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  user?.shippingAddress ?? 'No address added yet. Tap to add.',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Preferences & Settings'),
                  _buildMenuCard([
                    _MenuItem(
                        Icons.person_outline,
                        'Edit Profile Info',
                        () => Navigator.pushNamed(
                            context, AppRoutes.editProfile)),
                    _MenuItem(
                        Icons.chat_bubble_outline_rounded,
                        'My Messages',
                        () => Navigator.pushNamed(
                            context, AppRoutes.chatList)),
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
                    _MenuItem(
                        Icons.security_outlined,
                        'Security & Privacy',
                        () => Navigator.pushNamed(context, AppRoutes.securityPrivacy)),
                    _MenuItem(Icons.settings_outlined, 'General Settings',
                        () => Navigator.pushNamed(context, AppRoutes.settings)),
                  ]),

                  const SizedBox(height: 20),

                  _buildSectionTitle('Seller Center'),
                  _buildMenuCard([
                    _MenuItem(
                        Icons.dashboard_outlined,
                        'Seller Dashboard',
                        () {
                          final user = context.read<AuthProvider>().currentUser;
                          if (user == null) return;

                          if (user.isSeller == true) {
                            Navigator.pushNamed(context, AppRoutes.sellerDashboard);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.becomeSeller);
                          }
                        }),
                    
                    if (user?.isSeller == true)
                      _MenuItem(
                          Icons.bar_chart,
                          'Sales Analytics',
                          () => Navigator.pushNamed(
                              context, AppRoutes.sellerAnalytics)),
                  ]),

                  if (user?.isAdmin == true || user?.email == 'admin@bazaarhub.com') ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('Platform Administration'),
                    _buildMenuCard([
                      _MenuItem(
                          Icons.admin_panel_settings_rounded,
                          'Admin Control Center',
                          () => Navigator.pushNamed(
                              context, AppRoutes.adminDashboard)),
                    ]),
                  ],

                  const SizedBox(height: 30),

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

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

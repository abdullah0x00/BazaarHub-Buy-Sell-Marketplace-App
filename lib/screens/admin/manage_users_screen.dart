import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> list) {
    if (_search.isEmpty) return list;
    return list
        .where(
          (u) =>
              u.name.toLowerCase().contains(_search.toLowerCase()) ||
              u.email.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          if (admin.isLoading && admin.users.isEmpty) {
            return const LoadingWidget();
          }

          final buyers = _filtered(
              admin.users.where((u) => u.role == UserRole.buyer).toList());
          final sellers = _filtered(
              admin.users.where((u) => u.role == UserRole.seller).toList());
          final allFiltered = _filtered(admin.users);

          return Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textHint,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'All (${allFiltered.length})'),
                  Tab(text: 'Buyers (${buyers.length})'),
                  Tab(text: 'Sellers (${sellers.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _UserList(users: allFiltered),
                    _UserList(users: buyers),
                    _UserList(users: sellers),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;

  const _UserList({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Users',
        subtitle: 'No users found matching your search.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      itemBuilder: (ctx, i) => _UserTile(user: users[i]),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: user.isBlocked
            ? AppColors.error.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isBlocked
              ? AppColors.error.withValues(alpha: 0.2)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.azureSurface,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (user.isSeller)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Seller',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (user.isBlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Blocked',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'block') {
                final admin = context.read<AdminProvider>();
                final auth = context.read<AuthProvider>();
                await admin.toggleUserBlock(
                  user.id,
                  adminId: auth.currentUser?.id,
                  adminName: auth.currentUser?.name,
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'view',
                child: Text('View Details',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
              PopupMenuItem(
                value: 'block',
                child: Text(
                  user.isBlocked ? 'Unblock User' : 'Block User',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: user.isBlocked ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

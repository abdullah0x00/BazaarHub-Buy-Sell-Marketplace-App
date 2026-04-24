import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  Duration _timeLeft = const Duration(hours: 2, minutes: 45, seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHomeData();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  // Custom manual format to fix the string interpolation issue in logic
  String _getTimerText() {
    int h = _timeLeft.inHours;
    int m = _timeLeft.inMinutes.remainder(60);
    int s = _timeLeft.inSeconds.remainder(60);
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    
    final filteredProducts = products.products.where((p) {
      return !products.flashSale.any((f) => f.id == p.id) &&
          !products.recommended.any((r) => r.id == p.id);
    }).toList();
 
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<ProductProvider>().loadHomeData(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context, auth)),
              SliverToBoxAdapter(child: _buildSearchBar(context)),
              SliverToBoxAdapter(child: _buildBannerSlider(context)),
              SliverToBoxAdapter(child: _buildCategories(context)),

              if (products.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: LoadingWidget(),
                  ),
                )
              else ...[
                if (products.flashSale.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Flash Sale',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildTimerWidget(),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('See All', style: TextStyle(color: AppColors.azure)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: products.flashSale.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) => ProductCard(product: products.flashSale[i], width: 150),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (products.recommended.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ProductListSection(
                        title: 'Recommended For You',
                        products: products.recommended,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Just For You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Icon(Icons.filter_list, size: 20, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => ProductCard(product: filteredProducts[i]),
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${auth.currentUser?.name == 'Admin User' ? 'User' : (auth.currentUser?.name.split(' ').first ?? 'Guest')}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const Text(
                  'BazaarHub Marketplace',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none_outlined, size: 26),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                (auth.currentUser?.name.isNotEmpty ?? false) ? auth.currentUser!.name[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Search for anything...', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
              VerticalDivider(indent: 12, endIndent: 12, color: Colors.grey[300]),
              IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.search, arguments: {'triggerCamera': true}),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(top: 8),
      child: PageView(
        children: [
          _buildBannerItem(context, 'Summer Collection', 'Up to 50% Off', AppColors.primary, AppColors.azure),
          _buildBannerItem(context, 'Tech Deals', 'Free Shipping', AppColors.azure, AppColors.primaryDark),
          _buildBannerItem(context, 'Home Style', 'Starting PKR 999', AppColors.primaryDark, AppColors.accentDark),
        ],
      ),
    );
  }

  Widget _buildBannerItem(BuildContext context, String title, String sub, Color c1, Color c2) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c1, c2]),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final query = title.contains('Tech') ? 'Electronics' : (title.contains('Home') ? 'Home & Living' : 'Fashion');
                    Navigator.pushNamed(context, AppRoutes.search, arguments: {'query': query});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(80, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Shop Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_mall_outlined, size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (ctx, i) {
              final cat = AppConstants.categories[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.search, arguments: {'query': cat['name']});
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                      ),
                      child: Center(child: Text(cat['icon']!, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 8),
                    Text(cat['name']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.red, size: 14),
          const SizedBox(width: 4),
          Text(_getTimerText(), style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

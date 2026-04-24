import 'package:flutter/material.dart';

// Onboarding
import '../screens/onboarding/onboarding_screen1.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// Buyer
import '../screens/buyer/product_details_screen.dart';
import '../screens/buyer/cart_screen.dart';
import '../screens/buyer/checkout_screen.dart';
import '../screens/buyer/order_history_screen.dart';
import '../screens/buyer/wishlist_screen.dart';
import '../screens/buyer/categories_screen.dart';
import '../screens/buyer/search_screen.dart';
import '../screens/buyer/notifications_screen.dart';

// Seller
import '../screens/seller/become_seller_screen.dart';
import '../screens/seller/seller_dashboard_screen.dart';
import '../screens/seller/add_product_screen.dart';
import '../screens/seller/edit_product_screen.dart';
import '../screens/seller/seller_orders_screen.dart';
import '../screens/seller/seller_analytics_screen.dart';

// Profile
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';

// Admin
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_products_screen.dart';

// Main Shell
import '../screens/buyer/main_shell.dart';
import '../screens/splash_screen.dart';

/// Centralized route management for the app
class AppRoutes {
  static const String splash = '/';
  static const String onboarding1 = '/onboarding1';
  static const String onboarding2 = '/onboarding2';
  static const String onboarding3 = '/onboarding3';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String wishlist = '/wishlist';
  static const String categories = '/categories';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String becomeSeller = '/become-seller';
  static const String sellerDashboard = '/seller-dashboard';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String sellerOrders = '/seller-orders';
  static const String sellerAnalytics = '/seller-analytics';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String adminDashboard = '/admin-dashboard';
  static const String manageUsers = '/manage-users';
  static const String manageProducts = '/manage-products';

  static Route<dynamic> generateRoute(RouteSettings settings_) {
    switch (settings_.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings_);
      case onboarding1:
        return _buildRoute(const OnboardingScreen1(), settings_);
      case onboarding2:
        return _buildRoute(const OnboardingScreen2(), settings_);
      case onboarding3:
        return _buildRoute(const OnboardingScreen3(), settings_);
      case login:
        return _buildRoute(const LoginScreen(), settings_);
      case register:
        return _buildRoute(const RegisterScreen(), settings_);
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings_);
      case main:
        return _buildRoute(const MainShell(), settings_);
      case productDetails:
        final args = settings_.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ProductDetailsScreen(productId: args?['productId'] ?? ''),
          settings_,
        );
      case cart:
        return _buildRoute(const CartScreen(), settings_);
      case checkout:
        return _buildRoute(const CheckoutScreen(), settings_);
      case orderHistory:
        return _buildRoute(const OrderHistoryScreen(), settings_);
      case wishlist:
        return _buildRoute(const WishlistScreen(), settings_);
      case categories:
        return _buildRoute(const CategoriesScreen(), settings_);
      case search:
        final args = settings_.arguments as Map<String, dynamic>?;
        return _buildRoute(
          SearchScreen(
            initialQuery: args?['query'],
            triggerCamera: args?['triggerCamera'] ?? false,
          ),
          settings_,
        );
      case notifications:
        return _buildRoute(const NotificationsScreen(), settings_);
      case becomeSeller:
        return _buildRoute(const BecomeSellerScreen(), settings_);
      case sellerDashboard:
        return _buildRoute(const SellerDashboardScreen(), settings_);
      case addProduct:
        return _buildRoute(const AddProductScreen(), settings_);
      case editProduct:
        final args = settings_.arguments as Map<String, dynamic>?;
        return _buildRoute(
          EditProductScreen(productId: args?['productId'] ?? ''),
          settings_,
        );
      case sellerOrders:
        return _buildRoute(const SellerOrdersScreen(), settings_);
      case sellerAnalytics:
        return _buildRoute(const SellerAnalyticsScreen(), settings_);
      case profile:
        return _buildRoute(const ProfileScreen(), settings_);
      case editProfile:
        return _buildRoute(const EditProfileScreen(), settings_);
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings_);
      case adminDashboard:
        return _buildRoute(const AdminDashboardScreen(), settings_);
      case manageUsers:
        return _buildRoute(const ManageUsersScreen(), settings_);
      case manageProducts:
        return _buildRoute(const ManageProductsScreen(), settings_);
      default:
        return _buildRoute(const SplashScreen(), settings_);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

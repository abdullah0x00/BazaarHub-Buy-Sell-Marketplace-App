/// App-wide constants
library;

class AppConstants {
  // App Info
  static const String appName = 'BazaarHub';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Buy & Sell Anything';

  // SharedPreferences Keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyTwoFactor = 'two_factor_enabled';
  static const String keyBiometric = 'biometric_enabled';

  // Demo Admin Credentials
  static const String adminEmail = 'admin@bazaarhub.com';
  static const String adminPassword = 'Admin@123';

  // Pagination
  static const int pageSize = 20;

  // Image Placeholders (network)
  static const String placeholderProduct =
      'https://via.placeholder.com/300x300/E1F5FE/1565C0?text=Product';
  static const String placeholderAvatar =
      'https://via.placeholder.com/100x100/E1F5FE/1565C0?text=User';
  static const String placeholderBanner =
      'https://via.placeholder.com/800x300/1565C0/FFFFFF?text=BazaarHub';

  // Categories
  static const List<Map<String, String>> categories = [
    {'name': 'Electronics', 'icon': '📱'},
    {'name': 'Fashion', 'icon': '👗'},
    {'name': 'Home & Living', 'icon': '🏠'},
    {'name': 'Sports', 'icon': '⚽'},
    {'name': 'Beauty', 'icon': '💄'},
    {'name': 'Books', 'icon': '📚'},
    {'name': 'Toys', 'icon': '🧸'},
    {'name': 'Vehicles', 'icon': '🚗'},
    {'name': 'Food', 'icon': '🍕'},
    {'name': 'Others', 'icon': '📦'},
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Credit / Debit Card',
    'JazzCash',
    'EasyPaisa',
    'Bank Transfer',
    'Cash on Delivery',
  ];

  // Order Statuses
  static const String orderPending = 'Pending';
  static const String orderConfirmed = 'Confirmed';
  static const String orderShipped = 'Shipped';
  static const String orderDelivered = 'Delivered';
  static const String orderCancelled = 'Cancelled';

  // Padding / Spacing
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Animation Duration
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
}

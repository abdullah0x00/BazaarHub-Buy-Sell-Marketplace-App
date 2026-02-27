import 'package:flutter/material.dart';
import '../../config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {
      'icon': '🎉',
      'title': 'Order Confirmed!',
      'body': 'Your order ORD-003 has been confirmed by the seller.',
      'time': '2 min ago',
      'read': false,
      'type': 'order',
    },
    {
      'icon': '🚚',
      'title': 'Order Shipped',
      'body': 'Your order ORD-002 is on its way. Track it now.',
      'time': '1 hour ago',
      'read': false,
      'type': 'order',
    },
    {
      'icon': '⚡',
      'title': 'Flash Sale Starting!',
      'body':
          'Electronics sale starts in 30 minutes. Don\'t miss up to 40% OFF.',
      'time': '3 hours ago',
      'read': true,
      'type': 'promo',
    },
    {
      'icon': '❤️',
      'title': 'Wishlist Item on Sale',
      'body': 'iPhone 15 Pro Max from your wishlist is now 15% OFF.',
      'time': '1 day ago',
      'read': true,
      'type': 'promo',
    },
    {
      'icon': '✅',
      'title': 'Order Delivered',
      'body': 'Your order ORD-001 has been delivered. Please leave a review!',
      'time': '2 days ago',
      'read': true,
      'type': 'order',
    },
    {
      'icon': '💰',
      'title': 'Exclusive Offer',
      'body': 'Get 20% cashback on your next purchase. Use code: BAZAAR20',
      'time': '3 days ago',
      'read': true,
      'type': 'promo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark All Read',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.azure,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (ctx, i) {
          final n = _notifications[i];
          final unread = !(n['read'] as bool);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unread ? AppColors.azureSurface : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unread
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.divider,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unread
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      n['icon'] as String,
                      style: const TextStyle(fontSize: 22),
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
                          Expanded(
                            child: Text(
                              n['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight:
                                    unread ? FontWeight.w600 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        n['body'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['time'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

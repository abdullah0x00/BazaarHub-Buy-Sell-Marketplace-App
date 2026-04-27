import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final notificationService = NotificationService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => notificationService.markAllAsRead(userId),
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
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          
          final notifications = snapshot.data ?? [];
          
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications',
              subtitle: 'You will see alerts about your orders and products here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (ctx, i) {
              final n = notifications[i];
              return _NotificationTile(notification: n);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  String _getIcon(String type) {
    switch (type) {
      case 'order': return '🎉';
      case 'promo': return '⚡';
      case 'product_approval': return '📦';
      case 'product_status': return '✅';
      default: return '🔔';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return GestureDetector(
      onTap: () => NotificationService().markAsRead(notification.id),
      child: Container(
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
                  _getIcon(notification.type),
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
                          notification.title,
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
                    notification.body,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.createdAt),
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
      ),
    );
  }
}

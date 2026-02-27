import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final uid = context.read<AuthProvider>().currentUser?.id ?? '';
    _ordersFuture = OrderService().getBuyerOrders(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading orders...');
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders Yet',
              subtitle: 'You haven\'t placed any orders yet. Start shopping!',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => setState(_load),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                _StatusChip(status: order.status),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: AppColors.azureSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.productTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '×${item.quantity}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Footer
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: PKR ${_fmt(order.total)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      order.paymentMethod,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                if (order.status == OrderStatus.shipped &&
                    order.trackingNumber != null)
                  TextButton.icon(
                    onPressed: () => _showTracking(context, order),
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: const Text(
                      'Track',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTracking(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TrackingSheet(order: order),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  String _fmt(double v) {
    return v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    String label;
    switch (status) {
      case OrderStatus.pending:
        bg = AppColors.warning.withValues(alpha: 0.15);
        text = AppColors.warning;
        label = '⏳ Pending';
      case OrderStatus.confirmed:
        bg = AppColors.azure.withValues(alpha: 0.15);
        text = AppColors.azure;
        label = '✅ Confirmed';
      case OrderStatus.shipped:
        bg = AppColors.primary.withValues(alpha: 0.12);
        text = AppColors.primary;
        label = '🚚 Shipped';
      case OrderStatus.delivered:
        bg = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
        label = '✓ Delivered';
      case OrderStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.12);
        text = AppColors.error;
        label = '✕ Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  final OrderModel order;
  const _TrackingSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _TrackStep(
        'Order Placed',
        'Your order has been placed',
        true,
        Icons.check_circle,
      ),
      _TrackStep(
        'Order Confirmed',
        'Seller has confirmed your order',
        order.status.index >= 1,
        Icons.verified,
      ),
      _TrackStep(
        'Shipped',
        'Tracking: ${order.trackingNumber ?? 'N/A'}',
        order.status.index >= 2,
        Icons.local_shipping,
      ),
      _TrackStep(
        'Delivered',
        'Package delivered to your address',
        order.status == OrderStatus.delivered,
        Icons.home,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Track Order — ${order.id}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map(
                (e) => _TrackStepWidget(
                  step: e.value,
                  isLast: e.key == steps.length - 1,
                ),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TrackStep {
  final String title;
  final String subtitle;
  final bool done;
  final IconData icon;
  const _TrackStep(this.title, this.subtitle, this.done, this.icon);
}

class _TrackStepWidget extends StatelessWidget {
  final _TrackStep step;
  final bool isLast;
  const _TrackStepWidget({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: step.done ? AppColors.primary : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                color: step.done ? Colors.white : AppColors.textHint,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: step.done
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        step.done ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: step.done
                        ? AppColors.textSecondary
                        : AppColors.textHint,
                  ),
                ),
                if (!isLast) const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

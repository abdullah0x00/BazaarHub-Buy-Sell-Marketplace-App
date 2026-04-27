import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/log_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class SystemLogsScreen extends StatelessWidget {
  const SystemLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logService = LogService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('System Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: StreamBuilder<List<SystemLogModel>>(
        stream: logService.getSystemLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading security logs...');
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.security_rounded,
              title: 'No Logs Found',
              subtitle: 'System activities will appear here once they occur.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              return _LogTile(log: log);
            },
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final SystemLogModel log;
  const _LogTile({required this.log});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'user': return Colors.blue;
      case 'product': return Colors.orange;
      case 'order': return Colors.green;
      case 'auth': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'user': return Icons.person_outline;
      case 'product': return Icons.inventory_2_outlined;
      case 'order': return Icons.local_shipping_outlined;
      case 'auth': return Icons.lock_outline;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(log.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getTypeIcon(log.type), color: color, size: 20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(
              DateFormat('HH:mm').format(log.timestamp),
              style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(log.details, style: const TextStyle(fontSize: 12, color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'By: ${log.adminName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(log.timestamp),
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

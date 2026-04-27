import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Login History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<AuthProvider>().getLoginHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Fetching logs...');
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'No History Found',
              subtitle: 'Your login activities will appear here.',
            );
          }

          final logs = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final log = logs[i];
              final date = log['timestamp'] != null 
                  ? (log['timestamp'] as dynamic).toDate() 
                  : DateTime.now();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: log['platform'] == 'android' 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        log['platform'] == 'android' ? Icons.android : Icons.apple,
                        color: log['platform'] == 'android' ? Colors.green : Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['deviceName'] ?? 'Unknown Device',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

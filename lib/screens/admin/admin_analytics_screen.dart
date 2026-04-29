import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/admin_provider.dart';
import '../../config/theme.dart';
import '../../widgets/loading_widget.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoading = true);
    final data = await context.read<AdminProvider>().getPlatformAnalytics();
    if (mounted) {
      setState(() {
        _analytics = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Platform Analytics'),
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Generating Reports...')
          : RefreshIndicator(
              onRefresh: _fetchAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryGrid(),
                    const SizedBox(height: 24),
                    const Text('Revenue Growth (Last 6 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildRevenueChart(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatBox(label: 'Platform Earnings', value: 'PKR ${_fmt(_analytics?['totalPlatformFee'] ?? 0)}', icon: Icons.account_balance_wallet_rounded, color: Colors.green),
        _StatBox(label: 'Gross Sales', value: 'PKR ${_fmt(_analytics?['totalRevenue'] ?? 0)}', icon: Icons.payments_rounded, color: Colors.blue),
        _StatBox(label: 'Items Sold', value: '${_analytics?['totalItemsSold'] ?? 0}', icon: Icons.inventory_rounded, color: Colors.orange),
        _StatBox(label: 'Active Orders', value: '${_analytics?['activeOrders'] ?? 0}', icon: Icons.local_shipping_rounded, color: Colors.purple),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final List<Map<String, dynamic>> monthlyData = List<Map<String, dynamic>>.from(_analytics?['monthlyData'] ?? []);
    if (monthlyData.isEmpty) return const Center(child: Text('No data available'));

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < monthlyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(monthlyData[idx]['month'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: monthlyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['revenue'] as num).toDouble())).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic v) {
    final val = (v is num) ? v.toDouble() : 0.0;
    return val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../attendance/sales_manager_attendance_screen.dart';
import '../customers/sales_manager_customers_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../follow_ups/sales_manager_follow_ups_screen.dart';
import '../leads/sales_manager_leads_screen.dart';
import '../orders/sales_manager_orders_screen.dart';
import '../stock/sales_manager_stock_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class SalesManagerPerformanceScreen extends StatefulWidget {
  const SalesManagerPerformanceScreen({super.key});

  @override
  State<SalesManagerPerformanceScreen> createState() =>
      _SalesManagerPerformanceScreenState();
}

class _SalesManagerPerformanceScreenState
    extends State<SalesManagerPerformanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_PerformanceMetric> _metrics = const [
    _PerformanceMetric(
      title: 'Monthly Sales',
      target: 'Target: Rs50,000',
      achieved: 'Rs42,000',
      achievedLabel: 'Achieved',
      progress: 0.84,
      percentLabel: '84%',
      icon: Icons.track_changes_outlined,
    ),
    _PerformanceMetric(
      title: 'New Customers',
      target: 'Target: 20',
      achieved: '15',
      achievedLabel: 'Achieved',
      progress: 0.75,
      percentLabel: '75%',
      icon: Icons.track_changes_outlined,
    ),
    _PerformanceMetric(
      title: 'Orders Created',
      target: 'Target: 50',
      achieved: '45',
      achievedLabel: 'Achieved',
      progress: 0.90,
      percentLabel: '90%',
      icon: Icons.track_changes_outlined,
    ),
    _PerformanceMetric(
      title: 'Visits Completed',
      target: 'Target: 30',
      achieved: '28',
      achievedLabel: 'Achieved',
      progress: 0.93,
      percentLabel: '93%',
      icon: Icons.track_changes_outlined,
    ),
    _PerformanceMetric(
      title: 'Follow-ups Done',
      target: 'Target: 40',
      achieved: '35',
      achievedLabel: 'Achieved',
      progress: 0.88,
      percentLabel: '88%',
      icon: Icons.track_changes_outlined,
    ),
  ];

  void _showSnack(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action is not wired yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'My Performance' ||
        action == 'Targets & Performance' ||
        action == 'Targets and Performance') {
      return;
    }
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerCustomersScreen()),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerLeadsScreen()),
      );
      return;
    }
    if (action == 'Create Order' || action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerOrdersScreen()),
      );
      return;
    }
    if (action == 'Stock') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }
    if (action == 'Follow-Ups' || action == 'Follow-ups') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerFollowUpsScreen(),
        ),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerAttendanceScreen(),
        ),
      );
      return;
    }
    _showSnack(action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'My Performance',
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SalesManagerTopBar(title: 'My Performance'),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricGrid(),
                        const SizedBox(height: 16),
                        _buildOverallPerformance(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 1180;
        final medium = constraints.maxWidth > 760;

        if (!medium) {
          return Column(
            children: [
              for (var i = 0; i < _metrics.length; i++) ...[
                _MetricCard(data: _metrics[i]),
                if (i != _metrics.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        final firstRow = _metrics.take(3).toList();
        final secondRow = _metrics.skip(3).toList();

        return Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < firstRow.length; i++) ...[
                  Expanded(child: _MetricCard(data: firstRow[i])),
                  if (i != firstRow.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: secondRow.isNotEmpty
                      ? _MetricCard(data: secondRow.first)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: secondRow.length > 1
                      ? _MetricCard(data: secondRow[1])
                      : const SizedBox.shrink(),
                ),
                if (wide) const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverallPerformance() {
    const overallScore = 0.88;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Performance',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "This month's overall progress",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: overallScore,
                    minHeight: 12,
                    backgroundColor: AppColors.surfaceSoft,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                '88%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Overall Score',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _PerformanceMetric data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.target,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: AppColors.primary, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.achieved,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.achievedLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.percentLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'of target',
                    style: TextStyle(
                      color: AppColors.textLightMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: data.progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceSoft,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceMetric {
  final String title;
  final String target;
  final String achieved;
  final String achievedLabel;
  final double progress;
  final String percentLabel;
  final IconData icon;

  const _PerformanceMetric({
    required this.title,
    required this.target,
    required this.achieved,
    required this.achievedLabel,
    required this.progress,
    required this.percentLabel,
    required this.icon,
  });
}

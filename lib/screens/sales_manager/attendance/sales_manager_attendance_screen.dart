import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/delivery_attendance_record.dart';
import '../../../providers/api_provider.dart';
import '../../delivery/customers/delivery_customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../admin/quotations/admin_quotations_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../follow_ups/sales_manager_follow_ups_screen.dart';
import '../performance/sales_manager_performance_screen.dart';
import '../stock/sales_manager_stock_screen.dart';
import '../visits/sales_manager_visits_screen.dart';
import '../../delivery/attendance/delivery_attendance_calendar_screen.dart';

class SalesManagerAttendanceScreen extends StatefulWidget {
  const SalesManagerAttendanceScreen({super.key});

  @override
  State<SalesManagerAttendanceScreen> createState() =>
      _SalesManagerAttendanceScreenState();
}

class _SalesManagerAttendanceScreenState
    extends State<SalesManagerAttendanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<DeliveryAttendanceRecord>>? _attendanceFuture;
  bool _didStartLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _attendanceFuture = _loadAttendance();
      _didStartLoad = true;
    }
  }

  Future<List<DeliveryAttendanceRecord>> _loadAttendance() async {
    final rows = await ApiProviderScope.of(context).fetchMyAttendance();
    final records = rows.map(DeliveryAttendanceRecord.fromJson).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  void _openAttendanceCalendar(List<DeliveryAttendanceRecord> records) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryAttendanceCalendarScreen(records: records),
      ),
    );
  }

  final List<_CheckpointCardData> _checkpoints = const [
    _CheckpointCardData(
      title: 'Office Check-In',
      time: '04:33 PM',
      icon: Icons.login_rounded,
    ),
    _CheckpointCardData(
      title: 'Departure',
      time: '04:34 PM',
      icon: Icons.location_on_outlined,
    ),
    _CheckpointCardData(
      title: 'Return to Office',
      time: '04:34 PM',
      icon: Icons.apartment_outlined,
    ),
    _CheckpointCardData(
      title: 'Final Check-Out',
      time: '04:34 PM',
      icon: Icons.logout_rounded,
    ),
  ];
  final List<bool> _checkpointRecorded = List<bool>.filled(4, false);

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
    if (action == 'Attendance') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DeliveryCustomersScreen(),
        ),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Create Order') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NewAdminOrderScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Quotations' || action == 'Quotation') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const AdminQuotationsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
        ),
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
        MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
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
    _showSnack(action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Attendance',
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SalesManagerTopBar(title: 'Attendance'),
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
                        _buildCheckpointSection(),
                        const SizedBox(height: 22),
                        FutureBuilder<List<DeliveryAttendanceRecord>>(
                          future: _attendanceFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return _AttendanceLoadError(
                                onRetry: () => setState(
                                  () => _attendanceFuture = _loadAttendance(),
                                ),
                              );
                            }
                            return _buildHistorySection(
                              snapshot.data ?? const <DeliveryAttendanceRecord>[],
                            );
                          },
                        ),
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

  Widget _buildCheckpointSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
          const Text(
            "Today's Checkpoints",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 1100;
              if (!wide) {
                return Column(
                  children: [
                    for (var i = 0; i < _checkpoints.length; i++) ...[
                      _CheckpointCard(
                        data: _checkpoints[i],
                        recorded: _checkpointRecorded[i],
                        onMarkPresent: () {
                          setState(() => _checkpointRecorded[i] = true);
                        },
                      ),
                      if (i != _checkpoints.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < _checkpoints.length; i++) ...[
                    Expanded(
                      child: _CheckpointCard(
                        data: _checkpoints[i],
                        recorded: _checkpointRecorded[i],
                        onMarkPresent: () {
                          setState(() => _checkpointRecorded[i] = true);
                        },
                      ),
                    ),
                    if (i != _checkpoints.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<DeliveryAttendanceRecord> records) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
              const Expanded(
                child: Text(
                  'Attendance History',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _openAttendanceCalendar(records),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.green,
                  backgroundColor: AppColors.green.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _AttendanceHeaderRow(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          for (var i = 0; i < records.length; i++) ...[
            _AttendanceRow(record: records[i]),
            if (i != records.length - 1)
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
        ],
      ),
    );
  }
}

class _CheckpointCard extends StatelessWidget {
  final _CheckpointCardData data;
  final bool recorded;
  final VoidCallback onMarkPresent;

  const _CheckpointCard({
    required this.data,
    required this.recorded,
    required this.onMarkPresent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, color: AppColors.textPrimary, size: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.time,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: recorded
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Recorded',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textLightMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onMarkPresent,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Mark Present',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceHeaderRow extends StatelessWidget {
  const _AttendanceHeaderRow();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.9,
    );

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('DATE', style: labelStyle)),
          Expanded(flex: 2, child: Text('STATUS', style: labelStyle)),
          Expanded(flex: 2, child: Text('CHECK IN', style: labelStyle)),
          Expanded(flex: 2, child: Text('CHECK OUT', style: labelStyle)),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final DeliveryAttendanceRecord record;

  const _AttendanceRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              formatAttendanceDate(record.date),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusPill(
              label: record.status == 'present' ? 'Present' : 'Absent',
              color: record.isPresent ? AppColors.green : AppColors.red,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatAttendanceTime(record.checkIn),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatAttendanceTime(record.checkOut),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckpointCardData {
  final String title;
  final String time;
  final IconData icon;

  const _CheckpointCardData({
    required this.title,
    required this.time,
    required this.icon,
  });
}

class _AttendanceLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _AttendanceLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry attendance'),
        ),
      ),
    );
  }
}

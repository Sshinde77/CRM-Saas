import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../admin/customers/customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../attendance/sales_manager_attendance_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../follow_ups/sales_manager_follow_ups_screen.dart';
import '../performance/sales_manager_performance_screen.dart';
import '../stock/sales_manager_stock_screen.dart';

class SalesManagerVisitsScreen extends StatefulWidget {
  const SalesManagerVisitsScreen({super.key});

  @override
  State<SalesManagerVisitsScreen> createState() =>
      _SalesManagerVisitsScreenState();
}

class _SalesManagerVisitsScreenState extends State<SalesManagerVisitsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<_VisitEntry> _visits = const [
    _VisitEntry(
      customer: 'Rajesh Kumar',
      inTime: '2024-07-17 10:30 AM',
      outTime: '2024-07-17 11:15 AM',
      notes: 'Discussed new product range, placed order for 100 units',
      status: 'Completed',
    ),
    _VisitEntry(
      customer: 'Priya Desai',
      inTime: '2024-07-16 02:00 PM',
      outTime: '2024-07-16 02:45 PM',
      notes: 'Follow-up on previous order, collected payment',
      status: 'Completed',
    ),
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
    if (action == 'Visits') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
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
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomersScreen(useSalesManagerShell: true),
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
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
      );
      return;
    }
    _showSnack(action);
  }

  void _handleCheckIn() {
    final customer = _customerNameController.text.trim();
    final notes = _notesController.text.trim();

    final message = customer.isEmpty
        ? 'Check in is not wired yet'
        : 'Check in saved for $customer${notes.isEmpty ? '' : ' with notes'}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Visits',
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SalesManagerTopBar(title: 'Visits'),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 980;
                    final leftPanel = _CheckInCard(
                      customerNameController: _customerNameController,
                      notesController: _notesController,
                      onCheckIn: _handleCheckIn,
                    );
                    final rightPanel = _VisitHistoryPanel(visits: _visits);

                    if (!wide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leftPanel,
                          const SizedBox(height: 14),
                          rightPanel,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth * 0.34,
                          child: leftPanel,
                        ),
                        const SizedBox(width: 20),
                        Expanded(child: rightPanel),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInCard extends StatefulWidget {
  final TextEditingController customerNameController;
  final TextEditingController notesController;
  final VoidCallback onCheckIn;

  const _CheckInCard({
    required this.customerNameController,
    required this.notesController,
    required this.onCheckIn,
  });

  @override
  State<_CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends State<_CheckInCard> {
  late final FocusNode _customerFocusNode;
  late final FocusNode _notesFocusNode;

  @override
  void initState() {
    super.initState();
    _customerFocusNode = FocusNode()..addListener(_onFocusChanged);
    _notesFocusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _customerFocusNode.removeListener(_onFocusChanged);
    _notesFocusNode.removeListener(_onFocusChanged);
    _customerFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  bool get _customerFocused => _customerFocusNode.hasFocus;
  bool get _notesFocused => _notesFocusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check In',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Customer Name *',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _FieldContainer(
            focused: _customerFocused,
            child: TextField(
              controller: widget.customerNameController,
              focusNode: _customerFocusNode,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                hintText: '',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Notes (optional)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _FieldContainer(
            focused: _notesFocused,
            child: TextField(
              controller: widget.notesController,
              focusNode: _notesFocusNode,
              maxLines: 4,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton.icon(
              onPressed: widget.onCheckIn,
              icon: const Icon(Icons.place_outlined, size: 16),
              label: const Text(
                'Check In',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldContainer extends StatelessWidget {
  final Widget child;
  final bool focused;

  const _FieldContainer({required this.child, required this.focused});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused
              ? AppColors.primary
              : AppColors.border.withValues(alpha: 0.85),
          width: focused ? 1.4 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }
}

class _VisitHistoryPanel extends StatelessWidget {
  final List<_VisitEntry> visits;

  const _VisitHistoryPanel({required this.visits});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            'Visit History',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (var i = 0; i < visits.length; i++) ...[
          _VisitHistoryCard(record: visits[i]),
          if (i != visits.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _VisitHistoryCard extends StatelessWidget {
  final _VisitEntry record;

  const _VisitHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 24, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
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
                child: Text(
                  record.customer,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(label: record.status, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'In: ${record.inTime}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.schedule_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Out: ${record.outTime}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.75)),
          const SizedBox(height: 16),
          Text(
            record.notes,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VisitEntry {
  final String customer;
  final String inTime;
  final String outTime;
  final String notes;
  final String status;

  const _VisitEntry({
    required this.customer,
    required this.inTime,
    required this.outTime,
    required this.notes,
    required this.status,
  });
}

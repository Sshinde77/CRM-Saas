import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/completion_feedback_sheet.dart';
import '../../../widgets/delivery/customer_search_dialog.dart';
import '../../delivery/customers/delivery_customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../admin/quotations/admin_quotations_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_bottom_navigation.dart';
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
  final _pagination = ListPagination();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<CustomerModel> _customers = const [];
  CustomerModel? _selectedCustomer;
  bool _loadingCustomers = true;
  String? _customerLoadError;

  final List<_VisitEntry> _visits = [
    const _VisitEntry(
      customer: 'Rajesh Kumar',
      inTime: '2024-07-17 10:30 AM',
      outTime: '2024-07-17 11:15 AM',
      notes: 'Discussed new product range, placed order for 100 units',
      status: 'Completed',
    ),
    const _VisitEntry(
      customer: 'Priya Desai',
      inTime: '2024-07-16 02:00 PM',
      outTime: '2024-07-16 02:45 PM',
      notes: 'Follow-up on previous order, collected payment',
      status: 'Completed',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomers());
  }

  Future<void> _loadCustomers() async {
    if (!mounted) return;
    setState(() {
      _loadingCustomers = true;
      _customerLoadError = null;
    });
    try {
      final customers = await ApiProviderScope.of(context).fetchCustomers();
      if (!mounted) return;
      setState(() {
        _customers = customers;
        _loadingCustomers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCustomers = false;
        _customerLoadError = 'Unable to load customers';
      });
    }
  }

  Future<void> _selectCustomer() async {
    if (_loadingCustomers) return;
    if (_customerLoadError != null) {
      await _loadCustomers();
      if (!mounted || _customerLoadError != null) return;
    }
    final customer = await showDialog<CustomerModel>(
      context: context,
      builder: (_) => CustomerSearchDialog(
        customers: _customers,
        selectedCustomerId: _selectedCustomer?.id,
        emptyMessage: 'No customers available.',
      ),
    );
    if (!mounted || customer == null) return;
    setState(() {
      _selectedCustomer = customer;
      _customerNameController.text = customer.name;
    });
  }

  @override
  void dispose() {
    _pagination.dispose();
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
          builder: (_) => const DeliveryCustomersScreen(),
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

    if (customer.isEmpty || _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer before checking in.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _visits.insert(
        0,
        _VisitEntry(
          customer: customer,
          inTime: _formatVisitTime(DateTime.now()),
          outTime: '—',
          notes: notes.isEmpty ? 'No check-in notes.' : notes,
          status: 'In Progress',
        ),
      );
      _selectedCustomer = null;
      _customerNameController.clear();
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in at $customer.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _closeVisit(int index) async {
    if (index < 0 || index >= _visits.length) return;
    final visit = _visits[index];
    final feedback = await showCompletionFeedbackSheet(
      context: context,
      title: 'Close visit',
      subjectLabel: visit.customer,
    );
    if (!mounted || feedback == null) return;
    setState(() {
      _visits[index] = visit.copyWith(
        outTime: _formatVisitTime(DateTime.now()),
        notes: '${visit.notes}\n\nClosing feedback: $feedback',
        status: 'Completed',
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visit closed successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visits = _pagination.local(_visits);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.deliveryBackground,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Visits',
      ),
      bottomNavigationBar: const SalesManagerBottomNavigation(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            const SalesManagerTopBar(title: 'Visits'),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 840;
                    final leftPanel = _CheckInCard(
                      customerNameController: _customerNameController,
                      loadingCustomers: _loadingCustomers,
                      customerLoadError: _customerLoadError,
                      onSelectCustomer: _selectCustomer,
                      notesController: _notesController,
                      onCheckIn: _handleCheckIn,
                    );
                    final rightPanel = _VisitHistoryPanel(
                      visits: visits,
                      onCloseVisit: (index) => _closeVisit(
                        (_pagination.page - 1) * _pagination.pageSize + index,
                      ),
                    );

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          children: [
                            _VisitsOverview(totalVisits: _visits.length),
                            const SizedBox(height: 16),
                            if (!wide) ...[
                              leftPanel,
                              const SizedBox(height: 20),
                              rightPanel,
                            ] else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 320, child: leftPanel),
                                  const SizedBox(width: 20),
                                  Expanded(child: rightPanel),
                                ],
                              ),
                            ListPaginationBar(
                              pagination: _pagination,
                              onChanged: () => setState(() {}),
                            ),
                          ],
                        ),
                      ),
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

class _VisitsOverview extends StatelessWidget {
  final int totalVisits;

  const _VisitsOverview({required this.totalVisits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer visits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check in and keep every customer interaction organised.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$totalVisits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'visits',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatefulWidget {
  final TextEditingController customerNameController;
  final bool loadingCustomers;
  final String? customerLoadError;
  final VoidCallback onSelectCustomer;
  final TextEditingController notesController;
  final VoidCallback onCheckIn;

  const _CheckInCard({
    required this.customerNameController,
    required this.loadingCustomers,
    required this.customerLoadError,
    required this.onSelectCustomer,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Customer Name *',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: widget.onSelectCustomer,
            child: _FieldContainer(
              focused: _customerFocused,
              child: TextField(
                controller: widget.customerNameController,
                focusNode: _customerFocusNode,
                readOnly: true,
                onTap: widget.onSelectCustomer,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  hintText: widget.loadingCustomers
                      ? 'Loading customers...'
                      : widget.customerLoadError ?? 'Select customer',
                  suffixIcon: widget.loadingCustomers
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                fontSize: 14,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
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
                  borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
  final ValueChanged<int> onCloseVisit;

  const _VisitHistoryPanel({required this.visits, required this.onCloseVisit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Visit History',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (var i = 0; i < visits.length; i++) ...[
          _VisitHistoryCard(record: visits[i], onClose: () => onCloseVisit(i)),
          if (i != visits.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VisitHistoryCard extends StatelessWidget {
  final _VisitEntry record;
  final VoidCallback onClose;

  const _VisitHistoryCard({required this.record, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(label: record.status, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _VisitTime(label: 'In', value: record.inTime),
              _VisitTime(label: 'Out', value: record.outTime),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.75)),
          const SizedBox(height: 12),
          Text(
            record.notes,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          if (record.status != 'Completed') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Close Visit'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitTime extends StatelessWidget {
  final String label;
  final String value;

  const _VisitTime({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.schedule_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

  _VisitEntry copyWith({String? outTime, String? notes, String? status}) {
    return _VisitEntry(
      customer: customer,
      inTime: inTime,
      outTime: outTime ?? this.outTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

String _formatVisitTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : (value.hour > 12 ? value.hour - 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.year}-$month-$day ${hour.toString().padLeft(2, '0')}:$minute $period';
}

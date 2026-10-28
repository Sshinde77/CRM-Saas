import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/completion_feedback_sheet.dart';
import '../../delivery/customers/delivery_customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../admin/quotations/admin_quotations_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_bottom_navigation.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../../widgets/shared/management_page_summary.dart';
import '../../delivery/attendance/delivery_attendance_screen.dart';
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
  List<CustomerModel> _customers = const [];

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
    try {
      final customers = await ApiProviderScope.of(context).fetchCustomers();
      if (!mounted) return;
      setState(() {
        _customers = customers;
      });
    } catch (_) {
      // The customer count is supplemental; the visit form remains usable.
    }
  }

  Future<void> _openLogVisitDialog() async {
    final result = await Navigator.of(context).push<_LogVisitResult>(
      MaterialPageRoute(builder: (_) => const _CreateVisitPage()),
    );
    if (result == null || !mounted) return;
    setState(() {
      _visits.insert(
        0,
        _VisitEntry(
          customer: result.leadName,
          inTime: _formatVisitTime(DateTime.now()),
          outTime: '—',
          notes: [
            'Type: ${result.visitType[0].toUpperCase()}${result.visitType.substring(1)}',
            'Purpose: ${result.purpose}',
            if (result.notes.isNotEmpty) 'Notes: ${result.notes}',
            if (result.outcome.isNotEmpty) 'Outcome: ${result.outcome}',
          ].join('\n'),
          status: 'In Progress',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visit logged for ${result.leadName}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pagination.dispose();
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
        MaterialPageRoute(builder: (_) => const DeliveryCustomersScreen()),
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
        MaterialPageRoute(builder: (_) => const DeliveryAttendanceScreen()),
      );
      return;
    }
    _showSnack(action);
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      children: [
                        ManagementPageSummary(
                          title: 'Visits',
                          subtitle: '${_visits.length} customer visits',
                          icon: Icons.location_on_outlined,
                          onAdd: _openLogVisitDialog,
                          kpis: [
                            ManagementKpiData(
                              label: 'Total Visits',
                              value: '${_visits.length}',
                              icon: Icons.location_on_outlined,
                              color: AppColors.deliveryBlue,
                              background: AppColors.deliveryBlueSoft,
                            ),
                            ManagementKpiData(
                              label: 'Completed',
                              value:
                                  '${_visits.where((visit) => visit.status == 'Completed').length}',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.deliveryGreen,
                              background: AppColors.deliveryGreenSoft,
                            ),
                            ManagementKpiData(
                              label: 'In Progress',
                              value:
                                  '${_visits.where((visit) => visit.status == 'In Progress').length}',
                              icon: Icons.timelapse_rounded,
                              color: AppColors.deliveryOrange,
                              background: AppColors.deliveryOrangeSoft,
                            ),
                            ManagementKpiData(
                              label: 'Customers',
                              value: '${_customers.length}',
                              icon: Icons.groups_2_outlined,
                              color: AppColors.deliveryCustomerOrders,
                              background: AppColors.deliveryCustomerOrdersSoft,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _VisitHistoryPanel(
                          visits: visits,
                          onCloseVisit: (index) => _closeVisit(
                            (_pagination.page - 1) * _pagination.pageSize +
                                index,
                          ),
                        ),
                        ListPaginationBar(
                          pagination: _pagination,
                          onChanged: () => setState(() {}),
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
}

// ignore: unused_element
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

class _LogVisitResult {
  final String leadName;
  final String visitType;
  final String purpose;
  final String notes;
  final String outcome;

  const _LogVisitResult({
    required this.leadName,
    required this.visitType,
    required this.purpose,
    required this.notes,
    required this.outcome,
  });
}

class _CreateVisitPage extends StatefulWidget {
  const _CreateVisitPage();

  @override
  State<_CreateVisitPage> createState() => _CreateVisitPageState();
}

class _CreateVisitPageState extends State<_CreateVisitPage> {
  final _purposeController = TextEditingController(text: 'Product Demo');
  final _notesController = TextEditingController();
  final _outcomeController = TextEditingController();

  List<_VisitLeadOption> _leads = const [];
  _VisitLeadOption? _selectedLead;
  bool _loadingLeads = true;
  String? _leadLoadError;
  String _visitType = 'lead';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLeads());
  }

  Future<void> _loadLeads() async {
    if (!mounted) return;
    setState(() {
      _loadingLeads = true;
      _leadLoadError = null;
    });
    try {
      final raw = await ApiProviderScope.of(context).fetchLeads();
      if (!mounted) return;
      setState(() {
        _leads = raw
            .map(_VisitLeadOption.fromJson)
            .where((l) => l.id.isNotEmpty && l.name.isNotEmpty)
            .toList();
        _loadingLeads = false;
        _leadLoadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingLeads = false;
        _leadLoadError = 'Unable to load. Tap to retry.';
      });
    }
  }

  Future<void> _selectLead() async {
    if (_loadingLeads) return;
    if (_leadLoadError != null) {
      await _loadLeads();
      if (!mounted || _leadLoadError != null) return;
    }
    final lead = await showDialog<_VisitLeadOption>(
      context: context,
      builder: (_) =>
          _LeadSearchDialog(leads: _leads, selectedLeadId: _selectedLead?.id),
    );
    if (!mounted || lead == null) return;
    setState(() => _selectedLead = lead);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  void _save() {
    final purpose = _purposeController.text.trim();
    if (_selectedLead == null || purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a lead and enter the visit purpose.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _LogVisitResult(
        leadName: _selectedLead!.name,
        visitType: _visitType,
        purpose: purpose,
        notes: _notesController.text.trim(),
        outcome: _outcomeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      body: SafeArea(
        child: Column(
          children: [
            SalesManagerTopBar(
              title: 'Log Client Visit',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _VisitFieldLabel('Lead *'),
                        const SizedBox(height: 8),
                        _VisitLeadPickerCard(
                          selected: _selectedLead,
                          loading: _loadingLeads,
                          error: _leadLoadError,
                          onTap: _selectLead,
                          onClear: _selectedLead == null
                              ? null
                              : () => setState(() => _selectedLead = null),
                        ),
                        const SizedBox(height: 18),
                        _VisitFieldLabel('Visit Type'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _visitType,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'lead',
                              child: Text('Lead'),
                            ),
                            DropdownMenuItem(
                              value: 'customer',
                              child: Text('Customer'),
                            ),
                            DropdownMenuItem(
                              value: 'supplier',
                              child: Text('Supplier'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _visitType = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        _VisitFieldLabel('Purpose *'),
                        const SizedBox(height: 8),
                        _VisitInputBox(
                          controller: _purposeController,
                          hintText: 'Visit objective',
                        ),
                        const SizedBox(height: 18),
                        _VisitFieldLabel('Notes & Discussion'),
                        const SizedBox(height: 8),
                        _VisitInputBox(
                          controller: _notesController,
                          hintText: 'Key discussion points...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 18),
                        _VisitFieldLabel('Outcome'),
                        const SizedBox(height: 8),
                        _VisitInputBox(
                          controller: _outcomeController,
                          hintText: 'e.g. Requested quotation',
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.deliveryCardBorder),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.location_on_rounded, size: 20),
                  label: const Text(
                    'Log Visit',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitLeadOption {
  final String id;
  final String name;
  final String code;

  const _VisitLeadOption({
    required this.id,
    required this.name,
    required this.code,
  });

  factory _VisitLeadOption.fromJson(Map<String, dynamic> json) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return '';
    }

    return _VisitLeadOption(
      id: read(['id', 'lead_id']),
      name: read(['company_name', 'companyName', 'name', 'contact_person']),
      code: read(['lead_code', 'leadCode', 'code', 'lead_id']),
    );
  }
}

class _VisitLeadPickerCard extends StatelessWidget {
  final _VisitLeadOption? selected;
  final bool loading;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _VisitLeadPickerCard({
    required this.selected,
    required this.loading,
    required this.error,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasSelection ? AppColors.activeMenuBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasSelection ? AppColors.primary : AppColors.border,
            width: hasSelection ? 1.4 : 1.0,
          ),
        ),
        child: hasSelection
            ? Row(
                children: [
                  _VisitPersonAvatar(name: selected!.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected!.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (selected!.code.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            selected!.code,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onClear != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.activeMenuBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      loading
                          ? Icons.hourglass_empty_rounded
                          : (error != null
                                ? Icons.refresh_rounded
                                : Icons.search_rounded),
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loading
                          ? 'Loading leads...'
                          : (error ?? 'Tap to search and select a lead'),
                      style: TextStyle(
                        color: error != null
                            ? AppColors.red
                            : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
      ),
    );
  }
}

class _VisitPersonAvatar extends StatelessWidget {
  final String name;

  const _VisitPersonAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join('');
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LeadSearchDialog extends StatefulWidget {
  final List<_VisitLeadOption> leads;
  final String? selectedLeadId;

  const _LeadSearchDialog({required this.leads, this.selectedLeadId});

  @override
  State<_LeadSearchDialog> createState() => _LeadSearchDialogState();
}

class _LeadSearchDialogState extends State<_LeadSearchDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final leads = widget.leads
        .where(
          (lead) =>
              query.isEmpty ||
              lead.name.toLowerCase().contains(query) ||
              lead.code.toLowerCase().contains(query),
        )
        .toList();

    return AlertDialog(
      title: const Text('Select Lead'),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search leads',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: leads.isEmpty
                  ? const Center(child: Text('No matching leads'))
                  : ListView.separated(
                      itemCount: leads.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(lead.name),
                          subtitle: lead.code.isEmpty ? null : Text(lead.code),
                          trailing: lead.id == widget.selectedLeadId
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(lead),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitFieldLabel extends StatelessWidget {
  final String label;

  const _VisitFieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _VisitInputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _VisitInputBox({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: AppColors.primary,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _VisitTapInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;

  const _VisitTapInput({
    required this.controller,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: IgnorePointer(
        child: _VisitInputBox(controller: controller, hintText: hintText),
      ),
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

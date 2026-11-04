import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/completion_feedback_sheet.dart';
import '../../../widgets/customer_avatar.dart';
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
      MaterialPageRoute(builder: (_) => const CreateVisitPage()),
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

  Future<void> _openVisitDetails(int index) async {
    if (index < 0 || index >= _visits.length) return;
    final updated = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => VisitDetailScreen(
          customer: _visits[index].customer,
          inTime: _visits[index].inTime,
          outTime: _visits[index].outTime,
          notes: _visits[index].notes,
          status: _visits[index].status,
        ),
      ),
    );
    if (!mounted || updated == null) return;
    if (updated.status == 'Completed') {
      setState(() => _visits[index] = updated);
    }
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
                          onOpenVisit: (index) => _openVisitDetails(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer visits',
                  style: AppTextStyles.sectionHeading.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check in and keep every customer interaction organised.',
                  style: AppTextStyles.small.copyWith(color: Colors.white70),
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
                  style: AppTextStyles.importantNumber.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'visits',
                  style: AppTextStyles.small.copyWith(color: Colors.white70),
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

class CreateVisitPage extends StatefulWidget {
  final String? initialCustomerId;

  const CreateVisitPage({super.key, this.initialCustomerId});

  @override
  State<CreateVisitPage> createState() => _CreateVisitPageState();
}

class _CreateVisitPageState extends State<CreateVisitPage> {
  final _purposeController = TextEditingController(text: 'Product Demo');
  final _notesController = TextEditingController();
  final _outcomeController = TextEditingController();

  List<_VisitPartyOption> _parties = const [];
  _VisitPartyOption? _selectedParty;
  bool _loadingParties = true;
  String? _partyLoadError;
  String _visitType = 'lead';

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomerId?.trim().isNotEmpty == true) {
      _visitType = 'customer';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadParties());
  }

  Future<void> _loadParties() async {
    if (!mounted) return;
    setState(() {
      _loadingParties = true;
      _partyLoadError = null;
    });
    try {
      final api = ApiProviderScope.of(context);
      final parties = <_VisitPartyOption>[];
      if (_visitType == 'lead') {
        final pagination = ListPagination()..pageSize = 100;
        try {
          do {
            final raw = await api.fetchLeads(pagination: pagination);
            parties.addAll(raw.map(_VisitPartyOption.fromJson));
            if (pagination.page >= pagination.totalPages) break;
            pagination.page++;
          } while (true);
        } finally {
          pagination.dispose();
        }
      } else if (_visitType == 'customer') {
        final pagination = ListPagination()..pageSize = 100;
        try {
          do {
            final customers = await api.fetchCustomers(
              pagination: pagination,
              isActive: true,
            );
            parties.addAll(
              customers.map(
                (customer) => _VisitPartyOption(
                  id: customer.id,
                  name: (customer.businessName ?? customer.name).trim(),
                  code: (customer.customerId ?? '').trim(),
                  photoUrl: customer.profilePhotoUrl ?? '',
                ),
              ),
            );
            if (pagination.page >= pagination.totalPages) break;
            pagination.page++;
          } while (true);
        } finally {
          pagination.dispose();
        }
      } else {
        var page = 1;
        var totalPages = 1;
        do {
          final result = await api.fetchPaginatedSuppliers(
            page: page,
            pageSize: 100,
            isActive: true,
          );
          parties.addAll(result.items.map(_VisitPartyOption.fromJson));
          totalPages = result.totalPages <= 0 ? 1 : result.totalPages;
          page++;
        } while (page <= totalPages);
      }
      if (!mounted) return;
      final initialCustomerId = widget.initialCustomerId?.trim();
      final initialParty =
          initialCustomerId == null || initialCustomerId.isEmpty
          ? null
          : parties.where((party) => party.id == initialCustomerId).firstOrNull;
      setState(() {
        _parties = parties
            .where((party) => party.id.isNotEmpty && party.name.isNotEmpty)
            .toList();
        _selectedParty = initialParty;
        _loadingParties = false;
        _partyLoadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingParties = false;
        _partyLoadError = 'Unable to load. Tap to retry.';
      });
    }
  }

  Future<void> _selectParty() async {
    if (_loadingParties) return;
    if (_partyLoadError != null) {
      await _loadParties();
      if (!mounted || _partyLoadError != null) return;
    }
    final party = await showDialog<_VisitPartyOption>(
      context: context,
      builder: (_) => _VisitPartySearchDialog(
        title: 'Select $_visitTypeLabel',
        searchHint: 'Search $_visitTypeLabel',
        parties: _parties,
        selectedId: _selectedParty?.id,
      ),
    );
    if (!mounted || party == null) return;
    setState(() => _selectedParty = party);
  }

  String get _visitTypeLabel =>
      _visitType[0].toUpperCase() + _visitType.substring(1);

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  void _save() {
    final purpose = _purposeController.text.trim();
    if (_selectedParty == null || purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a Lead, Customer, or Supplier and enter the visit purpose.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _LogVisitResult(
        leadName: _selectedParty!.name,
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
                        _VisitFieldLabel('Visit Type'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _visitType,
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
                            if (value != null) {
                              setState(() {
                                _visitType = value;
                                _selectedParty = null;
                              });
                              _loadParties();
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        _VisitFieldLabel('Select $_visitTypeLabel *'),
                        const SizedBox(height: 8),
                        _VisitPartyPickerCard(
                          selected: _selectedParty,
                          loading: _loadingParties,
                          error: _partyLoadError,
                          entityLabel: _visitTypeLabel,
                          onTap: _selectParty,
                          onClear: _selectedParty == null
                              ? null
                              : () => setState(() => _selectedParty = null),
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
                    style: TextStyle(fontWeight: FontWeight.w600),
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

  // ignore: unused_element
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

// ignore: unused_element
class _VisitLeadPickerCard extends StatelessWidget {
  final _VisitLeadOption? selected;
  final bool loading;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  // ignore: unused_element_parameter
  const _VisitLeadPickerCard({
    required this.selected,
    required this.loading,
    required this.error,
    required this.onTap,
    // ignore: unused_element_parameter
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
                  CustomerAvatar(name: selected!.name, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected!.name, style: AppTextStyles.bodyStrong),
                        if (selected!.code.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            selected!.code,
                            style: AppTextStyles.smallStrong.copyWith(
                              color: AppColors.primary,
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
                    child: Text(
                      'Change',
                      style: AppTextStyles.smallStrong.copyWith(
                        color: AppColors.primary,
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
                      style: AppTextStyles.body.copyWith(
                        color: error != null
                            ? AppColors.red
                            : AppColors.textSecondary,
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

// ignore: unused_element
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
          style: AppTextStyles.bodyStrong.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _LeadSearchDialog extends StatefulWidget {
  final List<_VisitLeadOption> leads;
  final String? selectedLeadId;

  // ignore: unused_element_parameter
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

class _VisitPartyOption {
  final String id;
  final String name;
  final String code;
  final String photoUrl;

  const _VisitPartyOption({
    required this.id,
    required this.name,
    required this.code,
    this.photoUrl = '',
  });

  factory _VisitPartyOption.fromJson(Map<String, dynamic> json) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return '';
    }

    return _VisitPartyOption(
      id: read(['id', '_id', 'lead_id', 'customer_id', 'supplier_id']),
      name: read([
        'name',
        'company_name',
        'companyName',
        'business_name',
        'businessName',
        'supplier_name',
        'contact_person',
      ]),
      code: read([
        'lead_code',
        'leadCode',
        'customer_code',
        'customerCode',
        'supplier_code',
        'supplierCode',
        'code',
      ]),
      photoUrl: read([
        'customer_profile_photo_url',
        'customer_profile_image_url',
        'profile_photo_url',
        'profile_image_url',
        'profilePhoto',
        'avatar_url',
        'avatar',
      ]),
    );
  }
}

class _VisitPartyPickerCard extends StatelessWidget {
  final _VisitPartyOption? selected;
  final bool loading;
  final String? error;
  final String entityLabel;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _VisitPartyPickerCard({
    required this.selected,
    required this.loading,
    required this.error,
    required this.entityLabel,
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
                  CustomerAvatar(
                    name: selected!.name,
                    photoUrl: selected!.photoUrl,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected!.name, style: AppTextStyles.bodyStrong),
                        if (selected!.code.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            selected!.code,
                            style: AppTextStyles.smallStrong.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Change',
                    style: AppTextStyles.smallStrong.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  if (onClear != null) ...[
                    const SizedBox(width: 8),
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
                          ? 'Loading ${entityLabel.toLowerCase()}s...'
                          : (error ??
                                'Tap to search and select a ${entityLabel.toLowerCase()}'),
                      style: AppTextStyles.body.copyWith(
                        color: error != null
                            ? AppColors.red
                            : AppColors.textSecondary,
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

class _VisitPartySearchDialog extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<_VisitPartyOption> parties;
  final String? selectedId;

  const _VisitPartySearchDialog({
    required this.title,
    required this.searchHint,
    required this.parties,
    this.selectedId,
  });

  @override
  State<_VisitPartySearchDialog> createState() =>
      _VisitPartySearchDialogState();
}

class _VisitPartySearchDialogState extends State<_VisitPartySearchDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final parties = widget.parties
        .where(
          (party) =>
              query.isEmpty ||
              party.name.toLowerCase().contains(query) ||
              party.code.toLowerCase().contains(query),
        )
        .toList();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: parties.isEmpty
                  ? const Center(child: Text('No matching records'))
                  : ListView.separated(
                      itemCount: parties.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final party = parties[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CustomerAvatar(
                            name: party.name,
                            photoUrl: party.photoUrl,
                            size: 40,
                          ),
                          title: Text(party.name),
                          subtitle: party.code.isEmpty
                              ? null
                              : Text(party.code),
                          trailing: party.id == widget.selectedId
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(party),
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
    return Text(label, style: AppTextStyles.fieldLabel);
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
      style: AppTextStyles.fieldValue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
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

class _VisitHistoryPanel extends StatelessWidget {
  final List<_VisitEntry> visits;
  final ValueChanged<int> onCloseVisit;
  final ValueChanged<int> onOpenVisit;

  const _VisitHistoryPanel({
    required this.visits,
    required this.onCloseVisit,
    required this.onOpenVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Visit History', style: AppTextStyles.sectionHeading),
        ),
        for (var i = 0; i < visits.length; i++) ...[
          _VisitHistoryCard(
            record: visits[i],
            onClose: () => onCloseVisit(i),
            onTap: () => onOpenVisit(i),
          ),
          if (i != visits.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VisitHistoryCard extends StatelessWidget {
  final _VisitEntry record;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _VisitHistoryCard({
    required this.record,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                      style: AppTextStyles.bodyStrong,
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
              Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.75),
              ),
              const SizedBox(height: 12),
              Text(record.notes, style: AppTextStyles.body),
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
        ),
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
          style: AppTextStyles.smallStrong.copyWith(
            color: AppColors.textSecondary,
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
        style: AppTextStyles.smallStrong.copyWith(color: color),
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

class VisitDetailScreen extends StatelessWidget {
  final String customer;
  final String inTime;
  final String outTime;
  final String notes;
  final String status;

  const VisitDetailScreen({
    super.key,
    required this.customer,
    required this.inTime,
    required this.outTime,
    required this.notes,
    required this.status,
  });

  @override
  Widget build(BuildContext context) => _VisitDetailPage(
    record: _VisitEntry(
      customer: customer,
      inTime: inTime,
      outTime: outTime,
      notes: notes,
      status: status,
    ),
  );
}

class _VisitDetailPage extends StatefulWidget {
  final _VisitEntry record;

  const _VisitDetailPage({required this.record});

  @override
  State<_VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<_VisitDetailPage> {
  late _VisitEntry _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _closeVisit() async {
    final feedback = await showCompletionFeedbackSheet(
      context: context,
      title: 'Close visit',
      subjectLabel: _record.customer,
    );
    if (!mounted || feedback == null) return;
    setState(() {
      _record = _record.copyWith(
        outTime: _formatVisitTime(DateTime.now()),
        notes: '${_record.notes}\n\nClosing feedback: $feedback',
        status: 'Completed',
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Visit closed successfully.')));
  }

  void _close() => Navigator.of(context).pop(_record);

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: MediaQuery.textScalerOf(
        context,
      ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2),
    ),
    child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.deliveryBackground,
        body: SafeArea(
          child: Column(
            children: [
              SalesManagerTopBar(
                title: 'Visit Details',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: _close,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.deliverySurfaceBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_record.customer, style: AppTextStyles.cardTitle),
                        const SizedBox(height: 16),
                        _VisitDetailRow(
                          icon: Icons.login_rounded,
                          label: 'Check-in',
                          value: _record.inTime,
                        ),
                        const Divider(height: 24),
                        _VisitDetailRow(
                          icon: Icons.logout_rounded,
                          label: 'Check-out',
                          value: _record.outTime,
                        ),
                        const Divider(height: 24),
                        _VisitDetailRow(
                          icon: Icons.flag_outlined,
                          label: 'Status',
                          value: _record.status,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Visit notes',
                          style: AppTextStyles.smallStrong.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_record.notes, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _record.status == 'Completed' ? null : _closeVisit,
                icon: Icon(
                  _record.status == 'Completed'
                      ? Icons.task_alt_rounded
                      : Icons.logout_rounded,
                  size: 20,
                ),
                label: Text(
                  _record.status == 'Completed'
                      ? 'Visit completed'
                      : 'Close Visit',
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _VisitDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VisitDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(value, style: AppTextStyles.bodyStrong),
          ],
        ),
      ),
    ],
  );
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

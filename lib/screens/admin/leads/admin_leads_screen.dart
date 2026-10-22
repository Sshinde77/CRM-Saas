import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';

import 'package:crm_saas/core/theme/app_text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/customer_avatar.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_bottom_navigation.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../shared/lead_detail_screen.dart';
import '../../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../sales_manager/leads/add_lead_screen.dart';
import '../../sales_manager/performance/sales_manager_performance_screen.dart';
import '../../sales_manager/stock/sales_manager_stock_screen.dart';
import '../../sales_manager/visits/sales_manager_visits_screen.dart';
import '../customers/customers_screen.dart';
import '../orders/admin_orders_screen.dart';
import '../orders/new_admin_order_screen.dart';
import '../quotations/admin_quotations_screen.dart';

class AdminLeadsScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const AdminLeadsScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<AdminLeadsScreen> createState() => _AdminLeadsScreenState();
}

class _AdminLeadsScreenState extends State<AdminLeadsScreen> {
  final _pagination = ListPagination();
  int _listRequest = 0;
  Future<void> _changeListPage() async {
    if (_pagination.isLoading) return;
    setState(() => _pagination.isLoading = true);
    try {
      await _loadLeads();
    } finally {
      if (mounted) setState(() => _pagination.isLoading = false);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _statusFilter = 'All Status';
  String _sourceFilter = 'All Sources';
  String _teamFilter = 'All Team';
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _statusOptions = const ['All Status', 'New', 'Follow Up', 'Hot'];
  List<String> _sourceOptions = const [
    'All Sources',
    'Website',
    'Facebook Ads',
    'Referral',
    'Instagram',
  ];
  List<String> _teamOptions = const [
    'All Team',
    'Sunil Sales',
    'Neha Sharma',
    'Amit Verma',
  ];

  List<_LeadRecord> _leads = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadLeads();
    });
  }

  @override
  void dispose() {
    _pagination.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLeads() async {
    final listRequest = ++_listRequest;
    _pagination.filter(
      [
        _searchController.text,
        _statusFilter,
        _sourceFilter,
        _teamFilter,
      ].join('|'),
    );
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _apiProvider.fetchLeads(
        pagination: _pagination,
        status: _statusFilter == 'All Status' ? null : _statusFilter,
      );
      final leads = items.map(_LeadRecord.fromJson).toList();
      if (!mounted || listRequest != _listRequest) return;
      setState(() {
        _leads = leads;
        _statusOptions = [
          'All Status',
          ...leads
              .map((lead) => lead.status)
              .where((v) => v.trim().isNotEmpty)
              .toSet(),
        ];
        _sourceOptions = [
          'All Sources',
          ...leads
              .map((lead) => lead.source)
              .where((v) => v.trim().isNotEmpty)
              .toSet(),
        ];
        _teamOptions = [
          'All Team',
          ...leads
              .map((lead) => lead.assignedTo)
              .where((v) => v.trim().isNotEmpty)
              .toSet(),
        ];
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || listRequest != _listRequest) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddLeadPage() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddLeadScreen()));
    if (created == true && mounted) {
      await _loadLeads();
    }
  }

  Future<void> _openEditLeadPage(_LeadRecord lead) async {
    if (lead.id.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead edit is unavailable for this item.'),
        ),
      );
      return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddLeadScreen(leadId: lead.id)),
    );
    if (updated == true && mounted) {
      await _loadLeads();
    }
  }

  Future<void> _openLeadDetails(_LeadRecord lead) async {
    if (lead.id.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead detail is unavailable for this item.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeadDetailScreen(
          leadId: lead.id,
          useSalesManagerShell: widget.useSalesManagerShell,
        ),
      ),
    );
  }

  Future<void> _callLead(String phone) async {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.isEmpty || sanitized == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available.')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to call $phone')));
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty || digits == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available for WhatsApp.'),
        ),
      );
      return;
    }
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open WhatsApp.')));
    }
  }

  Future<void> _handleLeadAction(_LeadRecord lead, _LeadAction action) async {
    switch (action) {
      case _LeadAction.viewDetails:
        await _openLeadDetails(lead);
        return;
      case _LeadAction.edit:
        await _openEditLeadPage(lead);
        return;
      case _LeadAction.convertToCustomer:
        await _openLeadDetails(lead);
        return;
      case _LeadAction.delete:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Delete action for ${lead.personName} is not available.',
            ),
          ),
        );
        return;
    }
  }

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Leads') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
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
    if (action == 'Follow-ups' || action == 'Follow-Ups') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
        ),
      );
    }
  }

  int _activeFilterCount() {
    var count = 0;
    if (_statusFilter != 'All Status') count++;
    if (_sourceFilter != 'All Sources') count++;
    if (_teamFilter != 'All Team') count++;
    return count;
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempStatus = _statusFilter;
        String tempSource = _sourceFilter;
        String tempTeam = _teamFilter;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.deliveryGreenSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.deliveryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Filter Leads',
                            style: TextStyle(
                              color: AppColors.deliveryInk,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildFilterDropdown(
                      label: 'Lead Status',
                      value: tempStatus,
                      items: _statusOptions,
                      onChanged: (val) {
                        if (val != null) setModalState(() => tempStatus = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterDropdown(
                      label: 'Lead Source',
                      value: tempSource,
                      items: _sourceOptions,
                      onChanged: (val) {
                        if (val != null) setModalState(() => tempSource = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterDropdown(
                      label: 'Assigned Team Member',
                      value: tempTeam,
                      items: _teamOptions,
                      onChanged: (val) {
                        if (val != null) setModalState(() => tempTeam = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.deliverySurfaceBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.controlRadius,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _statusFilter = 'All Status';
                                _sourceFilter = 'All Sources';
                                _teamFilter = 'All Team';
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deliveryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.controlRadius,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _statusFilter = tempStatus;
                                _sourceFilter = tempSource;
                                _teamFilter = tempTeam;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.deliveryCardSoft,
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            border: Border.all(color: AppColors.deliverySurfaceBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
              items: items.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(
                      color: AppColors.deliveryInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  List<_LeadRecord> _filteredLeads() {
    final query = _searchController.text.trim().toLowerCase();

    return _leads.where((lead) {
      final statusOk =
          _statusFilter == 'All Status' ||
          lead.status.toLowerCase() == _statusFilter.toLowerCase();
      final sourceOk =
          _sourceFilter == 'All Sources' ||
          lead.source.toLowerCase() == _sourceFilter.toLowerCase();
      final teamOk =
          _teamFilter == 'All Team' ||
          lead.assignedTo.toLowerCase() == _teamFilter.toLowerCase();
      final queryOk =
          query.isEmpty ||
          lead.personName.toLowerCase().contains(query) ||
          lead.companyName.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.source.toLowerCase().contains(query) ||
          lead.category.toLowerCase().contains(query);
      return statusOk && sourceOk && teamOk && queryOk;
    }).toList();
  }

  int _countByStatus(String status) {
    return _leads
        .where((l) => l.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    _pagination.filters = {
      'search': _searchController.text,
      if (_statusFilter != 'All Status') 'status': _statusFilter,
      if (_sourceFilter != 'All Sources') 'source': _sourceFilter,
      if (_teamFilter != 'All Team') 'assigned_to': _teamFilter,
    };
    if (_pagination.observe(
      [
        _searchController.text,
        _statusFilter,
        _sourceFilter,
        _teamFilter,
      ].join('|'),
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadLeads();
      });
    }

    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    final leads = _filteredLeads();
    final query = _searchController.text.trim();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.deliveryBackground,
        drawer: widget.useSalesManagerShell
            ? SalesManagerSidebarDrawer(
                currentPage: 'Leads',
                onSelect: _handleSalesManagerSidebarSelection,
              )
            : const AppDrawer(activeItem: 'Leads'),
        bottomNavigationBar: widget.useSalesManagerShell
            ? const SalesManagerBottomNavigation(currentIndex: 1)
            : null,
        body: SafeArea(
          child: Column(
            children: [
              widget.useSalesManagerShell
                  ? const SalesManagerTopBar(title: 'Leads')
                  : AdminTopBar(
                      title: 'Leads',
                      leadingIcon: Icons.menu_rounded,
                      onLeadingTap: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      actions: [
                        Tooltip(
                          message: 'Refresh leads',
                          child: InkWell(
                            onTap: _loadLeads,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              Expanded(
                child: _isLoading
                    ? const _StateView.loading()
                    : _errorMessage != null
                    ? _StateView.error(
                        message: _errorMessage!,
                        onRetry: _loadLeads,
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadLeads,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenSmall,
                            AppSpacing.md,
                            AppSpacing.screenSmall,
                            AppSpacing.xl + 40,
                          ),
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 920,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _HeaderCard(
                                      total: _leads.length,
                                      onAdd: _openAddLeadPage,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _MetricsGrid(
                                      total: _leads.length,
                                      newCount: _countByStatus('New'),
                                      followUpCount: _countByStatus(
                                        'Follow Up',
                                      ),
                                      hotCount: _countByStatus('Hot'),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _SearchCard(
                                      controller: _searchController,
                                      query: query,
                                      activeFilterCount: _activeFilterCount(),
                                      onChanged: (_) => setState(() {}),
                                      onClear: () =>
                                          setState(_searchController.clear),
                                      onFilterTap: _openFilterSheet,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _QuickFiltersRow(
                                      selectedStatus: _statusFilter,
                                      onSelectStatus: (status) {
                                        setState(() => _statusFilter = status);
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: _SectionHeader(
                                            title: 'Lead List',
                                            count: leads.length,
                                            trailingIcon:
                                                Icons.leaderboard_outlined,
                                          ),
                                        ),
                                        ListPaginationPageSize(
                                          pagination: _pagination,
                                          loading: _isLoading,
                                          onChanged: _changeListPage,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    if (leads.isEmpty)
                                      _StateView.empty(
                                        hasSearch:
                                            query.isNotEmpty ||
                                            _activeFilterCount() > 0,
                                      )
                                    else
                                      ...leads.map(
                                        (lead) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _LeadCard(
                                            lead: lead,
                                            onTap: () => _openLeadDetails(lead),
                                            onCall: () => _callLead(lead.phone),
                                            onWhatsApp: () =>
                                                _openWhatsApp(lead.phone),
                                            onAction: (act) =>
                                                _handleLeadAction(lead, act),
                                          ),
                                        ),
                                      ),
                                    ListPaginationBar(
                                      pagination: _pagination,
                                      loading: _isLoading,
                                      onChanged: _changeListPage,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

class _HeaderCard extends StatelessWidget {
  final int total;
  final VoidCallback onAdd;

  const _HeaderCard({required this.total, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 14,
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
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.leaderboard_outlined,
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
                  'Sales Leads',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 16 : 18,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total leads in your sales pipeline',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final int total;
  final int newCount;
  final int followUpCount;
  final int hotCount;

  const _MetricsGrid({
    required this.total,
    required this.newCount,
    required this.followUpCount,
    required this.hotCount,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _MetricInfo(
        'Total Leads',
        total.toString(),
        Icons.groups_rounded,
        AppColors.deliveryBlue,
        AppColors.deliveryBlueSoft,
      ),
      _MetricInfo(
        'New Leads',
        newCount.toString(),
        Icons.trending_up_rounded,
        AppColors.deliveryGreen,
        AppColors.deliveryGreenSoft,
      ),
      _MetricInfo(
        'Follow Ups',
        followUpCount.toString(),
        Icons.access_time_rounded,
        AppColors.deliveryCustomerOrders,
        AppColors.deliveryCustomerOrdersSoft,
      ),
      _MetricInfo(
        'Hot Leads',
        hotCount.toString(),
        Icons.local_fire_department_rounded,
        AppColors.deliveryRed,
        AppColors.deliveryRedSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 68,
          ),
          itemBuilder: (_, index) => _MetricTile(info: rows[index]),
        );
      },
    );
  }
}

class _MetricInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MetricInfo(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}

class _MetricTile extends StatelessWidget {
  final _MetricInfo info;

  const _MetricTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliveryCardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: info.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(info.icon, color: info.color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF586176),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int activeFilterCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  const _SearchCard({
    required this.controller,
    required this.query,
    required this.activeFilterCount,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name, company, mobile...',
                  hintStyle: AppTextStyles.inputHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.deliveryGreen,
                    size: 20,
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          onPressed: onClear,
                        ),
                  filled: true,
                  fillColor: AppColors.deliveryCardSoft,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(
                      color: AppColors.deliverySurfaceBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(
                      color: AppColors.deliverySurfaceBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(
                      color: AppColors.deliveryGreen,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: activeFilterCount > 0
                ? AppColors.primary
                : AppColors.deliveryCardSoft,
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  border: Border.all(
                    color: activeFilterCount > 0
                        ? AppColors.primary
                        : AppColors.deliverySurfaceBorder,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.tune_rounded,
                        color: activeFilterCount > 0
                            ? Colors.white
                            : AppColors.deliveryInk,
                        size: 20,
                      ),
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.deliveryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFiltersRow extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelectStatus;

  const _QuickFiltersRow({
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    final filters = const [
      'All Status',
      'New',
      'Follow Up',
      'Hot',
      'Qualified',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((status) {
          final isSelected =
              selectedStatus.toLowerCase() == status.toLowerCase() ||
              (selectedStatus == 'All Status' && status == 'All Status');
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onSelectStatus(status),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.deliverySurfaceBorder,
                    ),
                  ),
                  child: Text(
                    status == 'All Status' ? 'All Leads' : status,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.deliveryInk,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData trailingIcon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.sectionHeading),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.deliveryCardSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.deliveryCardBorder),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final _LeadRecord lead;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final ValueChanged<_LeadAction> onAction;

  const _LeadCard({
    required this.lead,
    required this.onTap,
    required this.onCall,
    required this.onWhatsApp,
    required this.onAction,
  });

  Color _resolveStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('new')) return AppColors.deliveryGreen;
    if (s.contains('follow')) return AppColors.deliveryCustomerOrders;
    if (s.contains('hot')) return AppColors.deliveryRed;
    if (s.contains('qualified') ||
        s.contains('converted') ||
        s.contains('won')) {
      return AppColors.deliveryGreen;
    }
    if (s.contains('lost')) return AppColors.textMuted;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveStatusColor(lead.status);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Ink(
          decoration: _surfaceDecoration(),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: statusColor,
                  child: const SizedBox(width: 3.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomerAvatar(name: lead.personName, size: 50),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lead.personName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.deliveryInk,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _StatusBadge(
                                    label: lead.status,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business_outlined,
                                    size: 13,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      lead.companyName.isEmpty ||
                                              lead.companyName == '-'
                                          ? 'Independent Buyer'
                                          : lead.companyName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CardMiniField(
                                      label: 'Assigned',
                                      value: lead.assignedTo,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _CardMiniField(
                                      label: 'Source',
                                      value: lead.source,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _CardMiniField(
                                      label: 'Product',
                                      value: lead.category,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      color: AppColors.deliverySurfaceBorder,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textLightMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lead.lastActivity,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _CircularActionButton(
                          icon: Icons.call_rounded,
                          color: AppColors.deliveryGreen,
                          background: AppColors.deliveryGreenSoft,
                          onTap: onCall,
                          tooltip: 'Call lead',
                        ),
                        const SizedBox(width: 6),
                        _CircularActionButton(
                          icon: FontAwesomeIcons.whatsapp,
                          color: const Color(0xFF25D366),
                          background: const Color(0xFFEDFBF0),
                          onTap: onWhatsApp,
                          tooltip: 'WhatsApp',
                        ),
                        const SizedBox(width: 4),
                        PopupMenuButton<_LeadAction>(
                          tooltip: 'Options',
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: onAction,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _LeadAction.viewDetails,
                              child: Row(
                                children: [
                                  Icon(Icons.visibility_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: _LeadAction.edit,
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Lead'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: _LeadAction.convertToCustomer,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1_outlined,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Convert to Customer'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.deliveryCardSoft,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.deliveryCardBorder,
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardMiniField extends StatelessWidget {
  final String label;
  final String value;

  const _CardMiniField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value.isEmpty || value == '-' ? 'General' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.deliveryInk,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final String tooltip;

  const _CircularActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label.isEmpty ? 'New' : label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: _surfaceDecoration(),
      child: child,
    );
  }
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    border: Border.all(color: AppColors.deliverySurfaceBorder),
    boxShadow: const [
      BoxShadow(color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );
}

class _StateView extends StatelessWidget {
  final bool isLoading;
  final bool hasSearch;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const _StateView.loading()
    : isLoading = true,
      hasSearch = false,
      errorMessage = null,
      onRetry = null;

  const _StateView.empty({required this.hasSearch})
    : isLoading = false,
      errorMessage = null,
      onRetry = null;

  const _StateView.error({required String message, required this.onRetry})
    : isLoading = false,
      hasSearch = false,
      errorMessage = message;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.deliveryGreen),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.deliveryRed,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deliveryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.deliveryGreenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.leaderboard_outlined,
                color: AppColors.deliveryGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'No matching leads found' : 'No leads available yet',
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasSearch
                  ? 'Try searching with different keywords or reset filters.'
                  : 'Tap the "+" button to add your first sales lead.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _LeadAction { viewDetails, edit, convertToCustomer, delete }

class _LeadRecord {
  final String id;
  final String personName;
  final String companyName;
  final String phone;
  final String source;
  final String assignedTo;
  final String status;
  final String category;
  final String lastActivity;

  const _LeadRecord({
    required this.id,
    required this.personName,
    required this.companyName,
    required this.phone,
    required this.source,
    required this.assignedTo,
    required this.status,
    required this.category,
    required this.lastActivity,
  });

  factory _LeadRecord.fromJson(Map<String, dynamic> json) {
    final name = _leadString(json, const [
      'name',
      'contact_person',
      'contactPerson',
    ], fallback: 'New Lead');
    final assignedTo = _leadString(
      json,
      const ['assigned_salesperson_name', 'assignedSalespersonName'],
      nestedKeys: const ['assigned_salesperson', 'assigned_user', 'user'],
      fallback: '-',
    );
    return _LeadRecord(
      id: _leadString(json, const ['id', 'lead_id', 'leadId'], fallback: ''),
      personName: name,
      companyName: _leadString(
        json,
        const ['customer_name', 'customerName', 'company_name', 'companyName'],
        nestedKeys: const ['customer'],
        fallback: '-',
      ),
      phone: _leadString(json, const [
        'mobile_number',
        'mobileNumber',
        'phone',
      ], fallback: '-'),
      source: _leadString(json, const [
        'lead_source',
        'leadSource',
        'source',
      ], fallback: 'Direct'),
      assignedTo: assignedTo,
      status: _leadString(json, const [
        'lead_status',
        'leadStatus',
        'status',
      ], fallback: 'New'),
      category: _leadString(json, const [
        'interested_product',
        'interestedProduct',
        'category',
      ], fallback: 'General'),
      lastActivity: _relativeLeadTime(
        _leadString(json, const ['created_at', 'createdAt'], fallback: ''),
      ),
    );
  }
}

String _leadString(
  Map<String, dynamic> json,
  List<String> keys, {
  List<String> nestedKeys = const [],
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  for (final key in nestedKeys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      final nested = _leadString(value, const [
        'name',
        'full_name',
      ], fallback: '');
      if (nested.isNotEmpty) return nested;
    }
  }
  return fallback;
}

String _relativeLeadTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return 'Recently';
  final diff = DateTime.now().difference(parsed);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

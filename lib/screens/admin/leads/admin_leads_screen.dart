import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
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

class AdminLeadsScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const AdminLeadsScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<AdminLeadsScreen> createState() => _AdminLeadsScreenState();
}

class _AdminLeadsScreenState extends State<AdminLeadsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _productFilterController =
      TextEditingController();

  int _selectedPageSize = 10;
  String _statusFilter = 'All Status';
  String _sourceFilter = 'All Sources';
  String _teamFilter = 'All Team';

  final List<String> _statusOptions = const [
    'All Status',
    'New',
    'Follow Up',
    'Hot',
  ];

  final List<String> _sourceOptions = const [
    'All Sources',
    'Website',
    'Facebook Ads',
    'Referral',
    'Instagram',
  ];

  final List<String> _teamOptions = const [
    'All Team',
    'Sunil Sales',
    'Neha Sharma',
    'Amit Verma',
  ];

  final List<int> _pageSizeOptions = const [10, 25, 50, 100];

  // NOTE: avatarUrl points at placeholder photo URLs (pravatar.cc) purely so
  // the card layout matches the photo-avatar mockup. Swap these for real
  // lead/contact photo URLs from your backend when wiring this up.
  final List<_LeadRecord> _leads = const [
    _LeadRecord(
      personName: 'Rahul Sharma',
      companyName: 'Sharma Enterprises',
      phone: '9876543210',
      source: 'Website',
      assignedTo: 'Sunil Sales',
      assignedInitials: 'SS',
      status: 'New',
      category: 'IT Services',
      lastActivity: '2m ago',
      accentColor: AppColors.primary,
      avatarStart: AppColors.surfaceSoft,
      avatarEnd: AppColors.activeMenuBg,
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    ),
    _LeadRecord(
      personName: 'Priya Mehta',
      companyName: 'Mehta & Co.',
      phone: '9123456780',
      source: 'Facebook Ads',
      assignedTo: 'Neha Sharma',
      assignedInitials: 'NS',
      status: 'Follow Up',
      category: 'Consulting',
      lastActivity: '15m ago',
      accentColor: AppColors.blue,
      avatarStart: AppColors.surfaceSoft,
      avatarEnd: Color(0xFFD7E6D0),
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    _LeadRecord(
      personName: 'Amit Verma',
      companyName: 'Verma Solutions',
      phone: '9988776655',
      source: 'Referral',
      assignedTo: 'Amit Verma',
      assignedInitials: 'AV',
      status: 'Hot',
      category: 'Software',
      lastActivity: '1h ago',
      accentColor: AppColors.primary900,
      avatarStart: Color(0xFFE7F1E2),
      avatarEnd: Color(0xFFCFE0C7),
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
    ),
    _LeadRecord(
      personName: 'Neha Kapoor',
      companyName: 'Kapoor Industries',
      phone: '9765432109',
      source: 'Website',
      assignedTo: 'Sunil Sales',
      assignedInitials: 'SS',
      status: 'New',
      category: 'Manufacturing',
      lastActivity: '2h ago',
      accentColor: AppColors.primary,
      avatarStart: Color(0xFFEFF6EC),
      avatarEnd: Color(0xFFDCECD4),
      avatarUrl: 'https://i.pravatar.cc/150?img=44',
    ),
    _LeadRecord(
      personName: 'Sagar Patil',
      companyName: 'Patil Traders',
      phone: '9012345678',
      source: 'Instagram',
      assignedTo: 'Neha Sharma',
      assignedInitials: 'NS',
      status: 'Follow Up',
      category: 'Trading',
      lastActivity: '3h ago',
      accentColor: AppColors.blue,
      avatarStart: Color(0xFFE8F0E2),
      avatarEnd: Color(0xFFD7E3CF),
      avatarUrl: 'https://i.pravatar.cc/150?img=14',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _productFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddLeadPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddLeadScreen()));
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

  @override
  Widget build(BuildContext context) {
    final leads = _filteredLeads();
    final shownLeads = leads.take(_selectedPageSize).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: widget.useSalesManagerShell
          ? SalesManagerSidebarDrawer(
              currentPage: 'Leads',
              onSelect: _handleSalesManagerSidebarSelection,
            )
          : const AppDrawer(activeItem: 'Leads'),
      floatingActionButton: _buildFloatingAddButton(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return Column(
              children: [
                widget.useSalesManagerShell
                    ? const SalesManagerTopBar(title: 'Leads')
                    : AdminTopBar(
                        title: 'Leads',
                        leadingIcon: Icons.menu_rounded,
                        onLeadingTap: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 6 : 12,
                      10,
                      isMobile ? 6 : 12,
                      64,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchRow(isMobile),
                            const SizedBox(height: 8),
                            _buildQuickFilters(isMobile),
                            const SizedBox(height: 8),
                            _buildStatsSection(isMobile),
                            const SizedBox(height: 10),
                            _buildLeadList(shownLeads, isMobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_LeadRecord> _filteredLeads() {
    final query = _searchController.text.trim().toLowerCase();
    final productQuery = _productFilterController.text.trim().toLowerCase();

    return _leads.where((lead) {
      final statusOk =
          _statusFilter == 'All Status' || lead.status == _statusFilter;
      final sourceOk =
          _sourceFilter == 'All Sources' || lead.source == _sourceFilter;
      final teamOk =
          _teamFilter == 'All Team' || lead.assignedTo == _teamFilter;
      final queryOk =
          query.isEmpty ||
          lead.personName.toLowerCase().contains(query) ||
          lead.companyName.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.source.toLowerCase().contains(query);
      final productOk =
          productQuery.isEmpty ||
          lead.category.toLowerCase().contains(productQuery);
      return statusOk && sourceOk && teamOk && queryOk && productOk;
    }).toList();
  }

  Widget _buildSearchRow(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            decoration: _glassDecoration(radius: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 6),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 38),
                  hintText: 'Search leads by name, mobile or source...',
                  hintStyle: const TextStyle(
                    color: AppColors.textLightMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: _openFilterSheet,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: isMobile ? 38 : 42,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primary900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.sort_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                if (_activeFilterCount() > 0)
                  Positioned(
                    top: -4,
                    right: -3,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_activeFilterCount()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters(bool isMobile) {
    final chips = [
      _QuickFilterData(
        label: 'All Leads',
        icon: Icons.groups_2_outlined,
        dotColor: AppColors.primary,
        selected: _statusFilter == 'All Status',
        onTap: () => setState(() => _statusFilter = 'All Status'),
      ),
      _QuickFilterData(
        label: 'New',
        dotColor: AppColors.green,
        selected: _statusFilter == 'New',
        onTap: () => setState(() => _statusFilter = 'New'),
      ),
      _QuickFilterData(
        label: 'Follow Up',
        dotColor: AppColors.blue,
        selected: _statusFilter == 'Follow Up',
        onTap: () => setState(() => _statusFilter = 'Follow Up'),
      ),
      _QuickFilterData(
        label: 'Hot',
        dotColor: AppColors.primary900,
        selected: _statusFilter == 'Hot',
        onTap: () => setState(() => _statusFilter = 'Hot'),
      ),
      _QuickFilterData(
        label: 'More',
        icon: Icons.add_rounded,
        selected: false,
        onTap: _openFilterSheet,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            _buildQuickFilterChip(chips[i], isMobile),
            if (i != chips.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    final cards = [
      _StatCardData(
        value: '${_leads.length}',
        label: 'Total Leads',
        icon: Icons.groups_rounded,
        glowColor: AppColors.primary,
        iconBackground: const [AppColors.surfaceSoft, AppColors.activeMenuBg],
      ),
      _StatCardData(
        value: '${_countByStatus('New')}',
        label: 'New Leads',
        icon: Icons.trending_up_rounded,
        glowColor: AppColors.green,
        iconBackground: const [AppColors.statusActiveBg, AppColors.surfaceSoft],
      ),
      _StatCardData(
        value: '${_countByStatus('Follow Up')}',
        label: 'Follow Ups',
        icon: Icons.access_time_rounded,
        glowColor: AppColors.blue,
        iconBackground: const [Color(0xFFF3F7EF), Color(0xFFE3EBDD)],
      ),
      _StatCardData(
        value: '${_countByStatus('Hot')}',
        label: 'Hot Leads',
        icon: Icons.local_fire_department_rounded,
        glowColor: AppColors.primary900,
        iconBackground: const [Color(0xFFEAF3E6), Color(0xFFD9E8D2)],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = isMobile ? 6.0 : 10.0;
        final cardWidth = (width - (gap * 3)) / 4;

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(
                child: _buildStatCard(
                  cards[i],
                  isMobile: isMobile,
                  cardWidth: cardWidth,
                ),
              ),
              if (i != cards.length - 1) SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLeadList(List<_LeadRecord> leads, bool isMobile) {
    return Column(
      children: [
        for (var i = 0; i < leads.length; i++) ...[
          _buildLeadCard(leads[i], isMobile),
          if (i != leads.length - 1) const SizedBox(height: 8),
        ],
        if (leads.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _glassDecoration(radius: 16),
            child: const Text(
              'No leads found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeadCard(_LeadRecord lead, bool isMobile) {
    final statusStyle = _statusStyle(lead.status);

    return Container(
      decoration: _glassDecoration(radius: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: lead.accentColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 7 : 9,
                  vertical: isMobile ? 7 : 9,
                ),
                child: _buildLeadCardBody(lead, statusStyle, isMobile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single-row card body used at every width (matches the phone mockup):
  // avatar + name/company/pills on the left, a compact time/WhatsApp/source
  // stack, a divider, the call button, and the overflow menu — all in one row.
  Widget _buildLeadCardBody(
    _LeadRecord lead,
    _LeadStatusStyle statusStyle,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(lead, isMobile ? 40 : 34),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lead.personName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lead.companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 3,
                runSpacing: 3,
                children: [
                  _buildPill(
                    lead.status,
                    background: statusStyle.background,
                    foreground: statusStyle.foreground,
                  ),
                  _buildPill(
                    lead.category,
                    background: AppColors.surfaceSoft,
                    foreground: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: AppColors.border,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lead.lastActivity,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.green,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              lead.source,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        _buildActionSquare(icon: Icons.call_outlined),
        const SizedBox(width: 6),
        const Icon(
          Icons.more_vert_rounded,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ],
    );
  }

  Widget _buildAvatar(_LeadRecord lead, double size) {
    final initials = lead.personName
        .split(' ')
        .take(2)
        .map((part) => part[0])
        .join();

    Widget fallback() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [lead.avatarStart, lead.avatarEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (lead.avatarUrl == null || lead.avatarUrl!.isEmpty) {
      return fallback();
    }

    return ClipOval(
      child: Image.network(
        lead.avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(width: size, height: size, child: fallback());
        },
        errorBuilder: (context, error, stackTrace) => fallback(),
      ),
    );
  }

  Widget _buildPill(
    String label, {
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionSquare({required IconData icon}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 16),
    );
  }

  Widget _buildQuickFilterChip(_QuickFilterData data, bool isMobile) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: data.selected ? AppColors.activeMenuBg : AppColors.border,
            ),
            color: data.selected ? AppColors.surfaceSoft : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.icon != null)
                Icon(
                  data.icon,
                  color: data.selected
                      ? AppColors.primary
                      : AppColors.textMuted,
                  size: 14,
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: data.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                data.label,
                style: TextStyle(
                  color: data.selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    _StatCardData data, {
    bool isMobile = false,
    double? cardWidth,
  }) {
    final width = cardWidth ?? (isMobile ? 84 : 180);
    final isCompact = width < 90;
    final iconBubbleSize = isMobile
        ? width.clamp(28.0, 38.0).toDouble()
        : width.clamp(32.0, 46.0).toDouble();
    final iconSize = isMobile
        ? width.clamp(13.0, 18.0).toDouble()
        : width.clamp(18.0, 22.0).toDouble();
    final valueSize = isMobile
        ? width.clamp(11.0, 15.0).toDouble()
        : width.clamp(14.0, 18.0).toDouble();
    final labelSize = isMobile
        ? width.clamp(7.8, 10.0).toDouble()
        : width.clamp(9.0, 11.5).toDouble();
    final verticalPadding = isMobile ? (isCompact ? 10.0 : 12.0) : 14.0;
    final horizontalPadding = isMobile ? (isCompact ? 6.0 : 8.0) : 10.0;
    final valueSpacing = isMobile ? (isCompact ? 8.0 : 10.0) : 12.0;
    final labelSpacing = isMobile ? 4.0 : 6.0;

    return Container(
      constraints: BoxConstraints(
        minHeight: isMobile ? (isCompact ? 92 : 104) : 126,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 18 : 16),
        border: Border.all(
          color: isMobile ? AppColors.borderLight : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isMobile ? 0.06 : 0.04),
            blurRadius: isMobile ? 18 : 8,
            offset: Offset(0, isMobile ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconBubbleSize,
            height: iconBubbleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: data.iconBackground,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(data.icon, color: data.glowColor, size: iconSize),
          ),
          SizedBox(height: valueSpacing),
          Text(
            data.value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: labelSpacing),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: labelSize,
              fontWeight: isMobile ? FontWeight.w600 : FontWeight.w500,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return FloatingActionButton(
      onPressed: _openAddLeadPage,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primary900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
      ),
    );
  }

  BoxDecoration _glassDecoration({double radius = 22}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  int _activeFilterCount() {
    var count = 0;
    if (_statusFilter != 'All Status') count++;
    if (_sourceFilter != 'All Sources') count++;
    if (_teamFilter != 'All Team') count++;
    if (_productFilterController.text.trim().isNotEmpty) count++;
    return count;
  }

  int _countByStatus(String status) {
    return _leads.where((lead) => lead.status == status).length;
  }

  _LeadStatusStyle _statusStyle(String status) {
    switch (status) {
      case 'New':
        return const _LeadStatusStyle(
          background: AppColors.surfaceSoft,
          foreground: AppColors.primary,
        );
      case 'Follow Up':
        return const _LeadStatusStyle(
          background: Color(0xFFF3F7EF),
          foreground: AppColors.blue,
        );
      case 'Hot':
        return const _LeadStatusStyle(
          background: Color(0xFFEAF3E6),
          foreground: AppColors.primary900,
        );
      default:
        return const _LeadStatusStyle(
          background: AppColors.surfaceSoft,
          foreground: AppColors.textMuted,
        );
    }
  }

  Future<void> _openFilterSheet() async {
    String status = _statusFilter;
    String source = _sourceFilter;
    String team = _teamFilter;
    String product = _productFilterController.text;
    int pageSize = _selectedPageSize;
    final productController = TextEditingController(text: product);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lead Filters',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Refine the lead list with team, source and status.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sheetDropdown(
                      label: 'Status',
                      value: status,
                      items: _statusOptions,
                      onChanged: (value) =>
                          modalSetState(() => status = value!),
                    ),
                    const SizedBox(height: 14),
                    _sheetDropdown(
                      label: 'Source',
                      value: source,
                      items: _sourceOptions,
                      onChanged: (value) =>
                          modalSetState(() => source = value!),
                    ),
                    const SizedBox(height: 14),
                    _sheetDropdown(
                      label: 'Team',
                      value: team,
                      items: _teamOptions,
                      onChanged: (value) => modalSetState(() => team = value!),
                    ),
                    const SizedBox(height: 14),
                    _sheetDropdown(
                      label: 'Page Size',
                      value: '$pageSize',
                      items: _pageSizeOptions.map((e) => '$e').toList(),
                      onChanged: (value) =>
                          modalSetState(() => pageSize = int.parse(value!)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: productController,
                      decoration: InputDecoration(
                        labelText: 'Category filter',
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceSoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _statusFilter = 'All Status';
                                _sourceFilter = 'All Sources';
                                _teamFilter = 'All Team';
                                _selectedPageSize = 10;
                                _productFilterController.clear();
                              });
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(
                                color: AppColors.borderStrong,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _statusFilter = status;
                                _sourceFilter = source;
                                _teamFilter = team;
                                _selectedPageSize = pageSize;
                                _productFilterController.text =
                                    productController.text;
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text('Apply'),
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

    productController.dispose();
  }

  Widget _sheetDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
    );
  }
}

class _QuickFilterData {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final bool selected;
  final VoidCallback onTap;

  const _QuickFilterData({
    required this.label,
    this.icon,
    this.dotColor,
    required this.selected,
    required this.onTap,
  });
}

class _StatCardData {
  final String value;
  final String label;
  final IconData icon;
  final Color glowColor;
  final List<Color> iconBackground;

  const _StatCardData({
    required this.value,
    required this.label,
    required this.icon,
    required this.glowColor,
    required this.iconBackground,
  });
}

class _LeadStatusStyle {
  final Color background;
  final Color foreground;

  const _LeadStatusStyle({required this.background, required this.foreground});
}

class _LeadRecord {
  final String personName;
  final String companyName;
  final String phone;
  final String source;
  final String assignedTo;
  final String assignedInitials;
  final String status;
  final String category;
  final String lastActivity;
  final Color accentColor;
  final Color avatarStart;
  final Color avatarEnd;
  final String? avatarUrl;

  const _LeadRecord({
    required this.personName,
    required this.companyName,
    required this.phone,
    required this.source,
    required this.assignedTo,
    required this.assignedInitials,
    required this.status,
    required this.category,
    required this.lastActivity,
    required this.accentColor,
    required this.avatarStart,
    required this.avatarEnd,
    this.avatarUrl,
  });
}

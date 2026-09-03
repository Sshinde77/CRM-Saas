import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/super_admin/super_admin_sidebar.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  final String initialPage;
  final int initialPageIndex;
  final String initialQuery;

  const SuperAdminDashboardScreen({
    super.key,
    this.initialPage = 'Dashboard',
    this.initialPageIndex = 0,
    this.initialQuery = '',
  });

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _contentScrollController = ScrollController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  late String _query;
  late String _currentPage;
  late int _pageIndex;
  _OrganizationRow? _selectedOrganization;

  final List<_MetricItem> _metrics = const [
    _MetricItem(
      'Total Organizations',
      '41',
      Icons.apartment_rounded,
      AppColors.primary,
    ),
    _MetricItem('Active', '1', Icons.check_circle_rounded, AppColors.green),
    _MetricItem('Trial', '40', Icons.schedule_rounded, AppColors.blue),
    _MetricItem('Suspended', '0', Icons.block_rounded, AppColors.red),
    _MetricItem(
      'Pending Upgrades',
      '0',
      Icons.upgrade_rounded,
      AppColors.accentGrey,
    ),
    _MetricItem(
      'MRR Estimate',
      '₹599',
      Icons.currency_rupee_rounded,
      AppColors.green,
    ),
  ];

  final List<_TrendPoint> _growthPoints = const [
    _TrendPoint('Jan', 8),
    _TrendPoint('Feb', 13),
    _TrendPoint('Mar', 15),
    _TrendPoint('Apr', 19),
    _TrendPoint('May', 26),
    _TrendPoint('Jun', 33),
    _TrendPoint('Jul', 41),
  ];

  final List<_PlanSlice> _planSlices = const [
    _PlanSlice('No plan', 40, AppColors.primary, '98%'),
    _PlanSlice('Enterprise', 1, AppColors.blue, '2%'),
  ];

  final List<_OrganizationRow> _organizations = const [
    _OrganizationRow(
      name: 'Lead Test Org 761538',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'PDF Test Org 638588',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787553682',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787552294',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787552777',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787557385',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787553382',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787549871',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'Al Dev',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '9867072057',
      created: '8/24/2026',
    ),
    _OrganizationRow(
      name: 'ZZZ Probe Org 1787361440',
      plan: 'No plan',
      status: 'Trial',
      upgradeRequest: '—',
      businessType: '—',
      phone: '—',
      created: '8/22/2026',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _currentPage = widget.initialPage;
    _pageIndex = widget.initialPageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_contentScrollController.hasClients) {
        _contentScrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_OrganizationRow> get _filteredOrganizations {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _organizations;
    return _organizations.where((org) {
      return org.name.toLowerCase().contains(query) ||
          org.plan.toLowerCase().contains(query) ||
          org.status.toLowerCase().contains(query) ||
          org.upgradeRequest.toLowerCase().contains(query) ||
          org.businessType.toLowerCase().contains(query) ||
          org.phone.toLowerCase().contains(query) ||
          org.created.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1100;
    final organizations = _filteredOrganizations;

    if (desktop) {
      return ScrollConfiguration(
        behavior: const _NoScrollbarBehavior(),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.adminSidebarBg,
          body: Row(
            children: [
              SizedBox(
                width: 256,
                child: SuperAdminSidebar(
                  currentPage: _currentPage,
                  onSelect: _handleSelect,
                ),
              ),
              Expanded(
                child: _MainArea(
                  currentPage: _currentPage,
                  searchController: _searchController,
                  scrollController: _contentScrollController,
                  organizations: organizations,
                  selectedOrganization: _selectedOrganization,
                  metrics: _metrics,
                  growthPoints: _growthPoints,
                  planSlices: _planSlices,
                  onQueryChanged: (value) => setState(() => _query = value),
                  pageIndex: _pageIndex,
                  onPageChange: (index) => setState(() => _pageIndex = index),
                  onOpenOrganizationDetails: _openOrganizationDetails,
                  onNavigateToPage: _handleSelect,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: const _NoScrollbarBehavior(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.adminSidebarBg,
        drawer: SuperAdminSidebarDrawer(
          currentPage: _currentPage,
          onSelect: _handleSelect,
        ),
        body: _MainArea(
          currentPage: _currentPage,
          searchController: _searchController,
          scrollController: _contentScrollController,
          organizations: organizations,
          selectedOrganization: _selectedOrganization,
          metrics: _metrics,
          growthPoints: _growthPoints,
          planSlices: _planSlices,
          onQueryChanged: (value) => setState(() => _query = value),
          pageIndex: _pageIndex,
          onPageChange: (index) => setState(() => _pageIndex = index),
          onOpenOrganizationDetails: _openOrganizationDetails,
          onNavigateToPage: _handleSelect,
          showCompactMenuButton: true,
          onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
    );
  }

  void _handleSelect(String page) {
    setState(() {
      _currentPage = page;
      if (page != 'Organization Details') {
        _selectedOrganization = null;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_contentScrollController.hasClients) {
        _contentScrollController.jumpTo(0);
      }
    });
  }

  void _openOrganizationDetails(_OrganizationRow row) {
    setState(() {
      _selectedOrganization = row;
      _currentPage = 'Organization Details';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_contentScrollController.hasClients) {
        _contentScrollController.jumpTo(0);
      }
    });
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _MainArea extends StatelessWidget {
  final String currentPage;
  final TextEditingController searchController;
  final ScrollController scrollController;
  final List<_OrganizationRow> organizations;
  final _OrganizationRow? selectedOrganization;
  final List<_MetricItem> metrics;
  final List<_TrendPoint> growthPoints;
  final List<_PlanSlice> planSlices;
  final ValueChanged<String> onQueryChanged;
  final int pageIndex;
  final ValueChanged<int> onPageChange;
  final ValueChanged<_OrganizationRow> onOpenOrganizationDetails;
  final ValueChanged<String> onNavigateToPage;
  final bool showCompactMenuButton;
  final VoidCallback? onOpenMenu;

  const _MainArea({
    required this.currentPage,
    required this.searchController,
    required this.scrollController,
    required this.organizations,
    required this.selectedOrganization,
    required this.metrics,
    required this.growthPoints,
    required this.planSlices,
    required this.onQueryChanged,
    required this.pageIndex,
    required this.onPageChange,
    required this.onOpenOrganizationDetails,
    required this.onNavigateToPage,
    this.showCompactMenuButton = false,
    this.onOpenMenu,
  });

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final isOrganizationsPage = currentPage == 'Organizations';
    final isUpgradeRequestsPage = currentPage == 'Upgrade Requests';
    final isPlansPage = currentPage == 'Plans';
    final isPlatformAnalyticsPage = currentPage == 'Platform Analytics';
    final isOrganizationDetailsPage = currentPage == 'Organization Details';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                showCompactMenuButton: showCompactMenuButton,
                onOpenMenu: onOpenMenu,
              ),
              const SizedBox(height: 14),
              if (isOrganizationsPage) ...[
                _OrganizationsListPage(
                  searchController: searchController,
                  onQueryChanged: onQueryChanged,
                  organizations: organizations,
                  pageIndex: pageIndex,
                  onPageChange: onPageChange,
                  onViewDetails: onOpenOrganizationDetails,
                ),
              ] else if (isOrganizationDetailsPage) ...[
                _OrganizationDetailsView(
                  row: selectedOrganization ?? organizations.first,
                  onBack: () => onNavigateToPage('Organizations'),
                ),
              ] else if (isUpgradeRequestsPage) ...[
                const _UpgradeRequestsPage(),
              ] else if (isPlansPage) ...[
                const _PlansPage(),
              ] else if (isPlatformAnalyticsPage) ...[
                const _PlatformAnalyticsPage(),
              ] else ...[
                _SearchRow(
                  controller: searchController,
                  onChanged: onQueryChanged,
                ),
                const SizedBox(height: 16),
                _SummaryGrid(metrics: metrics),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1100;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ChartCard(
                              title: 'Organization Growth',
                              subtitle:
                                  'Cumulative organizations on the platform',
                              child: _GrowthChart(points: growthPoints),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ChartCard(
                              title: 'Organizations by Plan',
                              subtitle: 'Plan mix across all active accounts',
                              child: _PlanChart(slices: planSlices),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _ChartCard(
                          title: 'Organization Growth',
                          subtitle: 'Cumulative organizations on the platform',
                          child: _GrowthChart(points: growthPoints),
                        ),
                        const SizedBox(height: 12),
                        _ChartCard(
                          title: 'Organizations by Plan',
                          subtitle: 'Plan mix across all active accounts',
                          child: _PlanChart(slices: planSlices),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _OrganizationsCard(
                  organizations: organizations,
                  onQueryChanged: onQueryChanged,
                  pageIndex: pageIndex,
                  onPageChange: onPageChange,
                  onViewDetails: onOpenOrganizationDetails,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showCompactMenuButton;
  final VoidCallback? onOpenMenu;

  const _TopBar({required this.showCompactMenuButton, this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showCompactMenuButton) ...[
          _RoundIconButton(
            icon: Icons.menu_rounded,
            onTap: onOpenMenu ?? () {},
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textLightMuted,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search deliveries, customers, orders...',
                    style: TextStyle(
                      color: AppColors.textLightMuted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.help_outline_rounded, onTap: () {}),
        const SizedBox(width: 10),
        _RoundIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'RM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ravi Malhotra',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Super Admin',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textLightMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchRow({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.primary,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.textLightMuted,
          ),
          hintText: 'Search organizations...',
          hintStyle: TextStyle(color: AppColors.textLightMuted, fontSize: 12.5),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<_MetricItem> metrics;

  const _SummaryGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1400
        ? 6
        : width >= 1000
        ? 3
        : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.75,
      ),
      itemBuilder: (context, index) => _MetricCard(item: metrics[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;

  const _MetricCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GrowthChart extends StatelessWidget {
  final List<_TrendPoint> points;

  const _GrowthChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: CustomPaint(
        painter: _GrowthChartPainter(
          points: points,
          lineColor: AppColors.primary,
          fillColor: AppColors.activeMenuBg.withValues(alpha: 0.36),
          axisColor: AppColors.border.withValues(alpha: 0.75),
          textColor: AppColors.textLightMuted,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PlanChart extends StatelessWidget {
  final List<_PlanSlice> slices;

  const _PlanChart({required this.slices});

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (sum, item) => sum + item.value);

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(190),
                painter: _DonutPainter(slices: slices),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: slices
              .map(
                (slice) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: slice.color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${slice.label} ${slice.shareLabel}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OrganizationsCard extends StatelessWidget {
  final List<_OrganizationRow> organizations;
  final ValueChanged<String> onQueryChanged;
  final int pageIndex;
  final ValueChanged<int> onPageChange;
  final ValueChanged<_OrganizationRow> onViewDetails;

  const _OrganizationsCard({
    required this.organizations,
    required this.onQueryChanged,
    required this.pageIndex,
    required this.onPageChange,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Organizations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All organizations on the SAAS CRM platform',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 260,
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    onChanged: onQueryChanged,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.textLightMuted,
                      ),
                      hintText: 'Search organizations...',
                      hintStyle: TextStyle(
                        color: AppColors.textLightMuted,
                        fontSize: 12.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${organizations.length} results',
                style: const TextStyle(
                  color: AppColors.textLightMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1200,
              child: Column(
                children: [
                  _TableHeader(),
                  const Divider(height: 1, color: AppColors.border),
                  ...organizations.map(
                    (org) => Column(
                      children: [
                        _OrganizationRowItem(
                          row: org,
                          onViewDetails: onViewDetails,
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Page ${pageIndex + 1} of 5',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: pageIndex > 0
                    ? () => onPageChange(pageIndex - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.textSecondary,
              ),
              IconButton(
                onPressed: pageIndex < 4
                    ? () => onPageChange(pageIndex + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrganizationsListPage extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final List<_OrganizationRow> organizations;
  final int pageIndex;
  final ValueChanged<int> onPageChange;
  final ValueChanged<_OrganizationRow> onViewDetails;

  const _OrganizationsListPage({
    required this.searchController,
    required this.onQueryChanged,
    required this.organizations,
    required this.pageIndex,
    required this.onPageChange,
    required this.onViewDetails,
  });

  @override
  State<_OrganizationsListPage> createState() => _OrganizationsListPageState();
}

class _OrganizationsListPageState extends State<_OrganizationsListPage> {
  static const List<String> _statusOptions = [
    'All statuses',
    'Trial',
    'Active',
    'Locked',
    'Inactive',
    'Suspended',
  ];

  static const List<String> _upgradeOptions = [
    'All upgrade requests',
    'None',
    'Pending',
    'Approved',
    'Rejected',
  ];

  String _selectedStatus = 'All statuses';
  String _selectedUpgrade = 'All upgrade requests';

  List<_OrganizationRow> get _filteredOrganizations {
    return widget.organizations.where((org) {
      final statusMatches =
          _selectedStatus == 'All statuses' ||
          org.status.toLowerCase() == _selectedStatus.toLowerCase();
      final upgradeMatches =
          _selectedUpgrade == 'All upgrade requests' ||
          org.upgradeRequest.toLowerCase() == _selectedUpgrade.toLowerCase();
      return statusMatches && upgradeMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final organizations = _filteredOrganizations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organizations List',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusDropdown(
                      label: 'Status',
                      value: _selectedStatus,
                      options: _statusOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedStatus = value);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatusDropdown(
                      label: 'Upgrade request',
                      value: _selectedUpgrade,
                      options: _upgradeOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedUpgrade = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SearchRow(
                controller: widget.searchController,
                onChanged: widget.onQueryChanged,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${organizations.length} results',
                    style: const TextStyle(
                      color: AppColors.textLightMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...organizations.map(
                (org) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OrganizationMobileCard(
                    row: org,
                    onViewDetails: widget.onViewDetails,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Page ${widget.pageIndex + 1} of 5',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.pageIndex > 0
                        ? () => widget.onPageChange(widget.pageIndex - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: widget.pageIndex < 4
                        ? () => widget.onPageChange(widget.pageIndex + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpgradeRequestsPage extends StatefulWidget {
  const _UpgradeRequestsPage();

  @override
  State<_UpgradeRequestsPage> createState() => _UpgradeRequestsPageState();
}

class _UpgradeRequestsPageState extends State<_UpgradeRequestsPage> {
  static const List<String> _tabs = ['Pending', 'Approved', 'Rejected', 'All'];
  String _selectedTab = 'Pending';

  static const List<_UpgradeRequestItem> _items = [
    _UpgradeRequestItem(
      organization: 'Lead Test Org 761536',
      adminContact: 'leadtest761536@example.com',
      currentPlan: 'No plan',
      requestedPlan: 'Enterprise',
      amount: '₹599',
      status: 'Pending',
      requestedOn: '24 Aug 2026',
    ),
    _UpgradeRequestItem(
      organization: 'PDF Test Org 638555',
      adminContact: 'pdftest638555@example.com',
      currentPlan: 'Trial',
      requestedPlan: 'Pro',
      amount: '₹299',
      status: 'Approved',
      requestedOn: '23 Aug 2026',
    ),
    _UpgradeRequestItem(
      organization: 'ZZZ Probe Org 1787553662',
      adminContact: 'zzzprobe1787553662@example.com',
      currentPlan: 'No plan',
      requestedPlan: 'Business',
      amount: '₹999',
      status: 'Rejected',
      requestedOn: '22 Aug 2026',
    ),
    _UpgradeRequestItem(
      organization: 'Al Dev',
      adminContact: 'venkat.aidev@gmail.com',
      currentPlan: 'Trial',
      requestedPlan: 'Enterprise',
      amount: '₹599',
      status: 'Pending',
      requestedOn: '21 Aug 2026',
    ),
  ];

  List<_UpgradeRequestItem> get _filteredItems {
    if (_selectedTab == 'All') return _items;
    return _items.where((item) => item.status == _selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UpgradeTabs(
                tabs: _tabs,
                selectedTab: _selectedTab,
                onChanged: (value) => setState(() => _selectedTab = value),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UpgradeRequestCard(item: item),
                      ),
                    ),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 58),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.trending_up_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No upgrade requests here',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Nothing to review in this view right now.',
                                style: TextStyle(
                                  color: AppColors.textLightMuted,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpgradeTabs extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onChanged;

  const _UpgradeTabs({
    required this.tabs,
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs
            .map(
              (tab) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _UpgradeTabChip(
                  label: tab,
                  selected: tab == selectedTab,
                  onTap: () => onChanged(tab),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _UpgradeTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UpgradeTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.border : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeRequestItem {
  final String organization;
  final String adminContact;
  final String currentPlan;
  final String requestedPlan;
  final String amount;
  final String status;
  final String requestedOn;

  const _UpgradeRequestItem({
    required this.organization,
    required this.adminContact,
    required this.currentPlan,
    required this.requestedPlan,
    required this.amount,
    required this.status,
    required this.requestedOn,
  });
}

class _UpgradeRequestCard extends StatelessWidget {
  final _UpgradeRequestItem item;

  const _UpgradeRequestCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      'Approved' => AppColors.green,
      'Rejected' => AppColors.red,
      _ => AppColors.blue,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.organization,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.adminContact,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: 'Current', value: item.currentPlan),
                    _InfoChip(label: 'Requested', value: item.requestedPlan),
                    _InfoChip(label: 'Amount', value: item.amount),
                    _InfoChip(label: 'Date', value: item.requestedOn),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlansPage extends StatefulWidget {
  const _PlansPage();

  @override
  State<_PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<_PlansPage> {
  bool _monthly = true;

  static const List<_PlanCardData> _cards = [
    _PlanCardData(
      name: 'basic',
      monthlyPrice: '₹199',
      yearlyPrice: '₹1,499',
      subtitle: 'per month · 3 users · 500 orders',
      active: true,
      features: [
        'Up to 3 Users',
        'Up to 500 Orders / month',
        'Leads, Quotations & Sales Orders',
        'Inventory, Invoices & Basic Reports',
      ],
    ),
    _PlanCardData(
      name: 'pro',
      monthlyPrice: '₹399',
      yearlyPrice: '₹2,999',
      subtitle: 'per month · Unlimited users · Unlimited orders',
      active: false,
      features: [
        'Unlimited Users & Orders',
        'Multiple Warehouse Management',
        'Advanced Inventory & Accounting',
        'Advanced Analytics, Roles & Priority Support',
      ],
    ),
    _PlanCardData(
      name: 'pro',
      monthlyPrice: '₹399',
      yearlyPrice: '₹2,999',
      subtitle: 'per month · 10 users · 2,000 orders',
      active: true,
      features: [
        'Up to 10 Users',
        'Up to 2,000 Orders / month',
        'Purchase, Delivery & Vehicle Management',
        'Staff Management & Advanced Reports',
      ],
    ),
    _PlanCardData(
      name: 'Enterprise',
      monthlyPrice: '₹599',
      yearlyPrice: '₹4,999',
      subtitle: 'per month · Unlimited users · Unlimited orders',
      active: true,
      features: [
        'Unlimited Users & Orders',
        'Multiple Warehouse Management',
        'Advanced Inventory & Accounting',
        'Advanced Analytics, Roles & Priority Support',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cards = _cards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TogglePill(
                    label: 'Monthly',
                    selected: _monthly,
                    onTap: () => setState(() => _monthly = true),
                  ),
                  _TogglePill(
                    label: 'Yearly',
                    selected: !_monthly,
                    onTap: () => setState(() => _monthly = false),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showCreatePlanDialog(context),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Create Plan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1500
                ? 3
                : width >= 1024
                ? 2
                : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 1.55 : 1.9,
              ),
              itemBuilder: (context, index) {
                final plan = cards[index];
                return _PlanCard(data: plan, monthly: _monthly);
              },
            );
          },
        ),
      ],
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(14),
          backgroundColor: Colors.transparent,
          child: const _CreatePlanDialog(),
        );
      },
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.border : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanCardData data;
  final bool monthly;

  const _PlanCard({required this.data, required this.monthly});

  @override
  Widget build(BuildContext context) {
    final price = monthly ? data.monthlyPrice : data.yearlyPrice;
    final badgeColor = data.active ? AppColors.green : AppColors.accentGrey;
    final powerColor = data.active ? AppColors.green : AppColors.red;
    final powerBg = data.active
        ? AppColors.green.withValues(alpha: 0.12)
        : AppColors.red.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _Pill(
                      label: data.active ? 'Active' : 'Inactive',
                      color: badgeColor,
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: powerBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.active
                      ? Icons.power_settings_new_rounded
                      : Icons.power_off_rounded,
                  color: powerColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textLightMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                monthly ? data.yearlyPrice : data.monthlyPrice,
                style: const TextStyle(
                  color: AppColors.textLightMuted,
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            monthly
                ? data.subtitle
                : data.subtitle.replaceFirst('per month', 'per year'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...data.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCardData {
  final String name;
  final String monthlyPrice;
  final String yearlyPrice;
  final String subtitle;
  final bool active;
  final List<String> features;

  const _PlanCardData({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.subtitle,
    required this.active,
    required this.features,
  });
}

class _CreatePlanDialog extends StatefulWidget {
  const _CreatePlanDialog();

  @override
  State<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends State<_CreatePlanDialog> {
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _priceMonthController = TextEditingController();
  final TextEditingController _priceYearController = TextEditingController();
  final TextEditingController _originalMonthController =
      TextEditingController();
  final TextEditingController _originalYearController = TextEditingController();
  final TextEditingController _maxUsersController = TextEditingController();
  final TextEditingController _maxOrdersController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();

  bool _isDefaultPlan = false;

  @override
  void dispose() {
    _planNameController.dispose();
    _priceMonthController.dispose();
    _priceYearController.dispose();
    _originalMonthController.dispose();
    _originalYearController.dispose();
    _maxUsersController.dispose();
    _maxOrdersController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 760;
    final dialogWidth = isMobile ? size.width : 760.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: isMobile ? size.height * 0.96 : size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Create Plan',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DialogField(
                      label: 'Plan Name *',
                      controller: _planNameController,
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 560;
                        final children = [
                          _DialogField(
                            label: 'Price / month *',
                            controller: _priceMonthController,
                          ),
                          _DialogField(
                            label: 'Price / year *',
                            controller: _priceYearController,
                          ),
                          _DialogField(
                            label: 'Original price / month',
                            controller: _originalMonthController,
                          ),
                          _DialogField(
                            label: 'Original price / year',
                            controller: _originalYearController,
                          ),
                          _DialogField(
                            label: 'Max users',
                            controller: _maxUsersController,
                            hintText: 'Unlimited',
                          ),
                          _DialogField(
                            label: 'Max orders',
                            controller: _maxOrdersController,
                            hintText: 'Unlimited',
                          ),
                        ];

                        if (wide) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: children[0]),
                                  const SizedBox(width: 12),
                                  Expanded(child: children[1]),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: children[2]),
                                  const SizedBox(width: 12),
                                  Expanded(child: children[3]),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: children[4]),
                                  const SizedBox(width: 12),
                                  Expanded(child: children[5]),
                                ],
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            children[0],
                            const SizedBox(height: 12),
                            children[1],
                            const SizedBox(height: 12),
                            children[2],
                            const SizedBox(height: 12),
                            children[3],
                            const SizedBox(height: 12),
                            children[4],
                            const SizedBox(height: 12),
                            children[5],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _DialogField(
                      label: 'Features (one per line)',
                      controller: _featuresController,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _isDefaultPlan,
                        onChanged: (value) {
                          setState(() => _isDefaultPlan = value ?? false);
                        },
                        title: const Text(
                          'Set as default plan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Shown as the recommended plan for new organizations.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.borderStrong),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.surfaceSoft,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text(
                            'Create Plan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;

  const _DialogField({
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(
              color: AppColors.textLightMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _StatusDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textLightMuted,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              onChanged: onChanged,
              items: options.map((option) {
                final selected = option == value;
                return DropdownMenuItem<String>(
                  value: option,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrganizationMobileCard extends StatelessWidget {
  final _OrganizationRow row;
  final ValueChanged<_OrganizationRow> onViewDetails;

  const _OrganizationMobileCard({
    required this.row,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _OrganizationActionsMenu(
                row: row,
                onViewDetails: () => onViewDetails(row),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            row.phone == '—' ? 'Admin contact unavailable' : row.phone,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: 'Plan', value: row.plan),
              _InfoChip(label: 'MRR', value: '₹0'),
              _InfoChip(label: 'Status', value: row.status),
              _InfoChip(label: 'Upgrade', value: row.upgradeRequest),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Created: ${row.created}',
            style: const TextStyle(
              color: AppColors.textLightMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformAnalyticsPage extends StatelessWidget {
  const _PlatformAnalyticsPage();

  static const List<_AnalyticsStat> _stats = [
    _AnalyticsStat(
      label: 'Total Organizations',
      value: '41',
      icon: Icons.apartment_rounded,
      color: AppColors.primary,
    ),
    _AnalyticsStat(
      label: 'Active Organizations',
      value: '1',
      icon: Icons.apartment_rounded,
      color: AppColors.green,
    ),
    _AnalyticsStat(
      label: 'On Trial',
      value: '40',
      icon: Icons.schedule_rounded,
      color: AppColors.blue,
    ),
    _AnalyticsStat(
      label: 'Estimated MRR (Active Plans)',
      value: '₹599',
      icon: Icons.currency_rupee_rounded,
      color: const Color(0xFFF59E0B),
    ),
  ];

  static const List<_AnalyticsSignupRow> _recentSignups = [
    _AnalyticsSignupRow(
      organization: 'Lead Test Org 761536',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'PDF Test Org 638555',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'ZZZ Probe Org 1787553662',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'ZZZ Probe Org 1787553294',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'ZZZ Probe Org 1787552777',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'ZZZ Probe Org 1787551985',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'ZZZ Probe Org 1787551362',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
    _AnalyticsSignupRow(
      organization: 'ZZZ Probe Org 1787549671',
      plan: 'No Plan',
      status: 'trial',
      signedUp: '24 Aug 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1400
                ? 4
                : constraints.maxWidth >= 900
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 2.6 : 2.9,
              ),
              itemBuilder: (context, index) =>
                  _AnalyticsStatCard(stat: _stats[index]),
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final planCard = _AnalyticsBreakdownCard(
              title: 'Organizations by Plan',
              children: const [
                _BreakdownRow(label: 'No Plan', value: '40'),
                _BreakdownRow(label: 'Enterprise', value: '1'),
              ],
            );
            final statusCard = _AnalyticsBreakdownCard(
              title: 'Organizations by Status',
              children: const [
                _BreakdownRow(
                  label: 'trial',
                  value: '40',
                  badgeColor: AppColors.blue,
                ),
                _BreakdownRow(
                  label: 'active',
                  value: '1',
                  badgeColor: AppColors.green,
                ),
              ],
            );

            if (wide) {
              return Row(
                children: [
                  Expanded(child: planCard),
                  const SizedBox(width: 12),
                  Expanded(child: statusCard),
                ],
              );
            }

            return Column(
              children: [planCard, const SizedBox(height: 12), statusCard],
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recently Signed Up',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Newest organizations on the platform',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1200,
                  child: Column(
                    children: [
                      const _AnalyticsTableHeader(),
                      const Divider(height: 1, color: AppColors.border),
                      ..._recentSignups.map(
                        (row) => Column(
                          children: [
                            _AnalyticsTableRow(row: row),
                            const Divider(
                              height: 1,
                              color: AppColors.borderLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final _AnalyticsStat stat;

  const _AnalyticsStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  stat.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: stat.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: stat.color.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(stat.icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsBreakdownCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AnalyticsBreakdownCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? badgeColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = badgeColor ?? AppColors.textSecondary;
    final isBadge = badgeColor != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTableHeader extends StatelessWidget {
  const _AnalyticsTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.textLightMuted,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
    );

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text('ORGANIZATION', style: style)),
          Expanded(flex: 2, child: Text('PLAN', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          Expanded(flex: 2, child: Text('SIGNED UP', style: style)),
        ],
      ),
    );
  }
}

class _AnalyticsTableRow extends StatelessWidget {
  final _AnalyticsSignupRow row;

  const _AnalyticsTableRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                row.organization,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                row.plan,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _Pill(label: row.status, color: AppColors.blue),
            ),
            Expanded(
              flex: 2,
              child: Text(
                row.signedUp,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _AnalyticsSignupRow {
  final String organization;
  final String plan;
  final String status;
  final String signedUp;

  const _AnalyticsSignupRow({
    required this.organization,
    required this.plan,
    required this.status,
    required this.signedUp,
  });
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.textLightMuted,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
    );

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('ORGANIZATION', style: style)),
          Expanded(flex: 1, child: Text('PLAN', style: style)),
          Expanded(flex: 1, child: Text('STATUS', style: style)),
          Expanded(flex: 1, child: Text('UPGRADE REQUEST', style: style)),
          Expanded(flex: 1, child: Text('BUSINESS TYPE', style: style)),
          Expanded(flex: 1, child: Text('PHONE', style: style)),
          Expanded(flex: 1, child: Text('CREATED', style: style)),
          SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _OrganizationRowItem extends StatelessWidget {
  final _OrganizationRow row;
  final ValueChanged<_OrganizationRow> onViewDetails;

  const _OrganizationRowItem({required this.row, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                row.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: _Pill(label: row.plan, color: AppColors.borderStrong),
            ),
            Expanded(
              flex: 1,
              child: _Pill(
                label: row.status,
                color: row.status == 'Active'
                    ? AppColors.green
                    : AppColors.blue,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                row.upgradeRequest,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                row.businessType,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                row.phone,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                row.created,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            SizedBox(
              width: 24,
              child: _OrganizationActionsMenu(
                row: row,
                compact: true,
                onViewDetails: () => onViewDetails(row),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationActionsMenu extends StatelessWidget {
  final _OrganizationRow row;
  final bool compact;
  final VoidCallback onViewDetails;

  const _OrganizationActionsMenu({
    required this.row,
    required this.onViewDetails,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Organization actions',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Icon(
        Icons.more_vert_rounded,
        size: compact ? 16 : 18,
        color: AppColors.textLightMuted,
      ),
      onSelected: (value) {
        if (value == 'view_details') {
          onViewDetails();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'view_details',
          child: Text(
            'View details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationDetailsPage extends StatefulWidget {
  final _OrganizationRow row;
  final VoidCallback onClose;

  const _OrganizationDetailsPage({required this.row, required this.onClose});

  @override
  State<_OrganizationDetailsPage> createState() =>
      _OrganizationDetailsPageState();
}

class _OrganizationDetailsPageState extends State<_OrganizationDetailsPage> {
  late String _statusValue;

  @override
  void initState() {
    super.initState();
    _statusValue = widget.row.status;
  }

  String _emailForRow() {
    final slug = widget.row.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
    return '$slug@example.com';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 720;
    final popupWidth = isMobile
        ? size.width * 0.96
        : math.min(size.width * 0.82, 1320).toDouble();
    final popupHeight = isMobile
        ? size.height * 0.92
        : math.min(size.height * 0.84, 860).toDouble();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF7),
          borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 30,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: widget.onClose,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(
                        'Back',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                widget.row.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              _Pill(
                                label: widget.row.status,
                                color: AppColors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Organization Details',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text(
                        'Delete Organization',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 980;
                            final cards = [
                              _SummaryStatCard(
                                label: 'Current Plan',
                                value: widget.row.plan,
                                icon: Icons.credit_card_rounded,
                                accent: AppColors.primary,
                              ),
                              _SummaryStatCard(
                                label: 'Price / month',
                                value: '₹0',
                                icon: Icons.payments_outlined,
                                accent: AppColors.green,
                              ),
                              _SummaryStatCard(
                                label: 'Trial Days Left',
                                value: '7',
                                icon: Icons.schedule_rounded,
                                accent: AppColors.blue,
                              ),
                              _SummaryStatCard(
                                label: 'Member Since',
                                value: widget.row.created,
                                icon: Icons.calendar_month_rounded,
                                accent: AppColors.accentGrey,
                              ),
                            ];

                            if (wide) {
                              return Row(
                                children: [
                                  Expanded(child: cards[0]),
                                  const SizedBox(width: 12),
                                  Expanded(child: cards[1]),
                                  const SizedBox(width: 12),
                                  Expanded(child: cards[2]),
                                  const SizedBox(width: 12),
                                  Expanded(child: cards[3]),
                                ],
                              );
                            }

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: cards
                                  .map(
                                    (card) => SizedBox(
                                      width: math.max(
                                        0,
                                        (constraints.maxWidth - 12) / 2,
                                      ),
                                      child: card,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _DetailSection(
                          title: 'Status Override',
                          subtitle:
                              'Manually set the organization\'s account status.',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 180,
                                child: _StatusDropdown(
                                  label: 'Status',
                                  value: _statusValue,
                                  options: const [
                                    'Trial',
                                    'Active',
                                    'Locked',
                                    'Inactive',
                                    'Suspended',
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _statusValue = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA3B896),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: const Text(
                                  'Update Status',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 980;
                            final details = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DetailLine(
                                  label: 'Business Type',
                                  value: widget.row.businessType,
                                ),
                                _DetailLine(
                                  label: 'Email',
                                  value: _emailForRow(),
                                ),
                                _DetailLine(
                                  label: 'Phone',
                                  value: widget.row.phone,
                                ),
                                _DetailLine(label: 'GST Number', value: '—'),
                                _DetailLine(label: 'PAN Number', value: '—'),
                                _DetailLine(label: 'Address', value: '—'),
                                _DetailLine(
                                  label: 'Financial Year',
                                  value: '—',
                                ),
                              ],
                            );
                            const planDetails = Text(
                              'This organization has no active plan.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            );

                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _DetailSection(
                                      title: 'Organization Details',
                                      child: details,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _DetailSection(
                                      title: 'Plan Details',
                                      child: planDetails,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                _DetailSection(
                                  title: 'Organization Details',
                                  child: details,
                                ),
                                const SizedBox(height: 12),
                                _DetailSection(
                                  title: 'Plan Details',
                                  child: planDetails,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganizationDetailsView extends StatefulWidget {
  final _OrganizationRow row;
  final VoidCallback onBack;

  const _OrganizationDetailsView({required this.row, required this.onBack});

  @override
  State<_OrganizationDetailsView> createState() =>
      _OrganizationDetailsViewState();
}

class _OrganizationDetailsViewState extends State<_OrganizationDetailsView> {
  late String _statusValue;

  @override
  void initState() {
    super.initState();
    _statusValue = widget.row.status;
  }

  String _emailForRow() {
    final slug = widget.row.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
    return '$slug@example.com';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
              TextButton.icon(
                onPressed: widget.onBack,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          widget.row.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _Pill(label: widget.row.status, color: AppColors.blue),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Organization Details',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(
                  'Delete Organization',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final cards = [
                _SummaryStatCard(
                  label: 'Current Plan',
                  value: widget.row.plan,
                  icon: Icons.credit_card_rounded,
                  accent: AppColors.primary,
                ),
                _SummaryStatCard(
                  label: 'Price / month',
                  value: '₹0',
                  icon: Icons.payments_outlined,
                  accent: AppColors.green,
                ),
                _SummaryStatCard(
                  label: 'Trial Days Left',
                  value: '7',
                  icon: Icons.schedule_rounded,
                  accent: AppColors.blue,
                ),
                _SummaryStatCard(
                  label: 'Member Since',
                  value: widget.row.created,
                  icon: Icons.calendar_month_rounded,
                  accent: AppColors.accentGrey,
                ),
              ];

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[2]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[3]),
                  ],
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: math.max(0, (constraints.maxWidth - 12) / 2),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Status Override',
            subtitle: 'Manually set the organization\'s account status.',
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: _StatusDropdown(
                    label: 'Status',
                    value: _statusValue,
                    options: const [
                      'Trial',
                      'Active',
                      'Locked',
                      'Inactive',
                      'Suspended',
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _statusValue = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3B896),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Update Status',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailLine(
                    label: 'Business Type',
                    value: widget.row.businessType,
                  ),
                  _DetailLine(label: 'Email', value: _emailForRow()),
                  _DetailLine(label: 'Phone', value: widget.row.phone),
                  const _DetailLine(label: 'GST Number', value: '—'),
                  const _DetailLine(label: 'PAN Number', value: '—'),
                  const _DetailLine(label: 'Address', value: '—'),
                  const _DetailLine(label: 'Financial Year', value: '—'),
                ],
              );
              const planDetails = Text(
                'This organization has no active plan.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DetailSection(
                        title: 'Organization Details',
                        child: details,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailSection(
                        title: 'Plan Details',
                        child: planDetails,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _DetailSection(title: 'Organization Details', child: details),
                  const SizedBox(height: 12),
                  _DetailSection(title: 'Plan Details', child: planDetails),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color == AppColors.borderStrong
        ? AppColors.textSecondary
        : color;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: color == AppColors.borderStrong ? 0.12 : 0.12,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<_TrendPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color axisColor;
  final Color textColor;

  const _GrowthChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.axisColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 28.0;
    const topPadding = 6.0;
    const bottomPadding = 18.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    const maxValue = 45.0;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    for (var value = 0; value <= 45; value += 10) {
      final y = topPadding + chartHeight - (value / maxValue * chartHeight);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), axisPaint);

      final painter = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(0, y - painter.height / 2));
    }

    if (points.isEmpty) return;

    final stepX = points.length == 1 ? 0.0 : chartWidth / (points.length - 1);
    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = leftPadding + (stepX * i);
      final y =
          topPadding + chartHeight - (points[i].value / maxValue * chartHeight);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(
        leftPadding + (stepX * (points.length - 1)),
        topPadding + chartHeight,
      )
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final lastX = leftPadding + (stepX * (points.length - 1));
    final lastY =
        topPadding + chartHeight - (points.last.value / maxValue * chartHeight);
    canvas.drawCircle(Offset(lastX, lastY), 6, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(lastX, lastY),
      4,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _DonutPainter extends CustomPainter {
  final List<_PlanSlice> slices;

  const _DonutPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * (math.pi * 2);
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep - 0.04, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricItem(this.label, this.value, this.icon, this.iconColor);
}

class _TrendPoint {
  final String label;
  final double value;

  const _TrendPoint(this.label, this.value);
}

class _PlanSlice {
  final String label;
  final int value;
  final Color color;
  final String shareLabel;

  const _PlanSlice(this.label, this.value, this.color, this.shareLabel);
}

class _OrganizationRow {
  final String name;
  final String plan;
  final String status;
  final String upgradeRequest;
  final String businessType;
  final String phone;
  final String created;

  const _OrganizationRow({
    required this.name,
    required this.plan,
    required this.status,
    required this.upgradeRequest,
    required this.businessType,
    required this.phone,
    required this.created,
  });
}

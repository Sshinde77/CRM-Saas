import 'package:flutter/material.dart';

import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../customers/sales_manager_customers_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../orders/sales_manager_orders_screen.dart';
import '../visits/sales_manager_visits_screen.dart';
import 'add_lead_screen.dart';

class SalesManagerLeadsScreen extends StatefulWidget {
  const SalesManagerLeadsScreen({super.key});

  @override
  State<SalesManagerLeadsScreen> createState() =>
      _SalesManagerLeadsScreenState();
}

class _SalesManagerLeadsScreenState extends State<SalesManagerLeadsScreen> {
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
    'Follow-up',
    'Qualified',
    'Lost',
  ];

  final List<String> _sourceOptions = const [
    'All Sources',
    'Website',
    'Referral',
    'Walk-in',
    'Social Media',
  ];

  final List<String> _teamOptions = const [
    'All Team',
    'Sunil Sales',
    'Neha Sharma',
    'Amit Verma',
  ];

  final List<int> _pageSizeOptions = const [10, 25, 50, 100];

  final List<_LeadRecord> _leads = const [
    _LeadRecord(
      initials: 'GV',
      initialsColor: Color(0xFF3B82F6),
      name: 'Green Valley Retail',
      code: 'LEAD-1007',
      amount: 'Rs. 42,000',
      phone: '9876543210',
      email: 'anita@greenvalley.example',
      source: 'Website',
      assignedTo: 'Sunil',
      assignedInitials: 'S',
      status: 'New',
      product: 'Water Jar Refill (20L), Water Dispenser - Normal',
      closingDate: '18 Aug 2026',
      createdAt: '06 Aug 2026',
    ),
    _LeadRecord(
      initials: 'SM',
      initialsColor: Color(0xFFF43F5E),
      name: 'Shree Medical Store',
      code: 'LEAD-1006',
      amount: 'Rs. 18,500',
      phone: '9123456780',
      email: '',
      source: 'Referral',
      assignedTo: 'Sunil',
      assignedInitials: 'S',
      status: 'Follow-up',
      product: 'Water Jar Refill (20L)',
      closingDate: '12 Aug 2026',
      createdAt: '05 Aug 2026',
    ),
    _LeadRecord(
      initials: 'BN',
      initialsColor: Color(0xFF8B5CF6),
      name: 'Blue Nest Offices',
      code: 'LEAD-1005',
      amount: 'Rs. 67,000',
      phone: '9988776655',
      email: 'ops@bluenest.example',
      source: 'Walk-in',
      assignedTo: 'Neha Sharma',
      assignedInitials: 'NS',
      status: 'Qualified',
      product: 'Water Dispenser - Hot & Cold, Water Jar Refill (20L)',
      closingDate: '-',
      createdAt: '05 Aug 2026',
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

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    switch (action) {
      case 'Dashboard':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SalesManagerDashboardScreen(),
          ),
        );
        return;
      case 'Customers':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SalesManagerCustomersScreen(),
          ),
        );
        return;
      case 'Create Order':
      case 'Sales Orders':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesManagerOrdersScreen()),
        );
        return;
      case 'Visits':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
        );
        return;
      case 'Leads':
        return;
      default:
        _showSnack('$action is not wired yet');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final leads = _filteredLeads().where((lead) {
      if (query.isEmpty) return true;
      return lead.name.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.code.toLowerCase().contains(query);
    }).toList();

    final shownLeads = leads.take(_selectedPageSize).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Leads',
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return Column(
              children: [
                SalesManagerTopBar(title: 'Leads'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 18,
                      10,
                      isMobile ? 14 : 18,
                      18,
                    ),
                    child: isMobile
                        ? _buildMobileContent(shownLeads, leads.length)
                        : _buildDesktopContent(shownLeads),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_LeadRecord> _visibleLeads() {
    return _leads.where((lead) {
      final statusOk =
          _statusFilter == 'All Status' || lead.status == _statusFilter;
      final sourceOk =
          _sourceFilter == 'All Sources' || lead.source == _sourceFilter;
      final teamOk =
          _teamFilter == 'All Team' || lead.assignedTo == _teamFilter;
      return statusOk && sourceOk && teamOk;
    }).toList();
  }

  List<_LeadRecord> _filteredLeads() {
    final productQuery = _productFilterController.text.trim().toLowerCase();
    final visible = _visibleLeads();
    if (productQuery.isEmpty) return visible;
    return visible.where((lead) {
      return lead.product.toLowerCase().contains(productQuery);
    }).toList();
  }

  Widget _buildDesktopContent(List<_LeadRecord> shownLeads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanelHeader(),
        const SizedBox(height: 14),
        _buildFiltersRow(),
        const SizedBox(height: 14),
        _buildTableCard(shownLeads),
      ],
    );
  }

  Widget _buildMobileContent(List<_LeadRecord> shownLeads, int totalLeads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobilePanelHeader(shownLeads.length, totalLeads),
        const SizedBox(height: 12),
        _buildMobileTableCard(shownLeads, totalLeads),
      ],
    );
  }

  Widget _buildMobilePanelHeader(int shownLeads, int totalLeads) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _searchField(
                  controller: _searchController,
                  hintText: 'Search leads...',
                ),
              ),
              const SizedBox(width: 10),
              _iconBox(Icons.refresh_rounded, () => setState(() {})),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pillFilter(
                value: _statusFilter,
                items: _statusOptions,
                onChanged: (value) =>
                    setState(() => _statusFilter = value ?? _statusFilter),
              ),
              _pillFilter(
                value: _sourceFilter,
                items: _sourceOptions,
                onChanged: (value) =>
                    setState(() => _sourceFilter = value ?? _sourceFilter),
              ),
              _pillFilter(
                value: _teamFilter,
                items: _teamOptions,
                onChanged: (value) =>
                    setState(() => _teamFilter = value ?? _teamFilter),
              ),
              _pillFilter(
                value: '$_selectedPageSize / page',
                items: _pageSizeOptions.map((e) => '$e / page').toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(
                    () => _selectedPageSize = int.parse(value.split(' ').first),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Showing $shownLeads of $totalLeads leads',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openAddLeadPage,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Lead'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4A06),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
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

  Widget _buildMobileTableCard(List<_LeadRecord> leads, int totalLeads) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lead List',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '$totalLeads leads',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          if (leads.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(
                child: Text(
                  'No leads found.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1200),
                child: _buildTableCard(leads),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SizedBox.shrink()),
              const Spacer(),
              Row(
                children: [
                  _actionButton(
                    icon: Icons.tune_rounded,
                    label: 'Manage',
                    onTap: () => _showSnack('Manage is not wired yet'),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.upload_rounded,
                    label: 'Bulk Upload',
                    onTap: () => _showSnack('Bulk Upload is not wired yet'),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.download_rounded,
                    label: 'Export',
                    onTap: () => _showSnack('Export is not wired yet'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _openAddLeadPage,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Lead'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4A06),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF0B4A06,
                      ).withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFilterChipsRow(),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17, color: const Color(0xFF475569)),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111827),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFiltersRow() {
    final leads = _filteredLeads();
    final shownLeads = leads.take(_selectedPageSize).toList();

    return Row(
      children: [
        _filterField(
          width: 250,
          hintText: 'Search leads...',
          controller: _searchController,
          prefixIcon: Icons.search_rounded,
        ),
        const SizedBox(width: 10),
        _dropdownFilter(
          width: 160,
          value: _statusFilter,
          items: _statusOptions,
          onChanged: (value) =>
              setState(() => _statusFilter = value ?? _statusFilter),
        ),
        const SizedBox(width: 10),
        _dropdownFilter(
          width: 160,
          value: _sourceFilter,
          items: _sourceOptions,
          onChanged: (value) =>
              setState(() => _sourceFilter = value ?? _sourceFilter),
        ),
        const SizedBox(width: 10),
        _dropdownFilter(
          width: 150,
          value: _teamFilter,
          items: _teamOptions,
          onChanged: (value) =>
              setState(() => _teamFilter = value ?? _teamFilter),
        ),
        const SizedBox(width: 10),
        _filterField(
          width: 300,
          hintText: 'Filter by product...',
          controller: _productFilterController,
          prefixIcon: Icons.search_rounded,
        ),
        const SizedBox(width: 10),
        _iconBox(Icons.refresh_rounded, () => setState(() {})),
        const Spacer(),
        Row(
          children: [
            Text(
              'Showing ${shownLeads.length} of ${leads.length} leads',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            _dropdownFilter(
              width: 110,
              value: '$_selectedPageSize / page',
              items: _pageSizeOptions.map((size) => '$size / page').toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(
                  () => _selectedPageSize = int.parse(value.split(' ').first),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChipsRow() {
    return const SizedBox.shrink();
  }

  Widget _searchField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B4A06)),
          ),
        ),
      ),
    );
  }

  Widget _pillFilter({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _dropdownFilter(
      width: double.infinity,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _filterField({
    required double width,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
  }) {
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          prefixIcon: Icon(
            prefixIcon,
            size: 18,
            color: const Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B4A06)),
          ),
        ),
      ),
    );
  }

  Widget _dropdownFilter({
    required double width,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final dropdown = DropdownButtonFormField<String>(
      key: ValueKey<String>(value),
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0B4A06)),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF94A3B8),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13.5,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (!width.isFinite) {
      return SizedBox(height: 38, child: dropdown);
    }

    return SizedBox(width: width, height: 38, child: dropdown);
  }

  Widget _iconBox(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, color: const Color(0xFF475569), size: 18),
      ),
    );
  }

  Widget _buildTableCard(List<_LeadRecord> leads) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          for (var i = 0; i < leads.length; i++) ...[
            _LeadRow(record: leads[i]),
            if (i != leads.length - 1)
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
          if (leads.isEmpty)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Text(
                'No leads found.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    Text header(String text, {double? width}) {
      return Text(
        text,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24, child: _CheckBoxStub()),
          const SizedBox(width: 16),
          Expanded(flex: 24, child: header('LEAD')),
          Expanded(flex: 18, child: header('PHONE')),
          Expanded(flex: 12, child: header('SOURCE')),
          Expanded(flex: 18, child: header('ASSIGNED')),
          Expanded(flex: 12, child: header('STATUS')),
          Expanded(flex: 22, child: header('PRODUCT')),
          Expanded(flex: 12, child: header('CLOSING DATE')),
          Expanded(flex: 12, child: header('CREATED')),
          const SizedBox(width: 28, child: SizedBox()),
        ],
      ),
    );
  }
}

class _LeadRow extends StatelessWidget {
  final _LeadRecord record;

  const _LeadRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 24, child: _CheckBoxStub()),
          const SizedBox(width: 16),
          Expanded(
            flex: 24,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: record.initialsColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    record.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record.code} - ${record.amount}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.phone,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (record.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.email,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: _Chip(
              label: record.source,
              background: const Color(0xFFF3F4F6),
              foreground: const Color(0xFF334155),
            ),
          ),
          Expanded(
            flex: 18,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4A06),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    record.assignedInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    record.assignedTo,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: _Chip(
              label: record.status,
              background: _leadStatusBackground(record.status),
              foreground: _leadStatusColor(record.status),
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(
              record.product,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              record.closingDate,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              record.createdAt,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            width: 28,
            child: Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadMobileCard extends StatelessWidget {
  final _LeadRecord record;

  const _LeadMobileCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: record.initialsColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  record.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _Chip(
                          label: record.status,
                          background: _leadStatusBackground(record.status),
                          foreground: _leadStatusColor(record.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.code} Ã¢â‚¬Â¢ ${record.amount}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Phone', record.phone),
          if (record.email.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow('Email', record.email),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _Chip(
                label: record.source,
                background: const Color(0xFFF3F4F6),
                foreground: const Color(0xFF334155),
              ),
              const SizedBox(width: 10),
              _Chip(
                label: record.assignedTo,
                background: const Color(0xFFEFF6FF),
                foreground: const Color(0xFF1D4ED8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.product,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoRow('Closing', record.closingDate)),
              const SizedBox(width: 12),
              Expanded(child: _infoRow('Created', record.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CheckBoxStub extends StatelessWidget {
  const _CheckBoxStub();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
    );
  }
}

Color _leadStatusColor(String status) {
  switch (status) {
    case 'New':
      return const Color(0xFF2563EB);
    case 'Follow-up':
      return const Color(0xFFD97706);
    case 'Qualified':
      return const Color(0xFF059669);
    case 'Lost':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF334155);
  }
}

Color _leadStatusBackground(String status) {
  switch (status) {
    case 'New':
      return const Color(0xFFEFF6FF);
    case 'Follow-up':
      return const Color(0xFFFFF7ED);
    case 'Qualified':
      return const Color(0xFFEFFAF4);
    case 'Lost':
      return const Color(0xFFFEE2E2);
    default:
      return const Color(0xFFF3F4F6);
  }
}

class _LeadRecord {
  final String initials;
  final Color initialsColor;
  final String name;
  final String code;
  final String amount;
  final String phone;
  final String email;
  final String source;
  final String assignedTo;
  final String assignedInitials;
  final String status;
  final String product;
  final String closingDate;
  final String createdAt;

  const _LeadRecord({
    required this.initials,
    required this.initialsColor,
    required this.name,
    required this.code,
    required this.amount,
    required this.phone,
    required this.email,
    required this.source,
    required this.assignedTo,
    required this.assignedInitials,
    required this.status,
    required this.product,
    required this.closingDate,
    required this.createdAt,
  });
}

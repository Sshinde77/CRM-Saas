import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class AdminLeadsScreen extends StatefulWidget {
  const AdminLeadsScreen({super.key});

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
    'Sunil',
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
      amount: 'Rs.42,000',
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
      initialsColor: Color(0xFFFF2D55),
      name: 'Shree Medical Store',
      code: 'LEAD-1006',
      amount: 'Rs18,500',
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
      amount: 'Rs67,000',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
    final query = _searchController.text.trim().toLowerCase();
    final productQuery = _productFilterController.text.trim().toLowerCase();

    return _visibleLeads().where((lead) {
      final searchOk =
          query.isEmpty ||
          lead.name.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.code.toLowerCase().contains(query);
      final productOk =
          productQuery.isEmpty ||
          lead.product.toLowerCase().contains(productQuery);
      return searchOk && productOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final leads = _filteredLeads();
    final shownLeads = leads.take(_selectedPageSize).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Leads'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Leads',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 1024;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPanel(constraints.maxWidth, isMobile, shownLeads, leads.length),
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

  Widget _buildPanel(
    double maxWidth,
    bool isMobile,
    List<_LeadRecord> shownLeads,
    int totalLeads,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 16 : 20,
        isMobile ? 16 : 24,
        isMobile ? 18 : 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildMobileControls(totalLeads, shownLeads.length),
            const SizedBox(height: 14),
            _buildMobileLeads(shownLeads),
          ] else ...[
            _buildDesktopControls(totalLeads, shownLeads.length),
            const SizedBox(height: 18),
            _buildLeadsTable(shownLeads),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopControls(int totalLeads, int shownCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _filterField(
                    width: 312,
                    hintText: 'Search leads...',
                    controller: _searchController,
                    prefixIcon: Icons.search_rounded,
                  ),
                  _dropdownFilter(
                    width: 194,
                    value: _statusFilter,
                    items: _statusOptions,
                    onChanged: (value) {
                      setState(() => _statusFilter = value ?? _statusFilter);
                    },
                  ),
                  _dropdownFilter(
                    width: 194,
                    value: _sourceFilter,
                    items: _sourceOptions,
                    onChanged: (value) {
                      setState(() => _sourceFilter = value ?? _sourceFilter);
                    },
                  ),
                  _dropdownFilter(
                    width: 202,
                    value: _teamFilter,
                    items: _teamOptions,
                    onChanged: (value) {
                      setState(() => _teamFilter = value ?? _teamFilter);
                    },
                  ),
                  _filterField(
                    width: 360,
                    hintText: 'Filter by product...',
                    controller: _productFilterController,
                    prefixIcon: Icons.search_rounded,
                  ),
                  _iconBox(
                    Icons.refresh_rounded,
                    () => setState(() {
                      _searchController.clear();
                      _productFilterController.clear();
                      _statusFilter = 'All Status';
                      _sourceFilter = 'All Sources';
                      _teamFilter = 'All Team';
                      _selectedPageSize = 10;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                _actionButton(
                  icon: Icons.tune_rounded,
                  label: 'Manage',
                  onTap: () => _showMessage('Manage is not wired yet.'),
                ),
                _actionButton(
                  icon: Icons.upload_file_outlined,
                  label: 'Bulk Upload',
                  onTap: () => _showMessage('Bulk Upload is not wired yet.'),
                ),
                _actionButton(
                  icon: Icons.download_rounded,
                  label: 'Export',
                  onTap: () => _showMessage('Export is not wired yet.'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showMessage('Add Lead is not wired yet.'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Lead'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: AppColors.primary.withValues(alpha: 0.24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text.rich(
              TextSpan(
                text: 'Showing ',
                children: [
                  TextSpan(
                    text: '$shownCount',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: ' of $totalLeads leads'),
                ],
              ),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 14),
            _dropdownFilter(
              width: 128,
              value: '$_selectedPageSize / page',
              items: _pageSizeOptions.map((size) => '$size / page').toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedPageSize = int.parse(value.split(' ').first);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileControls(int totalLeads, int shownCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterField(
          width: double.infinity,
          hintText: 'Search leads...',
          controller: _searchController,
          prefixIcon: Icons.search_rounded,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dropdownFilter(
                width: double.infinity,
                value: _statusFilter,
                items: _statusOptions,
                onChanged: (value) {
                  setState(() => _statusFilter = value ?? _statusFilter);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdownFilter(
                width: double.infinity,
                value: _sourceFilter,
                items: _sourceOptions,
                onChanged: (value) {
                  setState(() => _sourceFilter = value ?? _sourceFilter);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dropdownFilter(
                width: double.infinity,
                value: _teamFilter,
                items: _teamOptions,
                onChanged: (value) {
                  setState(() => _teamFilter = value ?? _teamFilter);
                },
              ),
            ),
            const SizedBox(width: 10),
            _iconBox(
              Icons.refresh_rounded,
              () => setState(() {
                _searchController.clear();
                _productFilterController.clear();
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _filterField(
          width: double.infinity,
          hintText: 'Filter by product...',
          controller: _productFilterController,
          prefixIcon: Icons.search_rounded,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _actionButton(
              icon: Icons.tune_rounded,
              label: 'Manage',
              onTap: () => _showMessage('Manage is not wired yet.'),
            ),
            _actionButton(
              icon: Icons.upload_file_outlined,
              label: 'Bulk Upload',
              onTap: () => _showMessage('Bulk Upload is not wired yet.'),
            ),
            _actionButton(
              icon: Icons.download_rounded,
              label: 'Export',
              onTap: () => _showMessage('Export is not wired yet.'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showMessage('Add Lead is not wired yet.'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Lead'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            text: 'Showing ',
            children: [
              TextSpan(
                text: '$shownCount',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(text: ' of $totalLeads leads'),
            ],
          ),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _dropdownFilter(
          width: 132,
          value: '$_selectedPageSize / page',
          items: _pageSizeOptions.map((size) => '$size / page').toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedPageSize = int.parse(value.split(' ').first);
            });
          },
        ),
      ],
    );
  }

  Widget _buildLeadsTable(List<_LeadRecord> leads) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(22),
      ),
      child: leads.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(36),
              child: Center(
                child: Text(
                  'No leads found.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                _buildTableHeader(),
                for (var i = 0; i < leads.length; i++) ...[
                  _LeadRow(record: leads[i]),
                  if (i != leads.length - 1)
                    const Divider(height: 1, color: AppColors.borderLight),
                ],
              ],
            ),
    );
  }

  Widget _buildTableHeader() {
    Text header(String text) {
      return Text(
        text,
        style: const TextStyle(
          color: AppColors.textLightMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFC),
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 28, child: _CheckBoxStub()),
          const SizedBox(width: 18),
          Expanded(flex: 24, child: header('LEAD')),
          Expanded(flex: 18, child: header('PHONE')),
          Expanded(flex: 12, child: header('SOURCE')),
          Expanded(flex: 18, child: header('ASSIGNED')),
          Expanded(flex: 12, child: header('STATUS')),
          Expanded(flex: 22, child: header('PRODUCT')),
          Expanded(flex: 12, child: header('CLOSING DATE')),
          Expanded(flex: 12, child: header('CREATED')),
          const SizedBox(width: 28, child: Center(child: Text('ACTIONS', style: TextStyle(color: AppColors.textLightMuted, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1)))),
        ],
      ),
    );
  }

  Widget _buildMobileLeads(List<_LeadRecord> leads) {
    if (leads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'No leads found.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < leads.length; i++) ...[
          _LeadMobileCard(record: leads[i]),
          if (i != leads.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _filterField({
    required double width,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
  }) {
    return SizedBox(
      width: width.isFinite ? width : null,
      child: SizedBox(
        height: 46,
        child: TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textLightMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: AppColors.textLightMuted,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: _outlineBorder(AppColors.borderStrong),
            enabledBorder: _outlineBorder(AppColors.borderStrong),
            focusedBorder: _outlineBorder(AppColors.primary),
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
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textLightMuted,
      ),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: _outlineBorder(AppColors.borderStrong),
        enabledBorder: _outlineBorder(AppColors.borderStrong),
        focusedBorder: _outlineBorder(AppColors.primary),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
    );

    return SizedBox(
      width: width.isFinite ? width : null,
      height: 46,
      child: dropdown,
    );
  }

  Widget _iconBox(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Icon(icon, color: AppColors.accentGrey, size: 20),
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
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }
}

class _LeadRow extends StatelessWidget {
  final _LeadRecord record;

  const _LeadRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Row(
        children: [
          const SizedBox(width: 28, child: _CheckBoxStub()),
          const SizedBox(width: 18),
          Expanded(
            flex: 24,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: record.initialsColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    record.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record.code} - ${record.amount}',
                        style: const TextStyle(
                          color: AppColors.textLightMuted,
                          fontSize: 12,
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
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (record.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.email,
                    style: const TextStyle(
                      color: AppColors.textLightMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: _LeadChip(
              label: record.source,
              background: AppColors.surfaceSoft,
              foreground: AppColors.textSecondary,
            ),
          ),
          Expanded(
            flex: 18,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    record.assignedInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    record.assignedTo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: _LeadChip(
              label: record.status,
              background: _leadStatusBackground(record.status),
              foreground: _leadStatusColor(record.status),
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(
              record.product,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              record.closingDate,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              record.createdAt,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            width: 28,
            child: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textLightMuted,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _LeadChip(
                          label: record.status,
                          background: _leadStatusBackground(record.status),
                          foreground: _leadStatusColor(record.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.code} - ${record.amount}',
                      style: const TextStyle(
                        color: AppColors.textLightMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textLightMuted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _mobileInfoRow('Phone', record.phone),
          if (record.email.isNotEmpty) ...[
            const SizedBox(height: 8),
            _mobileInfoRow('Email', record.email),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _LeadChip(
                label: record.source,
                background: AppColors.surfaceSoft,
                foreground: AppColors.textSecondary,
              ),
              _LeadChip(
                label: record.assignedTo,
                background: const Color(0xFFEAF4EE),
                foreground: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.product,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _mobileInfoRow('Closing', record.closingDate)),
              const SizedBox(width: 12),
              Expanded(child: _mobileInfoRow('Created', record.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLightMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LeadChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _LeadChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
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
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderStrong),
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
      return AppColors.statusActiveText;
    case 'Lost':
      return AppColors.statusInactiveText;
    default:
      return AppColors.textSecondary;
  }
}

Color _leadStatusBackground(String status) {
  switch (status) {
    case 'New':
      return const Color(0xFFEFF6FF);
    case 'Follow-up':
      return const Color(0xFFFFF7ED);
    case 'Qualified':
      return AppColors.statusActiveBg;
    case 'Lost':
      return AppColors.statusInactiveBg;
    default:
      return AppColors.surfaceSoft;
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

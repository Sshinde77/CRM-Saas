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
  final TextEditingController _productController = TextEditingController();

  String _statusFilter = 'All Status';
  String _sourceFilter = 'All Sources';
  String _teamFilter = 'All Team';
  int _selectedPageSize = 10;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

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
      initialsColor: Color(0xFFFF2D55),
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
    _productController.dispose();
    super.dispose();
  }

  List<_LeadRecord> _filteredLeads() {
    final search = _searchController.text.trim().toLowerCase();
    final product = _productController.text.trim().toLowerCase();

    return _leads.where((lead) {
      final matchesStatus =
          _statusFilter == 'All Status' || lead.status == _statusFilter;
      final matchesSource =
          _sourceFilter == 'All Sources' || lead.source == _sourceFilter;
      final matchesTeam =
          _teamFilter == 'All Team' || lead.assignedTo == _teamFilter;
      final matchesSearch =
          search.isEmpty ||
          lead.name.toLowerCase().contains(search) ||
          lead.phone.toLowerCase().contains(search) ||
          lead.code.toLowerCase().contains(search) ||
          lead.email.toLowerCase().contains(search);
      final matchesProduct =
          product.isEmpty || lead.product.toLowerCase().contains(product);

      return matchesStatus &&
          matchesSource &&
          matchesTeam &&
          matchesSearch &&
          matchesProduct;
    }).take(_selectedPageSize).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFilterSheet() async {
    String status = _statusFilter;
    String source = _sourceFilter;
    String team = _teamFilter;
    final productController = TextEditingController(text: _productController.text);

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Lead Filters',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _sheetDropdown(
                      label: 'Status',
                      value: status,
                      items: _statusOptions,
                      onChanged: (value) {
                        setSheetState(() => status = value ?? status);
                      },
                    ),
                    const SizedBox(height: 14),
                    _sheetDropdown(
                      label: 'Source',
                      value: source,
                      items: _sourceOptions,
                      onChanged: (value) {
                        setSheetState(() => source = value ?? source);
                      },
                    ),
                    const SizedBox(height: 14),
                    _sheetDropdown(
                      label: 'Team',
                      value: team,
                      items: _teamOptions,
                      onChanged: (value) {
                        setSheetState(() => team = value ?? team);
                      },
                    ),
                    const SizedBox(height: 14),
                    _sheetField(
                      label: 'Product',
                      hint: 'Filter by product',
                      controller: productController,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                status = 'All Status';
                                source = 'All Sources';
                                team = 'All Team';
                                productController.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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

    if (applied != true || !mounted) return;

    setState(() {
      _statusFilter = status;
      _sourceFilter = source;
      _teamFilter = team;
      _productController.text = productController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leads = _filteredLeads();

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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleRow(),
                    const SizedBox(height: 14),
                    _searchRow(),
                    const SizedBox(height: 12),
                    _filterChips(),
                    const SizedBox(height: 14),
                    if (leads.isEmpty)
                      _emptyState()
                    else
                      ...leads.map(
                        (lead) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _leadCard(lead),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Total Leads: ',
                        children: [
                          TextSpan(
                            text: '${leads.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13,
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
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Leads',
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => _showMessage('Add Lead is not wired yet.'),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Lead'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search lead, phone, email...',
                hintStyle: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 2),
                  child: Icon(
                    Icons.search_rounded,
                    color: textPrimary,
                    size: 21,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 42,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                border: _outlineBorder(AppColors.borderStrong),
                enabledBorder: _outlineBorder(AppColors.borderStrong),
                focusedBorder: _outlineBorder(AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Filter leads',
          child: InkWell(
            onTap: _openFilterSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStrong),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.filter_list_rounded,
                color: textPrimary,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChips() {
    final chips = <Widget>[];

    if (_statusFilter != 'All Status') {
      chips.add(_filterChip('Status: $_statusFilter'));
    }
    if (_sourceFilter != 'All Sources') {
      chips.add(_filterChip('Source: $_sourceFilter'));
    }
    if (_teamFilter != 'All Team') {
      chips.add(_filterChip('Team: $_teamFilter'));
    }
    if (_productController.text.trim().isNotEmpty) {
      chips.add(_filterChip('Product: ${_productController.text.trim()}'));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...chips,
        ActionChip(
          label: const Text('Clear filters'),
          onPressed: () {
            setState(() {
              _statusFilter = 'All Status';
              _sourceFilter = 'All Sources';
              _teamFilter = 'All Team';
              _productController.clear();
              _searchController.clear();
              _selectedPageSize = 10;
            });
          },
          backgroundColor: const Color(0xFFF4F6F8),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.surfaceSoft,
      side: BorderSide(color: AppColors.borderLight),
    );
  }

  Widget _leadCard(_LeadRecord lead) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(lead.initials, compact ? 52 : 60, lead.initialsColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            lead.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusChip(lead.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lead.code} - ${lead.amount}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoPairRow(
                      leftIcon: Icons.call_outlined,
                      leftText: lead.phone,
                      rightIcon: Icons.language_rounded,
                      rightText: lead.source,
                    ),
                    if (lead.email.trim().isNotEmpty) ...[
                      const SizedBox(height: 7),
                      _infoLine(Icons.email_outlined, lead.email),
                    ],
                    const SizedBox(height: 7),
                    _infoPairRow(
                      leftIcon: Icons.person_outline_rounded,
                      leftText: lead.assignedTo,
                      rightIcon: Icons.inventory_2_outlined,
                      rightText: lead.product,
                    ),
                    const SizedBox(height: 7),
                    _infoPairRow(
                      leftIcon: Icons.event_outlined,
                      leftText: 'Closing: ${lead.closingDate}',
                      rightIcon: Icons.schedule_outlined,
                      rightText: 'Created: ${lead.createdAt}',
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _actionRow(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoPairRow({
    required IconData leftIcon,
    required String leftText,
    required IconData rightIcon,
    required String rightText,
  }) {
    return Row(
      children: [
        Expanded(child: _infoLine(leftIcon, leftText)),
        const SizedBox(width: 8),
        Expanded(child: _infoLine(rightIcon, rightText)),
      ],
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: textPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.tune_rounded,
          label: 'Manage',
          color: AppColors.primary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: () => _showMessage('Manage is not wired yet.'),
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.upload_file_outlined,
          label: 'Bulk Upload',
          color: textPrimary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: () => _showMessage('Bulk Upload is not wired yet.'),
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.download_rounded,
          label: 'Export',
          color: AppColors.red,
          backgroundColor: const Color(0xFFFFEBEB),
          onTap: () => _showMessage('Export is not wired yet.'),
        ),
      ],
    );
  }

  Widget _avatar(String initials, double size, Color backgroundColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.24,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final foreground = _leadStatusColor(status);
    final background = _leadStatusBackground(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text(
          'No leads match your search.',
          style: TextStyle(color: textSecondary, fontSize: 15),
        ),
      ),
    );
  }

  Widget _sheetField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: _outlineBorder(AppColors.borderStrong),
            enabledBorder: _outlineBorder(AppColors.borderStrong),
            focusedBorder: _outlineBorder(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _sheetDropdown({
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
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey<String>('$label-$value'),
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
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
        ),
      ],
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
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

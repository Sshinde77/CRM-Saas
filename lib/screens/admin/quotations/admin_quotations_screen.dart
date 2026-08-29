import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'create_quotation_screen.dart';
import 'quotation_detail_screen.dart';

class AdminQuotationsScreen extends StatefulWidget {
  const AdminQuotationsScreen({super.key});

  @override
  State<AdminQuotationsScreen> createState() => _AdminQuotationsScreenState();
}

class _AdminQuotationsScreenState extends State<AdminQuotationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'All status';
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _statusOptions = const [
    'All status',
    'Draft',
    'Sent',
    'Accepted',
    'Rejected',
  ];

  List<_QuotationRecord> _quotations = const [
    _QuotationRecord(
      id: 'QT-2026-1003',
      number: 'QT-2026-1003',
      customer: 'Hotel Grand Meridian',
      salesperson: 'Vikram Singh',
      date: '06 Aug 2026',
      validUntil: '21 Aug 2026',
      amount: '₹2,240',
      status: 'Draft',
      itemCount: '1 item(s)',
      statusColor: Color(0xFF6B7280),
      statusBackground: Color(0xFFF3F4F6),
    ),
    _QuotationRecord(
      id: 'QT-2026-1002',
      number: 'QT-2026-1002',
      customer: 'Sunrise Corporate Park',
      salesperson: 'Vikram Singh',
      date: '05 Aug 2026',
      validUntil: '20 Aug 2026',
      amount: '₹6,278',
      status: 'Sent',
      itemCount: '1 item(s)',
      statusColor: Color(0xFF2563EB),
      statusBackground: Color(0xFFEFF6FF),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadQuotations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _apiProvider.fetchQuotations();
      if (!mounted) return;
      setState(() {
        _quotations = items.map(_QuotationRecord.fromJson).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<_QuotationRecord> _filteredQuotations() {
    final query = _searchController.text.trim().toLowerCase();
    return _quotations.where((quotation) {
      final statusOk =
          _selectedStatus == 'All status' ||
          quotation.status == _selectedStatus;
      if (!statusOk) return false;
      if (query.isEmpty) return true;
      return quotation.number.toLowerCase().contains(query) ||
          quotation.customer.toLowerCase().contains(query) ||
          quotation.salesperson.toLowerCase().contains(query) ||
          quotation.date.toLowerCase().contains(query) ||
          quotation.validUntil.toLowerCase().contains(query) ||
          quotation.amount.toLowerCase().contains(query) ||
          quotation.status.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openCreateQuotationScreen() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewQuotationScreen()));

    if (result != null && mounted) {
      await _loadQuotations();
    }
  }

  Future<void> _openEditQuotationScreen(_QuotationRecord _) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewQuotationScreen()));

    if (result != null && mounted) {
      await _loadQuotations();
    }
  }

  Future<void> _openQuotationDetails(_QuotationRecord record) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuotationDetailScreen(quotationId: record.id),
      ),
    );

    if (result != null && mounted) {
      await _loadQuotations();
    }
  }

  Future<bool> _confirmDeleteQuotation(_QuotationRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Quotation',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Delete ${record.number}? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _deleteQuotation(_QuotationRecord record) async {
    final confirmed = await _confirmDeleteQuotation(record);
    if (!confirmed || !mounted) return;

    try {
      await _apiProvider.deleteQuotation(record.id);
      if (!mounted) return;
      await _loadQuotations();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${record.number} deleted')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete quotation: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quotations = _filteredQuotations();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Quotation'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return Column(
              children: [
                AdminTopBar(
                  title: 'Quotation',
                  leadingIcon: Icons.menu_rounded,
                  onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 18,
                      10,
                      isMobile ? 14 : 18,
                      18,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: isMobile
                          ? _isLoading
                                ? _loadingState()
                                : _errorMessage != null
                                ? _errorState(_errorMessage!, _loadQuotations)
                                : _buildMobileContent(quotations)
                          : _isLoading
                          ? _loadingState()
                          : _errorMessage != null
                          ? _errorState(_errorMessage!, _loadQuotations)
                          : _buildDesktopContent(quotations),
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

  Widget _buildDesktopContent(List<_QuotationRecord> quotations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _searchField(width: 350),
                    _statusDropdown(width: 200),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _openCreateQuotationScreen,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Quotation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4A06),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: _buildQuotationCardList(quotations),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Row(
            children: [
              Text(
                '${quotations.length} of ${_quotations.length}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                'Quotations',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF0B4A06))),
    );
  }

  Widget _errorState(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent(List<_QuotationRecord> quotations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _searchField(width: double.infinity)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _statusDropdown(width: 180),
                  ElevatedButton.icon(
                    onPressed: _openCreateQuotationScreen,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Quotation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4A06),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
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
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var i = 0; i < quotations.length; i++) ...[
                _QuotationCard(
                  record: quotations[i],
                  onView: () => _openQuotationDetails(quotations[i]),
                  onEdit: () => _openEditQuotationScreen(quotations[i]),
                  onDelete: () => _deleteQuotation(quotations[i]),
                ),
                if (i != quotations.length - 1) const SizedBox(height: 12),
              ],
              if (quotations.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text(
                      'No quotations found.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 18),
          child: Row(
            children: [
              Text(
                '${quotations.length} of ${_quotations.length}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                'Quotations',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchField({required double width}) {
    final field = TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search quotations',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0B4A06)),
        ),
      ),
    );

    if (!width.isFinite) {
      return SizedBox(height: 44, child: field);
    }

    return SizedBox(width: width, height: 44, child: field);
  }

  Widget _statusDropdown({required double width}) {
    final dropdown = DropdownButtonFormField<String>(
      key: ValueKey<String>(_selectedStatus),
      initialValue: _selectedStatus,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedStatus = value);
      },
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0B4A06)),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF94A3B8),
      ),
      items: _statusOptions
          .map(
            (status) => DropdownMenuItem<String>(
              value: status,
              child: Text(
                status,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (!width.isFinite) {
      return SizedBox(height: 44, child: dropdown);
    }

    return SizedBox(width: width, height: 44, child: dropdown);
  }

  Widget _buildQuotationCardList(List<_QuotationRecord> quotations) {
    if (quotations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No quotations found.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < quotations.length; i++) ...[
          _QuotationCard(
            record: quotations[i],
            onView: () => _openQuotationDetails(quotations[i]),
            onEdit: () => _openEditQuotationScreen(quotations[i]),
            onDelete: () => _deleteQuotation(quotations[i]),
          ),
          if (i != quotations.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _QuotationRecord {
  final String id;
  final String number;
  final String customer;
  final String salesperson;
  final String date;
  final String validUntil;
  final String amount;
  final String status;
  final String itemCount;
  final Color statusColor;
  final Color statusBackground;

  const _QuotationRecord({
    required this.id,
    required this.number,
    required this.customer,
    required this.salesperson,
    required this.date,
    required this.validUntil,
    required this.amount,
    required this.status,
    required this.itemCount,
    required this.statusColor,
    required this.statusBackground,
  });

  factory _QuotationRecord.fromJson(Map<String, dynamic> json) {
    final status = _stringValue(json, const ['status'], fallback: 'Draft');
    final itemCount = _numValue(json, const ['item_count', 'itemCount']);
    final number = _stringValue(json, const [
      'quotation_number',
      'quotationNumber',
      'number',
      'id',
    ]);
    final id = _stringValue(json, const [
      'id',
      'quotation_id',
      'quotationId',
    ], fallback: number);
    return _QuotationRecord(
      id: id,
      number: number,
      customer: _stringValue(
        json,
        const ['customer_name', 'customerName'],
        nestedKeys: const ['customer'],
      ),
      salesperson: _stringValue(
        json,
        const ['salesperson_name', 'salespersonName'],
        nestedKeys: const ['salesperson', 'user'],
      ),
      date: _formatApiDate(
        _stringValue(json, const ['quotation_date', 'quotationDate', 'date']),
      ),
      validUntil: _formatApiDate(
        _stringValue(json, const ['valid_until', 'validUntil']),
      ),
      amount: _formatMoney(_numValue(json, const ['total', 'amount'])),
      status: status,
      itemCount: '${itemCount.toStringAsFixed(0)} item(s)',
      statusColor: _quotationStatusColor(status),
      statusBackground: _quotationStatusBackground(status),
    );
  }

  String get initials {
    final source = customer == '-' ? number : customer;
    final parts = source
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'QT';
    if (parts.length == 1) {
      final text = parts.first.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      if (text.isEmpty) return 'QT';
      return text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

String _stringValue(
  Map<String, dynamic> json,
  List<String> keys, {
  List<String> nestedKeys = const [],
  String fallback = '-',
}) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  for (final nestedKey in nestedKeys) {
    final nested = json[nestedKey];
    if (nested is Map<String, dynamic>) {
      final value = _stringValue(nested, const [
        'name',
        'full_name',
      ], fallback: '');
      if (value.isNotEmpty) return value;
    }
  }
  return fallback;
}

double _numValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value != null) {
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

String _formatMoney(double value) =>
    'Rs. ${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';

String _formatApiDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? '-' : value;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
}

Color _quotationStatusColor(String status) {
  return switch (status.toLowerCase()) {
    'sent' => const Color(0xFF2563EB),
    'accepted' => const Color(0xFF16A34A),
    'rejected' => const Color(0xFFDC2626),
    _ => const Color(0xFF6B7280),
  };
}

Color _quotationStatusBackground(String status) {
  return switch (status.toLowerCase()) {
    'sent' => const Color(0xFFEFF6FF),
    'accepted' => const Color(0xFFE8F8EE),
    'rejected' => const Color(0xFFFEE2E2),
    _ => const Color(0xFFF3F4F6),
  };
}

class _QuotationCard extends StatelessWidget {
  final _QuotationRecord record;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuotationCard({
    required this.record,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              _quotationAvatar(record.initials, compact ? 52 : 60),
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
                            record.number,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: record.status,
                          background: record.statusBackground,
                          foreground: record.statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoPairRow(
                      leftIcon: Icons.person_outline_rounded,
                      leftText: record.salesperson,
                      rightIcon: Icons.inventory_2_outlined,
                      rightText: record.itemCount,
                    ),
                    const SizedBox(height: 7),
                    _infoPairRow(
                      leftIcon: Icons.calendar_today_outlined,
                      leftText: record.date,
                      rightIcon: Icons.event_available_outlined,
                      rightText: record.validUntil,
                    ),
                    const SizedBox(height: 7),
                    _infoPairRow(
                      leftIcon: Icons.currency_rupee_rounded,
                      leftText: record.amount,
                      rightIcon: Icons.circle_rounded,
                      rightText: record.status,
                      rightIconColor: record.statusColor,
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
    Color? rightIconColor,
  }) {
    return Row(
      children: [
        Expanded(child: _infoLine(leftIcon, leftText)),
        const SizedBox(width: 8),
        Expanded(
          child: _infoLine(
            rightIcon,
            rightText,
            iconColor: rightIconColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoLine(
    IconData icon,
    String text, {
    Color iconColor = AppColors.textPrimary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
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
          icon: Icons.visibility_outlined,
          label: 'View Details',
          color: AppColors.primary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: onView,
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: AppColors.textPrimary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: onEdit,
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AppColors.red,
          backgroundColor: const Color(0xFFFFEBEB),
          onTap: onDelete,
        ),
      ],
    );
  }

  Widget _quotationAvatar(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.24,
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
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

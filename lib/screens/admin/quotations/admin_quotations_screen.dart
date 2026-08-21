import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'create_quotation_screen.dart';

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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NewQuotationScreen(),
                    ),
                  );
                },
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
          child: _buildTable(quotations),
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NewQuotationScreen(),
                        ),
                      );
                    },
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
                _QuotationCard(record: quotations[i]),
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
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 18),
          child: Row(
            children: [
              Text(
                '1 to 2 of 2',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
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

  Widget _buildTable(List<_QuotationRecord> quotations) {
    final rows = quotations.isEmpty
        ? [
            const Padding(
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
            ),
          ]
        : quotations
              .map(
                (record) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.number,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.itemCount,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: Text(
                          record.customer,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Text(
                          record.salesperson,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          record.date,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          record.validUntil,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          record.amount,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusChip(
                            label: record.status,
                            background: record.statusBackground,
                            foreground: record.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 14),
          child: Row(
            children: const [
              SizedBox(width: 190, child: _TableHeading('QUOTATION')),
              SizedBox(width: 260, child: _TableHeading('CUSTOMER')),
              SizedBox(width: 180, child: _TableHeading('SALESPERSON')),
              SizedBox(width: 150, child: _TableHeading('DATE')),
              SizedBox(width: 150, child: _TableHeading('VALID UNTIL')),
              SizedBox(width: 120, child: _TableHeading('AMOUNT')),
              SizedBox(width: 110, child: _TableHeading('STATUS')),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        if (quotations.isEmpty)
          const Padding(
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
          )
        else
          ...rows,
      ],
    );
  }
}

class _QuotationRecord {
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
    return _QuotationRecord(
      number: _stringValue(
        json,
        const ['quotation_number', 'quotationNumber', 'number', 'id'],
      ),
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
      final value = _stringValue(nested, const ['name', 'full_name'], fallback: '');
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

String _formatMoney(double value) => 'Rs. ${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';

String _formatApiDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? '-' : value;
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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

  const _QuotationCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.number,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.itemCount,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: record.status,
                background: record.statusBackground,
                foreground: record.statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Customer', record.customer),
          const SizedBox(height: 8),
          _infoRow('Salesperson', record.salesperson),
          const SizedBox(height: 8),
          _infoRow('Date', record.date),
          const SizedBox(height: 8),
          _infoRow('Valid Until', record.validUntil),
          const SizedBox(height: 8),
          _infoRow('Amount', record.amount),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 94,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TableHeading extends StatelessWidget {
  final String title;

  const _TableHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

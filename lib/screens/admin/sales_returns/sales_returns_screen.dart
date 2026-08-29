import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'new_sales_return_screen.dart';

class SalesReturnsScreen extends StatefulWidget {
  const SalesReturnsScreen({super.key});

  @override
  State<SalesReturnsScreen> createState() => _SalesReturnsScreenState();
}

class _SalesReturnsScreenState extends State<SalesReturnsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const List<String> _statusOptions = [
    'All status',
    'Requested',
    'Received',
    'Approved',
    'Rejected',
  ];

  String _selectedStatus = 'All status';
  String _query = '';

  final List<_SalesReturnRecord> _returns = [
    _SalesReturnRecord(
      returnNo: 'SR-2026-001',
      orderNo: 'SO-2026-1005',
      customer: 'Green Leaf Caterers',
      date: DateTime(2026, 7, 12),
      reason: 'Damaged items',
      status: 'Requested',
      amount: 1240,
    ),
    _SalesReturnRecord(
      returnNo: 'SR-2026-002',
      orderNo: 'SO-2026-1008',
      customer: 'Hotel Grand Meridian',
      date: DateTime(2026, 7, 14),
      reason: 'Wrong quantity delivered',
      status: 'Received',
      amount: 860,
    ),
    _SalesReturnRecord(
      returnNo: 'SR-2026-003',
      orderNo: 'SO-2026-1011',
      customer: 'The Coastal Kitchen',
      date: DateTime(2026, 7, 18),
      reason: 'Customer cancellation',
      status: 'Approved',
      amount: 540,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _formatMoney(double value) {
    final rounded = value.round();
    final digits = rounded.toString();
    if (digits.length <= 3) return 'INR $digits';

    final last3 = digits.substring(digits.length - 3);
    final parts = <String>[];
    String rest = digits.substring(0, digits.length - 3);
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return 'INR ${parts.join(',')},$last3';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Requested':
        return AppColors.blue;
      case 'Received':
        return AppColors.amber;
      case 'Approved':
        return AppColors.green;
      case 'Rejected':
        return AppColors.red;
      default:
        return AppColors.secondary;
    }
  }

  List<_SalesReturnRecord> get _filteredReturns {
    final query = _query.trim().toLowerCase();
    return _returns.where((item) {
      final statusMatch =
          _selectedStatus == 'All status' || item.status == _selectedStatus;
      if (!statusMatch) return false;
      if (query.isEmpty) return true;
      return item.returnNo.toLowerCase().contains(query) ||
          item.orderNo.toLowerCase().contains(query) ||
          item.customer.toLowerCase().contains(query) ||
          item.reason.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query) ||
          _formatDate(item.date).toLowerCase().contains(query) ||
          _formatMoney(item.amount).toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleNewReturn() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewSalesReturnScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final returns = _filteredReturns;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Sales Returns'),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  SizedBox(width: 290, child: _searchField()),
                                  SizedBox(
                                    width: 165,
                                    child: _statusDropdown(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _newReturnButton(compact: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    returns.isEmpty
                        ? _emptyState()
                        : Column(
                            children: [
                              const Divider(
                                height: 1,
                                color: Color(0xFFE5E7EB),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
                                child: ListView.separated(
                                  itemCount: returns.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 20,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  itemBuilder: (context, index) {
                                    return _returnListTile(returns[index]);
                                  },
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFE5E7EB),
                              ),
                            ],
                          ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            '${returns.length} to ${returns.isEmpty ? 0 : returns.length}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Sales Returns',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _roundIconButton(Icons.help_outline_rounded, onTap: () {}),
          const SizedBox(width: 10),
          _roundIconButton(Icons.notifications_none_rounded, onTap: () {}),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4A06),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'RS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rahul Sharma',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Color(0xFF0B4A06),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, {required VoidCallback onTap}) {
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
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20),
        ),
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          hintText: 'Search sales returns',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0B4A06)),
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Color(0xFF94A3B8),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          selectedItemBuilder: (context) {
            return _statusOptions
                .map(
                  (status) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList();
          },
          items: _statusOptions
              .map(
                (status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'All status'
                          ? AppColors.primary
                          : const Color(0xFF475569),
                      fontWeight: status == 'All status'
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
      ),
    );
  }

  Widget _newReturnButton({required bool compact}) {
    return ElevatedButton.icon(
      onPressed: _handleNewReturn,
      icon: Icon(Icons.add_rounded, size: compact ? 18 : 20),
      label: const Text('New Return'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B4A06),
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x330B4A06),
        minimumSize: Size(compact ? 0 : 46, compact ? 36 : 46),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 18 : 22,
          vertical: compact ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: TextStyle(
          fontSize: compact ? 13 : 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Center(
        child: Column(
          children: [
            const Text(
              'No sales returns found',
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Raise a return request against an existing invoice.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            _newReturnButton(compact: true),
          ],
        ),
      ),
    );
  }

  Widget _returnListTile(_SalesReturnRecord item) {
    final statusColor = _statusColor(item.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.keyboard_return_rounded,
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
                  item.returnNo,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.customer} - ${_formatDate(item.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesReturnRecord {
  final String returnNo;
  final String orderNo;
  final String customer;
  final DateTime date;
  final String reason;
  final String status;
  final double amount;

  const _SalesReturnRecord({
    required this.returnNo,
    required this.orderNo,
    required this.customer,
    required this.date,
    required this.reason,
    required this.status,
    required this.amount,
  });
}

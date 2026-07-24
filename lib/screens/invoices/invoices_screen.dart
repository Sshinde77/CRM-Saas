import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

enum _InvoiceTab { sales, purchases }

class _SalesInvoice {
  final String invoiceNo;
  final String customer;
  final DateTime date;
  final String status;
  final double total;

  _SalesInvoice({
    required this.invoiceNo,
    required this.customer,
    required this.date,
    required this.status,
    required this.total,
  });
}

class _PurchaseInvoice {
  final String invoiceNo;
  final String supplier;
  final DateTime date;
  final String status;
  final double total;

  _PurchaseInvoice({
    required this.invoiceNo,
    required this.supplier,
    required this.date,
    required this.status,
    required this.total,
  });
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  _InvoiceTab _selectedTab = _InvoiceTab.sales;

  final List<_SalesInvoice> _salesInvoices = [
    _SalesInvoice(
      invoiceNo: 'SI-2026-001',
      customer: 'Anita Sharma',
      date: DateTime(2026, 7, 23),
      status: 'Paid',
      total: 2450,
    ),
    _SalesInvoice(
      invoiceNo: 'SI-2026-002',
      customer: 'Vikram Singh',
      date: DateTime(2026, 7, 22),
      status: 'Pending',
      total: 1890,
    ),
    _SalesInvoice(
      invoiceNo: 'SI-2026-003',
      customer: 'Priya Nair',
      date: DateTime(2026, 7, 21),
      status: 'Overdue',
      total: 3120,
    ),
    _SalesInvoice(
      invoiceNo: 'SI-2026-004',
      customer: 'Rahul Mehta',
      date: DateTime(2026, 7, 20),
      status: 'Paid',
      total: 1680,
    ),
  ];

  final List<_PurchaseInvoice> _purchaseInvoices = [
    _PurchaseInvoice(
      invoiceNo: 'PI-2026-001',
      supplier: 'Prime Manufacturing',
      date: DateTime(2026, 7, 23),
      status: 'Paid',
      total: 6420,
    ),
    _PurchaseInvoice(
      invoiceNo: 'PI-2026-002',
      supplier: 'Bottle Suppliers Inc',
      date: DateTime(2026, 7, 22),
      status: 'Pending',
      total: 4850,
    ),
    _PurchaseInvoice(
      invoiceNo: 'PI-2026-003',
      supplier: 'Aqua Pack Traders',
      date: DateTime(2026, 7, 21),
      status: 'Overdue',
      total: 9100,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime value) {
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
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
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
      case 'Paid':
        return AppColors.green;
      case 'Pending':
        return AppColors.blue;
      case 'Overdue':
        return AppColors.red;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSales = _selectedTab == _InvoiceTab.sales;
    final searchQuery = _searchController.text.trim().toLowerCase();

    final filteredSales = _salesInvoices.where((invoice) {
      if (searchQuery.isEmpty) return true;
      return invoice.invoiceNo.toLowerCase().contains(searchQuery) ||
          invoice.customer.toLowerCase().contains(searchQuery) ||
          _formatDate(invoice.date).toLowerCase().contains(searchQuery) ||
          invoice.status.toLowerCase().contains(searchQuery) ||
          _formatMoney(invoice.total).toLowerCase().contains(searchQuery);
    }).toList();

    final filteredPurchases = _purchaseInvoices.where((invoice) {
      if (searchQuery.isEmpty) return true;
      return invoice.invoiceNo.toLowerCase().contains(searchQuery) ||
          invoice.supplier.toLowerCase().contains(searchQuery) ||
          _formatDate(invoice.date).toLowerCase().contains(searchQuery) ||
          invoice.status.toLowerCase().contains(searchQuery) ||
          _formatMoney(invoice.total).toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Invoices'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Invoices',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoices',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Switch between sales and purchase invoices',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _tabButton(
                              label: 'Sales Invoices',
                              selected: isSales,
                              onTap: () =>
                                  setState(() => _selectedTab = _InvoiceTab.sales),
                            ),
                          ),
                          Expanded(
                            child: _tabButton(
                              label: 'Purchase Invoices',
                              selected: !isSales,
                              onTap: () => setState(
                                () => _selectedTab = _InvoiceTab.purchases,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSales ? 'Sales Invoices' : 'Purchase Invoices',
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSales
                                ? 'Search by invoice, customer, date, status, or total.'
                                : 'Search by invoice, supplier, date, status, or total.',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded),
                              hintText: isSales
                                  ? 'Search sales invoices'
                                  : 'Search purchase invoices',
                              hintStyle: const TextStyle(color: textSecondary),
                              filled: true,
                              fillColor: AppColors.surfaceSoft,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.secondary.withValues(alpha: 0.14),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.purple,
                                  width: 1.4,
                                ),
                              ),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (isSales)
                            _buildSalesList(filteredSales)
                          else
                            _buildPurchaseList(filteredPurchases),
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

  Widget _tabButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.purple : textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesList(List<_SalesInvoice> invoices) {
    if (invoices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No sales invoices match your search.',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: invoices
          .map((invoice) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _invoiceCard(
                  invoiceNo: invoice.invoiceNo,
                  primaryLabel: 'Customer',
                  primaryValue: invoice.customer,
                  date: invoice.date,
                  status: invoice.status,
                  total: invoice.total,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPurchaseList(List<_PurchaseInvoice> invoices) {
    if (invoices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No purchase invoices match your search.',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: invoices
          .map((invoice) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _invoiceCard(
                  invoiceNo: invoice.invoiceNo,
                  primaryLabel: 'Supplier',
                  primaryValue: invoice.supplier,
                  date: invoice.date,
                  status: invoice.status,
                  total: invoice.total,
                ),
              ))
          .toList(),
    );
  }

  Widget _invoiceCard({
    required String invoiceNo,
    required String primaryLabel,
    required String primaryValue,
    required DateTime date,
    required String status,
    required double total,
  }) {
    final statusColor = _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceNo,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      primaryLabel,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.22)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(primaryLabel, primaryValue),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoRow('Date', _formatDate(date))),
              const SizedBox(width: 12),
              Expanded(child: _infoRow('Total', _formatMoney(total))),
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
            color: textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

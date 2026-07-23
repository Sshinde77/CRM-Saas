import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class _ExpenseRecord {
  final String expenseId;
  final String category;
  final String description;
  final String submittedBy;
  final DateTime date;
  final double amount;
  final String status;

  _ExpenseRecord({
    required this.expenseId,
    required this.category,
    required this.description,
    required this.submittedBy,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final List<_ExpenseRecord> _expenses = [
    _ExpenseRecord(
      expenseId: 'EXP-2026-001',
      category: 'Fuel',
      description: 'Vehicle fuel refill for delivery route',
      submittedBy: 'Suresh Kumar',
      date: DateTime(2026, 7, 23),
      amount: 2450,
      status: 'Approved',
    ),
    _ExpenseRecord(
      expenseId: 'EXP-2026-002',
      category: 'Maintenance',
      description: 'Minor repair for delivery vehicle',
      submittedBy: 'Ramesh Yadav',
      date: DateTime(2026, 7, 22),
      amount: 1800,
      status: 'Pending',
    ),
    _ExpenseRecord(
      expenseId: 'EXP-2026-003',
      category: 'Office',
      description: 'Stationery and printing materials',
      submittedBy: 'Anita Sharma',
      date: DateTime(2026, 7, 21),
      amount: 640,
      status: 'Rejected',
    ),
    _ExpenseRecord(
      expenseId: 'EXP-2026-004',
      category: 'Utilities',
      description: 'Monthly electricity charge',
      submittedBy: 'Priya Nair',
      date: DateTime(2026, 7, 20),
      amount: 5280,
      status: 'Approved',
    ),
    _ExpenseRecord(
      expenseId: 'EXP-2026-005',
      category: 'Travel',
      description: 'Client visit and local conveyance',
      submittedBy: 'Vikram Singh',
      date: DateTime(2026, 7, 19),
      amount: 950,
      status: 'Pending',
    ),
    _ExpenseRecord(
      expenseId: 'EXP-2026-006',
      category: 'Marketing',
      description: 'Promotional banners and flyers',
      submittedBy: 'Rahul Mehta',
      date: DateTime(2026, 7, 18),
      amount: 3100,
      status: 'Approved',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ExpenseRecord> get _filteredExpenses {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _expenses;

    return _expenses.where((expense) {
      return expense.expenseId.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query) ||
          expense.description.toLowerCase().contains(query) ||
          expense.submittedBy.toLowerCase().contains(query) ||
          _formatDate(expense.date).toLowerCase().contains(query) ||
          _formatMoney(expense.amount).toLowerCase().contains(query) ||
          expense.status.toLowerCase().contains(query);
    }).toList();
  }

  int get _totalExpenses => _expenses.length;

  int get _pendingCount =>
      _expenses.where((expense) => expense.status == 'Pending').length;

  int get _approvedCount =>
      _expenses.where((expense) => expense.status == 'Approved').length;

  int get _rejectedCount =>
      _expenses.where((expense) => expense.status == 'Rejected').length;

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
      case 'Approved':
        return AppColors.green;
      case 'Pending':
        return AppColors.blue;
      case 'Rejected':
        return AppColors.red;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _filteredExpenses;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Expenses'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Expenses',
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
                      'Expenses',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track submitted expenses and approval status',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width >= 1000
                            ? 4
                            : width >= 700
                                ? 2
                                : 1;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: crossAxisCount == 1 ? 4.2 : 2.2,
                          children: [
                            _statCard(
                              label: 'Total Expenses',
                              value: _totalExpenses.toString(),
                              icon: Icons.receipt_long_outlined,
                              color: AppColors.purple,
                            ),
                            _statCard(
                              label: 'Pending',
                              value: _pendingCount.toString(),
                              icon: Icons.timelapse_outlined,
                              color: AppColors.blue,
                            ),
                            _statCard(
                              label: 'Approved',
                              value: _approvedCount.toString(),
                              icon: Icons.verified_outlined,
                              color: AppColors.green,
                            ),
                            _statCard(
                              label: 'Rejected',
                              value: _rejectedCount.toString(),
                              icon: Icons.cancel_outlined,
                              color: AppColors.red,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
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
                          const Text(
                            'All Expenses',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Search by expense ID, category, description, submitted by, date, amount, or status.',
                            style: TextStyle(
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
                              hintText: 'Search expenses',
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
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.14,
                                  ),
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
                          if (expenses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No expenses match your search.',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: expenses
                                  .map(
                                    (expense) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _buildExpenseCard(expense),
                                    ),
                                  )
                                  .toList(),
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

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(_ExpenseRecord expense) {
    final statusColor = _statusColor(expense.status);

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
                  Icons.request_quote_outlined,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.expenseId,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expense.category,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.22)),
                ),
                child: Text(
                  expense.status,
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
          _infoRow('Description', expense.description),
          const SizedBox(height: 10),
          _infoRow('Submitted By', expense.submittedBy),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoRow('Date', _formatDate(expense.date)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoRow('Amount', _formatMoney(expense.amount)),
              ),
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

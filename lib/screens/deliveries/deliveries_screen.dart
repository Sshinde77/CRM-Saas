import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class _DeliveryRecord {
  final String orderNo;
  final String customer;
  final String deliveryPartner;
  final String status;
  final DateTime scheduledDate;
  final double amountDue;

  _DeliveryRecord({
    required this.orderNo,
    required this.customer,
    required this.deliveryPartner,
    required this.status,
    required this.scheduledDate,
    required this.amountDue,
  });
}

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final List<_DeliveryRecord> _deliveries = [
    _DeliveryRecord(
      orderNo: 'ORD-2026-001',
      customer: 'Anita Sharma',
      deliveryPartner: 'Suresh Kumar',
      status: 'Delivered',
      scheduledDate: DateTime(2026, 7, 23),
      amountDue: 0,
    ),
    _DeliveryRecord(
      orderNo: 'ORD-2026-002',
      customer: 'Vikram Singh',
      deliveryPartner: 'Ramesh Yadav',
      status: 'In Progress',
      scheduledDate: DateTime(2026, 7, 23),
      amountDue: 1250,
    ),
    _DeliveryRecord(
      orderNo: 'ORD-2026-003',
      customer: 'Priya Nair',
      deliveryPartner: 'Suresh Kumar',
      status: 'Failed',
      scheduledDate: DateTime(2026, 7, 22),
      amountDue: 890,
    ),
    _DeliveryRecord(
      orderNo: 'ORD-2026-004',
      customer: 'Rahul Mehta',
      deliveryPartner: 'Suresh Kumar',
      status: 'Delivered',
      scheduledDate: DateTime(2026, 7, 22),
      amountDue: 0,
    ),
    _DeliveryRecord(
      orderNo: 'ORD-2026-005',
      customer: 'Neha Gupta',
      deliveryPartner: 'Ramesh Yadav',
      status: 'In Progress',
      scheduledDate: DateTime(2026, 7, 24),
      amountDue: 430,
    ),
    _DeliveryRecord(
      orderNo: 'ORD-2026-006',
      customer: 'Arjun Iyer',
      deliveryPartner: 'Suresh Kumar',
      status: 'Delivered',
      scheduledDate: DateTime(2026, 7, 21),
      amountDue: 0,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_DeliveryRecord> get _filteredDeliveries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _deliveries;

    return _deliveries.where((delivery) {
      return delivery.orderNo.toLowerCase().contains(query) ||
          delivery.customer.toLowerCase().contains(query) ||
          delivery.deliveryPartner.toLowerCase().contains(query) ||
          delivery.status.toLowerCase().contains(query) ||
          _formatDate(delivery.scheduledDate).toLowerCase().contains(query) ||
          _formatMoney(delivery.amountDue).toLowerCase().contains(query);
    }).toList();
  }

  int get _totalDeliveries => _deliveries.length;

  int get _deliveredCount =>
      _deliveries.where((delivery) => delivery.status == 'Delivered').length;

  int get _inProgressCount =>
      _deliveries.where((delivery) => delivery.status == 'In Progress').length;

  int get _failedCount =>
      _deliveries.where((delivery) => delivery.status == 'Failed').length;

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
      case 'Delivered':
        return AppColors.green;
      case 'In Progress':
        return AppColors.blue;
      case 'Failed':
        return AppColors.red;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveries = _filteredDeliveries;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Deliveries'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Deliveries',
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
                      'Deliveries',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track order delivery status and outstanding balances',
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
                              label: 'Total Deliveries',
                              value: _totalDeliveries.toString(),
                              icon: Icons.local_shipping_outlined,
                              color: AppColors.purple,
                            ),
                            _statCard(
                              label: 'Delivered',
                              value: _deliveredCount.toString(),
                              icon: Icons.verified_outlined,
                              color: AppColors.green,
                            ),
                            _statCard(
                              label: 'In Progress',
                              value: _inProgressCount.toString(),
                              icon: Icons.timelapse_outlined,
                              color: AppColors.blue,
                            ),
                            _statCard(
                              label: 'Failed',
                              value: _failedCount.toString(),
                              icon: Icons.error_outline_rounded,
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
                            'All Deliveries',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Search by order, customer, delivery partner, status, scheduled date, or amount due.',
                            style: TextStyle(color: textSecondary, fontSize: 12.5),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded),
                              hintText: 'Search deliveries',
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
                          if (deliveries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No deliveries match your search.',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: deliveries
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child:
                                          _buildDeliveryCard(entry.value),
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

  Widget _buildDeliveryCard(_DeliveryRecord delivery) {
    final statusColor = _statusColor(delivery.status);

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
                  Icons.local_shipping_outlined,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.orderNo,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      delivery.scheduledDate.toIso8601String().split('T').first,
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
                  delivery.status,
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
          _infoRow('Customer', delivery.customer),
          const SizedBox(height: 10),
          _infoRow('Delivery Partner', delivery.deliveryPartner),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  'Scheduled Date',
                  _formatDate(delivery.scheduledDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoRow('Amount Due', _formatMoney(delivery.amountDue)),
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

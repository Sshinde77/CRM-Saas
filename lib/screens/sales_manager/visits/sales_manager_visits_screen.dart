import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../customers/sales_manager_customers_screen.dart';
import '../leads/sales_manager_leads_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../orders/sales_manager_orders_screen.dart';

class SalesManagerVisitsScreen extends StatefulWidget {
  const SalesManagerVisitsScreen({super.key});

  @override
  State<SalesManagerVisitsScreen> createState() =>
      _SalesManagerVisitsScreenState();
}

class _SalesManagerVisitsScreenState extends State<SalesManagerVisitsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tabs = const [
    'Today',
    'This Week',
    'This Month',
    'Custom',
  ];

  int _selectedTab = 0;

  final List<_VisitRecord> _visits = const [
    _VisitRecord(
      customer: 'Shree Ganesh Traders',
      location: 'Dadar, Mumbai',
      time: '10:00 AM - 10:45 AM',
      status: 'Completed',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.green,
    ),
    _VisitRecord(
      customer: 'Maa Durga Stores',
      location: 'Matunga, Mumbai',
      time: '12:00 PM - 12:45 PM',
      status: 'In Progress',
      icon: Icons.storefront_rounded,
      color: AppColors.orange,
    ),
    _VisitRecord(
      customer: 'Patel Retailers',
      location: 'Sion, Mumbai',
      time: '03:00 PM - 03:45 PM',
      status: 'Planned',
      icon: Icons.store_mall_directory_rounded,
      color: AppColors.blue,
    ),
    _VisitRecord(
      customer: 'S.K. Enterprises',
      location: 'Ghatkopar, Mumbai',
      time: '05:00 PM - 05:30 PM',
      status: 'Planned',
      icon: Icons.apartment_rounded,
      color: AppColors.purple,
    ),
  ];

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Visits') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerLeadsScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerCustomersScreen()),
      );
      return;
    }
    if (action == 'Create Order' || action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerOrdersScreen()),
      );
      return;
    }
    _showSnack(action);
  }

  void _showSnack(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action is not wired yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Visits',
      ),
      body: SafeArea(
        child: Column(
          children: [
            SalesManagerTopBar(title: 'Visits'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 14),
                    _buildTabs(),
                    const SizedBox(height: 14),
                    for (var i = 0; i < _visits.length; i++) ...[
                      _VisitTile(record: _visits[i]),
                      if (i != _visits.length - 1) const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: TextButton(
                        onPressed: _showAllVisits,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.surfaceSoft,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'View All Visits',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final selected = index == _selectedTab;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(_tabs[index]),
              selected: selected,
              onSelected: (_) => setState(() => _selectedTab = index),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.7),
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 4;

        return Row(
          children: [
            _VisitStatCard(
              width: cardWidth,
              icon: Icons.location_on_rounded,
              iconColor: AppColors.green,
              iconBackground: AppColors.green.withValues(alpha: 0.12),
              value: '7',
              label: 'Total Visits',
              viewAllColor: AppColors.green,
            ),
            const SizedBox(width: 4),
            _VisitStatCard(
              width: cardWidth,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.blue,
              iconBackground: AppColors.blue.withValues(alpha: 0.12),
              value: '3',
              label: 'Completed',
              viewAllColor: AppColors.blue,
            ),
            const SizedBox(width: 4),
            _VisitStatCard(
              width: cardWidth,
              icon: Icons.access_time_rounded,
              iconColor: AppColors.orange,
              iconBackground: AppColors.orange.withValues(alpha: 0.12),
              value: '2',
              label: 'In Progress',
              viewAllColor: AppColors.orange,
            ),
            const SizedBox(width: 4),
            _VisitStatCard(
              width: cardWidth,
              icon: Icons.close_rounded,
              iconColor: AppColors.red,
              iconBackground: AppColors.red.withValues(alpha: 0.12),
              value: '2',
              label: 'Missed',
              viewAllColor: AppColors.red,
            ),
          ],
        );
      },
    );
  }

  void _showAllVisits() {
    _showSnack('View all visits');
  }
}

class _VisitTile extends StatelessWidget {
  final _VisitRecord record;

  const _VisitTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = _visitStatusColor(record.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: record.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(record.icon, color: record.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.customer,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.time,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitRecord {
  final String customer;
  final String location;
  final String time;
  final String status;
  final IconData icon;
  final Color color;

  const _VisitRecord({
    required this.customer,
    required this.location,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class _VisitStatCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String label;
  final Color viewAllColor;

  const _VisitStatCard({
    required this.width,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.label,
    required this.viewAllColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
      decoration: BoxDecoration(
        color: iconBackground.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconBackground.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View all >',
            style: TextStyle(
              color: viewAllColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Color _visitStatusColor(String status) {
  switch (status) {
    case 'Completed':
      return AppColors.green;
    case 'In Progress':
      return AppColors.orange;
    case 'Planned':
      return AppColors.blue;
    default:
      return AppColors.primary;
  }
}

class _RecordVisitPage extends StatefulWidget {
  final List<_VisitCustomer> customers;

  const _RecordVisitPage({required this.customers});

  @override
  State<_RecordVisitPage> createState() => _RecordVisitPageState();
}

class _RecordVisitPageState extends State<_RecordVisitPage> {
  late _VisitCustomer _selectedCustomer;
  String _selectedPurpose = 'Regular Visit';
  String _selectedOutcome =
      'Interested in new offers and\nwill place order next week.';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _checkoutTimeController = TextEditingController(
    text: '20 May 2024, 10:45 AM',
  );

  final List<String> _purposes = const [
    'Regular Visit',
    'Payment Follow-up',
    'Product Demo',
    'New Order Discussion',
  ];

  final List<String> _outcomes = const [
    'Interested in new offers and\nwill place order next week.',
    'Requested follow-up next week.',
    'Order confirmed during visit.',
    'Need to revisit with pricing.',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customers.first;
    _notesController.text = 'Discussed new products and\nmonthly scheme.';
    _feedbackController.text = 'Happy with the product quality\nand service.';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _feedbackController.dispose();
    _checkoutTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Record Visit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.75)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DropdownCard<_VisitCustomer>(
                      value: _selectedCustomer,
                      items: widget.customers
                          .map(
                            (customer) => DropdownMenuItem<_VisitCustomer>(
                              value: customer,
                              child: _CustomerDropdownRow(customer: customer),
                            ),
                          )
                          .toList(),
                      selectedBuilder: _CustomerDropdownRow(
                        customer: _selectedCustomer,
                      ),
                      onChanged: (customer) {
                        if (customer == null) return;
                        setState(() => _selectedCustomer = customer);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Visit Details',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      label: 'Check-in Time',
                      value: '20 May 2024, 10:15 AM',
                      trailing: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DropdownCard<String>(
                      value: _selectedPurpose,
                      items: _purposes
                          .map(
                            (purpose) => DropdownMenuItem<String>(
                              value: purpose,
                              child: Text(
                                purpose,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      selectedBuilder: Text(
                        _selectedPurpose,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedPurpose = value);
                      },
                      label: 'Purpose of Visit',
                      requiredMark: true,
                    ),
                    const SizedBox(height: 10),
                    _TextSectionCard(
                      label: 'Visit Notes',
                      controller: _notesController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _TextSectionCard(
                      label: 'Customer Feedback',
                      controller: _feedbackController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _DropdownCard<String>(
                      value: _selectedOutcome,
                      items: _outcomes
                          .map(
                            (outcome) => DropdownMenuItem<String>(
                              value: outcome,
                              child: Text(
                                outcome,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      selectedBuilder: Text(
                        _selectedOutcome,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedOutcome = value);
                      },
                      label: 'Visit Outcome',
                      requiredMark: true,
                    ),
                    const SizedBox(height: 10),
                    _TextSectionCard(
                      label: 'Check-out Time',
                      controller: _checkoutTimeController,
                      trailing: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Visit',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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
}

class _DropdownCard<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final Widget selectedBuilder;
  final ValueChanged<T?> onChanged;
  final String? label;
  final bool requiredMark;

  const _DropdownCard({
    required this.value,
    required this.items,
    required this.selectedBuilder,
    required this.onChanged,
    this.label,
    this.requiredMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label == null
        ? null
        : requiredMark
        ? '$label *'
        : label;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayLabel != null) ...[
            Text(
              displayLabel,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textLightMuted,
              ),
              borderRadius: BorderRadius.circular(14),
              dropdownColor: Colors.white,
              items: items,
              selectedItemBuilder: (_) =>
                  items.map((_) => selectedBuilder).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerDropdownRow extends StatelessWidget {
  final _VisitCustomer customer;

  const _CustomerDropdownRow({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.adminSidebarBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                customer.location,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoCard({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _TextSectionCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final Widget? trailing;

  const _TextSectionCard({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffixIcon: trailing,
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _VisitCustomer {
  final String name;
  final String location;

  const _VisitCustomer({required this.name, required this.location});
}

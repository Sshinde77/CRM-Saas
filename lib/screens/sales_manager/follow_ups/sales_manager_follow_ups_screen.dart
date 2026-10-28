import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';

import 'package:crm_saas/core/theme/app_text_styles.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/app_calendar_date_picker.dart';
import '../../../widgets/completion_feedback_sheet.dart';
import '../../delivery/customers/delivery_customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../admin/quotations/admin_quotations_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/shared/management_page_summary.dart';
import '../../delivery/attendance/delivery_attendance_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../performance/sales_manager_performance_screen.dart';
import '../stock/sales_manager_stock_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class SalesManagerFollowUpsScreen extends StatefulWidget {
  const SalesManagerFollowUpsScreen({super.key});

  @override
  State<SalesManagerFollowUpsScreen> createState() =>
      _SalesManagerFollowUpsScreenState();
}

class _SalesManagerFollowUpsScreenState
    extends State<SalesManagerFollowUpsScreen> {
  final _pagination = ListPagination();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<_FollowUpItem> _items = [
    _FollowUpItem(
      customerName: 'Shree Ganesh Traders',
      dateLabel: '18 May 2024',
      timeLabel: '10:30 AM',
      note: 'Call regarding pending payment and next order.',
      status: 'Pending',
      color: AppColors.orange,
      priority: 'High',
      phone: '+91 98765 43210',
      contactPerson: 'Rajesh Sharma',
      followUpType: 'Call',
    ),
    _FollowUpItem(
      customerName: 'Maa Durga Stores',
      dateLabel: '19 May 2024',
      timeLabel: '02:15 PM',
      note: 'Discuss scheme pricing and new products.',
      status: 'Done',
      color: AppColors.green,
      priority: 'Medium',
      phone: '+91 98210 77441',
      contactPerson: 'Neha Verma',
      followUpType: 'Meeting',
    ),
    _FollowUpItem(
      customerName: 'Patel Retailers',
      dateLabel: '20 May 2024',
      timeLabel: '04:00 PM',
      note: 'Send quotation and confirm requirement list.',
      status: 'Pending',
      color: AppColors.blue,
      priority: 'Low',
      phone: '+91 98980 22118',
      contactPerson: 'Amit Patel',
      followUpType: 'Email',
    ),
  ];

  @override
  void dispose() {
    _pagination.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_FollowUpItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesFilter =
          _selectedFilter == 'All' ||
          (_selectedFilter == 'Upcoming'
              ? item.status != 'Done'
              : item.status == _selectedFilter);
      final matchesQuery =
          query.isEmpty ||
          item.customerName.toLowerCase().contains(query) ||
          item.contactPerson.toLowerCase().contains(query) ||
          item.note.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<void> _openDetails(_FollowUpItem item) async {
    final updated = await Navigator.of(context).push<_FollowUpItem>(
      MaterialPageRoute(builder: (_) => _FollowUpDetailScreen(item: item)),
    );
    if (updated == null || !mounted) return;
    final index = _items.indexOf(item);
    if (index != -1) setState(() => _items[index] = updated);
  }

  void _showSnack(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action is not wired yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Follow-Ups' || action == 'Follow-ups') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DeliveryCustomersScreen()),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Create Order') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NewAdminOrderScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Quotations' || action == 'Quotation') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const AdminQuotationsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Stock') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
        ),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DeliveryAttendanceScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    _showSnack(action);
  }

  Future<void> _openAddFollowUpDialog() async {
    final result = await Navigator.of(context).push<_FollowUpItem>(
      MaterialPageRoute(builder: (_) => const _CreateFollowUpPage()),
    );
    if (result == null || !mounted) return;
    setState(() => _items.insert(0, result));
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _pagination.local(
      _visibleItems,
      filterKey: _searchController.text + _selectedFilter,
    );
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.deliveryBackground,
        drawer: SalesManagerSidebarDrawer(
          onSelect: _handleSidebarSelection,
          currentPage: 'Follow-Ups',
        ),
        body: SafeArea(
          child: Column(
            children: [
              SalesManagerTopBar(
                title: 'Follow-Ups',
                onNotificationTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => setState(() {}),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 920),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ManagementPageSummary(
                                    title: 'Follow-Ups',
                                    subtitle:
                                        '${_items.length} customer follow-ups',
                                    icon: Icons.assignment_outlined,
                                    onAdd: _openAddFollowUpDialog,
                                    kpis: [
                                      ManagementKpiData(
                                        label: 'Upcoming',
                                        value:
                                            '${_items.where((item) => item.status == 'Pending').length}',
                                        icon: Icons.schedule_rounded,
                                        color: AppColors.deliveryBlue,
                                        background: AppColors.deliveryBlueSoft,
                                      ),
                                      ManagementKpiData(
                                        label: 'Completed',
                                        value:
                                            '${_items.where((item) => item.status == 'Done').length}',
                                        icon: Icons.task_alt_rounded,
                                        color: AppColors.deliveryGreen,
                                        background: AppColors.deliveryGreenSoft,
                                      ),
                                      ManagementKpiData(
                                        label: 'High Priority',
                                        value:
                                            '${_items.where((item) => item.priority == 'High').length}',
                                        icon: Icons.flag_outlined,
                                        color: AppColors.deliveryRed,
                                        background: AppColors.deliveryRedSoft,
                                      ),
                                      ManagementKpiData(
                                        label: 'Total',
                                        value: '${_items.length}',
                                        icon: Icons.list_alt_rounded,
                                        color: AppColors.deliveryOrange,
                                        background:
                                            AppColors.deliveryOrangeSoft,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _FollowUpSearch(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 12),
                                  _FollowUpFilters(
                                    selected: _selectedFilter,
                                    onSelected: (value) =>
                                        setState(() => _selectedFilter = value),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Scheduled follow-ups',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${visibleItems.length} items',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (visibleItems.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _FollowUpEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          sliver: SliverList.separated(
                            itemCount: visibleItems.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = visibleItems[index];
                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 920,
                                  ),
                                  child: _FollowUpCard(
                                    item: item,
                                    onTap: () => _openDetails(item),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: ListPaginationBar(
                          pagination: _pagination,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _FollowUpPageIntro extends StatelessWidget {
  const _FollowUpPageIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan every customer touchpoint',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Stay on top of calls, meetings, and sales commitments.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _FollowUpSummary extends StatelessWidget {
  final List<_FollowUpItem> items;

  const _FollowUpSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final pending = items.where((item) => item.status == 'Pending').length;
    final done = items.where((item) => item.status == 'Done').length;
    final high = items.where((item) => item.priority == 'High').length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _SummaryInfo('Upcoming', '$pending', Icons.schedule_rounded),
          _SummaryInfo('Completed', '$done', Icons.task_alt_rounded),
          _SummaryInfo('High priority', '$high', Icons.flag_outlined),
        ];
        return Row(
          children: List.generate(cards.length, (index) {
            final item = cards[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == cards.length - 1 ? 0 : 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.deliveryCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: AppColors.primary, size: 20),
                      const SizedBox(height: 8),
                      Text(
                        item.value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SummaryInfo {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryInfo(this.label, this.value, this.icon);
}

class _FollowUpSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _FollowUpSearch({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: AppColors.primary,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search customer, contact, or note',
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deliveryCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deliveryCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _FollowUpFilters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FollowUpFilters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Upcoming', 'Done'].map((label) {
          final active = selected == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: active,
              onSelected: (_) => onSelected(label),
              showCheckmark: false,
              selectedColor: AppColors.activeMenuBg,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: active
                    ? AppColors.primary
                    : AppColors.deliveryCardBorder,
              ),
              labelStyle: TextStyle(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FollowUpEmptyState extends StatelessWidget {
  const _FollowUpEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.activeMenuBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No follow-ups found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try another filter or create a new follow-up.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpTypeIcon extends StatelessWidget {
  final String type;

  const _FollowUpTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'Meeting' => Icons.groups_2_outlined,
      'Email' => Icons.mail_outline_rounded,
      _ => Icons.call_outlined,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.activeMenuBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final _FollowUpItem item;
  final VoidCallback onTap;

  const _FollowUpCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.deliveryCardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FollowUpTypeIcon(type: item.followUpType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(label: item.status, color: item.color),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.contactPerson} • ${item.followUpType}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                icon: Icons.calendar_today_outlined,
                                label: item.dateLabel,
                              ),
                              _MetaChip(
                                icon: Icons.schedule_rounded,
                                label: item.timeLabel,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FollowUpDetailScreen extends StatefulWidget {
  final _FollowUpItem item;

  const _FollowUpDetailScreen({required this.item});

  @override
  State<_FollowUpDetailScreen> createState() => _FollowUpDetailScreenState();
}

class _FollowUpDetailScreenState extends State<_FollowUpDetailScreen> {
  late _FollowUpItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _markCompleted() async {
    final feedback = await showCompletionFeedbackSheet(
      context: context,
      title: 'Complete follow-up',
      subjectLabel: _item.customerName,
    );
    if (!mounted || feedback == null) return;
    setState(() {
      _item = _item.copyWith(
        status: 'Done',
        color: AppColors.primary,
        note: '${_item.note}\n\nCompletion feedback: $feedback',
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Follow-up marked as completed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _close() => Navigator.of(context).pop(_item);

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _close();
        },
        child: Scaffold(
          backgroundColor: AppColors.deliveryBackground,
          bottomNavigationBar: _DetailActionBar(
            completed: _item.status == 'Done',
            onComplete: _markCompleted,
          ),
          body: SafeArea(
            child: Column(
              children: [
                SalesManagerTopBar(
                  title: 'Follow-Up Details',
                  leadingIcon: Icons.arrow_back_rounded,
                  onLeadingTap: _close,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailHero(item: _item),
                            const SizedBox(height: 16),
                            _DetailSection(
                              title: 'Schedule',
                              child: Column(
                                children: [
                                  _DetailRow(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'Date',
                                    value: _item.dateLabel,
                                  ),
                                  const Divider(
                                    height: 20,
                                    color: AppColors.deliveryCardBorder,
                                  ),
                                  _DetailRow(
                                    icon: Icons.schedule_rounded,
                                    label: 'Time',
                                    value: _item.timeLabel,
                                  ),
                                  const Divider(
                                    height: 20,
                                    color: AppColors.deliveryCardBorder,
                                  ),
                                  _DetailRow(
                                    icon: Icons.flag_outlined,
                                    label: 'Priority',
                                    value: _item.priority,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _DetailSection(
                              title: 'Customer',
                              child: Column(
                                children: [
                                  _DetailRow(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Contact person',
                                    value: _item.contactPerson,
                                  ),
                                  const Divider(
                                    height: 20,
                                    color: AppColors.deliveryCardBorder,
                                  ),
                                  _DetailRow(
                                    icon: Icons.phone_outlined,
                                    label: 'Phone number',
                                    value: _item.phone,
                                  ),
                                  const Divider(
                                    height: 20,
                                    color: AppColors.deliveryCardBorder,
                                  ),
                                  _DetailRow(
                                    icon: Icons.forum_outlined,
                                    label: 'Follow-up type',
                                    value: _item.followUpType,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _DetailSection(
                              title: 'Follow-up note',
                              child: Text(
                                _item.note,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _DetailSection(
                              title: 'Activity',
                              child: _ActivityTimeline(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  final _FollowUpItem item;

  const _DetailHero({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.followUpType} with ${item.contactPerson}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(label: item.status, color: Colors.white),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.activeMenuBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TimelineEntry(
          title: 'Follow-up scheduled',
          subtitle: 'Created by Sales Manager',
          active: true,
        ),
        SizedBox(height: 14),
        _TimelineEntry(
          title: 'Customer response',
          subtitle: 'Waiting for the next interaction',
          active: false,
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;

  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.borderStrong,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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

class _DetailActionBar extends StatelessWidget {
  final bool completed;
  final VoidCallback onComplete;

  const _DetailActionBar({required this.completed, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.deliveryCardBorder)),
        ),
        child: SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: completed ? null : onComplete,
            icon: Icon(
              completed ? Icons.task_alt_rounded : Icons.check_rounded,
              size: 20,
            ),
            label: Text(
              completed ? 'Follow-up completed' : 'Mark as completed',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.activeMenuBg,
              disabledForegroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateFollowUpPage extends StatefulWidget {
  const _CreateFollowUpPage();

  @override
  State<_CreateFollowUpPage> createState() => _CreateFollowUpPageState();
}

class _CreateFollowUpPageState extends State<_CreateFollowUpPage> {
  final _titleController = TextEditingController(text: 'General Follow-up');
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 11, minute: 0);
  String _priority = 'medium';
  List<_LeadOption> _leads = const [];
  _LeadOption? _selectedLead;
  bool _loadingLookups = true;
  String? _lookupError;
  bool _didSetInitialTime = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLookups());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSetInitialTime) return;
    _timeController.text = _selectedTime.format(context);
    _didSetInitialTime = true;
  }

  Future<void> _loadLookups() async {
    if (!mounted) return;
    setState(() {
      _loadingLookups = true;
      _lookupError = null;
    });
    final provider = ApiProviderScope.of(context);

    List<_LeadOption> leads = const [];
    String? leadsError;

    try {
      final raw = await provider.fetchLeads();
      leads = raw
          .map(_LeadOption.fromJson)
          .where((l) => l.id.isNotEmpty && l.name.isNotEmpty)
          .toList();
    } catch (_) {
      leadsError = 'Unable to load leads. Tap to retry.';
    }

    if (!mounted) return;
    setState(() {
      _leads = leads;
      _loadingLookups = false;
      _lookupError = leadsError;
    });
  }

  Future<void> _pickLead() async {
    if (_loadingLookups) return;
    if (_lookupError != null) {
      await _loadLookups();
      if (!mounted || _lookupError != null) return;
    }
    final lead = await showDialog<_LeadOption>(
      context: context,
      builder: (_) =>
          _LeadSearchDialog(leads: _leads, selectedLeadId: _selectedLead?.id),
    );
    if (!mounted || lead == null) return;
    setState(() => _selectedLead = lead);
  }

  Future<void> _pickDate() async {
    final picked = await showAppCalendarDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      title: 'Follow-up Date',
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked == null) return;
    setState(() {
      _selectedTime = picked;
      _timeController.text = picked.format(context);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final dateLabel = _dateController.text.trim();
    final timeLabel = _timeController.text.trim();
    final note = _noteController.text.trim();

    if (_selectedLead == null ||
        title.isEmpty ||
        dateLabel.isEmpty ||
        timeLabel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a lead, and fill title, date and time.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentUser = ApiProviderScope.of(context).currentUser;
    Navigator.of(context).pop(
      _FollowUpItem(
        title: title,
        customerName: _selectedLead!.name,
        dateLabel: dateLabel,
        timeLabel: timeLabel,
        note: note.isEmpty ? 'No notes added.' : note,
        status: 'Pending',
        color: AppColors.orange,
        priority: _priority[0].toUpperCase() + _priority.substring(1),
        phone: 'Not provided',
        contactPerson: currentUser?.name ?? 'Me',
        followUpType: 'Call',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      body: SafeArea(
        child: Column(
          children: [
            SalesManagerTopBar(
              title: 'New Follow-Up',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Lead *'),
                        const SizedBox(height: 8),
                        _LeadPickerCard(
                          selected: _selectedLead,
                          loading: _loadingLookups,
                          error: _lookupError,
                          onTap: _pickLead,
                          onClear: _selectedLead == null
                              ? null
                              : () => setState(() => _selectedLead = null),
                        ),
                        const SizedBox(height: 18),
                        _FieldLabel('Title *'),
                        const SizedBox(height: 8),
                        _InputBox(
                          controller: _titleController,
                          hintText: 'Follow-up title',
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Date *'),
                                  const SizedBox(height: 8),
                                  _TapInputBox(
                                    controller: _dateController,
                                    hintText: 'Select date',
                                    onTap: _pickDate,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Time *'),
                                  const SizedBox(height: 8),
                                  _TapInputBox(
                                    controller: _timeController,
                                    hintText: 'Select time',
                                    onTap: _pickTime,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _FieldLabel('Priority'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                            DropdownMenuItem(
                              value: 'medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'high',
                              child: Text('High'),
                            ),
                            DropdownMenuItem(
                              value: 'urgent',
                              child: Text('Urgent'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _priority = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        _FieldLabel('Description / Requirements'),
                        const SizedBox(height: 8),
                        _InputBox(
                          controller: _noteController,
                          hintText: 'Optional details...',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.deliveryCardBorder),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 20),
                  label: const Text(
                    'Schedule Follow-up',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadPickerCard extends StatelessWidget {
  final _LeadOption? selected;
  final bool loading;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _LeadPickerCard({
    required this.selected,
    required this.loading,
    required this.error,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasSelection ? AppColors.activeMenuBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasSelection ? AppColors.primary : AppColors.border,
            width: hasSelection ? 1.4 : 1.0,
          ),
        ),
        child: hasSelection
            ? Row(
                children: [
                  _PersonAvatar(name: selected!.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected!.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (selected!.code.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            selected!.code,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onClear != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.activeMenuBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      loading
                          ? Icons.hourglass_empty_rounded
                          : (error != null
                                ? Icons.refresh_rounded
                                : Icons.search_rounded),
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loading
                          ? 'Loading leads...'
                          : (error ?? 'Tap to search and select a lead'),
                      style: TextStyle(
                        color: error != null
                            ? AppColors.red
                            : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  final String name;

  const _PersonAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join('');
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LeadSearchDialog extends StatefulWidget {
  final List<_LeadOption> leads;
  final String? selectedLeadId;

  const _LeadSearchDialog({required this.leads, this.selectedLeadId});

  @override
  State<_LeadSearchDialog> createState() => _LeadSearchDialogState();
}

class _LeadSearchDialogState extends State<_LeadSearchDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final leads = widget.leads
        .where(
          (lead) =>
              query.isEmpty ||
              lead.name.toLowerCase().contains(query) ||
              lead.code.toLowerCase().contains(query),
        )
        .toList();

    return AlertDialog(
      title: const Text('Select Lead'),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search leads',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: leads.isEmpty
                  ? const Center(child: Text('No matching leads'))
                  : ListView.separated(
                      itemCount: leads.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(lead.name),
                          subtitle: lead.code.isEmpty ? null : Text(lead.code),
                          trailing: lead.id == widget.selectedLeadId
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(lead),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadOption {
  final String id;
  final String name;
  final String code;

  const _LeadOption({required this.id, required this.name, required this.code});

  factory _LeadOption.fromJson(Map<String, dynamic> json) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return '';
    }

    return _LeadOption(
      id: read(['id', 'lead_id']),
      name: read(['company_name', 'companyName', 'name', 'contact_person']),
      code: read(['lead_code', 'leadCode', 'code', 'lead_id']),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.fieldLabel);
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _InputBox({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: AppColors.primary,
      style: AppTextStyles.fieldValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _TapInputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;

  const _TapInputBox({
    required this.controller,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: IgnorePointer(
        child: _InputBox(controller: controller, hintText: hintText),
      ),
    );
  }
}

class _FollowUpItem {
  final String title;
  final String customerName;
  final String dateLabel;
  final String timeLabel;
  final String note;
  final String status;
  final Color color;
  final String priority;
  final String phone;
  final String contactPerson;
  final String followUpType;

  _FollowUpItem({
    this.title = 'General Follow-up',
    required this.customerName,
    required this.dateLabel,
    required this.timeLabel,
    required this.note,
    required this.status,
    required this.color,
    required this.priority,
    required this.phone,
    required this.contactPerson,
    required this.followUpType,
  });

  _FollowUpItem copyWith({String? status, Color? color, String? note}) {
    return _FollowUpItem(
      title: title,
      customerName: customerName,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      note: note ?? this.note,
      status: status ?? this.status,
      color: color ?? this.color,
      priority: priority,
      phone: phone,
      contactPerson: contactPerson,
      followUpType: followUpType,
    );
  }
}

String _formatDate(DateTime date) {
  final months = [
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

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/soft_action_button.dart';

class SalesManagerDashboardScreen extends StatefulWidget {
  const SalesManagerDashboardScreen({super.key});

  @override
  State<SalesManagerDashboardScreen> createState() =>
      _SalesManagerDashboardScreenState();
}

class _SalesManagerDashboardScreenState
    extends State<SalesManagerDashboardScreen> {
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  SalesRange _selectedRange = SalesRange.today;

  final List<_SalesSummary> _summaries = const [
    _SalesSummary(
      label: "Today's Sales",
      value: 'Rs. 84,600',
      delta: '+12.8%',
      icon: Icons.currency_rupee,
      color: AppColors.green,
    ),
    _SalesSummary(
      label: 'Monthly Sales',
      value: 'Rs. 12.6L',
      delta: '+18.4%',
      icon: Icons.calendar_month_rounded,
      color: AppColors.secondary,
    ),
    _SalesSummary(
      label: 'Target Achievement',
      value: '78%',
      delta: 'Target: 16L',
      icon: Icons.flag_rounded,
      color: AppColors.blue,
    ),
    _SalesSummary(
      label: 'Assigned Customers',
      value: '146',
      delta: '24 active today',
      icon: Icons.groups_rounded,
      color: AppColors.orange,
    ),
    _SalesSummary(
      label: 'Planned Visits',
      value: '18',
      delta: '11 completed',
      icon: Icons.route_rounded,
      color: AppColors.teal,
    ),
    _SalesSummary(
      label: 'Pending Follow-ups',
      value: '9',
      delta: '3 overdue',
      icon: Icons.alarm_rounded,
      color: AppColors.red,
    ),
    _SalesSummary(
      label: 'Orders Created',
      value: '32',
      delta: '5 awaiting approval',
      icon: Icons.receipt_long_rounded,
      color: AppColors.purple,
    ),
    _SalesSummary(
      label: 'New Customers',
      value: '7',
      delta: 'Added today',
      icon: Icons.person_add_alt_rounded,
      color: AppColors.amber,
    ),
    _SalesSummary(
      label: 'Outstanding Follow-ups',
      value: 'Rs. 1.42L',
      delta: '12 accounts',
      icon: Icons.call_received_rounded,
      color: AppColors.red,
    ),
    _SalesSummary(
      label: 'Cash Collected',
      value: 'Rs. 57,200',
      delta: '61% collected',
      icon: Icons.payments_rounded,
      color: AppColors.green,
    ),
    _SalesSummary(
      label: 'Attendance Status',
      value: 'Checked-in',
      delta: '09:12 AM',
      icon: Icons.fingerprint_rounded,
      color: AppColors.secondary,
    ),
    _SalesSummary(
      label: 'Team Performance',
      value: '92%',
      delta: '3 reps above target',
      icon: Icons.leaderboard_rounded,
      color: AppColors.blue,
    ),
  ];

  final List<double> _salesTrend = const [
    42,
    51,
    47,
    63,
    58,
    72,
    84,
  ];

  final List<_PipelineSlice> _orderPipeline = const [
    _PipelineSlice('Draft', 8, AppColors.secondary),
    _PipelineSlice('Confirmed', 11, AppColors.blue),
    _PipelineSlice('Processing', 6, AppColors.orange),
    _PipelineSlice('Out for Delivery', 4, AppColors.green),
    _PipelineSlice('Overdue', 3, AppColors.red),
  ];

  final List<_TeamMember> _team = const [
    _TeamMember('Ravi Kumar', 'Rs. 3.2L', 96, AppColors.secondary),
    _TeamMember('Ananya Singh', 'Rs. 2.8L', 88, AppColors.blue),
    _TeamMember('Mohit Sharma', 'Rs. 2.1L', 81, AppColors.teal),
    _TeamMember('Pooja Verma', 'Rs. 1.7L', 74, AppColors.orange),
  ];

  final List<_FollowUpTask> _followUps = const [
    _FollowUpTask(
      customer: 'Silver Oak Apartments',
      note: 'Payment commitment due today',
      time: '11:30 AM',
      status: 'High priority',
      color: AppColors.red,
    ),
    _FollowUpTask(
      customer: 'Cloud Nine Cafe',
      note: 'Repeat order and upsell meeting',
      time: '01:15 PM',
      status: 'Visit planned',
      color: AppColors.secondary,
    ),
    _FollowUpTask(
      customer: 'Prime Legal Associates',
      note: 'Pending quotation approval',
      time: '04:00 PM',
      status: 'Waiting',
      color: AppColors.amber,
    ),
  ];

  final List<_VisitPlan> _visitPlan = const [
    _VisitPlan('Morning route', '6 scheduled', '4 completed', AppColors.green),
    _VisitPlan('Midday route', '7 scheduled', '3 completed', AppColors.blue),
    _VisitPlan('Evening route', '5 scheduled', '4 pending', AppColors.orange),
  ];

  final List<_CustomerOpportunity> _opportunities = const [
    _CustomerOpportunity(
      customer: 'Rajdhani Sweets & Snacks',
      value: 'Rs. 28,400',
      reason: 'Reorder due tomorrow',
      status: 'Hot lead',
      color: AppColors.secondary,
    ),
    _CustomerOpportunity(
      customer: 'TechNova Solutions Pvt Ltd',
      value: 'Rs. 19,850',
      reason: 'Outstanding follow-up',
      status: 'Payment due',
      color: AppColors.red,
    ),
    _CustomerOpportunity(
      customer: 'Nexus Mart',
      value: 'Rs. 15,700',
      reason: 'New onboarding requested',
      status: 'New customer',
      color: AppColors.blue,
    ),
  ];

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {});
  }

  void _changeRange(SalesRange range) {
    setState(() => _selectedRange = range);
  }

  void _showActionSnack(String action) {
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
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Sales Manager',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _showActionSnack('Navigation drawer'),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 14),
                      _buildQuickActions(),
                      const SizedBox(height: 18),
                      _buildRangeChips(),
                      const SizedBox(height: 14),
                      _buildSummaryGrid(),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 900;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildPerformanceCard()),
                                const SizedBox(width: 14),
                                Expanded(flex: 2, child: _buildPipelineCard()),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildPerformanceCard(),
                              const SizedBox(height: 14),
                              _buildPipelineCard(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 900;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildTeamCard()),
                                const SizedBox(width: 14),
                                Expanded(child: _buildFollowUpCard()),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildTeamCard(),
                              const SizedBox(height: 14),
                              _buildFollowUpCard(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildVisitAndOpportunityCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.96),
            AppColors.blue.withValues(alpha: 0.88),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Manager Overview',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track targets, team performance, customer coverage, and collections in one place.',
                      style: TextStyle(
                        color: Color(0xFFEDE7FF),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroPill(
                Icons.calendar_today_rounded,
                _selectedRange.label,
              ),
              _heroPill(Icons.group_rounded, '4 reps active'),
              _heroPill(Icons.route_rounded, '18 visits planned'),
              _heroPill(Icons.payments_rounded, 'Rs. 57,200 collected'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SoftActionButton(
          label: 'Assign Customer',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: () => _showActionSnack('Assign Customer'),
        ),
        SoftActionButton(
          label: 'New Order',
          icon: Icons.add_shopping_cart_rounded,
          onPressed: () => _showActionSnack('New Order'),
        ),
        SoftActionButton(
          label: 'Plan Visits',
          icon: Icons.route_rounded,
          onPressed: () => _showActionSnack('Plan Visits'),
        ),
      ],
    );
  }

  Widget _buildRangeChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: SalesRange.values.map((range) {
        final selected = range == _selectedRange;
        return ChoiceChip(
          label: Text(range.label),
          selected: selected,
          onSelected: (_) => _changeRange(range),
          selectedColor: AppColors.secondary.withValues(alpha: 0.16),
          backgroundColor: AppColors.surfaceSoft,
          labelStyle: TextStyle(
            color: selected ? AppColors.secondary : textPrimary,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: selected
                  ? AppColors.secondary
                  : AppColors.secondary.withValues(alpha: 0.18),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 700
                ? 3
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _summaries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.38,
          ),
          itemBuilder: (context, index) {
            return _summaryCard(_summaries[index]);
          },
        );
      },
    );
  }

  Widget _summaryCard(_SalesSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  summary.label,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: summary.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(summary.icon, color: summary.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary.value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.delta,
            style: TextStyle(
              color: summary.color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return _SectionCard(
      title: 'Sales Performance',
      subtitle: 'Trend and target progress for the selected range',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  'Target',
                  'Rs. 16.0L',
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  'Achieved',
                  'Rs. 12.6L',
                  AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineSparklinePainter(
                  values: _salesTrend,
                  lineColor: AppColors.secondary,
                  fillColor: AppColors.secondary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Completion',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            '78%',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: 0.78,
                                minHeight: 10,
                                backgroundColor:
                                    AppColors.secondary.withValues(alpha: 0.14),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Coverage',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '86%',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard() {
    return _SectionCard(
      title: 'Order Pipeline',
      subtitle: 'Status distribution for sales orders',
      child: Column(
        children: [
          for (final slice in _orderPipeline) ...[
            _barRow(slice.label, slice.count, slice.color),
            if (slice != _orderPipeline.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _barRow(String label, int count, Color color) {
    final maxCount = _orderPipeline
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);
    final width = (count / maxCount).clamp(0.1, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: width,
            minHeight: 10,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard() {
    return _SectionCard(
      title: 'Team Performance',
      subtitle: 'Sales officers and achievement against target',
      child: Column(
        children: [
          for (final member in _team) ...[
            _teamRow(member),
            if (member != _team.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _teamRow(_TeamMember member) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: member.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: member.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.sales,
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
                  color: member.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${member.targetPercent}%',
                  style: TextStyle(
                    color: member.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: member.targetPercent / 100,
              minHeight: 9,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(member.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard() {
    return _SectionCard(
      title: 'Follow-ups',
      subtitle: 'Pending customer commitments and visit reminders',
      child: Column(
        children: [
          for (final followUp in _followUps) ...[
            _followUpTile(followUp),
            if (followUp != _followUps.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _followUpTile(_FollowUpTask followUp) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  followUp.customer,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: followUp.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  followUp.status,
                  style: TextStyle(
                    color: followUp.color,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            followUp.note,
            style: const TextStyle(color: textSecondary, fontSize: 12.2),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: followUp.color,
              ),
              const SizedBox(width: 6),
              Text(
                followUp.time,
                style: TextStyle(
                  color: followUp.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitAndOpportunityCard() {
    return _SectionCard(
      title: 'Visits and Opportunities',
      subtitle: 'Route progress and high-value customer actions',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 800;
          final content = [
            Expanded(child: _buildVisitPlanCard()),
            const SizedBox(width: 14),
            Expanded(child: _buildOpportunityCard()),
          ];

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            );
          }

          return Column(
            children: [
              _buildVisitPlanCard(),
              const SizedBox(height: 14),
              _buildOpportunityCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisitPlanCard() {
    return Column(
      children: [
        for (final plan in _visitPlan) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: plan.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: plan.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.total} planned - ${plan.completed} completed',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  plan.completed,
                  style: TextStyle(
                    color: plan.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOpportunityCard() {
    return Column(
      children: [
        for (final opportunity in _opportunities) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: opportunity.color.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        opportunity.customer,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      opportunity.value,
                      style: TextStyle(
                        color: opportunity.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  opportunity.reason,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12.2,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: opportunity.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      opportunity.status,
                      style: TextStyle(
                        color: opportunity.color,
                        fontSize: 11.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.3,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LineSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _LineSparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal).abs() < 0.0001 ? 1.0 : maxVal - minVal;
    final horizontalStep = values.length == 1
        ? size.width
        : size.width / (values.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = i * horizontalStep;
      final normalized = (values[i] - minVal) / range;
      final y = size.height - (normalized * (size.height - 24)) - 12;
      points.add(Offset(x, y));
    }

    final areaPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }

    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(linePath, paint);
  }

  @override
  bool shouldRepaint(covariant _LineSparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

enum SalesRange { today, thisWeek, thisMonth }

extension on SalesRange {
  String get label {
    switch (this) {
      case SalesRange.today:
        return 'Today';
      case SalesRange.thisWeek:
        return 'This Week';
      case SalesRange.thisMonth:
        return 'This Month';
    }
  }
}

class _SalesSummary {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;

  const _SalesSummary({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.color,
  });
}

class _PipelineSlice {
  final String label;
  final int count;
  final Color color;

  const _PipelineSlice(this.label, this.count, this.color);
}

class _TeamMember {
  final String name;
  final String sales;
  final int targetPercent;
  final Color color;

  const _TeamMember(this.name, this.sales, this.targetPercent, this.color);
}

class _FollowUpTask {
  final String customer;
  final String note;
  final String time;
  final String status;
  final Color color;

  const _FollowUpTask({
    required this.customer,
    required this.note,
    required this.time,
    required this.status,
    required this.color,
  });
}

class _VisitPlan {
  final String title;
  final String total;
  final String completed;
  final Color color;

  const _VisitPlan(this.title, this.total, this.completed, this.color);
}

class _CustomerOpportunity {
  final String customer;
  final String value;
  final String reason;
  final String status;
  final Color color;

  const _CustomerOpportunity({
    required this.customer,
    required this.value,
    required this.reason,
    required this.status,
    required this.color,
  });
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  static const Color _bgColor = AppColors.surfaceSoft;
  static const Color _panelColor = AppColors.surface;
  static const Color _primaryAccent = AppColors.primary;
  static const Color _primaryAccentDark = AppColors.primary;
  static const Color _primaryAccentSoft = AppColors.surfaceSoft;
  static const Color _mutedText = AppColors.textSecondary;
  static const Color _darkText = AppColors.textPrimary;
  static const Color _ringDark = AppColors.textPrimary;
  static const Color _ringGrey = AppColors.accentGrey;
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _shadowColor = Color(0xFF0F172A);

  static const List<_SuperAdminMetric> _metrics = [
    _SuperAdminMetric(
      label: 'Total Organizations',
      value: '4',
      icon: Icons.apartment_rounded,
      iconColor: _primaryAccentDark,
      chipColor: _primaryAccentSoft,
    ),
    _SuperAdminMetric(
      label: 'Active',
      value: '3',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.primary,
      chipColor: AppColors.surfaceSoft,
    ),
    _SuperAdminMetric(
      label: 'Trial',
      value: '1',
      icon: Icons.schedule_rounded,
      iconColor: AppColors.secondary,
      chipColor: Color(0xFFF4F4F4),
    ),
    _SuperAdminMetric(
      label: 'Suspended',
      value: '0',
      icon: Icons.block_rounded,
      iconColor: AppColors.secondary,
      chipColor: Color(0xFFF4F4F4),
    ),
    _SuperAdminMetric(
      label: 'MRR Estimate',
      value: 'Rs. 48,000',
      icon: Icons.currency_rupee_rounded,
      iconColor: AppColors.primary,
      chipColor: AppColors.surfaceSoft,
    ),
  ];

  static const List<_GrowthPoint> _growthPoints = [
    _GrowthPoint(label: 'Feb', value: 1),
    _GrowthPoint(label: 'Apr', value: 1),
    _GrowthPoint(label: 'Jun', value: 2),
    _GrowthPoint(label: 'Aug', value: 2),
    _GrowthPoint(label: 'Oct', value: 3),
    _GrowthPoint(label: 'Dec', value: 3),
    _GrowthPoint(label: 'Feb', value: 4),
  ];

  static const List<_PlanSlice> _planSlices = [
    _PlanSlice(
      label: 'Enterprise',
      value: 1,
      color: _primaryAccent,
      shareLabel: '25%',
    ),
    _PlanSlice(
      label: 'Pro',
      value: 2,
      color: _ringDark,
      shareLabel: '50%',
    ),
    _PlanSlice(
      label: 'Free',
      value: 1,
      color: _ringGrey,
      shareLabel: '25%',
    ),
  ];

  static const List<_OrganizationEntry> _organizations = [
    _OrganizationEntry(
      name: 'BlueWave Distributors',
      plan: 'Pro',
      status: 'Active',
      revenue: 'Rs. 18,000',
    ),
    _OrganizationEntry(
      name: 'AquaFresh Supply Co.',
      plan: 'Enterprise',
      status: 'Active',
      revenue: 'Rs. 20,000',
    ),
    _OrganizationEntry(
      name: 'Prime Water Services',
      plan: 'Free',
      status: 'Trial',
      revenue: 'Rs. 0',
    ),
    _OrganizationEntry(
      name: 'Hillside Beverages',
      plan: 'Pro',
      status: 'Active',
      revenue: 'Rs. 10,000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 18),
                    _buildSearchBar(),
                    const SizedBox(height: 18),
                    _buildHeroBanner(),
                    const SizedBox(height: 18),
                    _buildMetricGrid(),
                    const SizedBox(height: 18),
                    _buildGrowthCard(),
                    const SizedBox(height: 18),
                    _buildPlanCard(),
                    const SizedBox(height: 18),
                    _buildOrganizationsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryAccentDark, _primaryAccent],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primaryAccent.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Super Admin',
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: _darkText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _buildIconButton(Icons.help_outline_rounded),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildIconButton(Icons.notifications_none_rounded),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _primaryAccentDark,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _panelColor, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Icon(icon, color: _darkText, size: 22),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: _mutedText),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search organizations, plans, or invoices',
              style: TextStyle(
                color: _mutedText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryAccentDark, _primaryAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryAccent.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Platform snapshot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Keep growth, billing, and organization health in one mobile view.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '4 organizations onboarded, 3 paying subscriptions, and one trial set to convert this week.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid() {
    return Column(
      children: [
        for (var index = 0; index < _metrics.length; index += 2)
          Padding(
            padding: EdgeInsets.only(bottom: index + 2 < _metrics.length ? 12 : 0),
            child: Row(
              children: [
                Expanded(child: _buildMetricCard(_metrics[index])),
                if (index + 1 < _metrics.length) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard(_metrics[index + 1])),
                ] else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricCard(_SuperAdminMetric metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: metric.chipColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(metric.icon, color: metric.iconColor, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            metric.value,
            style: const TextStyle(
              color: _darkText,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard() {
    return _DashboardCard(
      title: 'Organization Growth',
      subtitle: 'Cumulative organizations on the platform',
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _GrowthChartPainter(
                points: _growthPoints,
                lineColor: _primaryAccent,
                fillColor: _primaryAccentSoft.withValues(alpha: 0.55),
                axisColor: _borderColor,
                textColor: _mutedText,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _growthPoints
                .map(
                  (point) => Text(
                    point.label,
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    final total = _planSlices.fold<int>(0, (sum, slice) => sum + slice.value);
    return _DashboardCard(
      title: 'Organizations by Plan',
      subtitle: 'Plan mix across all active accounts',
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(220),
                  painter: _DonutChartPainter(
                    slices: _planSlices,
                    strokeWidth: 28,
                    gapRadians: 0.045,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: _planSlices
                .map(
                  (slice) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: slice.color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slice.label} ${slice.shareLabel}',
                        style: const TextStyle(
                          color: _darkText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationsCard() {
    return _DashboardCard(
      title: 'Organizations',
      subtitle: 'Recent tenant overview',
      child: Column(
        children: _organizations
            .map(
              (org) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _primaryAccentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          org.name.substring(0, 1),
                          style: const TextStyle(
                            color: _primaryAccentDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              org.name,
                              style: const TextStyle(
                                color: _darkText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${org.plan} Plan',
                              style: const TextStyle(
                                color: _mutedText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(org.status).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              org.status,
                              style: TextStyle(
                                color: _statusColor(org.status),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            org.revenue,
                            style: const TextStyle(
                              color: _darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: _panelColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _BottomNavItem(icon: Icons.dashboard_customize_rounded, label: 'Home', active: true),
          _BottomNavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
          _BottomNavItem(icon: Icons.apartment_rounded, label: 'Orgs'),
          _BottomNavItem(icon: Icons.workspace_premium_outlined, label: 'Plans'),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.primary;
      case 'trial':
        return AppColors.secondary;
      case 'suspended':
        return AppColors.secondary;
      default:
        return AppColors.accentGrey;
    }
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _DashboardCard({
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
        color: SuperAdminDashboardScreen._panelColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SuperAdminDashboardScreen._borderColor),
        boxShadow: [
          BoxShadow(
            color: SuperAdminDashboardScreen._shadowColor.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SuperAdminDashboardScreen._darkText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: SuperAdminDashboardScreen._mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? SuperAdminDashboardScreen._primaryAccentDark
        : SuperAdminDashboardScreen._mutedText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<_GrowthPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color axisColor;
  final Color textColor;

  const _GrowthChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.axisColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 30.0;
    const topPadding = 8.0;
    const bottomPadding = 18.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    const maxValue = 4.0;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    for (var value = 0; value <= maxValue; value++) {
      final y = topPadding + chartHeight - (value / maxValue * chartHeight);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), axisPaint);

      final painter = TextPainter(
        text: TextSpan(
          text: value.toInt().toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(0, y - painter.height / 2));
    }

    if (points.isEmpty) return;

    final stepX = points.length == 1 ? 0.0 : chartWidth / (points.length - 1);
    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = leftPadding + (stepX * i);
      final y = topPadding + chartHeight - (points[i].value / maxValue * chartHeight);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(leftPadding + (stepX * (points.length - 1)), topPadding + chartHeight)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final lastPoint = points.last;
    final lastX = leftPadding + (stepX * (points.length - 1));
    final lastY =
        topPadding + chartHeight - (lastPoint.value / maxValue * chartHeight);

    canvas.drawCircle(
      Offset(lastX, lastY),
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      4,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.textColor != textColor;
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_PlanSlice> slices;
  final double strokeWidth;
  final double gapRadians;

  const _DonutChartPainter({
    required this.slices,
    required this.strokeWidth,
    required this.gapRadians,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * (math.pi * 2);
      final adjustedSweep = math.max(0.0, sweep - gapRadians);

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, adjustedSweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gapRadians != gapRadians;
  }
}

class _SuperAdminMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color chipColor;

  const _SuperAdminMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.chipColor,
  });
}

class _GrowthPoint {
  final String label;
  final double value;

  const _GrowthPoint({required this.label, required this.value});
}

class _PlanSlice {
  final String label;
  final int value;
  final Color color;
  final String shareLabel;

  const _PlanSlice({
    required this.label,
    required this.value,
    required this.color,
    required this.shareLabel,
  });
}

class _OrganizationEntry {
  final String name;
  final String plan;
  final String status;
  final String revenue;

  const _OrganizationEntry({
    required this.name,
    required this.plan,
    required this.status,
    required this.revenue,
  });
}

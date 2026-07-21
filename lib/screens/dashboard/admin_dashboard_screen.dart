import 'dart:ui';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../profile/admin_profile_screen.dart';
import '../settings/admin_settings_screen.dart';
import '../../widgets/app_drawer.dart';

/// Admin Dashboard — glassmorphism redesign on a white background.
/// Section order (as requested): Overview stats -> Sales Trend -> Top Products -> Recent Orders.
/// Same accent colour theme as the reference screens (teal / green / purple / blue / amber / orange / red),
/// re-styled with frosted glass cards over a white backdrop with soft pastel colour glows.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _query = '';

  // Side drawer nav is now handled by the shared AppDrawer widget
  // (see lib/widgets/app_drawer.dart).

  // ---- Theme colours (kept from the original app's palette) ----
  static const Color bg = AppColors.primary;
  static const Color teal = AppColors.teal;
  static const Color green = AppColors.green;
  static const Color purple = AppColors.purple;
  static const Color blue = AppColors.blue;
  static const Color amber = AppColors.amber;
  static const Color orange = AppColors.orange;
  static const Color red = AppColors.red;

  // ---- Text colours for a light background ----
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  // ---- Mock data — replace with your providers / API calls ----
  final List<_StatItem> _stats = const [
    _StatItem("Today's Sales", '₹23,242', Icons.currency_rupee, green),
    _StatItem('Monthly Sales', '₹66,160', Icons.calendar_month, purple),
    _StatItem('Yearly Sales', '₹66,160', Icons.event, blue),
    _StatItem('Purchases This Month', '₹1,89,215', Icons.inventory_2, teal),
    _StatItem('Low Stock Items', '5', Icons.warning_amber_rounded, amber),
    _StatItem('Pending Orders', '6', Icons.schedule, blue),
    _StatItem('Pending Deliveries', '6', Icons.local_shipping, orange),
    _StatItem('Outstanding Receivables', '₹42,225', Icons.account_balance_wallet, green),
    _StatItem('Outstanding Payables', '₹93,820', Icons.credit_card, red),
  ];

  final List<double> _salesTrend = const [
    2, 5, 9, 3, 12, 6, 4, 7, 6, 2, 1, 3, 1, 1, 1, 1, 34,
  ];
  final List<String> _trendLabels = const ['1 Jul', '4 Jul', '7 Jul', '10 Jul', '13 Jul', '17 Jul'];

  final List<_ProductRevenue> _topProducts = const [
    _ProductRevenue('Water Jar Refill (20L)', 14400),
    _ProductRevenue('Water Dispenser - Normal (Standard)', 11200),
    _ProductRevenue('Water Dispenser - Hot & Cold (Standard)', 9000),
    _ProductRevenue('Packaged Drinking Water (1L)', 6400),
    _ProductRevenue('Packaged Drinking Water (500ml)', 4300),
  ];

  final List<_OrderItem> _orders = const [
    _OrderItem('SO-2026-1016', 'Silver Oak Apartments', 'Draft'),
    _OrderItem('SO-2026-1015', 'Rajdhani Sweets & Snacks', 'Draft'),
    _OrderItem('SO-2026-1014', 'Prime Legal Associates', 'Draft'),
    _OrderItem('SO-2026-1013', 'Cloud Nine Café', 'Confirmed'),
    _OrderItem('SO-2026-1011', 'TechNova Solutions Pvt Ltd', 'Confirmed'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _query.isEmpty
        ? _orders
        : _orders
            .where((o) =>
                o.orderNo.toLowerCase().contains(_query.toLowerCase()) ||
                o.customer.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const AppDrawer(activeItem: 'Dashboard'),
      body: SafeArea(
        child: CustomScrollView(
          // Soft pastel glows behind the glass cards — this is what gives the
          // frosted panels something visible to blur, even on a plain white page.

          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsGrid(),
                      const SizedBox(height: 20),
                      _buildSalesTrend(),
                      const SizedBox(height: 20),
                      _buildTopProducts(),
                      const SizedBox(height: 20),
                      _buildRecentOrders(filteredOrders),
                    ]),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  // ---------------- Header ----------------
  Widget _buildHeader() {
    return AdminTopBar(
      title: 'Dashboard',
      leadingIcon: Icons.menu_rounded,
      onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
      trailingAvatar: _buildAccountMenu(),
    );
  }

  // ---------------- Account dropdown (Profile / Settings / Logout) ----------------
  Widget _buildAccountMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(-8, 48),
      elevation: 0,
      color: AppColors.primary.withOpacity(0.96),
      shadowColor: textPrimary.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: textPrimary.withOpacity(0.06)),
      ),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
          );
        } else if (value == 'settings') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
          );
        } else if (value == 'logout') {
          // TODO: call your auth sign-out logic here.
        }
      },
      itemBuilder: (context) => [
        _accountMenuItem(value: 'profile', icon: Icons.person_outline, label: 'Profile'),
        _accountMenuItem(value: 'settings', icon: Icons.settings_outlined, label: 'Settings'),
        const PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1),
        ),
        _accountMenuItem(
          value: 'logout',
          icon: Icons.logout_rounded,
          label: 'Logout',
          color: red,
        ),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [purple, blue]),
        ),
        alignment: Alignment.center,
        child: const Text('AS',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  PopupMenuItem<String> _accountMenuItem({
    required String value,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final c = color ?? textPrimary;
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  color: c, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }


  Widget _iconBadge(IconData icon, Color bg, Color fg) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 20),
    );
  }

  // ---------------- Stats Grid (main dashboard) ----------------
  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, i) {
        final s = _stats[i];
        return _GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.icon, color: s.color, size: 19),
              ),
              const Spacer(),
              Text(s.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(s.value,
                  style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Sales Trend ----------------
  Widget _buildSalesTrend() {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Sales Trend', 'Daily sales this month'),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(values: _salesTrend, color: teal),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _trendLabels
                .map((l) => Text(l, style: TextStyle(color: textSecondary.withOpacity(0.85), fontSize: 11)))
                .toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ---------------- Top Products ----------------
  Widget _buildTopProducts() {
    final maxVal = _topProducts.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Top Products', 'By revenue this month'),
          const SizedBox(height: 18),
          ..._topProducts.map((p) {
            final fraction = (p.revenue / maxVal).clamp(0.05, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(p.name, style: TextStyle(color: textPrimary.withOpacity(0.85), fontSize: 13)),
                      ),
                      Text('₹${(p.revenue / 1000).toStringAsFixed(1)}K',
                          style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Container(height: 10, color: textPrimary.withOpacity(0.06)),
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [teal, teal.withOpacity(0.55)]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------- Recent Orders ----------------
  Widget _buildRecentOrders(List<_OrderItem> orders) {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _sectionTitle('Recent Orders', 'Latest sales orders across the organization'),
              ),
              Text('${orders.length} results', style: TextStyle(color: textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: textPrimary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: textPrimary.withOpacity(0.08)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: textSecondary.withOpacity(0.7)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No orders match your search.', style: TextStyle(color: textSecondary, fontSize: 13)),
            )
          else
            ...orders.map((o) => _orderTile(o)),
        ],
      ),
    );
  }

  Widget _orderTile(_OrderItem o) {
    final isConfirmed = o.status == 'Confirmed';
    final statusColor = isConfirmed ? blue : textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: textPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textPrimary.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(o.orderNo, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(
            flex: 4,
            child: Text(o.customer,
                overflow: TextOverflow.ellipsis, style: TextStyle(color: textPrimary.withOpacity(0.75), fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(isConfirmed ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.35)),
            ),
            child: Text(o.status,
                style: TextStyle(
                    color: isConfirmed ? blue : textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }
}

// ---------------- Reusable Glass Container ----------------
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _GlassContainer({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.primary.withOpacity(0.55),
            border: Border.all(color: AppColors.primary.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2A2E).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------------- Line Chart Painter (Sales Trend) ----------------
class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _LineChartPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    const minVal = 0.0;
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    final dx = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Gridlines
    final gridPaint = Paint()
      ..color = const Color(0xFF1F2A2E).withOpacity(0.06)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Area fill under the line
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.30), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = color.withOpacity(0.20));
      canvas.drawCircle(p, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

// ---------------- Data Models ----------------
class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _ProductRevenue {
  final String name;
  final double revenue;
  const _ProductRevenue(this.name, this.revenue);
}

class _OrderItem {
  final String orderNo;
  final String customer;
  final String status;
  const _OrderItem(this.orderNo, this.customer, this.status);
}


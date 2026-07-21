import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../profile/admin_profile_screen.dart';
import '../settings/admin_settings_screen.dart';
import '../../widgets/app_drawer.dart';

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
  static const Color bg = Color(0xFFFFFFFF);
  static const Color teal = Color(0xFF1FA2B0);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color amber = Color(0xFFF6A609);
  static const Color orange = Color(0xFFFB923C);
  static const Color red = Color(0xFFEF4444);

  // ---- Text colours for a light background ----
  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

  final List<_StatItem> _stats = const [
    _StatItem("Today's Sales", 'Rs. 23,242', Icons.currency_rupee, green),
    _StatItem('Monthly Sales', 'Rs. 66,160', Icons.calendar_month, purple),
    _StatItem('Yearly Sales', 'Rs. 66,160', Icons.event, blue),
    _StatItem('Purchases This Month', 'Rs. 1,89,215', Icons.inventory_2, teal),
    _StatItem('Low Stock Items', '5', Icons.warning_amber_rounded, amber),
    _StatItem('Pending Orders', '6', Icons.schedule, blue),
    _StatItem('Pending Deliveries', '6', Icons.local_shipping, orange),
    _StatItem('Outstanding Receivables', 'Rs. 42,225', Icons.account_balance_wallet, green),
    _StatItem('Outstanding Payables', 'Rs. 93,820', Icons.credit_card, red),
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
    _OrderItem('SO-2026-1013', 'Cloud Nine Cafe', 'Confirmed'),
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
            .where(
              (o) =>
                  o.orderNo.toLowerCase().contains(_query.toLowerCase()) ||
                  o.customer.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const AppDrawer(activeItem: 'Dashboard'),
      body: Stack(
        children: [
          // Soft pastel glows behind the glass cards — this is what gives the
          // frosted panels something visible to blur, even on a plain white page.
          Positioned(top: -60, left: -70, child: _glowBlob(teal, 220)),
          Positioned(top: 140, right: -100, child: _glowBlob(purple, 260)),
          Positioned(bottom: -90, left: 30, child: _glowBlob(orange, 240)),
          Positioned(top: 420, right: 10, child: _glowBlob(green, 180)),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
        ],
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: _GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: _iconBadge(Icons.menu, textPrimary.withOpacity(0.06), textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dashboard',
                      style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('SAAS Distributors · as of 2026-07-17',
                      style: TextStyle(color: textSecondary.withOpacity(0.9), fontSize: 12)),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _iconBadge(Icons.notifications_none_rounded, textPrimary.withOpacity(0.06), textPrimary),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            _buildAccountMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(-8, 48),
      elevation: 0,
      color: Colors.white.withOpacity(0.96),
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
        }
      },
      itemBuilder: (context) => [
        _accountMenuItem(value: 'profile', icon: Icons.person_outline, label: 'Profile'),
        _accountMenuItem(value: 'settings', icon: Icons.settings_outlined, label: 'Settings'),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
          Text(
            label,
            style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color bgColor, Color fg) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 20),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.20), blurRadius: 100, spreadRadius: 30),
        ],
      ),
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
        return _CardContainer(
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
              Text(
                s.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                s.value,
                style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesTrend() {
    return _CardContainer(
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
                .map((label) => Text(label, style: TextStyle(color: textSecondary.withOpacity(0.85), fontSize: 11)))
                .toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final maxVal = _topProducts.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    return _CardContainer(
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
                        child: Text(
                          p.name,
                          style: TextStyle(color: textPrimary.withOpacity(0.85), fontSize: 13),
                        ),
                      ),
                      Text(
                        'Rs. ${(p.revenue / 1000).toStringAsFixed(1)}K',
                        style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
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

  Widget _buildRecentOrders(List<_OrderItem> orders) {
    return _CardContainer(
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
              child: Text(
                'No orders match your search.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            )
          else
            ...orders.map(_orderTile),
        ],
      ),
    );
  }

  Widget _orderTile(_OrderItem order) {
    final isConfirmed = order.status == 'Confirmed';
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
            child: Text(
              order.orderNo,
              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              order.customer,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textPrimary.withOpacity(0.75), fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(isConfirmed ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.35)),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: isConfirmed ? blue : textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
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

class _CardContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _CardContainer({
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
            color: Colors.white.withOpacity(0.55),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
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

    final gridPaint = Paint()
      ..color = const Color(0xFF1F2A2E).withOpacity(0.06)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
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

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = color.withOpacity(0.20));
      canvas.drawCircle(point, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

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
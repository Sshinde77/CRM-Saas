import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../admin/customers/customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class SalesManagerStockScreen extends StatefulWidget {
  const SalesManagerStockScreen({super.key});

  @override
  State<SalesManagerStockScreen> createState() => _SalesManagerStockScreenState();
}

class _SalesManagerStockScreenState extends State<SalesManagerStockScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  int _selectedTab = 0;
  String _selectedCategory = 'All categories';

  final List<String> _tabs = const ['All', 'Active', 'Out of Stock', 'Inactive'];
  final List<String> _categories = const [
    'All categories',
    'Beverages',
    'Snacks',
    'Stationery',
    'Personal Care',
    'Accessories',
  ];

  final List<_StockItem> _items = const [
    _StockItem(
      name: 'Ballpoint Pen Pack',
      sku: '--',
      variants: 2,
      stock: 320,
      category: 'Stationery',
      status: 'In Stock',
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.primary,
      accentColor: AppColors.green,
    ),
    _StockItem(
      name: 'Classic Salted Chips 150g',
      sku: 'DEMO-20260816-215942-CLASSI',
      variants: 0,
      stock: 391,
      category: 'Snacks',
      status: 'In Stock',
      icon: Icons.fastfood_rounded,
      iconColor: AppColors.blue,
      accentColor: AppColors.blue,
    ),
    _StockItem(
      name: 'Cola Can 330ml (Case of 24)',
      sku: 'DEMO-20260816-215942-COLAC',
      variants: 0,
      stock: 110,
      category: 'Beverages',
      status: 'In Stock',
      icon: Icons.local_drink_rounded,
      iconColor: AppColors.primary900,
      accentColor: AppColors.green,
    ),
    _StockItem(
      name: 'Cotton T-Shirt',
      sku: '--',
      variants: 3,
      stock: 200,
      category: 'Accessories',
      status: 'In Stock',
      icon: Icons.checkroom_rounded,
      iconColor: AppColors.orange,
      accentColor: AppColors.blue,
    ),
    _StockItem(
      name: 'Herbal Shampoo 340ml',
      sku: 'DEMO-20260816-215942-HERBAL',
      variants: 0,
      stock: 97,
      category: 'Personal Care',
      status: 'In Stock',
      icon: Icons.spa_rounded,
      iconColor: AppColors.green,
      accentColor: AppColors.green,
    ),
    _StockItem(
      name: 'Mango Juice',
      sku: '--',
      variants: 3,
      stock: 240,
      category: 'Beverages',
      status: 'In Stock',
      icon: Icons.local_drink_outlined,
      iconColor: AppColors.orange,
      accentColor: AppColors.blue,
    ),
    _StockItem(
      name: 'Sparkling Mineral Water 1L',
      sku: 'DEMO-20260816-215942-SPARKL',
      variants: 0,
      stock: 538,
      category: 'Beverages',
      status: 'In Stock',
      icon: Icons.water_drop_rounded,
      iconColor: AppColors.blue,
      accentColor: AppColors.green,
    ),
    _StockItem(
      name: 'USB-C Charging Cable 1m',
      sku: 'DEMO-20260816-215942-USB-C',
      variants: 0,
      stock: 197,
      category: 'Accessories',
      status: 'In Stock',
      icon: Icons.usb_rounded,
      iconColor: AppColors.primary,
      accentColor: AppColors.blue,
    ),
    _StockItem(
      name: 'Ballpoint Pen Pack',
      sku: '--',
      variants: 2,
      stock: 316,
      category: 'Stationery',
      status: 'In Stock',
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.primary,
      accentColor: AppColors.green,
    ),
    _StockItem(
      name: 'Classic Salted Chips 150g',
      sku: 'DEMO-20260816-220627-CLASSI',
      variants: 0,
      stock: 385,
      category: 'Snacks',
      status: 'In Stock',
      icon: Icons.fastfood_rounded,
      iconColor: AppColors.blue,
      accentColor: AppColors.blue,
    ),
    _StockItem(
      name: 'Premium Mouthwash 250ml',
      sku: 'DEMO-20260816-220627-MOU',
      variants: 0,
      stock: 0,
      category: 'Personal Care',
      status: 'Out of Stock',
      icon: Icons.medical_services_outlined,
      iconColor: AppColors.red,
      accentColor: AppColors.red,
    ),
    _StockItem(
      name: 'Promo Tote Bag',
      sku: 'DEMO-20260816-220627-TOTE',
      variants: 1,
      stock: 0,
      category: 'Accessories',
      status: 'Inactive',
      icon: Icons.shopping_bag_outlined,
      iconColor: AppColors.orange,
      accentColor: AppColors.orange,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    switch (action) {
      case 'Stock':
        return;
      case 'Dashboard':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
        );
        return;
      case 'Customers':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const CustomersScreen(useSalesManagerShell: true),
          ),
        );
        return;
      case 'Leads':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
          ),
        );
        return;
      case 'Create Order':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const NewAdminOrderScreen(useSalesManagerShell: true),
          ),
        );
        return;
      case 'Sales Orders':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
          ),
        );
        return;
      case 'Visits':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
        );
        return;
      default:
        _showSnack('$action is not wired yet');
    }
  }

  List<_StockItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final statusMatch = switch (_selectedTab) {
        1 => item.status == 'In Stock',
        2 => item.status == 'Out of Stock',
        3 => item.status == 'Inactive',
        _ => true,
      };
      final categoryMatch = _selectedCategory == 'All categories' ||
          item.category == _selectedCategory;
      final queryMatch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      return statusMatch && categoryMatch && queryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Stock',
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SalesManagerTopBar(title: 'Stock'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryGrid(),
                        const SizedBox(height: 16),
                        _buildMainPanel(items),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final children = [
          _SummaryCard(
            title: 'Tracked Products',
            value: '${_items.length}',
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primary.withValues(alpha: 0.14),
          ),
          _SummaryCard(
            title: 'Total Stock Units',
            value: '${_items.fold<int>(0, (sum, item) => sum + item.stock)}',
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.blue,
            iconBackground: AppColors.blue.withValues(alpha: 0.14),
          ),
          _SummaryCard(
            title: 'Out of Stock',
            value: '${_items.where((item) => item.status == "Out of Stock").length}',
            icon: Icons.cancel_outlined,
            iconColor: AppColors.red,
            iconBackground: AppColors.red.withValues(alpha: 0.14),
          ),
          _SummaryCard(
            title: 'Inactive',
            value: '${_items.where((item) => item.status == "Inactive").length}',
            icon: Icons.visibility_off_outlined,
            iconColor: AppColors.orange,
            iconBackground: AppColors.orange.withValues(alpha: 0.16),
          ),
        ];

        if (isCompact) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final card in children)
                SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: card,
                ),
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMainPanel(List<_StockItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final selected = index == _selectedTab;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == _tabs.length - 1 ? 0 : 18,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.85)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 980;

              if (compact) {
                return Column(
                  children: [
                    _searchField(),
                    const SizedBox(height: 10),
                    _categoryField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _searchField()),
                  const SizedBox(width: 10),
                  SizedBox(width: 230, child: _categoryField()),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No stock items match the current filters.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    ...items.map((item) => _StockTableRow(item: item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textLightMuted,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              cursorColor: AppColors.primary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Search products, brands, SKU',
                hintStyle: TextStyle(
                  color: AppColors.textLightMuted,
                  fontSize: 12.5,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryField() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textLightMuted,
          ),
          items: _categories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedCategory = value);
          },
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const labelStyle = TextStyle(
      color: Color(0xFF8F9AB0),
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    );

    return Row(
      children: const [
        Expanded(flex: 6, child: Text('PRODUCT', style: labelStyle)),
        Expanded(flex: 3, child: Text('SKU', style: labelStyle)),
        Expanded(flex: 1, child: Text('VARIANTS', style: labelStyle)),
        Expanded(flex: 2, child: Text('CURRENT STOCK', style: labelStyle)),
        Expanded(flex: 2, child: Text('STATUS', style: labelStyle)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
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
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockTableRow extends StatelessWidget {
  final _StockItem item;

  const _StockTableRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: item.accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.sku,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.variants}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.stock}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: item.status,
                color: item.status == 'Out of Stock'
                    ? AppColors.red
                    : item.status == 'Inactive'
                        ? AppColors.orange
                        : AppColors.green,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

class _StockItem {
  final String name;
  final String sku;
  final int variants;
  final int stock;
  final String category;
  final String status;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;

  const _StockItem({
    required this.name,
    required this.sku,
    required this.variants,
    required this.stock,
    required this.category,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
  });
}

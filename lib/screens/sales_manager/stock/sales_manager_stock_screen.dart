import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../admin/customers/customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../admin/quotations/admin_quotations_screen.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../attendance/sales_manager_attendance_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../follow_ups/sales_manager_follow_ups_screen.dart';
import '../performance/sales_manager_performance_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class SalesManagerStockScreen extends StatefulWidget {
  const SalesManagerStockScreen({super.key});

  @override
  State<SalesManagerStockScreen> createState() =>
      _SalesManagerStockScreenState();
}

class _SalesManagerStockScreenState extends State<SalesManagerStockScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0;
  String _selectedCategory = 'All categories';
  String? _selectedCategoryId;
  String _selectedSort = 'Name A-Z';
  final Map<String, _StockCategory> _knownCategories = {
    'All categories': const _StockCategory('All categories', null),
  };

  final List<String> _tabs = const [
    'All',
    'Active',
    'Out of Stock',
    'Inactive',
  ];
  static const List<String> _sortOptions = [
    'Name A-Z',
    'Name Z-A',
    'Stock High to Low',
    'Stock Low to High',
    'SKU A-Z',
    'Recently Added',
  ];

  List<_StockItem> _apiItems = [];

  List<_StockItem> get _sourceItems => _apiItems;

  List<_StockCategory> get _categoryOptions {
    final options = <String, _StockCategory>{..._knownCategories};
    for (final item in _sourceItems) {
      if (item.category.trim().isEmpty) continue;
      options[item.category] = _StockCategory(item.category, item.categoryId);
    }
    if (_selectedCategory != 'All categories') {
      options.putIfAbsent(
        _selectedCategory,
        () => _StockCategory(_selectedCategory, _selectedCategoryId),
      );
    }
    return options.values.toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadStock();
    });
  }

  Future<void> _loadStock() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rows = await _apiProvider.fetchStockBoard(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        categoryId: _selectedCategoryId,
      );
      final createdAtByProduct = await _loadProductCreatedAtMap();
      if (!mounted) return;
      setState(() {
        _apiItems = rows
            .map(_StockItem.fromJson)
            .map(
              (item) => item.copyWith(
                createdAt: item.createdAt ?? createdAtByProduct[item.id],
              ),
            )
            .toList();
        for (final item in _apiItems) {
          if (item.category.trim().isNotEmpty) {
            _knownCategories[item.category] =
                _StockCategory(item.category, item.categoryId);
          }
        }
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _apiItems = [];
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, DateTime>> _loadProductCreatedAtMap() async {
    try {
      final products = await _apiProvider.fetchProducts(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        categoryId: _selectedCategoryId,
      );
      return {
        for (final product in products)
          if (_readString(product, const ['id', '_id']).isNotEmpty)
            _readString(product, const ['id', '_id']): _readDate(
                  _readString(product, const ['created_at', 'createdAt']),
                ) ??
                DateTime(1900),
      };
    } catch (_) {
      return const {};
    }
  }

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
          MaterialPageRoute(
            builder: (_) => const SalesManagerDashboardScreen(),
          ),
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
      case 'Quotations':
      case 'Quotation':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const AdminQuotationsScreen(useSalesManagerShell: true),
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
      case 'Follow-ups':
      case 'Follow-Ups':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
        );
        return;
      case 'Attendance':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
        );
        return;
      case 'My Performance':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SalesManagerPerformanceScreen(),
          ),
        );
        return;
      default:
        _showSnack('$action is not wired yet');
    }
  }

  List<_StockItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _sourceItems.where((item) {
      final statusMatch = switch (_selectedTab) {
        1 => item.isActive,
        2 => item.stock <= 0,
        3 => !item.isActive,
        _ => true,
      };
      final categoryMatch =
          _selectedCategory == 'All categories' ||
          item.category == _selectedCategory;
      final queryMatch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query) ||
          item.brand.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      return statusMatch && categoryMatch && queryMatch;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'Name Z-A':
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case 'Stock High to Low':
          return b.stock.compareTo(a.stock);
        case 'Stock Low to High':
          return a.stock.compareTo(b.stock);
        case 'SKU A-Z':
          return a.sku.toLowerCase().compareTo(b.sku.toLowerCase());
        case 'Recently Added':
          return (b.createdAt ?? DateTime(1900)).compareTo(
            a.createdAt ?? DateTime(1900),
          );
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return filtered;
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
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadStock,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryGrid(),
                          const SizedBox(height: 10),
                          _buildMainPanel(items),
                        ],
                      ),
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
        final items = _sourceItems;
        final children = [
          _SummaryCard(
            title: 'Tracked Products',
            value: '${items.length}',
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primary.withValues(alpha: 0.14),
          ),
          _SummaryCard(
            title: 'Total Inventory',
            value:
                '${items.fold<int>(0, (sum, item) => sum + item.totalInventory)}',
            icon: Icons.warehouse_outlined,
            iconColor: AppColors.blue,
            iconBackground: AppColors.blue.withValues(alpha: 0.14),
          ),
          _SummaryCard(
            title: 'Out of Stock',
            value:
                '${items.where((item) => item.stock <= 0).length}',
            icon: Icons.cancel_outlined,
            iconColor: AppColors.red,
            iconBackground: AppColors.red.withValues(alpha: 0.14),
          ),
          _SummaryCard(
            title: 'Inactive',
            value:
                '${items.where((item) => !item.isActive).length}',
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
                SizedBox(width: (constraints.maxWidth - 12) / 2, child: card),
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
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
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
                    const SizedBox(height: 10),
                    _sortField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _searchField()),
                  const SizedBox(width: 10),
                  SizedBox(width: 230, child: _categoryField()),
                  const SizedBox(width: 10),
                  SizedBox(width: 210, child: _sortField()),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const _StockStatePanel(
                      icon: Icons.hourglass_empty_rounded,
                      title: 'Loading stock board...',
                    )
                  else if (_errorMessage != null)
                    _StockStatePanel(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load stock',
                      subtitle: _errorMessage!,
                      actionLabel: 'Retry',
                      onAction: _loadStock,
                    )
                  else if (items.isEmpty)
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
              onChanged: (_) => _loadStock(),
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
          items: _categoryOptions
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category.label,
                  child: Text(
                    category.label,
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
            final category = _categoryOptions.firstWhere(
              (option) => option.label == value,
              orElse: () => _StockCategory(value, null),
            );
            setState(() {
              _selectedCategory = category.label;
              _selectedCategoryId = category.id;
            });
            _loadStock();
          },
        ),
      ),
    );
  }

  Widget _sortField() {
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
          value: _selectedSort,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textLightMuted,
          ),
          items: _sortOptions
              .map(
                (sort) => DropdownMenuItem<String>(
                  value: sort,
                  child: Text(
                    sort,
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
            setState(() => _selectedSort = value);
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
        Expanded(flex: 2, child: Text('INVENTORY', style: labelStyle)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.brand.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
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
            flex: 2,
            child: Text(
              '${item.totalInventory}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
              style: TextStyle(
                color: item.stock <= 0 ? AppColors.red : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (!item.isActive)
                    const _StatusPill(
                      label: 'Inactive',
                      color: AppColors.orange,
                    ),
                  if (item.stock <= 0)
                    const _StatusPill(
                      label: 'Out of Stock',
                      color: AppColors.red,
                    ),
                  if (item.isActive && item.stock > 0)
                    const _StatusPill(
                      label: 'In Stock',
                      color: AppColors.green,
                    ),
                ],
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

class _StockStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StockStatePanel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _StockItem {
  final String id;
  final String name;
  final String sku;
  final String brand;
  final int totalInventory;
  final int variants;
  final int stock;
  final String category;
  final String? categoryId;
  final String status;
  final bool isActive;
  final DateTime? createdAt;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;

  const _StockItem({
    this.id = '',
    required this.name,
    required this.sku,
    this.brand = '',
    required this.totalInventory,
    required this.variants,
    required this.stock,
    required this.category,
    this.categoryId,
    required this.status,
    this.isActive = true,
    this.createdAt,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
  });

  factory _StockItem.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product', 'product_details']);
    final source = product.isEmpty ? json : <String, dynamic>{...json, ...product};
    final brand = _readMap(source, const ['brand']);
    final category = _readMap(source, const ['category']);
    final stock = _readInt(source, const [
      'total_stock',
      'totalStock',
      'total_inventory',
      'totalInventory',
      'current_stock',
      'currentStock',
      'stock',
      'quantity',
    ]);
    final totalInventory = _readInt(source, const [
      'total_inventory',
      'totalInventory',
      'inventory',
      'inventory_count',
      'inventoryCount',
    ]);
    final isActive = _readBool(source, const ['is_active', 'isActive', 'active'], fallback: true);
    final status = !isActive
        ? 'Inactive'
        : stock <= 0
        ? 'Out of Stock'
        : 'In Stock';
    final statusColor = status == 'Out of Stock'
        ? AppColors.red
        : status == 'Inactive'
        ? AppColors.orange
        : AppColors.green;

    return _StockItem(
      id: _firstNonEmpty([
        _readString(source, const ['product_id', 'productId']),
        _readString(source, const ['id', '_id']),
      ]),
      name: _readString(source, const ['name', 'product_name', 'productName'], fallback: 'Product'),
      sku: _readString(source, const ['sku', 'product_sku', 'productSku'], fallback: '--'),
      brand: _firstNonEmpty([
        _readString(source, const ['brand_name', 'brandName']),
        _readDirectString(source, 'brand'),
        _readString(brand, const ['name']),
      ]),
      totalInventory: totalInventory > 0 ? totalInventory : stock,
      variants: _readList(source, const ['variations', 'variants']).length,
      stock: stock,
      category: _firstNonEmpty([
        _readString(source, const ['product_type', 'productType', 'category_name', 'categoryName']),
        _readString(category, const ['name']),
        'Uncategorized',
      ]),
      categoryId: _firstNonEmpty([
        _readString(source, const ['category_id', 'categoryId']),
        _readString(category, const ['id', '_id']),
        _readString(source, const ['product_type', 'productType']),
      ]),
      status: status,
      isActive: isActive,
      createdAt: _readDate(
        _readString(source, const ['created_at', 'createdAt', 'created_on']),
      ),
      icon: _iconForProduct(source),
      iconColor: statusColor,
      accentColor: statusColor,
    );
  }

  _StockItem copyWith({DateTime? createdAt}) {
    return _StockItem(
      id: id,
      name: name,
      sku: sku,
      brand: brand,
      totalInventory: totalInventory,
      variants: variants,
      stock: stock,
      category: category,
      categoryId: categoryId,
      status: status,
      isActive: isActive,
      createdAt: createdAt ?? this.createdAt,
      icon: icon,
      iconColor: iconColor,
      accentColor: accentColor,
    );
  }
}

String _readDirectString(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is! String) return '';
  final text = value.trim();
  return text.isNotEmpty && text.toLowerCase() != 'null' ? text : '';
}

Map<String, dynamic> _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

List<dynamic> _readList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) return value;
  }
  return const [];
}

String _readString(
  Map<String, dynamic> source,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return fallback;
}

int _readInt(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9\-]'), ''));
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

bool _readBool(
  Map<String, dynamic> source,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = source[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'active' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == 'inactive' ||
          normalized == '0') {
        return false;
      }
    }
  }
  return fallback;
}

DateTime? _readDate(String value) {
  if (value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

IconData _iconForProduct(Map<String, dynamic> source) {
  final text = '${_readString(source, const ['name', 'product_name'])} '
          '${_readString(source, const ['product_type', 'category_name'])}'
      .toLowerCase();
  if (text.contains('drink') || text.contains('water') || text.contains('juice')) {
    return Icons.local_drink_rounded;
  }
  if (text.contains('food') || text.contains('snack') || text.contains('chips')) {
    return Icons.fastfood_rounded;
  }
  if (text.contains('shirt') || text.contains('bag')) {
    return Icons.shopping_bag_outlined;
  }
  if (text.contains('cable') || text.contains('usb')) {
    return Icons.usb_rounded;
  }
  if (text.contains('care') || text.contains('shampoo')) {
    return Icons.spa_rounded;
  }
  return Icons.inventory_2_outlined;
}

class _StockCategory {
  final String label;
  final String? id;

  const _StockCategory(this.label, this.id);
}

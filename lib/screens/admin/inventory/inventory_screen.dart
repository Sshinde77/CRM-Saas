import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';

import 'package:crm_saas/core/theme/app_text_styles.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../utils/product_image_url.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/product_image.dart';

// Place this file at: lib/screens/inventory/inventory_screen.dart

/// Inventory screen.
/// - Top stats: Total Products, Low Stock Items, Out of Stock, Stock Value (at cost)
/// - Stock levels / catalog of all categories (filter chips with per-category counts)
/// - Redesigned catalog cards: Product Name, Reorder Level, Category, HSN/SAC,
///   Status, Current Stock, Min Stock
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _pagination = ListPagination();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';
  String _selectedCategory = 'All Categories';
  bool _isLoading = false;
  String? _errorMessage;
  ApiProvider? _apiProvider;
  bool _providerReady = false;

  List<_InventoryItem> _items = const [
    _InventoryItem(
      name: 'Packaged Drinking Water (250ml)',
      category: 'Packaged Water',
      hsnSac: '2201',
      currentStock: 500,
      minStock: 100,
      reorderLevel: 150,
      unitCost: 6,
    ),
    _InventoryItem(
      name: 'Packaged Drinking Water (500ml)',
      category: 'Packaged Water',
      hsnSac: '2201',
      currentStock: 420,
      minStock: 100,
      reorderLevel: 150,
      unitCost: 9,
    ),
    _InventoryItem(
      name: 'Packaged Drinking Water (1L)',
      category: 'Packaged Water',
      hsnSac: '2201',
      currentStock: 40,
      minStock: 80,
      reorderLevel: 120,
      unitCost: 12,
    ),
    _InventoryItem(
      name: 'Mineral Water Bottle (1L)',
      category: 'Mineral Water',
      hsnSac: '2201',
      currentStock: 180,
      minStock: 60,
      reorderLevel: 90,
      unitCost: 15,
    ),
    _InventoryItem(
      name: 'Mineral Water Bottle (2L)',
      category: 'Mineral Water',
      hsnSac: '2201',
      currentStock: 25,
      minStock: 30,
      reorderLevel: 50,
      unitCost: 24,
    ),
    _InventoryItem(
      name: 'Sparkling Water Can (330ml)',
      category: 'Sparkling Water',
      hsnSac: '2202',
      currentStock: 0,
      minStock: 20,
      reorderLevel: 40,
      unitCost: 20,
    ),
    _InventoryItem(
      name: 'Water Jar Refill (20L)',
      category: 'Water Jar',
      hsnSac: '2201',
      currentStock: 25,
      minStock: 20,
      reorderLevel: 35,
      unitCost: 28,
    ),
    _InventoryItem(
      name: 'Water Jar Refill (10L)',
      category: 'Water Jar',
      hsnSac: '2201',
      currentStock: 8,
      minStock: 15,
      reorderLevel: 25,
      unitCost: 18,
    ),
    _InventoryItem(
      name: 'Flavored Water - Lemon (500ml)',
      category: 'Flavored Water',
      hsnSac: '2202',
      currentStock: 70,
      minStock: 25,
      reorderLevel: 40,
      unitCost: 14,
    ),
    _InventoryItem(
      name: 'Flavored Water - Mint (500ml)',
      category: 'Flavored Water',
      hsnSac: '2202',
      currentStock: 0,
      minStock: 25,
      reorderLevel: 40,
      unitCost: 14,
    ),
    _InventoryItem(
      name: 'Alkaline Water Bottle (1L)',
      category: 'Alkaline Water',
      hsnSac: '2201',
      currentStock: 12,
      minStock: 15,
      reorderLevel: 25,
      unitCost: 18,
    ),
    _InventoryItem(
      name: 'Water Dispenser - Normal (Standard)',
      category: 'Dispenser',
      hsnSac: '8418',
      currentStock: 8,
      minStock: 5,
      reorderLevel: 8,
      unitCost: 2400,
    ),
    _InventoryItem(
      name: 'Water Dispenser - Hot & Cold (Standard)',
      category: 'Dispenser',
      hsnSac: '8418',
      currentStock: 5,
      minStock: 5,
      reorderLevel: 8,
      unitCost: 4200,
    ),
    _InventoryItem(
      name: 'Dispenser Stand',
      category: 'Accessories',
      hsnSac: '9403',
      currentStock: 12,
      minStock: 10,
      reorderLevel: 15,
      unitCost: 800,
    ),
    _InventoryItem(
      name: 'Jar Cap (Pack of 10)',
      category: 'Accessories',
      hsnSac: '3923',
      currentStock: 200,
      minStock: 50,
      reorderLevel: 80,
      unitCost: 90,
    ),
    _InventoryItem(
      name: 'Bottle Crate (24-slot)',
      category: 'Accessories',
      hsnSac: '3923',
      currentStock: 60,
      minStock: 20,
      reorderLevel: 35,
      unitCost: 220,
    ),
    _InventoryItem(
      name: 'Dispenser Tap Kit',
      category: 'Accessories',
      hsnSac: '3923',
      currentStock: 3,
      minStock: 10,
      reorderLevel: 15,
      unitCost: 150,
    ),
    _InventoryItem(
      name: 'Water Testing Kit',
      category: 'Accessories',
      hsnSac: '3822',
      currentStock: 18,
      minStock: 10,
      reorderLevel: 15,
      unitCost: 550,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInventory();
    });
  }

  @override
  void dispose() {
    _pagination.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final raw = await _apiProvider!.fetchStockBoard(
        search: _query.trim().isEmpty ? null : _query.trim(),
      );
      if (!mounted) return;
      final items = raw
          .map((json) => _InventoryItem.fromJson(json))
          .where((i) => i.name.isNotEmpty)
          .toList();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Keep existing items on error so the list stays visible.
        if (_items.isEmpty) _errorMessage = e.toString();
      });
    }
  }

  // ---- Derived data ----

  List<String> get _categories {
    final set = <String>{'All Categories'};
    for (final item in _items) {
      set.add(item.category);
    }
    return set.toList();
  }

  int _countForCategory(String category) {
    if (category == 'All Categories') return _items.length;
    return _items.where((i) => i.category == category).length;
  }

  int get _totalProducts => _items.length;

  int get _lowStockCount => _items
      .where((i) => i.currentStock > 0 && i.currentStock <= i.minStock)
      .length;

  int get _outOfStockCount => _items.where((i) => i.currentStock == 0).length;

  double get _stockValue =>
      _items.fold(0, (sum, i) => sum + (i.currentStock * i.unitCost));

  List<_InventoryItem> get _filteredItems {
    return _items.where((item) {
      final matchesCategory =
          _selectedCategory == 'All Categories' ||
          item.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty ||
          item.name.toLowerCase().contains(_query.toLowerCase()) ||
          item.category.toLowerCase().contains(_query.toLowerCase()) ||
          item.hsnSac.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  String _statusFor(_InventoryItem item) {
    if (item.currentStock == 0) return 'Out of Stock';
    if (item.currentStock <= item.minStock) return 'Low Stock';
    return 'In Stock';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Out of Stock':
        return AppColors.red;
      case 'Low Stock':
        return AppColors.amber;
      default:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _pagination.local(
      _filteredItems,
      filterKey: [_query, _selectedCategory].join('|'),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Inventory'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Inventory',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inventory', style: AppTextStyles.screenHeading),
                    const SizedBox(height: 4),
                    Text(
                      'Track stock levels, reorder points, and stock value across your catalog',
                      style: AppTextStyles.body.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: 20),

                    _buildStatsGrid(),

                    const SizedBox(height: 24),
                    const Text(
                      'Stock Levels',
                      style: AppTextStyles.sectionHeading,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse stock by category',
                      style: AppTextStyles.body.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryCatalog(),

                    const SizedBox(height: 24),
                    _buildSearchBar(filtered.length),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ListPaginationPageSize(
                        pagination: _pagination,
                        onChanged: () => setState(() {}),
                      ),
                    ),

                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _loadInventory,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No inventory items match your filters.',
                            style: AppTextStyles.body.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _inventoryCard(item),
                        ),
                      ),
                    ListPaginationBar(
                      pagination: _pagination,
                      onChanged: () => setState(() {}),
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

  // ---------------- Stats grid ----------------
  Widget _buildStatsGrid() {
    final stats = [
      _StatCardData(
        'Total Products',
        '$_totalProducts',
        Icons.inventory_2_outlined,
        AppColors.purple,
      ),
      _StatCardData(
        'Low Stock Items',
        '$_lowStockCount',
        Icons.warning_amber_rounded,
        AppColors.amber,
      ),
      _StatCardData(
        'Out of Stock',
        '$_outOfStockCount',
        Icons.remove_shopping_cart_outlined,
        AppColors.red,
      ),
      _StatCardData(
        'Stock Value (at cost)',
        '₹${_formatMoney(_stockValue)}',
        Icons.account_balance_wallet_outlined,
        AppColors.green,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, i) => _statCard(stats[i]),
        );
      },
    );
  }

  Widget _statCard(_StatCardData stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  style: AppTextStyles.fieldLabel.copyWith(
                    color: textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: stat.color, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(stat.value, style: AppTextStyles.importantNumber),
        ],
      ),
    );
  }

  // ---------------- Category catalog / stock levels ----------------
  Widget _buildCategoryCatalog() {
    final categories = _categories;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final category = categories[i];
          final selected = category == _selectedCategory;
          final count = _countForCategory(category);
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: selected ? Colors.white : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count item${count == 1 ? '' : 's'}',
                    style: AppTextStyles.body.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.85)
                          : textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Search bar ----------------
  Widget _buildSearchBar(int resultCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Catalog', style: AppTextStyles.sectionHeading),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by product, category, or HSN/SAC...',
              prefixIcon: const Icon(Icons.search, color: textSecondary),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.24),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.24),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$resultCount results',
              style: AppTextStyles.body.copyWith(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Redesigned inventory card ----------------
  // Shows: Product Name, Reorder Level, Category, HSN/SAC, Status, Current Stock, Min Stock
  Widget _inventoryCard(_InventoryItem item) {
    final status = _statusFor(item);
    final statusColor = _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(
            alpha: status == 'In Stock' ? 0.18 : 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(
                imageUrl: item.imageUrl,
                size: 52,
                borderRadius: 10,
                seed: item.name,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: statusColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('Category', item.category)),
              Expanded(child: _infoItem('HSN/SAC', item.hsnSac)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoItem('Current Stock', '${item.currentStock} units'),
              ),
              Expanded(child: _infoItem('Min Stock', '${item.minStock} units')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoItem('Reorder Level', '${item.reorderLevel} units'),
              ),
              Expanded(
                child: _infoItem(
                  'Stock Value',
                  '₹${_formatMoney(item.currentStock * item.unitCost)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.bodyStrong,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatMoney(num value) {
    // Simple Indian-style digit grouping without extra packages (e.g. 189215 -> 1,89,215)
    final isNegative = value < 0;
    final digits = value.abs().round().toString();
    if (digits.length <= 3) return (isNegative ? '-' : '') + digits;

    final last3 = digits.substring(digits.length - 3);
    final parts = <String>[];
    String rest = digits.substring(0, digits.length - 3);
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    final formatted = '${parts.join(',')},$last3';
    return (isNegative ? '-' : '') + formatted;
  }
}

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCardData(this.label, this.value, this.icon, this.color);
}

class _InventoryItem {
  final String name;
  final String category;
  final String hsnSac;
  final int currentStock;
  final int minStock;
  final int reorderLevel;
  final double unitCost;
  final String? imageUrl;

  const _InventoryItem({
    required this.name,
    required this.category,
    required this.hsnSac,
    required this.currentStock,
    required this.minStock,
    required this.reorderLevel,
    required this.unitCost,
    this.imageUrl,
  });

  factory _InventoryItem.fromJson(Map<String, dynamic> json) {
    String readText(List<String> keys, {String fallback = ''}) {
      for (final k in keys) {
        final v = json[k]?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
      return fallback;
    }

    int readInt(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is num) return v.toInt();
        final parsed = int.tryParse(v?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return 0;
    }

    double readDbl(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is num) return v.toDouble();
        final parsed = double.tryParse(v?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return 0;
    }

    return _InventoryItem(
      name: readText(const ['name', 'product_name', 'title']),
      category: readText(const ['category', 'category_name']),
      hsnSac: readText(const ['hsn_sac_code', 'hsn', 'sac', 'hsn_code']),
      currentStock: readInt(const [
        'current_stock',
        'available_quantity',
        'stock',
        'quantity',
      ]),
      minStock: readInt(const ['min_stock', 'minimum_stock', 'safety_stock']),
      reorderLevel: readInt(const [
        'reorder_level',
        'reorder_point',
        'reorder_quantity',
      ]),
      unitCost: readDbl(const [
        'unit_cost',
        'cost_price',
        'purchase_price',
        'price',
      ]),
      imageUrl: productImageUrlFromJson(json),
    );
  }
}

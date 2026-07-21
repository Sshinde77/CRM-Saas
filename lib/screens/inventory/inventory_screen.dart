import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';
  String _selectedCategory = 'All Categories';

  final List<String> _categories = const [
    'All Categories',
    'Packaged Water',
    'Mineral Water',
    'Sparkling Water',
    'Water Jar',
    'Flavored Water',
    'Alkaline Water',
    'Dispenser',
    'Accessories',
  ];

  final List<_InventoryItem> _items = const [
    _InventoryItem(
      name: 'Packaged Drinking Water (250ml)',
      category: 'Packaged Water',
      hsnSac: '2201',
      stock: 500,
      minStock: 80,
      reorderLevel: 120,
      costPrice: 6,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Packaged Drinking Water (500ml)',
      category: 'Packaged Water',
      hsnSac: '2201',
      stock: 420,
      minStock: 75,
      reorderLevel: 110,
      costPrice: 9,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Packaged Drinking Water (1L)',
      category: 'Packaged Water',
      hsnSac: '2201',
      stock: 300,
      minStock: 60,
      reorderLevel: 90,
      costPrice: 12,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Mineral Water Bottle (1L)',
      category: 'Mineral Water',
      hsnSac: '2201',
      stock: 180,
      minStock: 45,
      reorderLevel: 70,
      costPrice: 14,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Mineral Water Bottle (2L)',
      category: 'Mineral Water',
      hsnSac: '2201',
      stock: 90,
      minStock: 30,
      reorderLevel: 50,
      costPrice: 23,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Sparkling Water Can (330ml)',
      category: 'Sparkling Water',
      hsnSac: '2202',
      stock: 60,
      minStock: 20,
      reorderLevel: 35,
      costPrice: 20,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Water Jar Refill (20L)',
      category: 'Water Jar',
      hsnSac: '2201',
      stock: 25,
      minStock: 12,
      reorderLevel: 18,
      costPrice: 28,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Water Jar Refill (10L)',
      category: 'Water Jar',
      hsnSac: '2201',
      stock: 15,
      minStock: 10,
      reorderLevel: 14,
      costPrice: 18,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Flavored Water - Lemon (500ml)',
      category: 'Flavored Water',
      hsnSac: '2202',
      stock: 70,
      minStock: 18,
      reorderLevel: 32,
      costPrice: 13,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Flavored Water - Mint (500ml)',
      category: 'Flavored Water',
      hsnSac: '2202',
      stock: 0,
      minStock: 12,
      reorderLevel: 24,
      costPrice: 13,
      status: 'Inactive',
    ),
    _InventoryItem(
      name: 'Alkaline Water Bottle (1L)',
      category: 'Alkaline Water',
      hsnSac: '2201',
      stock: 40,
      minStock: 14,
      reorderLevel: 24,
      costPrice: 16,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Water Dispenser - Normal (Standard)',
      category: 'Dispenser',
      hsnSac: '8418',
      stock: 8,
      minStock: 6,
      reorderLevel: 10,
      costPrice: 2800,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Water Dispenser - Hot & Cold (Standard)',
      category: 'Dispenser',
      hsnSac: '8418',
      stock: 5,
      minStock: 4,
      reorderLevel: 8,
      costPrice: 5100,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Dispenser Stand',
      category: 'Accessories',
      hsnSac: '9403',
      stock: 12,
      minStock: 8,
      reorderLevel: 14,
      costPrice: 860,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Jar Cap (Pack of 10)',
      category: 'Accessories',
      hsnSac: '3923',
      stock: 200,
      minStock: 40,
      reorderLevel: 60,
      costPrice: 85,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Bottle Crate (24-slot)',
      category: 'Accessories',
      hsnSac: '3923',
      stock: 60,
      minStock: 16,
      reorderLevel: 24,
      costPrice: 210,
      status: 'Active',
    ),
    _InventoryItem(
      name: 'Dispenser Tap Kit',
      category: 'Accessories',
      hsnSac: '3923',
      stock: 30,
      minStock: 10,
      reorderLevel: 20,
      costPrice: 140,
      status: 'Low Stock',
    ),
    _InventoryItem(
      name: 'Water Testing Kit',
      category: 'Accessories',
      hsnSac: '3822',
      stock: 18,
      minStock: 8,
      reorderLevel: 12,
      costPrice: 610,
      status: 'Low Stock',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_InventoryItem> get _filteredItems {
    final query = _query.trim().toLowerCase();
    return _items.where((item) {
      final matchesCategory =
          _selectedCategory == 'All Categories' || item.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.hsnSac.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  int get _totalProducts => _items.length;

  int get _lowStockItems =>
      _items.where((item) => item.stock > 0 && item.stock <= item.minStock).length;

  int get _outOfStockItems => _items.where((item) => item.stock == 0).length;

  double get _stockValueAtCost =>
      _items.fold<double>(0, (sum, item) => sum + (item.costPrice * item.stock));

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
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
                    const Text(
                      'Inventory',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track stock levels across your catalog',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryGrid(),
                    const SizedBox(height: 20),
                    _buildCatalogFilters(items.length),
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No inventory items match your filters.',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _inventoryCard(item),
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

  Widget _buildSummaryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _summaryCard(
              label: 'Total Products',
              value: _totalProducts.toString(),
              icon: Icons.inventory_2_outlined,
              color: AppColors.blue,
            );
          case 1:
            return _summaryCard(
              label: 'Low Stock Items',
              value: _lowStockItems.toString(),
              icon: Icons.warning_amber_rounded,
              color: AppColors.amber,
            );
          case 2:
            return _summaryCard(
              label: 'Out of Stock',
              value: _outOfStockItems.toString(),
              icon: Icons.remove_shopping_cart_outlined,
              color: AppColors.red,
            );
          default:
            return _summaryCard(
              label: 'Stock Value at Cost',
              value: 'Rs. ${_stockValueAtCost.toStringAsFixed(0)}',
              icon: Icons.payments_outlined,
              color: AppColors.green,
            );
        }
      },
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogFilters(int resultCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
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
          const Text(
            'Category Catalog',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _filterDropdown(
            _selectedCategory,
            _categories,
            (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search, color: textSecondary),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.24)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.24)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: AppColors.purple),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$resultCount results',
              style: const TextStyle(color: textSecondary, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(String value, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.24)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _inventoryCard(_InventoryItem item) {
    final statusColor = _statusColor(item.status);
    final health = _stockHealth(item);
    final healthColor = _healthColor(health);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pill(item.status, statusColor),
              const Spacer(),
              _iconBadge(
                icon: Icons.circle,
                color: healthColor,
                tooltip: health,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('Reorder Level', '${item.reorderLevel} units')),
              Expanded(child: _infoItem('Category', item.category)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('HSN/SAC', item.hsnSac)),
              Expanded(child: _infoItem('Current Stock', '${item.stock} units')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('Min Stock', '${item.minStock} units')),
              Expanded(child: _infoItem('Stock Value at Cost', 'Rs. ${item.stockValueAtCost.toStringAsFixed(0)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _iconBadge({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
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
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _stockHealth(_InventoryItem item) {
    if (item.stock == 0) return 'Out of Stock';
    if (item.stock <= item.minStock) return 'Low Stock';
    return 'In Stock';
  }

  Color _healthColor(String status) {
    switch (status) {
      case 'Out of Stock':
        return AppColors.red;
      case 'Low Stock':
        return AppColors.amber;
      default:
        return AppColors.green;
    }
  }

  Color _statusColor(String status) {
    if (status == 'Inactive') return AppColors.textSecondary;
    if (status == 'Low Stock') return AppColors.amber;
    return AppColors.green;
  }
}

class _InventoryItem {
  final String name;
  final String category;
  final String hsnSac;
  final int stock;
  final int minStock;
  final int reorderLevel;
  final double costPrice;
  final String status;

  const _InventoryItem({
    required this.name,
    required this.category,
    required this.hsnSac,
    required this.stock,
    required this.minStock,
    required this.reorderLevel,
    required this.costPrice,
    required this.status,
  });

  double get stockValueAtCost => stock * costPrice;
}


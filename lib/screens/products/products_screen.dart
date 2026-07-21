import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

/// Products screen — mobile version of the "Product Catalog" web page.
/// Redesigned as a card list: each product shows Product Name, Brand,
/// Category, HSN, Selling Price, Stock, Status, and View/Edit/Delete actions.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';
  String _selectedCategory = 'All Categories';
  String _selectedBrand = 'All Brands';

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

  final List<String> _brands = const [
    'All Brands',
    'AquaPure',
    'HydroMax',
    'CrystalClear',
    'PureFlow',
  ];

  // Mock catalog — replace with your providers / API calls.
  final List<_ProductItem> _products = [
    _ProductItem(name: 'Packaged Drinking Water (250ml)', brand: 'AquaPure', category: 'Packaged Water', hsn: '2201', price: 10, stock: 500, status: 'Active'),
    _ProductItem(name: 'Packaged Drinking Water (500ml)', brand: 'AquaPure', category: 'Packaged Water', hsn: '2201', price: 15, stock: 420, status: 'Active'),
    _ProductItem(name: 'Packaged Drinking Water (1L)', brand: 'AquaPure', category: 'Packaged Water', hsn: '2201', price: 20, stock: 300, status: 'Active'),
    _ProductItem(name: 'Mineral Water Bottle (1L)', brand: 'CrystalClear', category: 'Mineral Water', hsn: '2201', price: 25, stock: 180, status: 'Active'),
    _ProductItem(name: 'Mineral Water Bottle (2L)', brand: 'CrystalClear', category: 'Mineral Water', hsn: '2201', price: 40, stock: 90, status: 'Active'),
    _ProductItem(name: 'Sparkling Water Can (330ml)', brand: 'HydroMax', category: 'Sparkling Water', hsn: '2202', price: 35, stock: 60, status: 'Active'),
    _ProductItem(name: 'Water Jar Refill (20L)', brand: 'PureFlow', category: 'Water Jar', hsn: '2201', price: 45, stock: 25, status: 'Active'),
    _ProductItem(name: 'Water Jar Refill (10L)', brand: 'PureFlow', category: 'Water Jar', hsn: '2201', price: 30, stock: 15, status: 'Active'),
    _ProductItem(name: 'Flavored Water - Lemon (500ml)', brand: 'AquaPure', category: 'Flavored Water', hsn: '2202', price: 22, stock: 70, status: 'Active'),
    _ProductItem(name: 'Flavored Water - Mint (500ml)', brand: 'AquaPure', category: 'Flavored Water', hsn: '2202', price: 22, stock: 0, status: 'Inactive'),
    _ProductItem(name: 'Alkaline Water Bottle (1L)', brand: 'CrystalClear', category: 'Alkaline Water', hsn: '2201', price: 28, stock: 40, status: 'Active'),
    _ProductItem(name: 'Water Dispenser - Normal (Standard)', brand: 'HydroMax', category: 'Dispenser', hsn: '8418', price: 3500, stock: 8, status: 'Active'),
    _ProductItem(name: 'Water Dispenser - Hot & Cold (Standard)', brand: 'HydroMax', category: 'Dispenser', hsn: '8418', price: 6200, stock: 5, status: 'Active'),
    _ProductItem(name: 'Dispenser Stand', brand: 'PureFlow', category: 'Accessories', hsn: '9403', price: 1200, stock: 12, status: 'Active'),
    _ProductItem(name: 'Jar Cap (Pack of 10)', brand: 'PureFlow', category: 'Accessories', hsn: '3923', price: 150, stock: 200, status: 'Active'),
    _ProductItem(name: 'Bottle Crate (24-slot)', brand: 'AquaPure', category: 'Accessories', hsn: '3923', price: 350, stock: 60, status: 'Active'),
    _ProductItem(name: 'Dispenser Tap Kit', brand: 'HydroMax', category: 'Accessories', hsn: '3923', price: 250, stock: 30, status: 'Inactive'),
    _ProductItem(name: 'Water Testing Kit', brand: 'CrystalClear', category: 'Accessories', hsn: '3822', price: 899, stock: 18, status: 'Active'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ProductItem> get _filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All Categories' || p.category == _selectedCategory;
      final matchesBrand = _selectedBrand == 'All Brands' || p.brand == _selectedBrand;
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.brand.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase()) ||
          p.hsn.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesBrand && matchesQuery;
    }).toList();
  }

  Future<void> _openProductFormDialog({_ProductItem? existing, int? index}) async {
    final result = await showDialog<_ProductItem>(
      context: context,
      builder: (_) => _ProductFormDialog(
        categories: _categories.where((c) => c != 'All Categories').toList(),
        brands: _brands.where((b) => b != 'All Brands').toList(),
        existing: existing,
      ),
    );
    if (result == null) return;
    setState(() {
      if (index != null) {
        _products[index] = result;
      } else {
        _products.add(result);
      }
    });
  }

  Future<void> _confirmDelete(_ProductItem product, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete product?', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently remove "${product.name}" from your catalog.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _products.removeAt(index));
    }
  }

  void _showProductDetails(_ProductItem product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _detailRow('Brand', product.brand),
              _detailRow('Category', product.category),
              _detailRow('HSN', product.hsn),
              _detailRow('Selling Price', '₹${product.price.toStringAsFixed(2)}'),
              _detailRow('Stock', '${product.stock} units'),
              _detailRow('Status', product.status),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: textSecondary, fontSize: 13))),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Products'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Products',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Products',
                                style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage your product catalog and variants',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openProductFormDialog(),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFiltersCard(filtered.length),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('No products match your filters.',
                              style: const TextStyle(color: textSecondary, fontSize: 13)),
                        ),
                      )
                    else
                      ...filtered.map((p) {
                        final index = _products.indexOf(p);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _productCard(p, index),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(int resultCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Catalog', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _filterDropdown(_selectedCategory, _categories, (v) => setState(() => _selectedCategory = v))),
              const SizedBox(width: 10),
              Expanded(child: _filterDropdown(_selectedBrand, _brands, (v) => setState(() => _selectedBrand = v))),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search products...',
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$resultCount results', style: const TextStyle(color: textSecondary, fontSize: 12.5)),
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
          style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
          dropdownColor: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  // ---------------- Product card ----------------
  Widget _productCard(_ProductItem product, int index) {
    final statusColor = _statusColor(product.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusChip(product.status, statusColor),
              const Spacer(),
              _iconActionButton(
                icon: Icons.visibility_outlined,
                color: AppColors.blue,
                tooltip: 'View',
                onTap: () => _showProductDetails(product),
              ),
              const SizedBox(width: 8),
              _iconActionButton(
                icon: Icons.edit_outlined,
                color: AppColors.purple,
                tooltip: 'Edit',
                onTap: () => _openProductFormDialog(existing: product, index: index),
              ),
              const SizedBox(width: 8),
              _iconActionButton(
                icon: Icons.delete_outline_rounded,
                color: AppColors.red,
                tooltip: 'Delete',
                onTap: () => _confirmDelete(product, index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showProductDetails(product),
            child: Text(
              product.name,
              style: const TextStyle(color: AppColors.purple, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('Brand', product.brand)),
              Expanded(child: _infoItem('Category', product.category)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('HSN', product.hsn)),
              Expanded(child: _infoItem('Selling Price', '₹${product.price.toStringAsFixed(2)}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoItem('Stock', '${product.stock} units')),
              Expanded(child: _infoItem('Status', product.status)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _iconActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'Active') return AppColors.green;
    if (status == 'Inactive') return AppColors.textSecondary;
    return AppColors.blue;
  }
}

class _ProductItem {
  final String name;
  final String brand;
  final String category;
  final String hsn;
  final double price;
  final int stock;
  final String status;
  const _ProductItem({
    required this.name,
    required this.brand,
    required this.category,
    required this.hsn,
    required this.price,
    required this.stock,
    required this.status,
  });
}

// ---------------- Add / Edit Product dialog ----------------
class _ProductFormDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> brands;
  final _ProductItem? existing;

  const _ProductFormDialog({required this.categories, required this.brands, this.existing});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  late final TextEditingController _nameController;
  late final TextEditingController _hsnController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _category;
  late String _brand;
  late String _status;
  String? _nameError;

  bool get _isEditing => widget.existing != null;

  static const List<String> _statuses = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _hsnController = TextEditingController(text: existing?.hsn ?? '');
    _priceController = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: existing != null ? existing.stock.toString() : '');
    _category = existing?.category ?? widget.categories.first;
    _brand = existing?.brand ?? widget.brands.first;
    _status = existing?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty ? 'Please enter a product name' : null);
    if (_nameError != null) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    Navigator.of(context).pop(_ProductItem(
      name: name,
      brand: _brand,
      category: _category,
      hsn: _hsnController.text.trim(),
      price: price,
      stock: stock,
      status: _status,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_isEditing ? 'Edit Product' : 'Add Product',
                        style: const TextStyle(color: textPrimary, fontSize: 19, fontWeight: FontWeight.w800)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: AppColors.surfaceSoft, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 18, color: textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.secondary, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Product Name'),
                    TextField(
                      controller: _nameController,
                      autofocus: !_isEditing,
                      onChanged: (_) {
                        if (_nameError != null) setState(() => _nameError = null);
                      },
                      decoration: _decoration(hint: 'e.g. Packaged Drinking Water (1L)', errorText: _nameError),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Brand'),
                    _dropdownField(_brand, widget.brands, (v) => setState(() => _brand = v)),
                    const SizedBox(height: 16),
                    _fieldLabel('Category'),
                    _dropdownField(_category, widget.categories, (v) => setState(() => _category = v)),
                    const SizedBox(height: 16),
                    _fieldLabel('HSN Code'),
                    TextField(controller: _hsnController, decoration: _decoration(hint: 'e.g. 2201')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Selling Price'),
                              TextField(
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _decoration(hint: '₹0.00'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Stock'),
                              TextField(
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                decoration: _decoration(hint: '0'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Status'),
                    _dropdownField(_status, _statuses, (v) => setState(() => _status = v)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.secondary, height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    child: Text(_isEditing ? 'Save Changes' : 'Add Product'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _decoration({String? hint, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.purple),
      ),
    );
  }

  Widget _dropdownField(String value, List<String> options, ValueChanged<String> onChanged) {
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
          style: const TextStyle(color: textPrimary, fontSize: 14),
          dropdownColor: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

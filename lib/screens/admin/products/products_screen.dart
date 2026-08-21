import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

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
  String _sortBy = 'Latest';
  int _currentPage = 1;
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _categories = const [
    'All Categories',
    'Packaged Water',
    'Mineral Water',
    'Sparkling Water',
    'Water Jar',
    'Flavored Water',
    'Dispenser',
    'Accessories',
  ];

  List<String> _brands = const [
    'All Brands',
    'AquaPure',
    'HydroMax',
    'CrystalClear',
    'PureFlow',
  ];

  final List<String> _sortOptions = const ['Latest', 'Name', 'Price', 'Stock'];

  List<_ProductItem> _products = [
    _ProductItem(
      name: 'Packaged Drinking Water (250ml)',
      brand: 'AquaPure',
      category: 'Packaged Water',
      hsn: '2201',
      price: 10,
      stock: 500,
      status: 'Active',
      icon: Icons.water_drop_rounded,
      accent: AppColors.primary,
    ),
    _ProductItem(
      name: 'Packaged Drinking Water (500ml)',
      brand: 'AquaPure',
      category: 'Packaged Water',
      hsn: '2201',
      price: 15,
      stock: 420,
      status: 'Active',
      icon: Icons.local_drink_rounded,
      accent: AppColors.blue,
    ),
    _ProductItem(
      name: 'Mineral Water Bottle (1L)',
      brand: 'CrystalClear',
      category: 'Mineral Water',
      hsn: '2201',
      price: 25,
      stock: 180,
      status: 'Active',
      icon: Icons.local_drink_outlined,
      accent: AppColors.teal,
    ),
    _ProductItem(
      name: 'Sparkling Water Can (330ml)',
      brand: 'HydroMax',
      category: 'Sparkling Water',
      hsn: '2202',
      price: 35,
      stock: 8,
      status: 'Active',
      icon: Icons.bubble_chart_rounded,
      accent: AppColors.orange,
    ),
    _ProductItem(
      name: 'Water Jar Refill (20L)',
      brand: 'PureFlow',
      category: 'Water Jar',
      hsn: '2201',
      price: 45,
      stock: 25,
      status: 'Active',
      icon: Icons.inventory_2_rounded,
      accent: AppColors.green,
    ),
    _ProductItem(
      name: 'Flavored Water - Mint (500ml)',
      brand: 'AquaPure',
      category: 'Flavored Water',
      hsn: '2202',
      price: 22,
      stock: 0,
      status: 'Inactive',
      icon: Icons.eco_rounded,
      accent: AppColors.red,
    ),
    _ProductItem(
      name: 'Water Dispenser - Hot & Cold',
      brand: 'HydroMax',
      category: 'Dispenser',
      hsn: '8418',
      price: 6200,
      stock: 5,
      status: 'Active',
      icon: Icons.kitchen_rounded,
      accent: AppColors.orange,
    ),
    _ProductItem(
      name: 'Water Testing Kit',
      brand: 'CrystalClear',
      category: 'Accessories',
      hsn: '3822',
      price: 899,
      stock: 18,
      status: 'Active',
      icon: Icons.fact_check_rounded,
      accent: AppColors.purple,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _apiProvider.fetchProducts(),
        _apiProvider.fetchCategories(),
        _apiProvider.fetchBrands(),
      ]);
      final products = results[0].map(_ProductItem.fromJson).toList();
      final categories = results[1]
          .map((item) => _productText(item, const ['name', 'category_name']))
          .where((value) => value.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      final brands = results[2]
          .map((item) => _productText(item, const ['name']))
          .where((value) => value.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (!mounted) return;
      setState(() {
        _products = products;
        _categories = ['All Categories', ...categories];
        _brands = ['All Brands', ...brands];
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All Categories';
        }
        if (!_brands.contains(_selectedBrand)) {
          _selectedBrand = 'All Brands';
        }
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<_ProductItem> get _filteredProducts {
    final results = _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All Categories' ||
          p.category == _selectedCategory;
      final matchesBrand =
          _selectedBrand == 'All Brands' || p.brand == _selectedBrand;
      final normalizedQuery = _query.toLowerCase();
      final matchesQuery =
          normalizedQuery.isEmpty ||
          p.name.toLowerCase().contains(normalizedQuery) ||
          p.brand.toLowerCase().contains(normalizedQuery) ||
          p.category.toLowerCase().contains(normalizedQuery) ||
          p.hsn.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesBrand && matchesQuery;
    }).toList();

    switch (_sortBy) {
      case 'Name':
        results.sort((a, b) => a.name.compareTo(b.name));
      case 'Price':
        results.sort((a, b) => b.price.compareTo(a.price));
      case 'Stock':
        results.sort((a, b) => b.stock.compareTo(a.stock));
      default:
        break;
    }

    return results;
  }

  Future<void> _openProductFormDialog({
    _ProductItem? existing,
    int? index,
  }) async {
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
        _products.insert(0, result);
        _currentPage = 1;
      }
    });
  }

  Future<void> _confirmDelete(_ProductItem product, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Delete product?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
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
    if (confirmed == true) setState(() => _products.removeAt(index));
  }

  void _showProductDetails(_ProductItem product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _productVisual(product, size: 58),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _detailRow('Brand', product.brand),
              _detailRow('Category', product.category),
              _detailRow('HSN', product.hsn),
              _detailRow(
                'Selling Price',
                'Rs. ${product.price.toStringAsFixed(2)}',
              ),
              _detailRow('Stock', '${product.stock} units'),
              _detailRow('Status', _stockLabel(product)),
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
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Products'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Product List',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommandRow(),
                    const SizedBox(height: 18),
                    _buildSearchRow(),
                    const SizedBox(height: 18),
                    _buildCountAndSortRow(filtered.length),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 56),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      _ProductErrorState(
                        message: _errorMessage!,
                        onRetry: _loadProducts,
                      )
                    else if (filtered.isEmpty)
                      _emptyState()
                    else
                      ...filtered.map((product) {
                        final index = _products.indexOf(product);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _productCard(product, index),
                        );
                      }),
                    if (filtered.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildPagination(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandRow() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Manage products, pricing, and stock from one catalog.',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _openProductFormDialog(),
          icon: const Icon(Icons.add_rounded, size: 21),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {
              _query = value;
              _currentPage = 1;
            }),
            style: const TextStyle(color: textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(color: AppColors.textLightMuted),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: _outlineBorder(AppColors.border),
              enabledBorder: _outlineBorder(AppColors.border),
              focusedBorder: _outlineBorder(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _squareIconButton(
          icon: Icons.filter_alt_outlined,
          tooltip: 'Filter',
          onTap: _openFiltersSheet,
        ),
      ],
    );
  }

  Widget _buildCountAndSortRow(int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Products',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        _sortControl(),
      ],
    );
  }

  Widget _sortControl() {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort_rounded, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 8),
          const Text(
            'Sort by:',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textPrimary,
              ),
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              items: _sortOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _sortBy = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(_ProductItem product, int index) {
    final statusColor = _stockColor(product);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _productVisual(product, size: compact ? 82 : 96),
              const SizedBox(width: 14),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 116),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusChip(_stockLabel(product), statusColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rs. ${_formatPrice(product.price)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '${product.brand} - ${product.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Stock',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${product.stock}',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _cardActions(product, index),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _productVisual(_ProductItem product, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              color: product.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
          Icon(product.icon, size: size * 0.42, color: product.accent),
        ],
      ),
    );
  }

  Widget _cardActions(_ProductItem product, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _plainActionIcon(
          icon: Icons.visibility_outlined,
          color: AppColors.primary,
          tooltip: 'View',
          onTap: () => _showProductDetails(product),
        ),
        _verticalDivider(),
        _plainActionIcon(
          icon: Icons.edit_outlined,
          color: AppColors.blue,
          tooltip: 'Edit',
          onTap: () => _openProductFormDialog(existing: product, index: index),
        ),
        _verticalDivider(),
        _plainActionIcon(
          icon: Icons.delete_outline_rounded,
          color: AppColors.red,
          tooltip: 'Delete',
          onTap: () => _confirmDelete(product, index),
        ),
      ],
    );
  }

  Widget _plainActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: color, size: 21),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 24, color: AppColors.border);
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _squareIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: textPrimary, size: 25),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: AppColors.textLightMuted,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No products match your filters.',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageButton(
          Icons.chevron_left_rounded,
          onTap: () => _setPage(_currentPage - 1),
        ),
        const SizedBox(width: 10),
        _pageNumber(1),
        const SizedBox(width: 10),
        _pageNumber(2),
        const SizedBox(width: 10),
        _pageNumber(3),
        const SizedBox(width: 14),
        const Text(
          '...',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 14),
        _pageNumber(5),
        const SizedBox(width: 10),
        _pageButton(
          Icons.chevron_right_rounded,
          onTap: () => _setPage(_currentPage + 1),
        ),
      ],
    );
  }

  Widget _pageNumber(int page) {
    final selected = _currentPage == page;
    return InkWell(
      onTap: () => _setPage(page),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: selected ? Colors.white : textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _pageButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: textPrimary, size: 22),
      ),
    );
  }

  void _setPage(int page) {
    if (page < 1 || page > 5) return;
    setState(() => _currentPage = page);
  }

  void _openFiltersSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Products',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sheetDropdown(
                    label: 'Category',
                    value: _selectedCategory,
                    options: _categories,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  _sheetDropdown(
                    label: 'Brand',
                    value: _selectedBrand,
                    options: _brands,
                    onChanged: (value) {
                      setState(() => _selectedBrand = value);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textPrimary,
              ),
              items: options
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }

  String _stockLabel(_ProductItem product) {
    if (product.stock == 0 || product.status == 'Inactive') {
      return 'Out of Stock';
    }
    if (product.stock <= 10) return 'Low Stock';
    return 'In Stock';
  }

  Color _stockColor(_ProductItem product) {
    if (product.stock == 0 || product.status == 'Inactive') {
      return AppColors.red;
    }
    if (product.stock <= 10) return AppColors.orange;
    return AppColors.statusActiveText;
  }

  String _formatPrice(double value) {
    final raw = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
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
  final IconData icon;
  final Color accent;

  const _ProductItem({
    required this.name,
    required this.brand,
    required this.category,
    required this.hsn,
    required this.price,
    required this.stock,
    required this.status,
    required this.icon,
    required this.accent,
  });

  factory _ProductItem.fromJson(Map<String, dynamic> json) {
    final category = _productText(
      json,
      const ['category_label', 'categoryLabel', 'category'],
      nestedKeys: const ['category'],
      fallback: '-',
    );
    final stock = _productInt(
      json,
      const ['stock', 'current_stock', 'currentStock', 'inventory'],
    );
    return _ProductItem(
      name: _productText(json, const ['name'], fallback: '-'),
      brand: _productText(
        json,
        const ['brand'],
        nestedKeys: const ['brand'],
        fallback: '-',
      ),
      category: category,
      hsn: _productText(json, const ['hsn', 'hsn_sac', 'sku'], fallback: '-'),
      price: _productNum(
        json,
        const ['price', 'selling_price', 'sellingPrice', 'mrp'],
      ),
      stock: stock,
      status: _productBool(json['is_active']) ? 'Active' : 'Inactive',
      icon: Icons.inventory_2_rounded,
      accent: AppColors.primary,
    );
  }
}

class _ProductErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProductErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _productText(
  Map<String, dynamic> json,
  List<String> keys, {
  List<String> nestedKeys = const [],
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      final nested = _productText(value, const ['name'], fallback: '');
      if (nested.isNotEmpty) return nested;
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  for (final key in nestedKeys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      final text = _productText(value, const ['name'], fallback: '');
      if (text.isNotEmpty) return text;
    }
  }
  return fallback;
}

double _productNum(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value != null) {
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

int _productInt(Map<String, dynamic> json, List<String> keys) {
  return _productNum(json, keys).round();
}

bool _productBool(Object? value) {
  if (value == null) return true;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase().trim();
  return text != 'false' && text != 'inactive' && text != '0';
}

class _ProductFormDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> brands;
  final _ProductItem? existing;

  const _ProductFormDialog({
    required this.categories,
    required this.brands,
    this.existing,
  });

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
    _priceController = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(
      text: existing != null ? existing.stock.toString() : '',
    );
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
    setState(
      () => _nameError = name.isEmpty ? 'Please enter a product name' : null,
    );
    if (_nameError != null) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    Navigator.of(context).pop(
      _ProductItem(
        name: name,
        brand: _brand,
        category: _category,
        hsn: _hsnController.text.trim(),
        price: price,
        stock: stock,
        status: _status,
        icon: _iconForCategory(_category),
        accent: _accentForCategory(_category),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Dispenser':
        return Icons.kitchen_rounded;
      case 'Accessories':
        return Icons.inventory_2_rounded;
      case 'Water Jar':
        return Icons.inventory_rounded;
      case 'Sparkling Water':
        return Icons.bubble_chart_rounded;
      case 'Flavored Water':
        return Icons.eco_rounded;
      default:
        return Icons.local_drink_rounded;
    }
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'Dispenser':
        return AppColors.orange;
      case 'Accessories':
        return AppColors.teal;
      case 'Water Jar':
        return AppColors.blue;
      case 'Flavored Water':
        return AppColors.green;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Product' : 'Add Product',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderLight, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Product Name'),
                    TextField(
                      controller: _nameController,
                      autofocus: !_isEditing,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                      decoration: _decoration(
                        hint: 'e.g. Packaged Drinking Water (1L)',
                        errorText: _nameError,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Brand'),
                    _dropdownField(
                      _brand,
                      widget.brands,
                      (v) => setState(() => _brand = v),
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Category'),
                    _dropdownField(
                      _category,
                      widget.categories,
                      (v) => setState(() => _category = v),
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('HSN Code'),
                    TextField(
                      controller: _hsnController,
                      decoration: _decoration(hint: 'e.g. 2201'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Selling Price'),
                              TextField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: _decoration(hint: 'Rs. 0.00'),
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
                    const SizedBox(height: 14),
                    _fieldLabel('Status'),
                    _dropdownField(
                      _status,
                      _statuses,
                      (v) => setState(() => _status = v),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.borderLight, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
      child: Text(
        label,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _decoration({String? hint, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: _outlineBorder(AppColors.border),
      enabledBorder: _outlineBorder(AppColors.border),
      focusedBorder: _outlineBorder(AppColors.primary),
    );
  }

  Widget _dropdownField(
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textSecondary,
          ),
          style: const TextStyle(color: textPrimary, fontSize: 14),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

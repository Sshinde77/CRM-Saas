import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../services/api_service.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryVehicleLoadingScreen extends StatefulWidget {
  const DeliveryVehicleLoadingScreen({super.key});

  @override
  State<DeliveryVehicleLoadingScreen> createState() =>
      _DeliveryVehicleLoadingScreenState();
}

class _DeliveryVehicleLoadingScreenState
    extends State<DeliveryVehicleLoadingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final Map<String, TextEditingController> _itemControllers = {};

  Future<void>? _future;
  List<_LoadingProduct> _products = const [];
  List<_LoadingItem> _items = [];
  _LoadingProduct? _selectedProduct;
  _LoadingUser _user = const _LoadingUser(id: '', name: 'Delivery Partner');
  DateTime _loadingDate = DateTime.now();
  String? _error;
  bool _didStartLoad = false;
  bool _isSubmitting = false;

  int get _totalUnits => _items.fold(0, (sum, item) => sum + item.quantity);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _loadInitialData();
      _didStartLoad = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    for (final controller in _itemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = ApiProviderScope.of(context);
    final authMe = await provider.fetchAuthMe();
    final productRows = await provider.fetchProducts(isActive: true);
    final currentUser = provider.currentUser ?? authMe?.user;
    final products = productRows
        .map(_LoadingProduct.fromJson)
        .where((product) => product.id.isNotEmpty && product.name.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (!mounted) return;
    setState(() {
      _user = _LoadingUser(
        id: currentUser?.id?.trim() ?? '',
        name: (currentUser?.name.trim().isNotEmpty ?? false)
            ? currentUser!.name.trim()
            : 'Delivery Partner',
      );
      _products = products;
      _selectedProduct = products.isEmpty ? null : products.first;
    });
  }

  List<_LoadingProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);
    }).toList();
  }

  void _handleSearchChanged(String value) {
    final filtered = _filteredProducts;
    setState(() {
      if (filtered.isEmpty) {
        _selectedProduct = null;
      } else if (_selectedProduct == null ||
          !filtered.any((product) => product.id == _selectedProduct!.id)) {
        _selectedProduct = filtered.first;
      }
    });
  }

  void _addProduct() {
    final product = _selectedProduct;
    if (product == null) {
      _showMessage('Select a product to add.');
      return;
    }

    final quantity = (double.tryParse(_quantityController.text.trim()) ?? 0)
        .round();
    if (quantity <= 0) {
      _showMessage('Enter a quantity greater than zero.');
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    setState(() {
      if (existingIndex >= 0) {
        final existing = _items[existingIndex];
        final updated = existing.copyWith(quantity: existing.quantity + quantity);
        _items = [..._items]..[existingIndex] = updated;
        _controllerFor(updated).text = updated.quantity.toString();
      } else {
        final item = _LoadingItem(product: product, quantity: quantity);
        _items = [..._items, item];
        _controllerFor(item);
      }
      _quantityController.clear();
      _error = null;
    });
  }

  void _removeItem(_LoadingItem item) {
    setState(() {
      _items = _items.where((candidate) => candidate.product.id != item.product.id).toList();
      _itemControllers.remove(item.product.id)?.dispose();
    });
  }

  void _clearItems() {
    setState(() {
      _items = [];
      for (final controller in _itemControllers.values) {
        controller.dispose();
      }
      _itemControllers.clear();
    });
  }

  TextEditingController _controllerFor(_LoadingItem item) {
    return _itemControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(text: item.quantity.toString()),
    );
  }

  void _updateItemQuantity(_LoadingItem item, String value) {
    final quantity = (double.tryParse(value.trim()) ?? 0).round();
    setState(() {
      _items = _items
          .map(
            (candidate) => candidate.product.id == item.product.id
                ? candidate.copyWith(quantity: quantity < 0 ? 0 : quantity)
                : candidate,
          )
          .toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _loadingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.deliveryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _loadingDate = picked);
    }
  }

  Future<void> _submit() async {
    final deliveryPartnerId = _user.id.trim();
    final validItems = _items.where((item) => item.quantity > 0).toList();
    if (deliveryPartnerId.isEmpty) {
      setState(() => _error = 'Delivery partner id is missing.');
      return;
    }
    if (validItems.isEmpty) {
      setState(() => _error = 'Add at least one product to load.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ApiProviderScope.of(context).loadVehicleStock(
        deliveryPartnerId: deliveryPartnerId,
        date: _loadingDate,
        items: validItems
            .map(
              (item) => {
                'product_id': item.product.id,
                'loaded_qty': item.quantity,
              },
            )
            .toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Opening load recorded successfully.'),
          ),
        );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.deliveryVehicleStock,
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isSubmitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load vehicle stock. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting &&
              _products.isEmpty;
          final error = snapshot.hasError ? _cleanError(snapshot.error) : null;

          return Column(
            children: [
              DeliveryTopBar(
                title: 'Vehicle Loading',
                subtitle: 'Record opening stock for your vehicle',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.deliveryGreen,
                  onRefresh: () async {
                    final request = _loadInitialData();
                    setState(() => _future = request);
                    await request;
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            _KpiPanel(
                              itemCount: _items.length,
                              totalUnits: _totalUnits,
                            ),
                            const SizedBox(height: 14),
                            if (isLoading)
                              const _LoadingPanel()
                            else if (error != null)
                              _ErrorPanel(
                                message: error,
                                onRetry: () {
                                  final request = _loadInitialData();
                                  setState(() => _future = request);
                                },
                              )
                            else ...[
                              _DetailsCard(
                                loadingDate: _loadingDate,
                                deliveryPartner: _user.name,
                                onPickDate: _pickDate,
                              ),
                              const SizedBox(height: 14),
                              _ProductsCard(
                                searchController: _searchController,
                                quantityController: _quantityController,
                                products: _filteredProducts,
                                selectedProduct: _selectedProduct,
                                items: _items,
                                itemControllers: _itemControllers,
                                onSearchChanged: _handleSearchChanged,
                                onProductChanged: (product) {
                                  setState(() => _selectedProduct = product);
                                },
                                onAdd: _addProduct,
                                onClear: _clearItems,
                                onRemove: _removeItem,
                                onQuantityChanged: _updateItemQuantity,
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                _InlineError(message: _error!),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _BottomSummary(
                totalUnits: _totalUnits,
                productLines: _items.length,
                isSubmitting: _isSubmitting,
                onSave: _isSubmitting ? null : _submit,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KpiPanel extends StatelessWidget {
  final int itemCount;
  final int totalUnits;

  const _KpiPanel({required this.itemCount, required this.totalUnits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF063B25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF146C42).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063B25).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              icon: Icons.inventory_2_outlined,
              value: itemCount.toString(),
              label: 'Product Lines',
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _Metric(
              icon: Icons.layers_rounded,
              value: totalUnits.toString(),
              label: 'Units Loaded',
            ),
          ),
          const _MetricDivider(),
          const Expanded(
            child: _Metric(
              icon: Icons.radio_button_unchecked_rounded,
              value: 'Draft',
              label: 'Status',
              accent: Color(0xFFFFB020),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    this.accent = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD8F5DF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.24),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final DateTime loadingDate;
  final String deliveryPartner;
  final VoidCallback onPickDate;

  const _DetailsCard({
    required this.loadingDate,
    required this.deliveryPartner,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.calendar_month_outlined,
            title: 'Loading Details',
          ),
          const SizedBox(height: 18),
          _FieldRow(
            label: 'Loading Date',
            child: _SelectField(
              icon: Icons.calendar_today_outlined,
              text: _formatDate(loadingDate),
              trailing: Icons.keyboard_arrow_down_rounded,
              onTap: onPickDate,
            ),
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'Delivery Partner',
            child: _SelectField(
              icon: Icons.person_outline_rounded,
              text: deliveryPartner,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsCard extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController quantityController;
  final List<_LoadingProduct> products;
  final _LoadingProduct? selectedProduct;
  final List<_LoadingItem> items;
  final Map<String, TextEditingController> itemControllers;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_LoadingProduct?> onProductChanged;
  final VoidCallback onAdd;
  final VoidCallback onClear;
  final ValueChanged<_LoadingItem> onRemove;
  final void Function(_LoadingItem item, String value) onQuantityChanged;

  const _ProductsCard({
    required this.searchController,
    required this.quantityController,
    required this.products,
    required this.selectedProduct,
    required this.items,
    required this.itemControllers,
    required this.onSearchChanged,
    required this.onProductChanged,
    required this.onAdd,
    required this.onClear,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedProduct != null &&
            products.any((product) => product.id == selectedProduct!.id)
        ? selectedProduct
        : products.isEmpty
            ? null
            : products.first;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.add_box_outlined,
            title: 'Add Products',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: _inputDecoration(
              hint: 'Search product by name, SKU...',
              icon: Icons.search_rounded,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<_LoadingProduct>(
            value: selected,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: _inputDecoration(hint: 'Select a product'),
            items: products
                .map(
                  (product) => DropdownMenuItem(
                    value: product,
                    child: Text(
                      product.dropdownLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: products.isEmpty ? null : onProductChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: _inputDecoration(
              hint: 'Quantity to load',
              icon: Icons.numbers_rounded,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_box_outlined, size: 22),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFEAF7ED),
                foregroundColor: const Color(0xFF14783A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE8EDF2)),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF087333),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Products to Load (${items.length})',
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: items.isEmpty ? null : onClear,
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppColors.deliveryRed,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const _EmptyItems()
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LoadingItemRow(
                  item: item,
                  controller: itemControllers[item.product.id]!,
                  onChanged: (value) => onQuantityChanged(item, value),
                  onRemove: () => onRemove(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingItemRow extends StatelessWidget {
  final _LoadingItem item;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  const _LoadingItemRow({
    required this.item,
    required this.controller,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProductAvatar(product: item.product),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 62,
            height: 42,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: const Color(0xFFFAFBFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.deliveryGreen,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              item.product.unitLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Remove',
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.deliveryRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSummary extends StatelessWidget {
  final int totalUnits;
  final int productLines;
  final bool isSubmitting;
  final VoidCallback? onSave;

  const _BottomSummary({
    required this.totalUnits,
    required this.productLines,
    required this.isSubmitting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.deliveryGreen.withValues(alpha: 0.28)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDCEEE1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryStat(
                      label: 'Total Units',
                      value: totalUnits.toString(),
                      suffix: 'kg / L',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: const Color(0xFFDDE7E1),
                  ),
                  Expanded(
                    child: _SummaryStat(
                      label: 'Product Lines',
                      value: productLines.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: onSave,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 22),
                        label: Text(
                          isSubmitting ? 'Saving...' : 'Save Opening Load',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF06783D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF08733A),
                    fontSize: 28,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label),
              const SizedBox(height: 8),
              child,
            ],
          );
        }
        return Row(
          children: [
            SizedBox(width: 190, child: _FieldLabel(label)),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF4B5668),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final IconData icon;
  final String text;
  final IconData? trailing;
  final VoidCallback? onTap;

  const _SelectField({
    required this.icon,
    required this.text,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFBFCFD),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E7F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF313846), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text.trim().isEmpty ? '-' : text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4B5668),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) Icon(trailing, color: const Color(0xFF303746)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7ED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF087333), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  final _LoadingProduct product;

  const _ProductAvatar({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl.trim();
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2EDE6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Icon(product.fallbackIcon, color: const Color(0xFF39A04D), size: 26)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  product.fallbackIcon,
                  color: const Color(0xFF39A04D),
                  size: 26,
                );
              },
            ),
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDF2)),
      ),
      child: const Text(
        'Selected products will appear here.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: SizedBox(
        height: 260,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.deliveryGreen),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.deliveryRed,
              size: 36,
            ),
            const SizedBox(height: 10),
            const Text(
              'Vehicle loading could not load',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deliveryRedSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.statusInactiveBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.deliveryRed,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({required String hint, IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: const Color(0xFF718096)),
    hintStyle: const TextStyle(
      color: Color(0xFF98A2B3),
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.deliveryGreen, width: 1.4),
    ),
  );
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
}

String _cleanError(Object? error) {
  final text = error?.toString().trim() ?? '';
  if (text.isEmpty) return 'Something went wrong.';
  return text.replaceFirst('ApiException: ', '');
}

class _LoadingUser {
  final String id;
  final String name;

  const _LoadingUser({required this.id, required this.name});
}

class _LoadingItem {
  final _LoadingProduct product;
  final int quantity;

  const _LoadingItem({required this.product, required this.quantity});

  _LoadingItem copyWith({int? quantity}) {
    return _LoadingItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class _LoadingProduct {
  final String id;
  final String name;
  final String sku;
  final String unit;
  final String packageSize;
  final String imageUrl;

  const _LoadingProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.packageSize,
    required this.imageUrl,
  });

  factory _LoadingProduct.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product']);
    final source = product.isEmpty ? json : <String, dynamic>{...json, ...product};
    return _LoadingProduct(
      id: _readString(source, const ['id', '_id', 'product_id', 'productId']),
      name: _readString(source, const [
        'name',
        'product_name',
        'productName',
        'title',
      ], fallback: 'Product'),
      sku: _readString(source, const ['sku', 'SKU', 'code', 'product_code']),
      unit: _readString(source, const [
        'unit',
        'uom',
        'measurement_unit',
        'base_unit',
      ]),
      packageSize: _firstNonEmpty([
        _readString(source, const ['package_size', 'packageSize', 'size']),
        _readString(source, const ['variant', 'variant_name', 'variantName']),
      ]),
      imageUrl: _firstNonEmpty([
        _readString(source, const ['image_url', 'imageUrl', 'image', 'photo']),
        _readString(source, const ['thumbnail', 'thumbnail_url']),
      ]),
    );
  }

  String get unitLabel => unit.trim().isEmpty ? 'units' : unit.trim();

  String get meta {
    final parts = [
      if (sku.trim().isNotEmpty) 'SKU: $sku',
      if (packageSize.trim().isNotEmpty) packageSize,
    ];
    return parts.isEmpty ? unitLabel : parts.join('  /  ');
  }

  String get dropdownLabel {
    if (sku.trim().isEmpty) return name;
    return '$name - $sku';
  }

  IconData get fallbackIcon {
    final text = name.toLowerCase();
    if (text.contains('oil')) return Icons.opacity_rounded;
    if (text.contains('rice') || text.contains('dal')) return Icons.grass_rounded;
    if (text.contains('sugar')) return Icons.inventory_2_outlined;
    return Icons.inventory_2_outlined;
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final text = value.trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

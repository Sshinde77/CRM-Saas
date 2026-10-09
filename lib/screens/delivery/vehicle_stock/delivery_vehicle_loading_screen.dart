import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/api_constants.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../utils/product_image_url.dart';
import '../../../widgets/app_calendar_date_picker.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryVehicleLoadingScreen extends StatefulWidget {
  const DeliveryVehicleLoadingScreen({
    super.key,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
  });

  final String? deliveryPartnerId;
  final String? deliveryPartnerName;

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
  List<_LoadingProduct> _catalogProducts = const [];
  List<_LoadingProduct> _products = const [];
  List<_LoadingItem> _items = [];
  List<_LoadableDelivery> _loadableDeliveries = const [];
  final Set<String> _readiedDeliveryIds = {};
  _LoadingProduct? _selectedProduct;
  _LoadingUser _user = const _LoadingUser(id: '', name: 'Delivery Partner');
  DateTime _loadingDate = DateTime.now();
  String? _error;
  bool _didStartLoad = false;
  bool _isSubmitting = false;
  _StockSession? _session;
  String _selectedCategory = 'All';
  String _vehicleNumber = '';

  int get _totalUnits => _items.fold(0, (sum, item) => sum + item.quantity);
  int get _orderUnits =>
      _products.fold(0, (sum, product) => sum + product.ordered.round());

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
    final currentUser = provider.currentUser ?? authMe?.user;
    final requestedPartnerId = widget.deliveryPartnerId?.trim() ?? '';
    final deliveryPartnerId = requestedPartnerId.isNotEmpty
        ? requestedPartnerId
        : currentUser?.id?.trim() ?? '';
    if (deliveryPartnerId.isEmpty) {
      throw const ApiException(message: 'Delivery partner id is missing.');
    }
    final results = await Future.wait<Object?>([
      provider.fetchDeliveryPartnerDeliveries(
        deliveryPartnerId: deliveryPartnerId,
      ),
      provider.fetchProducts(isActive: true),
      provider.fetchAssignedVehicles(deliveryPartnerId),
      provider.fetchCurrentVehicleStock(deliveryPartnerId),
    ]);
    final deliveryRows = results[0] as List<Map<String, dynamic>>;
    final productRows = results[1] as List<Map<String, dynamic>>;
    final vehicleRows = results[2] as List<Map<String, dynamic>>;
    final currentStock = results[3] as Map<String, dynamic>?;
    final loadableDeliveries = deliveryRows
        .map(_LoadableDelivery.fromJson)
        .where((delivery) => delivery.id.isNotEmpty && delivery.items.isNotEmpty)
        .toList();
    final plannedQuantities = <String, double>{};
    for (final delivery in loadableDeliveries) {
      for (final item in delivery.items) {
        plannedQuantities.update(
          item.productId,
          (quantity) => quantity + item.remaining,
          ifAbsent: () => item.remaining,
        );
      }
    }
    var vehicleNumber = currentStock == null
        ? ''
        : _stockVehicleNumber(currentStock);
    if (vehicleNumber.isEmpty && vehicleRows.isNotEmpty) {
      vehicleNumber = _stockVehicleNumber(vehicleRows.first);
    }
    if (vehicleNumber.isEmpty && deliveryPartnerId.isNotEmpty) {
      try {
        final sessions = await provider.fetchVehicleStockSessions();
        for (final row in sessions) {
          final source = _stockSource(row);
          final partner = _readMap(source, const [
            'delivery_partner',
            'deliveryPartner',
            'partner',
            'driver',
          ]);
          final partnerId = _firstNonEmpty([
            _readString(source, const [
              'delivery_partner_id',
              'deliveryPartnerId',
              'partner_id',
              'partnerId',
            ]),
            _readString(partner, const ['id', '_id']),
          ]);
          if (partnerId.isNotEmpty && partnerId != deliveryPartnerId) continue;
          vehicleNumber = _stockVehicleNumber(row);
          if (vehicleNumber.isNotEmpty) break;
        }
      } catch (_) {
        // Vehicle history is optional; loading can continue without it.
      }
    }
    final allProducts =
        productRows
            .map(_LoadingProduct.fromJson)
            .where(
              (product) => product.id.isNotEmpty && product.name.isNotEmpty,
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    final products = allProducts
        .where((product) => plannedQuantities.containsKey(product.id))
        .map(
          (product) => product.copyWith(
            ordered: plannedQuantities[product.id] ?? 0,
          ),
        )
        .toList();

    if (!mounted) return;
    setState(() {
      _user = _LoadingUser(
        id: deliveryPartnerId,
        name: (widget.deliveryPartnerName?.trim().isNotEmpty ?? false)
            ? widget.deliveryPartnerName!.trim()
            : (currentUser?.name.trim().isNotEmpty ?? false)
            ? currentUser!.name.trim()
            : 'Delivery Partner',
      );
      _catalogProducts = allProducts;
      _products = products;
      _loadableDeliveries = loadableDeliveries;
      _readiedDeliveryIds.clear();
      _selectedProduct = products.isEmpty ? null : products.first;
      _session = currentStock == null
          ? null
          : _StockSession.fromJson(currentStock, allProducts);
      _vehicleNumber = _session?.vehicleNumber.isNotEmpty == true
          ? _session!.vehicleNumber
          : vehicleNumber;
      if (_session?.date != null) _loadingDate = _session!.date!;
      for (final controller in _itemControllers.values) {
        controller.dispose();
      }
      _itemControllers.clear();
      _items = products
          .where((product) => product.ordered > 0)
          .map(
            (product) => _LoadingItem(
              product: product,
              quantity: product.ordered.round(),
            ),
          )
          .toList();
      for (final item in _items) {
        _controllerFor(item);
      }
    });
  }

  List<_LoadingProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    final categoryFiltered = _selectedCategory == 'All'
        ? _products
        : _products
              .where((product) => product.category == _selectedCategory)
              .toList();
    if (query.isEmpty) return categoryFiltered;
    return categoryFiltered.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);
    }).toList();
  }

  List<String> get _categories {
    final values =
        _products
            .map((product) => product.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...values];
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

    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    setState(() {
      if (existingIndex >= 0) {
        final existing = _items[existingIndex];
        final updated = existing.copyWith(
          quantity: existing.quantity + quantity,
        );
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
      _items = _items
          .where((candidate) => candidate.product.id != item.product.id)
          .toList();
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

  TextEditingController _controllerForProduct(_LoadingProduct product) {
    final existing = _items.where((item) => item.product.id == product.id);
    final quantity = existing.isEmpty ? 0 : existing.first.quantity;
    return _itemControllers.putIfAbsent(
      product.id,
      () => TextEditingController(text: quantity > 0 ? '$quantity' : ''),
    );
  }

  void _updateProductLoad(_LoadingProduct product, String value) {
    final quantity = (double.tryParse(value.trim()) ?? 0).round();
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    setState(() {
      if (existingIndex >= 0) {
        if (quantity <= 0) {
          _items = [..._items]..removeAt(existingIndex);
        } else {
          _items = [..._items]
            ..[existingIndex] = _LoadingItem(
              product: product,
              quantity: quantity,
            );
        }
      } else if (quantity > 0) {
        _items = [
          ..._items,
          _LoadingItem(product: product, quantity: quantity),
        ];
      }
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showAppCalendarDatePicker(
      context: context,
      initialDate: _loadingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      title: 'Loading Date',
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
      setState(() => _error = 'No picked delivery stock is ready to load.');
      return;
    }
    if (_loadableDeliveries.isEmpty) {
      setState(() => _error = 'No planned deliveries are ready to load.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final provider = ApiProviderScope.of(context);
      for (final delivery in _loadableDeliveries) {
        if (delivery.needsReady &&
            !_readiedDeliveryIds.contains(delivery.id)) {
          await provider.markDeliveryReady(delivery.id);
          _readiedDeliveryIds.add(delivery.id);
        }
      }
      await provider.loadDeliveryBatch(
        _loadableDeliveries.map((delivery) => delivery.id).toList(),
      );
      if (!mounted) return;
      for (final controller in _itemControllers.values) {
        controller.dispose();
      }
      _itemControllers.clear();
      _items = [];
      await _loadInitialData();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Planned deliveries loaded successfully.'),
          ),
        );
      setState(() => _isSubmitting = false);
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

  Future<void> _showAddLoadDialog() async {
    if (_catalogProducts.isEmpty) {
      _showMessage('No active products are available to add.');
      return;
    }
    final provider = ApiProviderScope.of(context);
    final quantities = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _StockAdjustmentSheet(
        title: 'Add More Stock',
        actionLabel: 'Add Stock',
        products: _catalogProducts,
        stockItems: _session?.items ?? const [],
        mode: _AdjustmentMode.add,
      ),
    );
    if (quantities == null || quantities.values.every((value) => value <= 0)) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final session = _session;
      if (session == null || session.id.isEmpty) {
        throw const ApiException(
          message: 'Vehicle stock session is unavailable.',
        );
      }
      await provider.addExtraVehicleStock(
        sessionId: session.id,
        items: quantities.entries
            .where((entry) => entry.value > 0)
            .map((entry) {
              final matches = _catalogProducts.where(
                (product) => product.id == entry.key,
              );
              final variantId = matches.isEmpty
                  ? ''
                  : matches.first.variantId;
              return {
                'product_id': entry.key,
                if (variantId.isNotEmpty) 'variant_id': variantId,
                'quantity': entry.value,
              };
            })
            .toList(),
      );
      await _loadInitialData();
      if (mounted) _showMessage('New load added successfully.');
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showCloseTodayDialog() async {
    final provider = ApiProviderScope.of(context);
    final session = _session;
    if (session == null || session.id.isEmpty) {
      _showMessage('Vehicle stock session is unavailable.');
      return;
    }
    final quantities = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _StockAdjustmentSheet(
        title: 'Return Products',
        actionLabel: 'Submit',
        products: session.items.map((item) => item.product).toList(),
        stockItems: session.items,
        mode: _AdjustmentMode.close,
      ),
    );
    if (quantities == null) return;
    setState(() => _isSubmitting = true);
    try {
      await provider.submitEndOfDayReturn(
        sessionId: session.id,
        items: session.items
            .map(
              (item) => {
                'product_id': item.product.id,
                'returned_qty': quantities[item.product.id] ?? 0,
              },
            )
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        _session = session.closedWithReturns(quantities);
        _isSubmitting = false;
      });
      _showMessage('Vehicle stock closed successfully.');
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showMessage(error.message);
      }
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
      body: SafeArea(
        child: FutureBuilder<void>(
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
                subtitle: 'Load picked deliveries onto your vehicle',
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
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            _KpiPanel(
                              orderUnits:
                                  _loadableDeliveries.isNotEmpty
                                  ? _orderUnits
                                  : _session?.totalOrdered.round() ?? 0,
                              loadedUnits: _session?.totalLoaded.round() ?? 0,
                              session: _session,
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
                                vehicleNumber:
                                    _session?.vehicleNumber ?? _vehicleNumber,
                                status: _session?.status,
                                onPickDate: _pickDate,
                              ),
                              const SizedBox(height: 14),
                              if (_session != null) ...[
                                _LoadedSessionBanner(session: _session!),
                                const SizedBox(height: 14),
                                _SessionProductsCard(session: _session!),
                                if (_loadableDeliveries.isNotEmpty)
                                  const SizedBox(height: 14),
                              ],
                              if (_loadableDeliveries.isNotEmpty)
                                _ProductsCard(
                                  searchController: _searchController,
                                  quantityController: _quantityController,
                                  products: _filteredProducts,
                                  selectedProduct: _selectedProduct,
                                  items: _items,
                                  itemControllers: _itemControllers,
                                  controllerForProduct: _controllerForProduct,
                                  onProductQuantityChanged: _updateProductLoad,
                                  categories: _categories,
                                  selectedCategory: _selectedCategory,
                                  onCategoryChanged: (category) => setState(
                                    () => _selectedCategory = category,
                                  ),
                                  onSearchChanged: _handleSearchChanged,
                                  onProductChanged: (product) {
                                    setState(() => _selectedProduct = product);
                                  },
                                  onAdd: _addProduct,
                                  onClear: _clearItems,
                                  onRemove: _removeItem,
                                  onQuantityChanged: _updateItemQuantity,
                                )
                              else if (_session == null)
                                const _NoPlannedDeliveries(),
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
              if (_loadableDeliveries.isNotEmpty)
                _BottomSummary(
                  totalUnits: _totalUnits,
                  productLines: _items.length,
                  isSubmitting: _isSubmitting,
                  onSave: _isSubmitting ? null : _submit,
                )
              else if (_session != null && !_session!.isClosed)
                _ActiveBottomActions(
                  busy: _isSubmitting,
                  onAddLoad: _showAddLoadDialog,
                  onCloseToday: _showCloseTodayDialog,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KpiPanel extends StatelessWidget {
  final int orderUnits;
  final int loadedUnits;
  final _StockSession? session;

  const _KpiPanel({
    required this.orderUnits,
    required this.loadedUnits,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.receipt_long_outlined,
                  value: orderUnits.toString(),
                  label: 'Order Units',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  icon: Icons.layers_rounded,
                  value: loadedUnits.toString(),
                  label: 'Loaded Units',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  icon: Icons.radio_button_unchecked_rounded,
                  value: session == null ? 'Draft' : 'Confirmed',
                  label: 'Status',
                  accent: const Color(0xFFFFB020),
                ),
              ),
            ],
          ),
          if (session != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    icon: Icons.local_shipping_outlined,
                    value: session!.totalDelivered.round().toString(),
                    label: 'Delivered',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    icon: Icons.inventory_2_outlined,
                    value: session!.totalRemaining.round().toString(),
                    label: 'Remaining',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    icon: Icons.assignment_return_outlined,
                    value: session!.totalReturned.round().toString(),
                    label: 'Returned',
                    accent: const Color(0xFFFFB020),
                  ),
                ),
              ],
            ),
          ],
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
    final color = accent == Colors.white ? AppColors.deliveryGreen : accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
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
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final DateTime loadingDate;
  final String deliveryPartner;
  final String vehicleNumber;
  final String? status;
  final VoidCallback onPickDate;

  const _DetailsCard({
    required this.loadingDate,
    required this.deliveryPartner,
    required this.vehicleNumber,
    required this.status,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.calendar_month_outlined,
            title: 'Loading Details',
            trailing: status == null
                ? null
                : _CompactStatusPill(status: status!),
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
            label: 'Vehicle Number',
            child: _SelectField(
              icon: Icons.local_shipping_outlined,
              text: vehicleNumber.isEmpty ? 'Not assigned' : vehicleNumber,
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
  final TextEditingController Function(_LoadingProduct) controllerForProduct;
  final void Function(_LoadingProduct product, String value)
  onProductQuantityChanged;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
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
    required this.controllerForProduct,
    required this.onProductQuantityChanged,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onProductChanged,
    required this.onAdd,
    required this.onClear,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.add_box_outlined,
            title: 'Planned Products',
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
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => onCategoryChanged(category),
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedColor: AppColors.deliveryGreen,
                  backgroundColor: const Color(0xFFF4F7F5),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (products.isEmpty)
            const _EmptyItems()
          else
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DraftProductRow(
                  product: product,
                  controller: controllerForProduct(product),
                  onChanged: (value) =>
                      onProductQuantityChanged(product, value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DraftProductRow extends StatelessWidget {
  const _DraftProductRow({
    required this.product,
    required this.controller,
    required this.onChanged,
  });

  final _LoadingProduct product;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final availabilityColor = product.available <= 0
        ? AppColors.deliveryRed
        : product.ordered > 0 && product.available < product.ordered
        ? AppColors.deliveryOrange
        : AppColors.deliveryGreen;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Row(
        children: [
          _ProductAvatar(product: product),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: availabilityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  product.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TinyProductMetric(
                        label: 'Ordered',
                        value: _quantity(product.ordered),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 74,
                      child: TextField(
                        controller: controller,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          labelText: 'To Load',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedSessionBanner extends StatelessWidget {
  const _LoadedSessionBanner({required this.session});

  final _StockSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deliveryGreenSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.deliveryGreen.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.deliveryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Already Loaded',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.vehicleNumber.isEmpty
                      ? 'An active stock session is open for today.'
                      : '${session.vehicleNumber} has an active stock session for today.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_quantity(session.totalLoaded)} loaded  |  '
                  '${_quantity(session.totalDelivered)} delivered  |  '
                  '${_quantity(session.totalRemaining)} remaining',
                  style: const TextStyle(
                    color: AppColors.deliveryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _CompactStatusPill(status: session.status),
        ],
      ),
    );
  }
}

class _SessionProductsCard extends StatefulWidget {
  const _SessionProductsCard({required this.session});
  final _StockSession session;

  @override
  State<_SessionProductsCard> createState() => _SessionProductsCardState();
}

class _SessionProductsCardState extends State<_SessionProductsCard> {
  final TextEditingController _search = TextEditingController();
  String _category = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        widget.session.items
            .map((item) => item.product.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final query = _search.text.trim().toLowerCase();
    final items = widget.session.items.where((item) {
      final matchesCategory =
          _category == 'All' || item.product.category == _category;
      final matchesSearch =
          query.isEmpty ||
          item.product.name.toLowerCase().contains(query) ||
          item.product.sku.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Currently Loaded Stock',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(
              hint: 'Search products by name or SKU',
              icon: Icons.search_rounded,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = index == 0 ? 'All' : categories[index - 1];
                final selected = category == _category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = category),
                  visualDensity: VisualDensity.compact,
                  selectedColor: AppColors.deliveryGreen,
                  backgroundColor: const Color(0xFFF4F7F5),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const _EmptyItems()
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SessionProductRow(
                  item: item,
                ),
              ),
        ],
      ),
    );
  }
}

class _SessionProductRow extends StatelessWidget {
  const _SessionProductRow({required this.item});
  final _StockItem item;

  @override
  Widget build(BuildContext context) {
    final availabilityColor = item.remaining <= 0
        ? AppColors.deliveryRed
        : item.delivered > 0
        ? AppColors.deliveryOrange
        : AppColors.deliveryGreen;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Row(
        children: [
          _ProductAvatar(product: item.product),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: availabilityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.product.meta,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TinyProductMetric(
                        label: 'Loaded',
                        value: _quantity(item.loaded),
                      ),
                    ),
                    Expanded(
                      child: _TinyProductMetric(
                        label: 'Extra',
                        value: _quantity(item.extra),
                        color: AppColors.deliveryBlue,
                      ),
                    ),
                    Expanded(
                      child: _TinyProductMetric(
                        label: 'Delivered',
                        value: _quantity(item.delivered),
                      ),
                    ),
                    Expanded(
                      child: _TinyProductMetric(
                        label: 'Remaining',
                        value: _quantity(item.remaining),
                        color: item.remaining <= 0
                            ? AppColors.deliveryRed
                            : AppColors.deliveryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyProductMetric extends StatelessWidget {
  const _TinyProductMetric({
    required this.label,
    required this.value,
    this.color = AppColors.deliveryGreen,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

// ignore: unused_element
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProductAvatar(product: item.product),
          const SizedBox(width: 10),
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
                    height: 1.15,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            height: 38,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              item.product.unitLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
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

class _ActiveBottomActions extends StatelessWidget {
  const _ActiveBottomActions({
    required this.busy,
    required this.onAddLoad,
    required this.onCloseToday,
  });
  final bool busy;
  final VoidCallback onAddLoad;
  final VoidCallback onCloseToday;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.deliverySurfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: busy ? null : onAddLoad,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                foregroundColor: AppColors.deliveryGreen,
                side: const BorderSide(color: AppColors.deliveryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add New Load'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: busy ? null : onCloseToday,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: AppColors.deliveryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(busy ? 'Please wait...' : 'Close Today'),
            ),
          ),
        ],
      ),
    ),
  );
}

enum _AdjustmentMode { add, close }

class _StockAdjustmentSheet extends StatefulWidget {
  const _StockAdjustmentSheet({
    required this.title,
    required this.actionLabel,
    required this.products,
    required this.mode,
    this.stockItems = const [],
  });
  final String title;
  final String actionLabel;
  final List<_LoadingProduct> products;
  final List<_StockItem> stockItems;
  final _AdjustmentMode mode;

  @override
  State<_StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends State<_StockAdjustmentSheet> {
  final _search = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  String _category = 'All';

  @override
  void dispose() {
    _search.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final categories =
        widget.products
            .map((product) => product.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final products = widget.products.where((product) {
      final matchesCategory =
          _category == 'All' || product.category == _category;
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deliveryInk,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(
                  hint: 'Search products by name or SKU',
                  icon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = index == 0 ? 'All' : categories[index - 1];
                    final selected = category == _category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      visualDensity: VisualDensity.compact,
                      selectedColor: AppColors.deliveryGreen,
                      backgroundColor: const Color(0xFFF4F7F5),
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final stock = widget.stockItems.where(
                      (item) => item.product.id == product.id,
                    );
                    final stockItem = stock.isEmpty ? null : stock.first;
                    final controller = _controllers.putIfAbsent(
                      product.id,
                      () => TextEditingController(),
                    );
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.deliverySurfaceBorder,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _ProductAvatar(product: product),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (stockItem != null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _TinyProductMetric(
                                          label: 'Ordered',
                                          value: _quantity(stockItem.ordered),
                                        ),
                                      ),
                                      Expanded(
                                        child: _TinyProductMetric(
                                          label: 'Loaded',
                                          value: _quantity(stockItem.loaded),
                                        ),
                                      ),
                                      Expanded(
                                        child: _TinyProductMetric(
                                          label: 'Delivered',
                                          value: _quantity(stockItem.delivered),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: widget.mode == _AdjustmentMode.close
                                    ? 'Returned'
                                    : 'Add',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop({
                    for (final entry in _controllers.entries)
                      entry.key: int.tryParse(entry.value.text.trim()) ?? 0,
                  }),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deliveryGreen,
                  ),
                  child: Text(widget.actionLabel),
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.deliveryGreen.withValues(alpha: 0.28),
            ),
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
              padding: const EdgeInsets.all(12),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
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
                            : const Icon(
                                Icons.local_shipping_outlined,
                                size: 22,
                              ),
                        label: Text(
                          isSubmitting
                              ? 'Submitting...'
                              : 'Submit Loaded Stock',
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

  const _SummaryStat({required this.label, required this.value});

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
              fontSize: 14,
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
                    fontSize: 16,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
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
            children: [_FieldLabel(label), const SizedBox(height: 8), child],
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
        fontSize: 14,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null)
                Icon(trailing, color: const Color(0xFF303746)),
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
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

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
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ?trailing,
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
    final imageBytes = productImageBytes(imageUrl);
    final fallback = Icon(
      product.fallbackIcon,
      color: const Color(0xFF39A04D),
      size: 30,
    );
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2EDE6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? fallback
          : imageBytes != null
          ? Image.memory(
              imageBytes,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            )
          : Image.network(
              imageUrl,
              headers: _productImageHeaders(imageUrl),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

Map<String, String>? _productImageHeaders(String imageUrl) {
  final imageUri = Uri.tryParse(imageUrl);
  final apiUri = Uri.tryParse(ApiConstants.baseUrl);
  final token = ApiService.accessToken?.trim() ?? '';
  if (imageUri == null ||
      apiUri == null ||
      token.isEmpty ||
      imageUri.scheme != apiUri.scheme ||
      imageUri.host != apiUri.host ||
      imageUri.port != apiUri.port) {
    return null;
  }
  return {
    ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix} $token',
  };
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
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoPlannedDeliveries extends StatelessWidget {
  const _NoPlannedDeliveries();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No picked deliveries are ready to load.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
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
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({required String hint, IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: const Color(0xFF718096)),
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

class _CompactStatusPill extends StatelessWidget {
  const _CompactStatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final closed = const {
      'closed',
      'completed',
      'reconciled',
    }.contains(status.toLowerCase());
    final color = closed ? AppColors.deliveryRed : AppColors.deliveryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        closed ? 'Closed' : 'Active',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StockSession {
  const _StockSession({
    required this.id,
    required this.vehicleNumber,
    required this.status,
    required this.date,
    required this.items,
    required this.orderUnits,
  });
  final String id;
  final String vehicleNumber;
  final String status;
  final DateTime? date;
  final List<_StockItem> items;
  final double orderUnits;

  factory _StockSession.fromJson(
    Map<String, dynamic> json,
    List<_LoadingProduct> products,
  ) {
    final nested = _readMap(json, const [
      'session',
      'vehicle_stock',
      'vehicleStock',
      'data',
    ]);
    final source = nested.isEmpty
        ? json
        : <String, dynamic>{...json, ...nested};
    final vehicle = _readMap(source, const ['vehicle']);
    final rows = _readList(source, const [
      'items',
      'stock_items',
      'stockItems',
      'loaded_items',
      'loadedItems',
      'products',
    ]);
    final items = rows
        .map((row) => _StockItem.fromJson(row, products))
        .toList();
    final explicitOrderUnits = _readDouble(source, const [
      'order_units',
      'orderUnits',
      'ordered_quantity',
      'orderedQuantity',
      'total_ordered',
      'totalOrdered',
    ]);
    return _StockSession(
      id: _readString(source, const ['id', '_id', 'session_id', 'sessionId']),
      vehicleNumber: _firstNonEmpty([
        _readString(source, const ['vehicle_number', 'vehicleNumber']),
        _readString(vehicle, const [
          'number',
          'vehicle_number',
          'vehicleNumber',
        ]),
      ]),
      status: _readString(source, const [
        'status',
        'session_status',
        'sessionStatus',
      ], fallback: 'active'),
      date: DateTime.tryParse(
        _readString(source, const [
          'date',
          'session_date',
          'sessionDate',
          'loading_date',
          'loadingDate',
        ]),
      ),
      items: items,
      orderUnits: explicitOrderUnits > 0
          ? explicitOrderUnits
          : items.fold(0, (sum, item) => sum + item.ordered),
    );
  }

  bool get isClosed => const {
    'closed',
    'completed',
    'reconciled',
  }.contains(status.toLowerCase());
  double get totalOrdered => orderUnits;
  double get totalLoaded =>
      items.fold(0, (sum, item) => sum + item.loaded + item.extra);
  double get totalDelivered =>
      items.fold(0, (sum, item) => sum + item.delivered);
  double get totalReturned => items.fold(0, (sum, item) => sum + item.returned);
  double get totalRemaining =>
      items.fold(0, (sum, item) => sum + item.remaining);

  _StockSession closedWithReturns(Map<String, int> returns) => _StockSession(
    id: id,
    vehicleNumber: vehicleNumber,
    status: 'closed',
    date: date,
    orderUnits: orderUnits,
    items: items
        .map(
          (item) => item.copyWith(
            returned: (returns[item.product.id] ?? 0).toDouble(),
          ),
        )
        .toList(),
  );
}

class _StockItem {
  const _StockItem({
    required this.product,
    required this.ordered,
    required this.loaded,
    required this.extra,
    required this.delivered,
    required this.returned,
    required this.remaining,
  });
  final _LoadingProduct product;
  final double ordered;
  final double loaded;
  final double extra;
  final double delivered;
  final double returned;
  final double remaining;

  factory _StockItem.fromJson(
    Map<String, dynamic> json,
    List<_LoadingProduct> products,
  ) {
    final embedded = _LoadingProduct.fromJson(json);
    final matching = products.where((product) => product.id == embedded.id);
    final product = matching.isEmpty ? embedded : matching.first;
    final loaded = _readDouble(json, const [
      'loaded_quantity',
      'loadedQuantity',
      'loaded_qty',
      'loaded',
      'quantity',
    ]);
    final delivered = _readDouble(json, const [
      'delivered_quantity',
      'deliveredQuantity',
      'delivered_qty',
      'delivered',
      'sold_quantity',
    ]);
    final extra = _readDouble(json, const [
      'extra_quantity',
      'extraQuantity',
      'extra_qty',
      'extra',
    ]);
    final returned = _readDouble(json, const [
      'returned_quantity',
      'returnedQuantity',
      'returned_qty',
      'returned',
    ]);
    final remainingValue = _readNullableDouble(json, const [
      'expected_closing_quantity',
      'expectedClosingQuantity',
      'expected_closing_qty',
      'remaining_quantity',
      'remainingQuantity',
      'remaining_qty',
      'remaining',
      'balance_quantity',
    ]);
    return _StockItem(
      product: product,
      ordered: _readDouble(json, const [
        'ordered_quantity',
        'orderedQuantity',
        'ordered_qty',
        'order_qty',
        'ordered',
      ]),
      loaded: loaded,
      extra: extra,
      delivered: delivered,
      returned: returned,
      remaining: remainingValue ?? (loaded + extra - delivered - returned),
    );
  }

  _StockItem copyWith({double? returned}) => _StockItem(
    product: product,
    ordered: ordered,
    loaded: loaded,
    extra: extra,
    delivered: delivered,
    returned: returned ?? this.returned,
    remaining: loaded + extra - delivered - (returned ?? this.returned),
  );
}

class _LoadableDelivery {
  const _LoadableDelivery({
    required this.id,
    required this.status,
    required this.items,
  });

  final String id;
  final String status;
  final List<_LoadableDeliveryItem> items;

  factory _LoadableDelivery.fromJson(Map<String, dynamic> json) {
    final status = _readString(json, const [
      'internal_status',
      'internalStatus',
      'status',
    ]).toLowerCase();
    const completedStatuses = {
      'cancelled',
      'canceled',
      'rejected',
      'delivered',
      'completed',
      'closed',
    };
    final items = completedStatuses.contains(status)
        ? const <_LoadableDeliveryItem>[]
        : _readList(json, const ['items', 'delivery_items', 'deliveryItems'])
              .map(_LoadableDeliveryItem.fromJson)
              .where(
                (item) => item.productId.isNotEmpty && item.remaining > 0,
              )
              .toList();
    return _LoadableDelivery(
      id: _readString(json, const ['id', '_id', 'delivery_id', 'deliveryId']),
      status: status,
      items: items,
    );
  }

  bool get needsReady => !const {
    'ready',
    'loaded',
    'in_transit',
  }.contains(status);
}

class _LoadableDeliveryItem {
  const _LoadableDeliveryItem({
    required this.productId,
    required this.remaining,
  });

  final String productId;
  final double remaining;

  factory _LoadableDeliveryItem.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product']);
    final productId = _firstNonEmpty([
      _readString(json, const ['product_id', 'productId']),
      _readString(product, const ['id', '_id', 'product_id', 'productId']),
    ]);
    final picked = _readDouble(json, const [
      'picked_quantity',
      'pickedQuantity',
      'picked_qty',
    ]);
    final loaded = _readDouble(json, const [
      'loaded_quantity',
      'loadedQuantity',
      'loaded_qty',
    ]);
    final remaining = picked - loaded;
    return _LoadableDeliveryItem(
      productId: productId,
      remaining: remaining > 0 ? remaining : 0,
    );
  }
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
    return _LoadingItem(product: product, quantity: quantity ?? this.quantity);
  }
}

class _LoadingProduct {
  final String id;
  final String variantId;
  final String name;
  final String sku;
  final String unit;
  final String packageSize;
  final String imageUrl;
  final String category;
  final double ordered;
  final double available;

  const _LoadingProduct({
    required this.id,
    required this.variantId,
    required this.name,
    required this.sku,
    required this.unit,
    required this.packageSize,
    required this.imageUrl,
    required this.category,
    required this.ordered,
    required this.available,
  });

  factory _LoadingProduct.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product']);
    final source = product.isEmpty
        ? json
        : <String, dynamic>{...json, ...product};
    return _LoadingProduct(
      id: _readString(source, const ['id', '_id', 'product_id', 'productId']),
      variantId: _firstNonEmpty([
        _readString(json, const ['variant_id', 'variantId']),
        _readString(source, const ['variant_id', 'variantId']),
        _readString(
          _readMap(json, const ['variant']),
          const ['id', '_id'],
        ),
      ]),
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
      imageUrl: productImageUrlFromJson(source) ?? '',
      category: _firstNonEmpty([
        _readString(source, const ['category_name', 'categoryName']),
        _readString(_readMap(source, const ['category']), const ['name']),
      ]),
      ordered: _readDouble(json, const [
        'ordered_quantity',
        'orderedQuantity',
        'ordered_qty',
        'order_qty',
        'ordered',
      ]),
      available: _readDouble(source, const [
        'available_quantity',
        'availableQuantity',
        'available_qty',
        'stock_quantity',
        'stock',
        'quantity',
      ]),
    );
  }

  _LoadingProduct copyWith({double? ordered}) => _LoadingProduct(
    id: id,
    variantId: variantId,
    name: name,
    sku: sku,
    unit: unit,
    packageSize: packageSize,
    imageUrl: imageUrl,
    category: category,
    ordered: ordered ?? this.ordered,
    available: available,
  );

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
    if (text.contains('rice') || text.contains('dal')) {
      return Icons.grass_rounded;
    }
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

Map<String, dynamic> _stockSource(Map<String, dynamic> json) {
  final nested = _readMap(json, const [
    'session',
    'vehicle_stock',
    'vehicleStock',
    'data',
  ]);
  return nested.isEmpty ? json : <String, dynamic>{...json, ...nested};
}

String _stockVehicleNumber(Map<String, dynamic> json) {
  final source = _stockSource(json);
  final vehicle = _readMap(source, const ['vehicle']);
  return _firstNonEmpty([
    _readString(source, const ['vehicle_number', 'vehicleNumber']),
    _readString(vehicle, const [
      'number',
      'vehicle_number',
      'vehicleNumber',
      'registration_number',
      'registrationNumber',
    ]),
  ]);
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

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }
  return const [];
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  return _readNullableDouble(json, keys) ?? 0;
}

double? _readNullableDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

String _quantity(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}

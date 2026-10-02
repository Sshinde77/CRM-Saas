import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../models/app_user.dart';
import '../../../models/auth_models.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../utils/product_image_url.dart';
import '../../../widgets/app_calendar_date_picker.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import '../../../widgets/delivery/customer_search_dialog.dart';
import '../../../widgets/delivery/delivery_partner_search_dialog.dart';
import '../customers/create_delivery_customer_screen.dart';

class CreateDeliveryOrderScreen extends StatefulWidget {
  final Widget? drawer;
  final bool assignDeliveryPartner;
  final VoidCallback? onCreated;

  const CreateDeliveryOrderScreen({
    super.key,
    this.drawer,
    this.assignDeliveryPartner = false,
    this.onCreated,
  });

  @override
  State<CreateDeliveryOrderScreen> createState() =>
      _CreateDeliveryOrderScreenState();
}

class _CreateDeliveryOrderScreenState extends State<CreateDeliveryOrderScreen> {
  static const _green = AppColors.deliveryGreen;
  static const _allWarehousesId = '__all_warehouses__';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _form = GlobalKey<FormState>();
  final _quantities = <String, int>{};
  final _priceInputs = <String, String>{};
  final _productScrollController = ScrollController();
  final _discount = TextEditingController(text: '0');
  List<CustomerModel> _customers = [];
  List<_OrderProduct> _products = [];
  List<Map<String, dynamic>> _warehouses = [];
  List<AppUser> _deliveryPartners = [];
  Map<String, double> _stockByProductId = {};
  CustomerModel? _customer;
  String? _selectedWarehouseId = _allWarehousesId;
  String? _selectedPartnerId;
  String _query = '', _category = 'All', _payment = 'Cash';
  bool _homeDelivery = false, _loading = true, _started = false;
  bool _stockLoading = false;
  bool _partnersLoading = false, _partnersLoaded = false;
  String? _partnersError;
  String? _stockError;
  final _loadErrors = <String, String>{};
  final _loaded = <String>{};
  DateTime _orderDate = DateUtils.dateOnly(DateTime.now());
  DateTime _deliveryDate = DateUtils.dateOnly(DateTime.now());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      // Customer loading notifies the shared provider.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadErrors.clear();
    });
    final api = ApiProviderScope.of(context);
    await Future.wait([
      _loadSection('Customers', () async {
        final customers = await api.fetchCustomers(isActive: true);
        if (mounted) setState(() => _customers = customers);
      }),
      _loadSection('Products', () async {
        final rows = await api.fetchProducts(isActive: true);
        final products = rows
            .map(_OrderProduct.fromJson)
            .where((p) => p.id.isNotEmpty)
            .toList();
        if (mounted) setState(() => _products = products);
      }),
      _loadSection('Warehouses', () async {
        final rows = await api.fetchWarehouses(isActive: true);
        final warehouses = rows
            .where(
              (w) =>
                  w['is_active'] == true &&
                  _text(w, ['id', 'warehouse_id']).isNotEmpty &&
                  _text(w, ['name', 'warehouse_name']).isNotEmpty,
            )
            .toList();
        if (mounted) {
          setState(() {
            _warehouses = warehouses;
            if (!warehouses.any(
              (w) => _text(w, ['id', 'warehouse_id']) == _selectedWarehouseId,
            )) {
              _selectedWarehouseId = _allWarehousesId;
            }
          });
        }
      }),
    ]);
    if (mounted) await _loadStockForWarehouse();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadStockForWarehouse() async {
    setState(() {
      _stockLoading = true;
      _stockError = null;
    });
    try {
      final selectedId = _selectedWarehouseId;
      final rows = await ApiProviderScope.of(context).fetchStockBoard(
        isActive: true,
        warehouseId: selectedId == _allWarehousesId ? null : selectedId,
      );
      final stockByProductId = <String, double>{};
      for (final row in rows) {
        final productId = _productIdFromStockRow(row);
        final stock = _stockFromRow(row);
        if (productId.isNotEmpty && stock != null) {
          stockByProductId[productId] = stock;
        }
      }
      if (mounted) {
        setState(() => _stockByProductId = stockByProductId);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _stockByProductId = {};
          _stockError = error is ApiException
              ? error.message
              : 'Could not load product availability.';
        });
      }
    } finally {
      if (mounted) setState(() => _stockLoading = false);
    }
  }

  Future<void> _loadDeliveryPartners({
    bool preserveSelectedPartner = false,
  }) async {
    if (_partnersLoading) return;
    setState(() {
      _partnersLoading = true;
      _partnersError = null;
    });
    try {
      final fetchedPartners = await ApiProviderScope.of(
        context,
      ).fetchDeliveryPartners().timeout(const Duration(seconds: 30));
      if (mounted) {
        setState(() {
          final partners = [...fetchedPartners];
          if (preserveSelectedPartner && _selectedPartnerId != null) {
            for (final partner in _deliveryPartners) {
              if (partner.id == _selectedPartnerId &&
                  !partners.any((option) => option.id == partner.id)) {
                partners.insert(0, partner);
                break;
              }
            }
          }
          _deliveryPartners = partners;
          _partnersLoaded = true;
          if (!partners.any((partner) => partner.id == _selectedPartnerId)) {
            _selectedPartnerId = null;
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _partnersError = error is ApiException
              ? error.message
              : 'Could not load delivery partners. Please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _partnersLoading = false);
    }
  }

  Future<void> _loadDeliveryPartnerChoices({required bool hasDefault}) async {
    if (!hasDefault) await _loadCurrentDeliveryPartner();
    if (mounted && _homeDelivery) {
      await _loadDeliveryPartners(preserveSelectedPartner: true);
    }
  }

  Future<void> _loadCurrentDeliveryPartner() async {
    if (_partnersLoading) return;
    setState(() {
      _partnersLoading = true;
      _partnersError = null;
    });
    try {
      final api = ApiProviderScope.of(context);
      var profile = api.currentUser ?? api.authMe?.user;
      if (profile == null) {
        try {
          profile = (await api.fetchAuthMe())?.user;
        } catch (_) {
          // The profile endpoint remains available when auth/me is unavailable.
        }
      }
      profile ??= await api.fetchCurrentUserProfile();
      final partner = _partnerFromProfile(profile);
      if (partner == null) {
        throw const ApiException(
          message: 'No delivery partner is associated with this account.',
        );
      }
      if (mounted) {
        setState(() {
          _deliveryPartners = [partner];
          _selectedPartnerId = partner.id;
          _partnersLoaded = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _partnersError = error is ApiException
              ? error.message
              : 'Could not load your delivery partner. Please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _partnersLoading = false);
    }
  }

  AppUser? _partnerFromProfile(CurrentUserProfile? profile) {
    final partnerId = (profile?.deliveryPartnerId ?? profile?.id)?.trim();
    if (partnerId == null || partnerId.isEmpty) return null;
    final partnerName = profile?.deliveryPartnerName ?? profile?.name ?? '';
    return AppUser(
      id: partnerId,
      name: partnerName.trim().isEmpty ? 'My delivery partner' : partnerName,
      email: profile?.email ?? '',
      role: 'delivery_partner',
    );
  }

  void _setHomeDelivery(bool value) {
    final api = ApiProviderScope.of(context);
    final cachedPartner = value && !widget.assignDeliveryPartner
        ? _partnerFromProfile(api.currentUser ?? api.authMe?.user)
        : null;
    setState(() {
      _homeDelivery = value;
      if (!value) _selectedPartnerId = null;
      if (cachedPartner != null) {
        _deliveryPartners = [cachedPartner];
        _selectedPartnerId = cachedPartner.id;
        _partnersLoaded = true;
      } else if (value && !widget.assignDeliveryPartner && _partnersLoaded) {
        _selectedPartnerId = _deliveryPartners.firstOrNull?.id;
      }
    });
    if (value) {
      if (widget.assignDeliveryPartner) {
        _loadDeliveryPartners();
      } else {
        _loadDeliveryPartnerChoices(hasDefault: cachedPartner != null);
      }
    }
  }

  Future<void> _loadSection(String name, Future<void> Function() fetch) async {
    if (_loaded.contains(name)) return;
    try {
      await fetch().timeout(const Duration(seconds: 30));
      if (mounted) setState(() => _loaded.add(name));
    } catch (error) {
      final detail = switch (error) {
        ApiException(statusCode: 403, message: final message)
            when message.toLowerCase().contains('not authenticated') =>
          'Please sign in again.',
        ApiException(statusCode: 403, message: final message) =>
          message.trim().toLowerCase() == 'forbidden'
              ? 'The API denied access (403).'
              : message,
        ApiException(statusCode: 401) => 'Please sign in again.',
        ApiException(:final message) => message,
        TimeoutException() => 'The request timed out.',
        _ => 'Could not load. Please retry.',
      };
      final reason =
          name == 'Warehouses' &&
              error is ApiException &&
              error.statusCode != null
          ? 'HTTP ${error.statusCode}: $detail'
          : detail;
      if (mounted) {
        setState(() => _loadErrors[name] = reason);
      }
    }
  }

  @override
  void dispose() {
    _productScrollController.dispose();
    _discount.dispose();
    super.dispose();
  }

  List<_OrderProduct> get _selected =>
      _products.where((p) => (_quantities[p.id] ?? 0) > 0).toList();
  double _unitPrice(_OrderProduct product) {
    final price = _priceInputs.containsKey(product.id)
        ? double.tryParse(_priceInputs[product.id]!)
        : product.price;
    return price != null && price.isFinite && price >= 0 ? price : 0;
  }

  String? _priceError(String? text) {
    final price = double.tryParse(text?.trim() ?? "");
    return price == null || !price.isFinite || price < 0
        ? "Enter a valid amount"
        : null;
  }

  double get _subtotal => _selected.fold(
    0,
    (sum, p) => sum + _unitPrice(p) * (_quantities[p.id] ?? 0),
  );
  double get _discountValue =>
      (double.tryParse(_discount.text) ?? 0).clamp(0, _subtotal).toDouble();
  double get _tax => _customer?.taxExempt == true || _subtotal <= 0
      ? 0
      : _selected.fold<double>(
          0,
          (sum, product) =>
              sum +
              _unitPrice(product) *
                  (_quantities[product.id] ?? 0) *
                  (1 - _discountValue / _subtotal) *
                  product.taxRate /
                  100,
        );
  double get _total => _subtotal - _discountValue + _tax;
  String _money(double value) => _formatOrderMoney(value);
  String _warehouseLabel(Map<String, dynamic> warehouse) {
    final name = _text(warehouse, ['name', 'warehouse_name']);
    final code = _text(warehouse, ['code']);
    return code.isEmpty ? name : '$name ($code)';
  }

  Map<String, dynamic>? _selectedWarehouse() {
    final selectedId = _selectedWarehouseId;
    if (selectedId == null ||
        selectedId.trim().isEmpty ||
        selectedId == _allWarehousesId) {
      return null;
    }
    for (final warehouse in _warehouses) {
      if (_text(warehouse, ['id', 'warehouse_id']) == selectedId) {
        return warehouse;
      }
    }
    return null;
  }

  String _productIdFromStockRow(Map<String, dynamic> row) {
    final product = row['product'];
    final data = product is Map<String, dynamic> ? {...row, ...product} : row;
    return _text(data, ['product_id', 'productId', 'id', '_id']);
  }

  double? _stockFromRow(Map<String, dynamic> row) {
    final product = row['product'];
    final data = product is Map<String, dynamic> ? {...row, ...product} : row;
    return _OrderProduct.readStock(data);
  }

  double? _displayStockFor(_OrderProduct product) {
    if (_stockByProductId.containsKey(product.id)) {
      return _stockByProductId[product.id];
    }
    return product.stock;
  }

  String _availabilityLabel(double? stock) {
    if (_stockLoading) return 'Availability: Loading';
    if (stock == null) return 'Availability: Checked on order';
    if (stock <= 0) return 'Availability: 0';
    final quantity = stock == stock.truncateToDouble()
        ? stock.toStringAsFixed(0)
        : stock.toString();
    return 'Availability: $quantity';
  }

  Color _availabilityColor(double? stock) {
    if (_stockLoading || stock == null) return AppColors.textLightMuted;
    if (stock <= 0) return AppColors.red;
    if (stock <= 10) return Colors.deepOrange;
    return _green;
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.year}';

  Future<void> _pickDate(bool delivery) async {
    final date = await showAppCalendarDatePicker(
      context: context,
      initialDate: delivery ? _deliveryDate : _orderDate,
      firstDate: delivery ? _orderDate : DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 10),
      title: delivery ? 'Delivery Date' : 'Order Date',
    );
    if (date == null || !mounted) return;
    setState(() {
      if (delivery) {
        _deliveryDate = date;
      } else {
        _orderDate = date;
        if (_deliveryDate.isBefore(date)) _deliveryDate = date;
      }
    });
  }

  Future<void> _preview() async {
    final formState = _form.currentState;
    if (formState == null || !formState.validate()) return;

    final customer = _customer;
    final selectedItems = _selected;
    for (final product in selectedItems) {
      if (_priceError(_priceInputs[product.id] ?? product.price.toString()) !=
          null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter a valid amount for ${product.name}.')),
        );
        return;
      }
    }
    final selectedWarehouse = _selectedWarehouse();
    final selectedPartner = _deliveryPartners
        .where((partner) => partner.id == _selectedPartnerId)
        .firstOrNull;
    if (customer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a customer.')));
      return;
    }
    if (selectedWarehouse == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a warehouse.')));
      return;
    }
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product.')),
      );
      return;
    }
    if (_homeDelivery && selectedPartner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a delivery partner.')),
      );
      return;
    }
    final placed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _SalesOrderPreviewPage(
          customer: customer,
          warehouse: selectedWarehouse,
          items: [
            for (final product in selectedItems)
              _PreviewItem(
                product,
                _quantities[product.id]!,
                _unitPrice(product),
              ),
          ],
          orderDate: _orderDate,
          deliveryDate: _deliveryDate,
          discount: _discountValue,
          paymentType: _payment,
          homeDelivery: _homeDelivery,
          deliveryPartner: _homeDelivery ? selectedPartner : null,
          onOrderCreated: () {
            if (!mounted) return;
            setState(() {
              _quantities.clear();
              _priceInputs.clear();
              _discount.text = '0';
            });
          },
          onQuantityChanged: (id, quantity) => setState(() {
            _quantities[id] = quantity;
            final enteredDiscount = double.tryParse(_discount.text) ?? 0;
            if (enteredDiscount > _subtotal) {
              _discount.text = _subtotal.toStringAsFixed(2);
            }
          }),
        ),
      ),
    );
    if (placed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sales order created successfully.')),
      );
      widget.onCreated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = _customer;

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.drawer,
      backgroundColor: AppColors.deliveryBackground,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: _green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selected.length} items',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      _money(_total),
                      style: const TextStyle(
                        color: _green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed:
                    _loading || _loadErrors.isNotEmpty || _warehouses.isEmpty
                    ? null
                    : _preview,
                child: const Text(
                  'Preview Sales Order',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Create Order',
              subtitle: 'Build a delivery sales order',
              leadingIcon: widget.drawer == null
                  ? Icons.arrow_back_rounded
                  : Icons.menu_rounded,
              onLeadingTap: widget.drawer == null
                  ? () => Navigator.of(context).maybePop()
                  : () => _scaffoldKey.currentState?.openDrawer(),
              actions: widget.drawer == null
                  ? const []
                  : [
                      DeliveryTopBarAction(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _form,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: LinearProgressIndicator(color: _green),
                          ),
                        if (_loadErrors.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Some order details are unavailable',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                ..._loadErrors.entries.map(
                                  (e) => Text('${e.key}: ${e.value}'),
                                ),
                                TextButton(
                                  onPressed: _loading ? null : _load,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        _sectionSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Customer *'),
                              FormField<CustomerModel>(
                                initialValue: _customer,
                                validator: (value) =>
                                    value == null ? 'Select a customer' : null,
                                builder: (field) => InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap:
                                      _loading ||
                                          _loadErrors.containsKey('Customers')
                                      ? null
                                      : () async {
                                          final customer =
                                              await showDialog<CustomerModel>(
                                                context: context,
                                                builder: (_) =>
                                                    CustomerSearchDialog(
                                                      customers: _customers,
                                                      selectedCustomerId:
                                                          _customer?.id,
                                                      onCreateCustomer: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).push<CustomerModel>(
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const CreateDeliveryCustomerScreen(),
                                                            ),
                                                          ),
                                                    ),
                                              );
                                          if (!mounted || customer == null)
                                            return;
                                          setState(() {
                                            if (!_customers.any(
                                              (c) => c.id == customer.id,
                                            )) {
                                              _customers = [
                                                ..._customers,
                                                customer,
                                              ];
                                            }
                                            _customer = customer;
                                          });
                                          field.didChange(customer);
                                        },
                                  child: InputDecorator(
                                    decoration:
                                        _decoration(
                                          '',
                                          icon: Icons.storefront_outlined,
                                        ).copyWith(
                                          errorText: field.errorText,
                                          suffixIcon: const Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                        ),
                                    child: Text(
                                      _customer?.name ?? 'Select customer',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              if (selectedCustomer != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: _green,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          selectedCustomer.deliveryAddress ??
                                              selectedCustomer.address ??
                                              selectedCustomer.billingAddress ??
                                              'No address available',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textLightMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heading('Order Details'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _dateField(
                                      'Order Date',
                                      _orderDate,
                                      false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dateField(
                                      'Delivery Date *',
                                      _deliveryDate,
                                      true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _label('Warehouse *'),
                              DropdownButtonFormField<String>(
                                key: ObjectKey(_warehouses),
                                isExpanded: true,
                                initialValue: _selectedWarehouseId,
                                decoration:
                                    _decoration(
                                      !_loaded.contains('Warehouses') &&
                                              _loading
                                          ? 'Loading warehouses...'
                                          : _loadErrors.containsKey(
                                              'Warehouses',
                                            )
                                          ? 'Could not load warehouses'
                                          : _warehouses.isEmpty
                                          ? 'No warehouses available'
                                          : 'Select warehouse',
                                    ).copyWith(
                                      errorText: _loadErrors['Warehouses'],
                                    ),
                                items: [
                                  const DropdownMenuItem(
                                    value: _allWarehousesId,
                                    child: Text(
                                      'All warehouses',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ..._warehouses.map(
                                    (w) => DropdownMenuItem(
                                      value: _text(w, ['id', 'warehouse_id']),
                                      child: Text(
                                        _warehouseLabel(w),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: _warehouses.isEmpty
                                    ? null
                                    : (v) {
                                        setState(
                                          () => _selectedWarehouseId = v,
                                        );
                                        _loadStockForWarehouse();
                                      },
                                validator: (v) =>
                                    v == null ? 'Select a warehouse' : null,
                              ),
                              if (_loadErrors.containsKey('Warehouses'))
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _loading ? null : _load,
                                    child: const Text('Retry warehouses'),
                                  ),
                                ),
                              if (_stockError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _stockError!,
                                    style: const TextStyle(
                                      color: AppColors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heading('Add products'),
                              TextField(
                                decoration: _decoration(
                                  'Search products by name or SKU',
                                  icon: Icons.search,
                                ),
                                onChanged: (v) => setState(
                                  () => _query = v.toLowerCase().trim(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      [
                                            'All',
                                            ..._products
                                                .map((p) => p.category)
                                                .where(
                                                  (c) =>
                                                      c.isNotEmpty &&
                                                      c != 'All',
                                                )
                                                .toSet(),
                                          ]
                                          .map(
                                            (c) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: ChoiceChip(
                                                label: Text(c),
                                                selected: _category == c,
                                                showCheckmark: false,
                                                selectedColor: _green,
                                                side: BorderSide(
                                                  color: _category == c
                                                      ? _green
                                                      : AppColors.border,
                                                  width: 0.7,
                                                ),
                                                labelStyle: TextStyle(
                                                  color: _category == c
                                                      ? Colors.white
                                                      : AppColors
                                                            .textLightMuted,
                                                ),
                                                onSelected: (_) => setState(
                                                  () => _category = c,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._productList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heading('Delivery Method'),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _choice(
                                        'Takeaway / Self Pickup',
                                        'Customer will collect the order.',
                                        Icons.storefront_outlined,
                                        !_homeDelivery,
                                        () => _setHomeDelivery(false),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _choice(
                                        'Home Delivery',
                                        'Deliver the order to the customer address.',
                                        Icons.local_shipping_outlined,
                                        _homeDelivery,
                                        () => _setHomeDelivery(true),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_homeDelivery) ...[
                                const SizedBox(height: 12),
                                _label('Delivery Partner *'),
                                FormField<String>(
                                  key: ValueKey(
                                    _selectedPartnerId ?? 'no-partner',
                                  ),
                                  initialValue: _selectedPartnerId,
                                  validator: (value) => value == null
                                      ? 'Select a delivery partner'
                                      : null,
                                  builder: (field) {
                                    final selectedPartner = _deliveryPartners
                                        .where(
                                          (partner) =>
                                              partner.id == _selectedPartnerId,
                                        )
                                        .firstOrNull;
                                    final disabled =
                                        _partnersLoading ||
                                        _deliveryPartners.isEmpty ||
                                        _partnersError != null;
                                    final label = _partnersLoading
                                        ? 'Loading delivery partners...'
                                        : _partnersError != null
                                        ? 'Could not load delivery partners'
                                        : _deliveryPartners.isEmpty
                                        ? 'No delivery partners available'
                                        : selectedPartner?.name ??
                                              'Select delivery partner';

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: disabled
                                          ? null
                                          : () async {
                                              final partner =
                                                  await showDialog<AppUser>(
                                                    context: context,
                                                    builder: (_) =>
                                                        DeliveryPartnerSearchDialog(
                                                          partners:
                                                              _deliveryPartners,
                                                          selectedPartnerId:
                                                              _selectedPartnerId,
                                                        ),
                                                  );
                                              if (!mounted || partner == null)
                                                return;
                                              setState(
                                                () => _selectedPartnerId =
                                                    partner.id,
                                              );
                                              field.didChange(partner.id);
                                            },
                                      child: InputDecorator(
                                        decoration:
                                            _decoration(
                                              '',
                                              icon: Icons
                                                  .delivery_dining_outlined,
                                            ).copyWith(
                                              errorText: field.errorText,
                                              suffixIcon: const Icon(
                                                Icons.keyboard_arrow_down,
                                              ),
                                            ),
                                        child: Text(
                                          label,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                selectedPartner == null &&
                                                    !_partnersLoading
                                                ? AppColors.textLightMuted
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_partnersError != null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _partnersError!,
                                          style: const TextStyle(
                                            color: AppColors.deliveryRed,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _partnersLoading
                                            ? null
                                            : () => _loadDeliveryPartners(
                                                preserveSelectedPartner: !widget
                                                    .assignDeliveryPartner,
                                              ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heading('Payment Type *'),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  const spacing = 8.0;
                                  final itemWidth =
                                      (constraints.maxWidth - spacing) / 2;

                                  return Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children:
                                        [
                                              'Cash',
                                              'Phone Pe',
                                              'Other',
                                              'Google Pay',
                                            ]
                                            .map(
                                              (p) => SizedBox(
                                                width: itemWidth,
                                                child: ChoiceChip(
                                                  avatar: Icon(
                                                    _payment == p
                                                        ? Icons
                                                              .radio_button_checked
                                                        : Icons
                                                              .radio_button_off,
                                                    color: _green,
                                                    size: 18,
                                                  ),
                                                  label: Text(p),
                                                  labelStyle: TextStyle(
                                                    color: _payment == p
                                                        ? AppColors.primary
                                                        : AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  selected: _payment == p,
                                                  showCheckmark: false,
                                                  selectedColor: _green
                                                      .withValues(alpha: 0.12),
                                                  side: BorderSide(
                                                    color: _payment == p
                                                        ? _green
                                                        : AppColors.border,
                                                    width: 0.7,
                                                  ),
                                                  onSelected: (_) => setState(
                                                    () => _payment = p,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heading('Order Summary'),
                              _summary(),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Text(
                                        'Discount',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _discount,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: _decoration('0').copyWith(
                                        prefixText: '₹ ',
                                        prefixStyle: const TextStyle(
                                          color: _green,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                      validator: (v) {
                                        final amount = double.tryParse(v ?? '');
                                        return amount == null ||
                                                !amount.isFinite ||
                                                amount < 0 ||
                                                amount > _subtotal
                                            ? 'Enter 0–${_subtotal.toStringAsFixed(2)}'
                                            : null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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

  List<Widget> _productList() {
    final visible = _products
        .where(
          (p) =>
              (_category == 'All' || _category == p.category) &&
              '${p.name} ${p.sku}'.toLowerCase().contains(_query),
        )
        .toList();
    if (visible.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('No products found.', textAlign: TextAlign.center),
        ),
      ];
    }
    final cards = visible.map<Widget>((p) {
      final quantity = _quantities[p.id] ?? 0;
      final displayStock = _displayStockFor(p);
      return Container(
        key: ValueKey('order-product-${p.id}'),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: quantity > 0
              ? _green.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: quantity > 0 ? _green : AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: p.image.isEmpty
                  ? const Icon(
                      Icons.inventory_2_outlined,
                      color: _green,
                      size: 40,
                    )
                  : Image.network(
                      p.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.inventory_2_outlined, color: _green),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (p.sku.isNotEmpty)
                    Text(
                      'SKU: ${p.sku}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLightMuted,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Text(
                    _availabilityLabel(displayStock),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _availabilityColor(displayStock),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: _money(_unitPrice(p)),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' / ${p.unit}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quantity > 0)
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      key: ValueKey('order-price-${p.id}'),
                      initialValue:
                          _priceInputs[p.id] ?? p.price.toStringAsFixed(2),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '\u20b9 ',
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                        errorMaxLines: 2,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: _priceError,
                      onChanged: (value) =>
                          setState(() => _priceInputs[p.id] = value),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Remove one ${p.name}',
                      visualDensity: VisualDensity.compact,
                      onPressed: quantity == 0
                          ? null
                          : () => setState(
                              () => _quantities[p.id] = quantity - 1,
                            ),
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      tooltip: 'Add one ${p.name}',
                      visualDensity: VisualDensity.compact,
                      color: _green,
                      onPressed: () =>
                          setState(() => _quantities[p.id] = quantity + 1),
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
    final content = <Widget>[
      if (visible.length > 5)
        SizedBox(
          height: (MediaQuery.sizeOf(context).height * 0.65).clamp(240, 460),
          child: Scrollbar(
            controller: _productScrollController,
            thumbVisibility: true,
            child: ListView.builder(
              key: const ValueKey('order-product-list'),
              controller: _productScrollController,
              primary: false,
              padding: EdgeInsets.zero,
              itemCount: cards.length,
              itemBuilder: (_, index) => cards[index],
            ),
          ),
        )
      else
        ...cards,
    ];
    return content;
  }

  Widget _summary() => Column(
    children: [
      if (_selected.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Add products to see your order summary.'),
        ),
      _totalRow('Subtotal', _money(_subtotal)),
      _totalRow('Tax', _taxPercentageLabel),
      _totalRow('Total', _money(_total), bold: true),
    ],
  );

  String get _taxPercentageLabel {
    if (_customer?.taxExempt == true || _subtotal <= 0) return '0%';
    final taxableAmount = _subtotal - _discountValue;
    if (taxableAmount <= 0) return '0%';
    final percentage = _tax / taxableAmount * 100;
    return percentage == percentage.roundToDouble()
        ? '${percentage.toStringAsFixed(0)}%'
        : '${percentage.toStringAsFixed(2)}%';
  }

  Widget _totalRow(String title, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: bold ? _green : null,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
  Widget _sectionSurface({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.deliveryDashboardHeaderEnd,
      ),
    ),
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
  Widget _dateField(String title, DateTime date, bool delivery) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(title),
      InkWell(
        onTap: () => _pickDate(delivery),
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: _decoration('').copyWith(
            suffixIcon: const Icon(Icons.calendar_month_outlined, size: 18),
          ),
          child: Text(_date(date), style: const TextStyle(fontSize: 14)),
        ),
      ),
    ],
  );
  Widget _choice(
    String title,
    String subtitle,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) => Material(
    color: selected ? _green.withValues(alpha: 0.06) : AppColors.surface,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _green : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 16,
                  color: _green,
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 20, color: _green),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  InputDecoration _decoration(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14),
    prefixIcon: icon == null ? null : Icon(icon, color: _green, size: 20),
    filled: true,
    fillColor: AppColors.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _green),
    ),
  );
}

String _formatOrderMoney(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  var whole = parts.first;
  if (whole.length > 3) {
    final lastThree = whole.substring(whole.length - 3);
    whole = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (whole.length > 2) {
      groups.insert(0, whole.substring(whole.length - 2));
      whole = whole.substring(0, whole.length - 2);
    }
    if (whole.isNotEmpty) groups.insert(0, whole);
    whole = '${groups.join(',')},$lastThree';
  }
  return '${value < 0 ? '− ' : ''}₹ $whole.${parts.last}';
}

class _PreviewItem {
  final _OrderProduct product;
  int quantity;

  final double unitPrice;

  _PreviewItem(this.product, this.quantity, this.unitPrice);
}

class _SalesOrderPreviewPage extends StatefulWidget {
  final CustomerModel customer;
  final Map<String, dynamic> warehouse;
  final List<_PreviewItem> items;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final double discount;
  final String paymentType;
  final bool homeDelivery;
  final AppUser? deliveryPartner;
  final VoidCallback onOrderCreated;
  final void Function(String id, int quantity) onQuantityChanged;

  const _SalesOrderPreviewPage({
    required this.customer,
    required this.warehouse,
    required this.items,
    required this.orderDate,
    required this.deliveryDate,
    required this.discount,
    required this.paymentType,
    required this.homeDelivery,
    required this.deliveryPartner,
    required this.onOrderCreated,
    required this.onQuantityChanged,
  });

  @override
  State<_SalesOrderPreviewPage> createState() => _SalesOrderPreviewPageState();
}

class _SalesOrderPreviewPageState extends State<_SalesOrderPreviewPage> {
  static const _green = AppColors.deliveryGreen;
  static const _header = AppColors.deliveryDashboardHeaderEnd;
  static const _red = AppColors.deliveryRed;
  final _paidController = TextEditingController(text: '0');
  final _previewScrollController = ScrollController();
  bool _submitting = false;
  String? _error;
  String? _createdOrderId;
  List<String> _stockShortages = [];

  List<_PreviewItem> get _items =>
      widget.items.where((item) => item.quantity > 0).toList();
  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);
  double get _discount => widget.discount.clamp(0, _subtotal).toDouble();
  double get _tax => widget.customer.taxExempt == true || _subtotal <= 0
      ? 0
      : _items.fold<double>(
          0,
          (sum, item) =>
              sum +
              item.unitPrice *
                  item.quantity *
                  (1 - _discount / _subtotal) *
                  item.product.taxRate /
                  100,
        );
  double get _total => _subtotal - _discount + _tax;
  double get _previousBalance => (widget.customer.outstanding ?? 0).toDouble();
  double get _grandTotal => _total + _previousBalance;
  double? get _paid => double.tryParse(_paidController.text.trim());
  String get _submitLabel {
    if (_submitting) {
      return _createdOrderId == null
          ? 'Creating Order...'
          : 'Assigning Partner...';
    }
    if (_createdOrderId == null) return 'Create Order';
    return _createdOrderId!.isEmpty ? 'Order Created' : 'Retry Assignment';
  }

  String _money(double value) => _formatOrderMoney(value);
  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.year}';
  String _apiDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _paidController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  void _setQuantity(_PreviewItem item, int quantity) {
    if (_createdOrderId != null) return;
    setState(() {
      item.quantity = quantity;
      _error = null;
      _stockShortages = [];
    });
    widget.onQuantityChanged(item.product.id, quantity);
  }

  Future<void> _createOrder() async {
    if (_items.isEmpty || _submitting) return;
    final paid = _paid;
    if (_createdOrderId == null &&
        (paid == null || !paid.isFinite || paid < 0 || paid > _grandTotal)) {
      setState(
        () => _error =
            'Enter a payment between ₹ 0.00 and ${_money(_grandTotal)}.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _stockShortages = [];
    });
    try {
      final api = ApiProviderScope.of(context);
      if (_createdOrderId == null) {
        final response = await api.createOrder(
          request: {
            'customer_id': widget.customer.id,
            'warehouse_id': _text(widget.warehouse, ['id', 'warehouse_id']),
            'order_date': _apiDate(widget.orderDate),
            'delivery_date': _apiDate(widget.deliveryDate),
            'fulfilment_method': widget.homeDelivery
                ? 'home_delivery'
                : 'self_pickup',
            'payment_type': widget.paymentType,
            'items': [
              for (final item in _items)
                {
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                  'unit_price': item.unitPrice,
                  'tax_rate': widget.customer.taxExempt == true
                      ? 0
                      : item.product.taxRate,
                },
            ],
            'discount': _discount,
            'paid_amount': paid,
          },
        );
        widget.onOrderCreated();
        if (widget.deliveryPartner != null) {
          _createdOrderId = _orderId(response);
          if (_createdOrderId!.isEmpty) {
            throw const ApiException(
              message: 'The server did not return an order ID.',
            );
          }
        }
      }
      if (widget.deliveryPartner != null) {
        await api.assignOrderDeliveryPartner(
          orderId: _createdOrderId!,
          deliveryPartnerId: widget.deliveryPartner!.id,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        final shortages = _createdOrderId == null && error is ApiException
            ? _parseStockShortages(error.message)
            : <String>[];
        setState(() {
          _stockShortages = shortages;
          _error = _createdOrderId != null
              ? _createdOrderId!.isEmpty
                    ? 'Order created, but the server did not return an ID to assign the delivery partner.'
                    : 'Order created, but the delivery partner could not be assigned. Try the assignment again. ${error is ApiException ? _readOrderError(error.message) : ''}'
              : shortages.isNotEmpty
              ? 'Not enough stock in ${_text(widget.warehouse, ['name', 'warehouse_name'])} to create this order.'
              : error is ApiException
              ? _readOrderError(error.message)
              : 'Could not create the order. Please try again.';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _previewScrollController.hasClients) {
            _previewScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _orderId(Map<String, dynamic> response) {
    for (final source in [
      response,
      response['order'],
      response['sales_order'],
      response['data'],
    ]) {
      if (source is Map<String, dynamic>) {
        final id = _text(source, ['id', '_id', 'order_id', 'orderId']);
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }

  dynamic _errorDetail(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) return decoded['detail'] ?? decoded;
      return decoded;
    } on FormatException {
      return message;
    }
  }

  List<String> _parseStockShortages(String message) {
    final detail = _errorDetail(message);
    if (detail is! Map || detail['error'] != 'INSUFFICIENT_STOCK') {
      return [];
    }
    final rows = detail['shortages'];
    if (rows is! List || rows.isEmpty) {
      return ['One or more selected products are out of stock.'];
    }
    return rows.whereType<Map>().map((row) {
      final id = row['product_id']?.toString();
      final product = _items.where((item) => item.product.id == id).firstOrNull;
      final name = row['product_name']?.toString().trim();
      final label = name != null && name.isNotEmpty
          ? name
          : product?.product.name ?? 'Product';
      final available = row['available_quantity']?.toString() ?? '0';
      final required = row['required_quantity']?.toString() ?? '1';
      return '$label: $available available, $required needed.';
    }).toList();
  }

  String _readOrderError(String message) {
    final detail = _errorDetail(message);
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    if (detail is Map) {
      for (final key in const ['message', 'error']) {
        final value = detail[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.replaceAll('_', ' ');
        }
      }
    }
    return 'Could not create the order. Please check the details and try again.';
  }

  Widget _errorCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.deliveryRedSoft,
      border: Border.all(color: AppColors.statusInactiveBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: _red),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _error!,
                style: const TextStyle(
                  color: _red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final shortage in _stockShortages)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    shortage,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              if (_stockShortages.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text(
                  'Remove the unavailable product or ask your team to add stock.',
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Edit'),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final address =
        widget.customer.deliveryAddress ??
        widget.customer.address ??
        widget.customer.billingAddress;
    final warehouseName = _text(widget.warehouse, ['name', 'warehouse_name']);
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  _items.isEmpty ||
                      _submitting ||
                      _stockShortages.isNotEmpty ||
                      _createdOrderId == ''
                  ? null
                  : _createOrder,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.shopping_bag_outlined, size: 19),
              label: Text(_submitLabel),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Sales Order Preview',
              subtitle: 'Review order details before creating',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    controller: _previewScrollController,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      const Text(
                        'Draft Sales Order',
                        style: TextStyle(
                          color: _header,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _errorCard(),
                      ],
                      const SizedBox(height: 12),
                      _card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.deliveryGreenSoft,
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: _green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.customer.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (address != null && address.isNotEmpty)
                                    Text(
                                      address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  _summaryIcon(Icons.receipt_long_outlined),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Order Summary',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                                    style: const TextStyle(
                                      color: _green,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _productTable(),
                            const Divider(height: 24, color: AppColors.border),
                            _summaryRow(
                              'Subtotal',
                              _money(_subtotal),
                              icon: Icons.sell_outlined,
                            ),
                            _summaryRow(
                              'Tax',
                              _money(_tax),
                              icon: Icons.receipt_long_outlined,
                            ),
                            _summaryRow(
                              'Discount',
                              '− ${_money(_discount)}',
                              icon: Icons.percent_rounded,
                              color: _green,
                            ),
                            const Divider(height: 18, color: AppColors.border),
                            _summaryRow(
                              'Total',
                              _money(_total),
                              icon: Icons.account_balance_wallet_outlined,
                              strong: true,
                            ),
                            _summaryRow(
                              'Previous Balance',
                              '+ ${_money(_previousBalance)}',
                              icon: Icons.receipt_long_outlined,
                            ),
                            _summaryRow(
                              'Grand Total',
                              _money(_grandTotal),
                              icon: Icons.shopping_bag_outlined,
                              highlight: true,
                              color: AppColors.primary,
                              strong: true,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  _summaryIcon(Icons.payments_outlined),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Paid Amount',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: TextField(
                                      controller: _paidController,
                                      readOnly: _createdOrderId != null,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        prefixStyle: const TextStyle(
                                          color: _green,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 9,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: _green,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      onChanged: (_) =>
                                          setState(() => _error = null),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _summaryRow(
                              'Balance',
                              _money(_grandTotal - (_paid ?? 0)),
                              icon: Icons.account_balance_wallet_outlined,
                              color: _red,
                              strong: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          children: [
                            _detailRow('Order Date', _date(widget.orderDate)),
                            _detailRow(
                              'Delivery Date',
                              _date(widget.deliveryDate),
                            ),
                            _detailRow('Warehouse', warehouseName),
                            _detailRow('Payment Type', widget.paymentType),
                            _detailRow(
                              'Delivery Method',
                              widget.homeDelivery
                                  ? 'Home Delivery'
                                  : 'Takeaway / Self Pickup',
                            ),
                            _detailRow(
                              'Order Delivery By',
                              widget.deliveryPartner?.name ??
                                  (widget.homeDelivery
                                      ? 'Home Delivery'
                                      : 'Self Pickup'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _summaryIcon(IconData icon) => Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(
      color: AppColors.adminSidebarBg,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 20, color: AppColors.primary),
  );

  Widget _summaryRow(
    String label,
    String value, {
    required IconData icon,
    Color? color,
    bool strong = false,
    bool highlight = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: highlight ? AppColors.surfaceSoft : null,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        _summaryIcon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _detailRow(String label, String value, {Color? color}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border, width: 0.7)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _productTable() => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth < 500
        ? _compactProducts()
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < 360 ? 360 : constraints.maxWidth,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Product',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Unit Price',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  for (final item in _items) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 34,
                                  height: 38,
                                  child: item.product.image.isEmpty
                                      ? const Icon(
                                          Icons.inventory_2_outlined,
                                          color: _green,
                                        )
                                      : Image.network(
                                          item.product.image,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, error, stack) =>
                                              const Icon(
                                                Icons.inventory_2_outlined,
                                                color: _green,
                                              ),
                                        ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (item.product.sku.isNotEmpty)
                                        Text(
                                          'SKU: ${item.product.sku}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: _createdOrderId == null
                                      ? () => _setQuantity(
                                          item,
                                          item.quantity - 1,
                                        )
                                      : null,
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _createdOrderId == null
                                      ? () => _setQuantity(
                                          item,
                                          item.quantity + 1,
                                        )
                                      : null,
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: _green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _money(item.unitPrice),
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _money(item.unitPrice * item.quantity),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                  ],
                  if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No products selected. Go back to add products.',
                      ),
                    ),
                ],
              ),
            ),
          ),
  );

  Widget _compactProducts() => Column(
    children: [
      if (_items.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('No products selected. Go back to add products.'),
        ),
      for (final item in _items) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: item.product.image.isEmpty
                        ? const Icon(
                            Icons.inventory_2_outlined,
                            size: 22,
                            color: _green,
                          )
                        : Image.network(
                            item.product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (_, error, stack) => const Icon(
                              Icons.inventory_2_outlined,
                              size: 22,
                              color: _green,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (item.product.sku.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'SKU: ${item.product.sku}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          '${_money(item.unitPrice)} / ${item.product.unit}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _money(item.unitPrice * item.quantity),
                      style: const TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Remove one ${item.product.name}',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceSoft,
                      foregroundColor: AppColors.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: _createdOrderId == null
                        ? () => _setQuantity(item, item.quantity - 1)
                        : null,
                    icon: const Icon(Icons.remove, size: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add one ${item.product.name}',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.deliveryGreenSoft,
                      foregroundColor: _green,
                    ),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: _createdOrderId == null
                        ? () => _setQuantity(item, item.quantity + 1)
                        : null,
                    icon: const Icon(Icons.add, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    ],
  );
}

class _OrderProduct {
  final String id, name, sku, unit, category, image;
  final double price;
  final double taxRate;
  final double? stock;
  const _OrderProduct(
    this.id,
    this.name,
    this.sku,
    this.unit,
    this.category,
    this.image,
    this.price,
    this.stock,
    this.taxRate,
  );

  String get availabilityLabel {
    final available = stock;
    if (available == null) return 'Availability: Checked on order';
    if (available <= 0) return 'Availability: 0';
    final quantity = available == available.truncateToDouble()
        ? available.toStringAsFixed(0)
        : available.toString();
    return 'Availability: $quantity';
  }

  Color get availabilityColor {
    final available = stock;
    if (available == null) return AppColors.textLightMuted;
    if (available <= 0) return AppColors.red;
    if (available <= 10) return Colors.deepOrange;
    return AppColors.deliveryGreen;
  }

  factory _OrderProduct.fromJson(Map<String, dynamic> json) {
    final nested = json['product'];
    final data = nested is Map<String, dynamic> ? {...json, ...nested} : json;
    final category = data['category'];
    return _OrderProduct(
      _text(data, ['id', '_id', 'product_id']),
      _text(data, ['name', 'product_name', 'title']),
      _text(data, ['sku', 'SKU', 'product_sku']),
      _text(data, ['uom', 'unit', 'base_unit'], fallback: 'unit'),
      category is Map<String, dynamic>
          ? _text(category, ['name'])
          : _text(data, ['category_name', 'category']),
      productImageUrlFromJson(data) ?? '',
      double.tryParse(
            _text(data, [
              'selling_price',
              'price',
              'sellingPrice',
              'unit_price',
              'mrp',
            ]),
          ) ??
          0,
      readStock(data),
      readTaxRate(data),
    );
  }

  static double readTaxRate(Map<String, dynamic> data) {
    for (final key in const ['tax', 'tax_rate', 'taxRate', 'gst', 'gst_rate']) {
      final rate = double.tryParse(data[key]?.toString() ?? '');
      if (rate != null && rate.isFinite && rate >= 0) return rate;
    }
    return 0;
  }

  static double? readStock(Map<String, dynamic> data) {
    for (final key in const [
      'available_stock',
      'available_quantity',
      'stock_quantity',
      'stock',
      'current_stock',
      'currentStock',
      'inventory',
      'total_inventory',
      'totalInventory',
      'total_stock',
      'totalStock',
    ]) {
      final value = double.tryParse(data[key]?.toString() ?? '');
      if (value != null && value.isFinite) return value;
    }
    return null;
  }
}

String _text(
  Map<String, dynamic> data,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = data[key];
    if (value != null && value is! Map && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

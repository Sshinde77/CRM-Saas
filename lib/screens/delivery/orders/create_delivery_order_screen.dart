import 'dart:async';

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';

class CreateDeliveryOrderScreen extends StatefulWidget {
  const CreateDeliveryOrderScreen({super.key});

  @override
  State<CreateDeliveryOrderScreen> createState() =>
      _CreateDeliveryOrderScreenState();
}

class _CreateDeliveryOrderScreenState extends State<CreateDeliveryOrderScreen> {
  static const _green = AppColors.deliveryGreen;
  final _form = GlobalKey<FormState>();
  final _quantities = <String, int>{};
  final _discount = TextEditingController(text: '0');
  List<CustomerModel> _customers = [];
  List<_OrderProduct> _products = [];
  List<Map<String, dynamic>> _warehouses = [];
  CustomerModel? _customer;
  String? _warehouse;
  String _query = '', _category = 'All', _payment = 'Cash';
  bool _homeDelivery = false, _loading = true, _started = false;
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
        final rows = await api.fetchWarehouses();
        final warehouses = rows
            .where((w) => _text(w, ['id', 'warehouse_id']).isNotEmpty)
            .toList();
        if (mounted) setState(() => _warehouses = warehouses);
      }),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadSection(String name, Future<void> Function() fetch) async {
    if (_loaded.contains(name)) return;
    try {
      await fetch().timeout(const Duration(seconds: 30));
      if (mounted) setState(() => _loaded.add(name));
    } catch (error) {
      final reason = switch (error) {
        ApiException(statusCode: 403) => 'Your account does not have access.',
        ApiException(statusCode: 401) => 'Please sign in again.',
        TimeoutException() => 'The request timed out.',
        _ => 'Could not load. Please retry.',
      };
      if (mounted) {
        setState(() => _loadErrors[name] = reason);
      }
    }
  }

  @override
  void dispose() {
    _discount.dispose();
    super.dispose();
  }

  List<_OrderProduct> get _selected =>
      _products.where((p) => (_quantities[p.id] ?? 0) > 0).toList();
  double get _subtotal =>
      _selected.fold(0, (sum, p) => sum + p.price * _quantities[p.id]!);
  double get _discountValue =>
      (double.tryParse(_discount.text) ?? 0).clamp(0, _subtotal).toDouble();
  double get _total => _subtotal - _discountValue;
  String _money(double value) => '₹ ${value.toStringAsFixed(2)}';
  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.year}';

  Future<void> _pickDate(bool delivery) async {
    final date = await showDatePicker(
      context: context,
      initialDate: delivery ? _deliveryDate : _orderDate,
      firstDate: delivery ? _orderDate : DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 10),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: _green)),
        child: child!,
      ),
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
    if (!_form.currentState!.validate()) return;
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product.')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _heading('Sales Order Preview'),
              Text(
                _customer!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order: ${_date(_orderDate)}   •   Delivery: ${_date(_deliveryDate)}',
              ),
              const SizedBox(height: 6),
              Text(
                'Warehouse: ${_text(_warehouses.firstWhere((w) => _text(w, ['id', 'warehouse_id']) == _warehouse), ['name', 'warehouse_name'])}',
              ),
              const SizedBox(height: 6),
              Text(
                '${_homeDelivery ? 'Home Delivery' : 'Takeaway / Self Pickup'} • $_payment',
              ),
              const Divider(height: 28),
              _summary(),
              const SizedBox(height: 20),
              const Text(
                'Review your selections before continuing. This preview has not submitted an order.',
                style: TextStyle(color: AppColors.textLightMuted),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: _green),
                  child: const Text('Back to Edit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: AppColors.deliveryDashboardHeaderEnd,
        foregroundColor: AppColors.surface,
      ),
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
                      style: const TextStyle(fontSize: 12),
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
              Flexible(
                flex: 2,
                child: FilledButton(
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
                  onPressed: _loading || _loadErrors.isNotEmpty
                      ? null
                      : _preview,
                  child: const Text(
                    'Preview Sales Order',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
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
                _label('Customer *'),
                DropdownButtonFormField<CustomerModel>(
                  isExpanded: true,
                  initialValue: _customer,
                  decoration: _decoration(
                    'Select customer',
                    icon: Icons.storefront_outlined,
                  ),
                  items: _customers
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _customer = value),
                  validator: (value) =>
                      value == null ? 'Select a customer' : null,
                ),
                if (_customer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: _green,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _customer!.deliveryAddress ??
                                _customer!.address ??
                                _customer!.billingAddress ??
                                'No address available',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLightMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _heading('Order Details'),
                Row(
                  children: [
                    Expanded(
                      child: _dateField('Order Date', _orderDate, false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dateField('Delivery Date *', _deliveryDate, true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _label('Warehouse *'),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _warehouse,
                  decoration: _decoration('Select warehouse'),
                  items: _warehouses
                      .map(
                        (w) => DropdownMenuItem(
                          value: _text(w, ['id', 'warehouse_id']),
                          child: Text(
                            _text(w, ['name', 'warehouse_name']),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _warehouse = v),
                  validator: (v) => v == null ? 'Select a warehouse' : null,
                ),
                _heading('Add products'),
                TextField(
                  decoration: _decoration(
                    'Search products by name or SKU',
                    icon: Icons.search,
                  ),
                  onChanged: (v) =>
                      setState(() => _query = v.toLowerCase().trim()),
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
                                  .where((c) => c.isNotEmpty && c != 'All')
                                  .toSet(),
                            ]
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(c),
                                  selected: _category == c,
                                  showCheckmark: false,
                                  selectedColor: _green,
                                  labelStyle: TextStyle(
                                    color: _category == c
                                        ? Colors.white
                                        : AppColors.textLightMuted,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _category = c),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                ..._productList(),
                _heading('Delivery Method'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _choice(
                        'Takeaway / Self Pickup',
                        'Customer will collect the order.',
                        Icons.storefront_outlined,
                        !_homeDelivery,
                        () => setState(() => _homeDelivery = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _choice(
                        'Home Delivery',
                        'Deliver the order to the customer address.',
                        Icons.local_shipping_outlined,
                        _homeDelivery,
                        () => setState(() => _homeDelivery = true),
                      ),
                    ),
                  ],
                ),
                _heading('Payment Type *'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Cash', 'Phone Pe', 'Other', 'Google Pay']
                      .map(
                        (p) => ChoiceChip(
                          avatar: Icon(
                            _payment == p
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: _green,
                            size: 18,
                          ),
                          label: Text(p),
                          selected: _payment == p,
                          showCheckmark: false,
                          selectedColor: _green.withValues(alpha: 0.12),
                          onSelected: (_) => setState(() => _payment = p),
                        ),
                      )
                      .toList(),
                ),
                _heading('Order Summary'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _summary(),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _discount,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration(
                          '0',
                        ).copyWith(labelText: 'Discount amount (₹)'),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final amount = double.tryParse(v ?? '');
                          return amount == null ||
                                  !amount.isFinite ||
                                  amount < 0 ||
                                  amount > _subtotal
                              ? 'Enter a discount between 0 and ${_subtotal.toStringAsFixed(2)}'
                              : null;
                        },
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
    return visible.map((p) {
      final quantity = _quantities[p.id] ?? 0;
      return Container(
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
          children: [
            SizedBox(
              width: 48,
              height: 64,
              child: p.image.isEmpty
                  ? const Icon(
                      Icons.inventory_2_outlined,
                      color: _green,
                      size: 32,
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
                      fontSize: 13,
                    ),
                  ),
                  if (p.sku.isNotEmpty)
                    Text(
                      'SKU: ${p.sku}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLightMuted,
                      ),
                    ),
                  if (p.stock != null)
                    Text(
                      '${p.stock} ${p.unit} available',
                      style: TextStyle(
                        fontSize: 10,
                        color: p.stock! <= 20 ? Colors.deepOrange : _green,
                      ),
                    ),
                  Text(
                    '${_money(p.price)} / ${p.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
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
            ),
            if (quantity > 0)
              const Icon(Icons.check_circle, color: _green, size: 18),
          ],
        ),
      );
    }).toList();
  }

  Widget _summary() => Column(
    children: [
      if (_selected.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Add products to see your order summary.'),
        ),
      ..._selected.map(
        (p) => _totalRow(
          '${p.name} × ${_quantities[p.id]}',
          _money(p.price * _quantities[p.id]!),
        ),
      ),
      const Divider(),
      _totalRow('Subtotal', _money(_subtotal)),
      _totalRow('Discount', '− ${_money(_discountValue)}'),
      _totalRow('Total', _money(_total), bold: true),
    ],
  );

  Widget _totalRow(String title, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: bold ? _green : null,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.deliveryDashboardHeaderEnd,
      ),
    ),
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
          child: Text(_date(date), style: const TextStyle(fontSize: 12)),
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
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
    hintStyle: const TextStyle(fontSize: 12),
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

class _OrderProduct {
  final String id, name, sku, unit, category, image;
  final double price;
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
  );
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
      _text(data, ['image_url', 'imageUrl', 'image', 'thumbnail_url']),
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
      double.tryParse(
        _text(data, ['available_stock', 'stock_quantity', 'stock']),
      ),
    );
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

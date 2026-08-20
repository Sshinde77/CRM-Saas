import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class SalesManagerCreateOrderScreen extends StatefulWidget {
  final String? initialCustomerName;

  const SalesManagerCreateOrderScreen({super.key, this.initialCustomerName});

  @override
  State<SalesManagerCreateOrderScreen> createState() =>
      _SalesManagerCreateOrderScreenState();
}

class _SalesManagerCreateOrderScreenState
    extends State<SalesManagerCreateOrderScreen> {
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _quickCustomerNameController =
      TextEditingController();
  final TextEditingController _quickCustomerPhoneController =
      TextEditingController();
  final TextEditingController _quickCustomerEmailController =
      TextEditingController();
  final TextEditingController _orderNotesController = TextEditingController();
  final TextEditingController _internalNotesController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController(text: '0');
  final TextEditingController _deliveryAddressController =
      TextEditingController();

  late final List<_OrderCustomer> _customers;
  late _OrderCustomer _selectedCustomer;

  final List<_OrderProduct> _products = [
    _OrderProduct(
      name: 'Premium Basmati Rice 25kg',
      price: 1650,
      stock: 120,
      icon: Icons.shopping_bag_rounded,
      quantity: 2,
    ),
    _OrderProduct(
      name: 'Sunflower Oil 1L',
      price: 1350,
      stock: 80,
      icon: Icons.water_drop_rounded,
      quantity: 1,
    ),
    _OrderProduct(
      name: 'Toor Dal 5kg',
      price: 650,
      stock: 45,
      icon: Icons.inventory_2_rounded,
      quantity: 2,
    ),
  ];

  static const List<_ProductCatalogItem> _catalog = [
    _ProductCatalogItem(
      name: 'Premium Basmati Rice 25kg',
      price: 1650,
      stock: 120,
      icon: Icons.shopping_bag_rounded,
    ),
    _ProductCatalogItem(
      name: 'Sunflower Oil 1L',
      price: 1350,
      stock: 80,
      icon: Icons.water_drop_rounded,
    ),
    _ProductCatalogItem(
      name: 'Toor Dal 5kg',
      price: 650,
      stock: 45,
      icon: Icons.inventory_2_rounded,
    ),
    _ProductCatalogItem(
      name: 'Wheat Atta 10kg',
      price: 380,
      stock: 60,
      icon: Icons.flatware_rounded,
    ),
    _ProductCatalogItem(
      name: 'Bottle Pack',
      price: 180,
      stock: 220,
      icon: Icons.local_drink_rounded,
    ),
  ];

  DateTime _orderDate = DateTime(2026, 8, 18);
  DateTime _deliveryDate = DateTime(2026, 8, 18);
  bool _useExistingCustomer = true;
  String _warehouse = 'Main Warehouse';
  String _paymentType = 'Select payment type';
  String _deliveryMethod = 'Takeaway / Self Pickup';
  String _discountType = 'Percentage';
  String _deliveryPartner = 'Not assigned';

  @override
  void initState() {
    super.initState();
    _customers = [
      const _OrderCustomer(name: 'Shree Ganesh Traders', location: 'Dadar, Mumbai'),
      const _OrderCustomer(name: 'Maa Durga Stores', location: 'Matunga, Mumbai'),
      const _OrderCustomer(name: 'Patel Retailers', location: 'Sion, Mumbai'),
      const _OrderCustomer(name: 'S.K. Enterprises', location: 'Ghatkopar, Mumbai'),
      const _OrderCustomer(name: 'New A One Traders', location: 'Kurla, Mumbai'),
    ];

    if (widget.initialCustomerName != null) {
      final initial = _customers.firstWhere(
        (customer) => customer.name == widget.initialCustomerName,
        orElse: () => _customers.first,
      );
      _selectedCustomer = initial;
    } else {
      _selectedCustomer = _customers.first;
    }

    _discountValueController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _quickCustomerNameController.dispose();
    _quickCustomerPhoneController.dispose();
    _quickCustomerEmailController.dispose();
    _orderNotesController.dispose();
    _internalNotesController.dispose();
    _discountValueController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  List<_OrderCustomer> get _filteredCustomers {
    final query = _customerSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _customers;
    return _customers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(query) ||
              customer.location.toLowerCase().contains(query),
        )
        .toList();
  }

  int get _itemsTotal =>
      _products.fold<int>(0, (sum, product) => sum + (product.price * product.quantity));

  int get _totalQuantity =>
      _products.fold<int>(0, (sum, product) => sum + product.quantity);

  int get _discountAmount {
    final raw = int.tryParse(_discountValueController.text.trim()) ?? 0;
    if (_discountType == 'Percentage') {
      return ((_itemsTotal * raw) / 100).round();
    }
    return raw;
  }

  int get _subtotal {
    final amount = _itemsTotal - _discountAmount;
    return amount < 0 ? 0 : amount;
  }

  int get _grandTotal => _subtotal;

  void _addProduct(_ProductCatalogItem item) {
    setState(() {
      final existingIndex =
          _products.indexWhere((product) => product.name == item.name);
      if (existingIndex >= 0) {
        _products[existingIndex].quantity += 1;
      } else {
        _products.add(
          _OrderProduct(
            name: item.name,
            price: item.price,
            stock: item.stock,
            icon: item.icon,
            quantity: 1,
          ),
        );
      }
    });
  }

  Future<void> _showAddProductSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Product',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap a product to add it to this order.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 420,
                  child: ListView.separated(
                    itemCount: _catalog.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = _catalog[index];
                      return Material(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _addProduct(product);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.border.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  child: Icon(
                                    product.icon,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Rs. ${product.price} - Stock ${product.stock}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate({required bool delivery}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: delivery ? _deliveryDate : _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (delivery) {
        _deliveryDate = picked;
      } else {
        _orderDate = picked;
      }
    });
  }

  void _addQuickCustomer() {
    final name = _quickCustomerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a customer name.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newCustomer = _OrderCustomer(
      name: name,
      location: _quickCustomerPhoneController.text.trim().isEmpty
          ? 'Quick added customer'
          : _quickCustomerPhoneController.text.trim(),
    );

    setState(() {
      _customers.add(newCustomer);
      _selectedCustomer = newCustomer;
      _useExistingCustomer = true;
      _customerSearchController.clear();
      _quickCustomerNameController.clear();
      _quickCustomerPhoneController.clear();
      _quickCustomerEmailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer added: ${newCustomer.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order ready for ${_selectedCustomer.name} with $_totalQuantity items.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 1180;
                      if (!wide) {
                        return Column(
                          children: [
                            _buildCustomerAndOrderDetailsSection(isWide: false),
                            const SizedBox(height: 12),
                            _buildProductsSection(),
                            const SizedBox(height: 12),
                            _buildDeliveryAndNotesSection(),
                            const SizedBox(height: 12),
                            _buildSummaryCard(),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildCustomerAndOrderDetailsSection(isWide: true),
                                const SizedBox(height: 12),
                                _buildProductsSection(),
                                const SizedBox(height: 12),
                                _buildDeliveryAndNotesSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(width: 250, child: _buildSummaryCard()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
          ),
        ),
        const Expanded(
          child: Text(
            'Create Order',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '●',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.red),
            ),
        ],
      ),
    );
  }

  Widget _field({
    required String hint,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    final textField = TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textLightMuted,
          fontSize: 12.5,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.72)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        suffixIcon: suffixIcon,
      ),
    );

    if (maxLines > 1) return textField;
    return SizedBox(height: 44, child: textField);
  }

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.textLightMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerAndOrderDetails({required bool isWide}) {
    final customerCard = _sectionCard(
      title: 'Customer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _radio(
                'Select Existing Customer',
                _useExistingCustomer,
                () => setState(() => _useExistingCustomer = true),
              ),
              _radio(
                'Quick Add Customer',
                !_useExistingCustomer,
                () => setState(() => _useExistingCustomer = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_useExistingCustomer) ...[
            _field(
              hint: 'Search by name, phone or email...',
              controller: _customerSearchController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
              ),
              child: DropdownButtonHideUnderline(
              child: DropdownButton<_OrderCustomer>(
                  value: _filteredCustomers.contains(_selectedCustomer)
                      ? _selectedCustomer
                      : null,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textLightMuted,
                  ),
                  items: _filteredCustomers
                      .map(
                        (customer) => DropdownMenuItem<_OrderCustomer>(
                          value: customer,
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (customer) {
                    if (customer == null) return;
                    setState(() => _selectedCustomer = customer);
                  },
                  hint: const Text(
                    'Select customer',
                    style: TextStyle(color: AppColors.textLightMuted),
                  ),
                ),
              ),
            ),
          ] else ...[
            _field(
              hint: 'Customer name',
              controller: _quickCustomerNameController,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    hint: 'Phone number',
                    controller: _quickCustomerPhoneController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    hint: 'Email address',
                    controller: _quickCustomerEmailController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _addQuickCustomer,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final orderDetailsCard = _sectionCard(
      title: 'Order Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Order Date'),
                    const SizedBox(height: 6),
                    _field(
                      hint: _formatDate(_orderDate),
                      readOnly: true,
                      onTap: () => _pickDate(delivery: false),
                      suffixIcon: IconButton(
                        onPressed: () => _pickDate(delivery: false),
                        icon: const Icon(Icons.calendar_month_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Delivery Date', required: true),
                    const SizedBox(height: 6),
                    _field(
                      hint: _formatDate(_deliveryDate),
                      readOnly: true,
                      onTap: () => _pickDate(delivery: true),
                      suffixIcon: IconButton(
                        onPressed: () => _pickDate(delivery: true),
                        icon: const Icon(Icons.calendar_month_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _label('Warehouse', required: true),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _warehouse,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textLightMuted,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Main Warehouse',
                    child: Text('Main Warehouse'),
                  ),
                  DropdownMenuItem(
                    value: 'West Warehouse',
                    child: Text('West Warehouse'),
                  ),
                  DropdownMenuItem(
                    value: 'Transit',
                    child: Text('Transit'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _warehouse = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _label('Payment Type', required: true),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _paymentType,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textLightMuted,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Select payment type',
                    child: Text('Select payment type'),
                  ),
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                  DropdownMenuItem(value: 'Card', child: Text('Card')),
                  DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _paymentType = value);
                },
              ),
            ),
          ),
        ],
      ),
    );

    if (!isWide) {
      return Column(
        children: [
          customerCard,
          const SizedBox(height: 12),
          orderDetailsCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: customerCard),
        const SizedBox(width: 12),
        Expanded(child: orderDetailsCard),
      ],
    );
  }

  Widget _buildCustomerAndOrderDetailsSection({required bool isWide}) {
    return _customerAndOrderDetails(isWide: isWide);
  }

  Widget _buildProductsSection() {
    return _sectionCard(
      title: 'Products / Order Items',
      trailing: OutlinedButton.icon(
        onPressed: _showAddProductSheet,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Product'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          visualDensity: VisualDensity.compact,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add products, set selling price and quantity.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (_products.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
              ),
              child: const Column(
                children: [
                  Text(
                    'No products added yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Click "Add Product" to start building this order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < _products.length; i++) ...[
                  _ProductRow(
                    product: _products[i],
                    onMinus: () {
                      setState(() {
                        if (_products[i].quantity > 1) {
                          _products[i].quantity -= 1;
                        }
                      });
                    },
                    onPlus: () {
                      setState(() => _products[i].quantity += 1);
                    },
                  ),
                  if (i != _products.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _field(
                    hint: 'Add notes for this order (optional)',
                    controller: _orderNotesController,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Quantity',
                      style: TextStyle(
                        color: AppColors.textLightMuted,
                        fontSize: 11.5,
                      ),
                    ),
                    Text(
                      '$_totalQuantity items',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Subtotal (Before Discount & GST)',
                      style: TextStyle(
                        color: AppColors.textLightMuted,
                        fontSize: 11.5,
                      ),
                    ),
                    Text(
                      'Rs. $_itemsTotal',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
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

  Widget _buildDeliveryAndNotesSection() {
    final deliveryCard = _sectionCard(
      title: 'Delivery Method',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _deliveryOption(
                  title: 'Takeaway / Self Pickup',
                  subtitle: 'Customer will collect the order from our store.',
                  icon: Icons.storefront_rounded,
                  selected: _deliveryMethod == 'Takeaway / Self Pickup',
                  onTap: () => setState(() {
                    _deliveryMethod = 'Takeaway / Self Pickup';
                    _deliveryPartner = 'Not assigned';
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _deliveryOption(
                  title: 'Home Delivery',
                  subtitle: 'We will deliver the order to customer address.',
                  icon: Icons.local_shipping_rounded,
                  selected: _deliveryMethod == 'Home Delivery',
                  onTap: () => setState(() => _deliveryMethod = 'Home Delivery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Assign Delivery Partner'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.72),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _deliveryPartner,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textLightMuted,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Not assigned',
                              child: Text('Not assigned'),
                            ),
                            DropdownMenuItem(value: 'Sunil', child: Text('Sunil')),
                            DropdownMenuItem(value: 'Ravi', child: Text('Ravi')),
                            DropdownMenuItem(value: 'Amit', child: Text('Amit')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _deliveryPartner = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Delivery Address'),
                    const SizedBox(height: 6),
                    _field(
                      hint: 'Delivery address',
                      controller: _deliveryAddressController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final notesCard = _sectionCard(
      title: 'Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Order Notes'),
                    const SizedBox(height: 6),
                    _field(
                      hint: 'Order notes',
                      controller: _orderNotesController,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Internal Notes'),
                    const SizedBox(height: 6),
                    _field(
                      hint: 'Internal notes',
                      controller: _internalNotesController,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please review all details before creating the order.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        deliveryCard,
        const SizedBox(height: 12),
        notesCard,
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Subtotal (Before Discount & GST)',
            value: 'Rs. $_itemsTotal',
          ),
          const SizedBox(height: 10),
          _discountRow(),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Subtotal', value: 'Rs. $_subtotal'),
          const SizedBox(height: 10),
          _SummaryRow(label: 'GST (0%)', value: 'Rs. 0'),
          const Divider(height: 22),
          _SummaryRow(label: 'Total Quantity', value: '$_totalQuantity items'),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Payment Type',
            value: _paymentType == 'Select payment type' ? 'Not selected' : _paymentType,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Delivery Partner',
            value: _deliveryMethod == 'Takeaway / Self Pickup'
                ? 'Takeaway / Not assigned'
                : _deliveryPartner,
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery Date', value: _formatDate(_deliveryDate)),
          const Divider(height: 22),
          _SummaryRow(
            label: 'Total Amount',
            value: 'Rs. $_grandTotal',
            emphasize: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createOrder,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text(
                'Create Order',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'You can review and edit the order before confirmation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _discountType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Percentage', child: Text('Percentage')),
                  DropdownMenuItem(value: 'Flat', child: Text('Flat')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _discountType = value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _field(
            hint: '0',
            controller: _discountValueController,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _discountType == 'Percentage' ? '%' : 'Rs',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _deliveryOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.adminSidebarBg : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.72),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderProduct {
  final String name;
  final int price;
  final int stock;
  final IconData icon;
  int quantity;

  _OrderProduct({
    required this.name,
    required this.price,
    required this.stock,
    required this.icon,
    required this.quantity,
  });
}

class _ProductCatalogItem {
  final String name;
  final int price;
  final int stock;
  final IconData icon;

  const _ProductCatalogItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.icon,
  });
}

class _ProductRow extends StatelessWidget {
  final _OrderProduct product;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _ProductRow({
    required this.product,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.adminSidebarBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(product.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Rs. ${product.price}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Stock: ${product.stock}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _QtyButton(icon: Icons.remove_rounded, onTap: onMinus),
          Container(
            width: 34,
            alignment: Alignment.center,
            child: Text(
              '${product.quantity}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _QtyButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, color: AppColors.textPrimary, size: 16),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: valueColor ?? AppColors.textPrimary,
      fontSize: emphasize ? 14 : 12.5,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: textStyle),
      ],
    );
  }
}

class _OrderCustomer {
  final String name;
  final String location;

  const _OrderCustomer({required this.name, required this.location});
}

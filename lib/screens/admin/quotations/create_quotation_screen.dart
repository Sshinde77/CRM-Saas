import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class NewQuotationScreen extends StatefulWidget {
  const NewQuotationScreen({super.key});

  @override
  State<NewQuotationScreen> createState() => _NewQuotationScreenState();
}

class _NewQuotationScreenState extends State<NewQuotationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _quotationNumberController =
      TextEditingController(text: 'QT-2026-1004');
  final TextEditingController _quotationDateController =
      TextEditingController(text: _formatDate(DateTime.now()));
  final TextEditingController _validUntilController =
      TextEditingController(text: _formatDate(DateTime.now().add(const Duration(days: 15))));
  final TextEditingController _billingAddressController = TextEditingController();
  final TextEditingController _shippingAddressController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _deliveryTermsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _termsConditionsController = TextEditingController();

  int _currentStep = 0;

  final List<_QuotationStep> _steps = const [
    _QuotationStep('Quotation Details', Icons.description_outlined),
    _QuotationStep('Terms Details', Icons.receipt_long_outlined),
    _QuotationStep('Quotation Items', Icons.inventory_2_outlined),
  ];

  final List<String> _customerOptions = const [
    'Hotel Grand Meridian',
    'Spice Route Restaurant',
    'Sunrise Corporate Park',
    'Mr. Arjun Reddy',
    'Green Leaf Caterers',
    'Café Mocha',
  ];

  final List<String> _salespersonOptions = const [
    'Vikram Singh',
    'Sunil Sales',
    'Neha Sharma',
  ];

  final List<String> _currencyOptions = const [
    'INR',
    'USD',
    'EUR',
  ];

  final List<String> _paymentOptions = const [
    'Net 7',
    'Net 15',
    'Net 30',
    'Advance',
    'Immediate',
    'Due on Receipt',
  ];

  final List<String> _deliveryOptions = const [
    'Standard delivery',
    'Express delivery',
    'Customer pickup',
    'Delivery within 2 business days',
  ];

  final List<_QuotationCatalogItem> _productOptions = const [
    _QuotationCatalogItem(
      name: 'Conference Setup',
      sku: 'SRV-1001',
      description: 'End-to-end event support and coordination.',
      uom: 'Service',
    ),
    _QuotationCatalogItem(
      name: 'Projector Rental',
      sku: 'EQP-2044',
      description: 'Full-day projector rental with basic cabling.',
      uom: 'Day',
    ),
    _QuotationCatalogItem(
      name: 'Premium Chair',
      sku: 'FUR-3012',
      description: 'Comfort seating for premium spaces and events.',
      uom: 'Nos',
    ),
    _QuotationCatalogItem(
      name: 'Office Stationery Pack',
      sku: 'STY-1180',
      description: 'Standard stationery bundle for daily office use.',
      uom: 'Pack',
    ),
  ];

  final List<String> _uomOptions = const [
    'Nos',
    'Pack',
    'Box',
    'Kg',
    'Ltr',
    'Hour',
    'Day',
    'Service',
  ];

  final List<String> _taxOptions = const [
    '0%',
    '5%',
    '12%',
    '18%',
  ];

  String? _selectedCustomer;
  String? _selectedSalesperson;
  String _selectedCurrency = 'INR';
  String _selectedPaymentTerm = 'Net 15';

  final List<_QuotationItemDraft> _items = [_QuotationItemDraft()];

  @override
  void initState() {
    super.initState();
    for (final item in _items) {
      item.attachRebuild(_onItemChanged);
    }
    _syncComputedFields();
  }

  @override
  void dispose() {
    _quotationNumberController.dispose();
    _quotationDateController.dispose();
    _validUntilController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _paymentTermsController.dispose();
    _deliveryTermsController.dispose();
    _notesController.dispose();
    _termsConditionsController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}';
  }

  DateTime? _parseDate(String text) {
    final parts = text.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 2),
      lastDate: lastDate ?? DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B4A06),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      controller.text = _formatDate(picked);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _onItemChanged() {
    _syncComputedFields();
    if (mounted) {
      setState(() {});
    }
  }

  void _addItem() {
    setState(() {
      final item = _QuotationItemDraft();
      item.attachRebuild(_onItemChanged);
      _items.add(item);
      _syncComputedFields();
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) return;
    setState(() {
      final item = _items.removeAt(index);
      item.dispose();
    });
  }

  void _handleProductSelection(_QuotationItemDraft item, String? productName) {
    _QuotationCatalogItem? product;
    for (final option in _productOptions) {
      if (option.name == productName) {
        product = option;
        break;
      }
    }

    item.productController.text = product?.name ?? '';
    item.skuController.text = product?.sku ?? '';
    item.descriptionController.text = product?.description ?? '';
    if (product != null) {
      item.uomController.text = product.uom;
    }
    _syncComputedFields();
    if (mounted) {
      setState(() {});
    }
  }

  String _currencyPrefix() {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'INR':
      default:
        return '₹';
    }
  }

  double _parseNumber(String text) {
    return double.tryParse(text.trim()) ?? 0;
  }

  double _parsePercent(String text) {
    return double.tryParse(text.replaceAll('%', '').trim()) ?? 0;
  }

  void _syncComputedFields() {
    for (final item in _items) {
      item.lineTotalController.text =
          '${_currencyPrefix()}${_lineTotal(item).toStringAsFixed(2)}';
    }
  }

  double _lineTotal(_QuotationItemDraft item) {
    final quantity = _parseNumber(item.quantityController.text);
    final unitPrice = _parseNumber(item.unitPriceController.text);
    final discount = _parsePercent(item.discountController.text);
    final tax = _parsePercent(item.taxController.text);
    final subtotal = quantity * unitPrice;
    final discounted = subtotal - (subtotal * discount / 100);
    final taxed = discounted + (discounted * tax / 100);
    return taxed < 0 ? 0 : taxed;
  }

  double get _quotationTotal {
    return _items.fold<double>(0, (sum, item) => sum + _lineTotal(item));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Quotation'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 980;

            return Column(
              children: [
                AdminTopBar(
                  title: 'Quotations',
                  leadingIcon: Icons.menu_rounded,
                  onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: isCompact
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                                  child: _buildCompactStepper(),
                                ),
                                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                                Expanded(child: _buildFormPanel(context)),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: 320,
                                  child: _buildDesktopStepper(),
                                ),
                                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                                Expanded(child: _buildFormPanel(context)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    final step = _steps[_currentStep];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _stepSubtitle(_currentStep),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: _buildCurrentStepForm(),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _currentStep == 0 ? null : () => setState(() => _currentStep--),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9CA3AF),
                  backgroundColor: const Color(0xFFF3F4F6),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_currentStep < _steps.length - 1) {
                    setState(() => _currentStep++);
                    return;
                  }
                  _showSnack('Quotation saved');
                  Navigator.of(context).maybePop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4A06),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(_currentStep < _steps.length - 1 ? 'Next' : 'Save Quotation'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStepper() {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quotation Steps',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < _steps.length; i++) ...[
              _CircleStepTile(
                index: i + 1,
                title: _steps[i].title,
                icon: _steps[i].icon,
                selected: _currentStep == i,
                completed: _currentStep > i,
                onTap: () => setState(() => _currentStep = i),
              ),
              if (i != _steps.length - 1)
                Container(
                  margin: const EdgeInsets.only(left: 22),
                  width: 2,
                  height: 28,
                  color: const Color(0xFFE5E7EB),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quotation Steps',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                _CompactCircleStep(
                  index: i + 1,
                  title: _steps[i].title,
                  icon: _steps[i].icon,
                  selected: _currentStep == i,
                  completed: _currentStep > i,
                  onTap: () => setState(() => _currentStep = i),
                ),
                if (i != _steps.length - 1)
                  Container(
                    width: 32,
                    height: 2,
                    color: const Color(0xFFE5E7EB),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _stepSubtitle(int step) {
    switch (step) {
      case 0:
        return 'Quotation number, dates, customer, and sales ownership.';
      case 1:
        return 'Terms, delivery notes, and quotation conditions.';
      case 2:
      default:
        return 'Add products, quantities, and pricing details.';
    }
  }

  Widget _buildCurrentStepForm() {
    switch (_currentStep) {
      case 0:
        return _buildQuotationDetailsStep();
      case 1:
        return _buildTermsDetailsStep();
      case 2:
      default:
        return _buildItemsStep();
    }
  }

  Widget _buildQuotationDetailsStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 700;

        final children = [
          _FormField(
            label: 'Quotation Number *',
            controller: _quotationNumberController,
            hintText: 'QT-2026-1004',
            readOnly: true,
          ),
          _FormDateField(
            label: 'Quotation Date *',
            controller: _quotationDateController,
            hintText: 'dd-mm-yyyy',
            onTap: () {
              _pickDate(
                controller: _quotationDateController,
                initialDate: _parseDate(_quotationDateController.text) ?? DateTime.now(),
              );
            },
          ),
          _FormDateField(
            label: 'Valid Until *',
            controller: _validUntilController,
            hintText: 'dd-mm-yyyy',
            onTap: () {
              final initial = _parseDate(_validUntilController.text) ??
                  DateTime.now().add(const Duration(days: 15));
              _pickDate(
                controller: _validUntilController,
                initialDate: initial,
                firstDate: DateTime.now(),
              );
            },
          ),
          _FormDropdown(
            label: 'Customer *',
            value: _selectedCustomer,
            hintText: 'Select customer',
            items: _customerOptions,
            onChanged: (value) => setState(() => _selectedCustomer = value),
          ),
          _FormField(
            label: 'Billing Address *',
            controller: _billingAddressController,
            hintText: 'Enter billing address',
          ),
          _FormField(
            label: 'Shipping Address',
            controller: _shippingAddressController,
            hintText: 'Enter shipping address',
          ),
          _FormDropdown(
            label: 'Salesperson *',
            value: _selectedSalesperson,
            hintText: 'Select salesperson',
            items: _salespersonOptions,
            onChanged: (value) => setState(() => _selectedSalesperson = value),
          ),
          _FormDropdown(
            label: 'Currency *',
            value: _selectedCurrency,
            hintText: 'Select currency',
            items: _currencyOptions,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedCurrency = value);
            },
          ),
        ];

        if (stacked) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 18),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 18),
                Expanded(child: children[1]),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: children[2]),
                const SizedBox(width: 18),
                Expanded(child: children[3]),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: children[4]),
                const SizedBox(width: 18),
                Expanded(child: children[5]),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: children[6]),
                const SizedBox(width: 18),
                Expanded(child: children[7]),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsDetailsStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 700;

        final paymentDropdown = _FormDropdown(
          label: 'Payment Terms *',
          value: _selectedPaymentTerm,
          hintText: 'Select payment terms',
          items: _paymentOptions,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedPaymentTerm = value);
          },
        );

        final deliveryDropdown = _FormDropdown(
          label: 'Delivery Terms',
          value: _deliveryTermsController.text.isEmpty
              ? null
              : _deliveryTermsController.text,
          hintText: 'Select delivery terms',
          items: _deliveryOptions,
          onChanged: (value) {
            setState(() => _deliveryTermsController.text = value ?? '');
          },
        );

        final notesField = _FormField(
          label: 'Notes',
          controller: _notesController,
          hintText: 'Internal remarks',
          maxLines: 5,
        );

        final termsField = _FormField(
          label: 'Terms & Conditions',
          controller: _termsConditionsController,
          hintText: 'Terms printed on quotation',
          maxLines: 5,
        );

        if (stacked) {
          return Column(
            children: [
              paymentDropdown,
              const SizedBox(height: 18),
              deliveryDropdown,
              const SizedBox(height: 18),
              notesField,
              const SizedBox(height: 18),
              termsField,
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: paymentDropdown),
                const SizedBox(width: 18),
                Expanded(child: deliveryDropdown),
              ],
            ),
            const SizedBox(height: 18),
            notesField,
            const SizedBox(height: 18),
            termsField,
          ],
        );
      },
    );
  }

  Widget _buildItemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quotation Items',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add products or services for this estimate.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _items.length; i++) ...[
          _QuotationItemCard(
            index: i + 1,
            item: _items[i],
            productOptions: _productOptions,
            uomOptions: _uomOptions,
            taxOptions: _taxOptions,
            currencyPrefix: _currencyPrefix(),
            canRemove: _items.length > 1,
            onProductChanged: (value) => _handleProductSelection(_items[i], value),
            onRemove: () => _removeItem(i),
          ),
          if (i != _items.length - 1) const SizedBox(height: 14),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 170,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quotation Total',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currencyPrefix()}${_quotationTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF0B4A06),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuotationStep {
  final String title;
  final IconData icon;

  const _QuotationStep(this.title, this.icon);
}

class _CircleStepTile extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _CircleStepTile({
    required this.index,
    required this.title,
    required this.icon,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = selected || completed
        ? const Color(0xFF0B4A06)
        : const Color(0xFFE5E7EB);
    final iconColor = selected || completed ? Colors.white : const Color(0xFF6B7280);
    final textColor = selected ? const Color(0xFF0B4A06) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFD1D5DB) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $index',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCircleStep extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _CompactCircleStep({
    required this.index,
    required this.title,
    required this.icon,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = selected || completed
        ? const Color(0xFF0B4A06)
        : const Color(0xFFE5E7EB);
    final iconColor = selected || completed ? Colors.white : const Color(0xFF6B7280);
    final textColor = selected ? const Color(0xFF0B4A06) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Step $index',
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 88,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotationItemDraft {
  final TextEditingController productController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController uomController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController discountController = TextEditingController(text: '0');
  final TextEditingController taxController = TextEditingController();
  final TextEditingController lineTotalController = TextEditingController();

  VoidCallback? _listener;

  void attachRebuild(VoidCallback listener) {
    _listener = listener;
    productController.addListener(listener);
    skuController.addListener(listener);
    descriptionController.addListener(listener);
    quantityController.addListener(listener);
    uomController.addListener(listener);
    unitPriceController.addListener(listener);
    discountController.addListener(listener);
    taxController.addListener(listener);
  }

  void detachRebuild() {
    final listener = _listener;
    if (listener == null) return;
    productController.removeListener(listener);
    skuController.removeListener(listener);
    descriptionController.removeListener(listener);
    quantityController.removeListener(listener);
    uomController.removeListener(listener);
    unitPriceController.removeListener(listener);
    discountController.removeListener(listener);
    taxController.removeListener(listener);
    _listener = null;
  }

  void dispose() {
    detachRebuild();
    productController.dispose();
    skuController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    uomController.dispose();
    unitPriceController.dispose();
    discountController.dispose();
    taxController.dispose();
    lineTotalController.dispose();
  }
}

class _QuotationItemCard extends StatelessWidget {
  final int index;
  final _QuotationItemDraft item;
  final List<_QuotationCatalogItem> productOptions;
  final List<String> uomOptions;
  final List<String> taxOptions;
  final String currencyPrefix;
  final bool canRemove;
  final ValueChanged<String?> onProductChanged;
  final VoidCallback onRemove;

  const _QuotationItemCard({
    required this.index,
    required this.item,
    required this.productOptions,
    required this.uomOptions,
    required this.taxOptions,
    required this.currencyPrefix,
    required this.canRemove,
    required this.onProductChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Item $index',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: canRemove ? onRemove : null,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: canRemove ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                ),
                label: Text(
                  'Remove',
                  style: TextStyle(
                    color: canRemove ? const Color(0xFF9CA3AF) : const Color(0xFFD1D5DB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 840;
              final skuField = _FormField(
                label: 'SKU',
                controller: item.skuController,
                hintText: 'Auto-filled product code',
                readOnly: true,
              );
              final descriptionField = _FormField(
                label: 'Description',
                controller: item.descriptionController,
                hintText: 'Product description',
                maxLines: 3,
              );
              final qtyField = _FormField(
                label: 'Quantity *',
                controller: item.quantityController,
                hintText: '0',
                keyboardType: TextInputType.number,
              );
              final uomField = _FormDropdown(
                label: 'UOM *',
                value: item.uomController.text.isEmpty ? null : item.uomController.text,
                hintText: 'Select UOM',
                items: uomOptions,
                onChanged: (value) => item.uomController.text = value ?? '',
              );
              final unitField = _FormField(
                label: 'Unit Price *',
                controller: item.unitPriceController,
                hintText: '0',
                keyboardType: TextInputType.number,
              );
              final discountField = _FormField(
                label: 'Discount (%)',
                controller: item.discountController,
                hintText: '0',
                keyboardType: TextInputType.number,
              );
              final taxField = _FormDropdown(
                label: 'Tax (%)',
                value: item.taxController.text.isEmpty ? null : item.taxController.text,
                hintText: 'Select tax',
                items: taxOptions,
                onChanged: (value) => item.taxController.text = value ?? '',
              );
              final lineTotalField = _FormField(
                label: 'Line Total',
                controller: item.lineTotalController,
                hintText: '0.00',
                readOnly: true,
                prefixText: currencyPrefix,
              );

              if (stacked) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _FormDropdown(
                            label: 'Product *',
                            value: item.productController.text.isEmpty ? null : item.productController.text,
                            hintText: 'Select product or service',
                            items: productOptions.map((product) => product.name).toList(),
                            onChanged: onProductChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: skuField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    descriptionField,
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: qtyField),
                        const SizedBox(width: 12),
                        Expanded(child: uomField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: unitField),
                        const SizedBox(width: 12),
                        Expanded(child: discountField),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: taxField),
                        const SizedBox(width: 12),
                        Expanded(child: lineTotalField),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _FormDropdown(
                          label: 'Product *',
                          value: item.productController.text.isEmpty ? null : item.productController.text,
                          hintText: 'Select product or service',
                          items: productOptions.map((product) => product.name).toList(),
                          onChanged: onProductChanged,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(flex: 4, child: skuField),
                    ],
                  ),
                  const SizedBox(height: 14),
                  descriptionField,
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: qtyField),
                      const SizedBox(width: 14),
                      Expanded(child: uomField),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: unitField),
                      const SizedBox(width: 14),
                      Expanded(child: discountField),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: taxField),
                      const SizedBox(width: 14),
                      Expanded(child: lineTotalField),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuotationCatalogItem {
  final String name;
  final String sku;
  final String description;
  final String uom;

  const _QuotationCatalogItem({
    required this.name,
    required this.sku,
    required this.description,
    required this.uom,
  });
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? prefixText;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: _inputDecoration(
          hintText,
          suffixIcon: suffixIcon,
          prefixText: prefixText,
        ),
      ),
    );
  }
}

class _FormDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;

  const _FormDateField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: _inputDecoration(
          hintText,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FormDropdown({
    required this.label,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: DropdownButtonFormField<String>(
        key: ValueKey<String?>(value),
        initialValue: value,
        isExpanded: true,
        menuMaxHeight: 280,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
        decoration: _inputDecoration(hintText),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

InputDecoration _inputDecoration(
  String hintText, {
  Widget? suffixIcon,
  String? prefixText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 13.5,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0B4A06)),
    ),
    prefixText: prefixText,
    suffixIcon: suffixIcon,
  );
}

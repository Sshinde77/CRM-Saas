import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../sales_manager/performance/sales_manager_performance_screen.dart';
import '../../sales_manager/stock/sales_manager_stock_screen.dart';
import '../../sales_manager/visits/sales_manager_visits_screen.dart';
import '../customers/customers_screen.dart';
import '../leads/admin_leads_screen.dart';
import 'admin_orders_screen.dart';

class NewAdminOrderScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const NewAdminOrderScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<NewAdminOrderScreen> createState() => _NewAdminOrderScreenState();
}

class _NewAdminOrderScreenState extends State<NewAdminOrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _productButtonKey = GlobalKey();
  final TextEditingController _companySearchController =
      TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _deliveryDate;
  bool _useExistingCompany = true;
  String _paymentType = 'UPI';
  String _deliveryMethod = 'Takeaway Order';
  static const List<String> _companyOptions = [
    'Hotel Grand Meridian',
    'Spice Route Restaurant',
    'Sunrise Corporate Park',
    'Green Leaf Caterers',
  ];

  static const List<_ProductOption> _productOptions = [
    _ProductOption('Water Jar Refill (20L)', 'SKU: WJR-20L', '₹240'),
    _ProductOption('Water Dispenser - Normal', 'SKU: WD-NRM', '₹5,499'),
    _ProductOption('Water Dispenser - Hot & Cold', 'SKU: WD-HC', '₹9,999'),
    _ProductOption('Water Bottle Pack', 'SKU: WBP-12', '₹180'),
    _ProductOption('Installation Service', 'SKU: INST-001', '₹499'),
  ];

  @override
  void initState() {
    super.initState();
    _deliveryDate = DateTime(2026, 8, 10);
  }

  @override
  void dispose() {
    _companySearchController.dispose();
    _companyController.dispose();
    _notesController.dispose();
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

  Future<void> _pickDeliveryDate() async {
    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        DateTime selectedDate = _deliveryDate ?? DateTime.now();

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF111827),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: StatefulBuilder(
              builder: (context, setLocalState) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CalendarDatePicker(
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          currentDate: DateTime.now(),
                          onDateChanged: (date) {
                            setLocalState(() => selectedDate = date);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setLocalState(
                              () => selectedDate = DateTime.now(),
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                color: Color(0xFF0B4A06),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(selectedDate),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B4A06),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Select'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    setState(() => _deliveryDate = picked);
  }

  void _createOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Order is not wired yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectPaymentType(String value) => setState(() => _paymentType = value);

  void _selectDeliveryMethod(String value) =>
      setState(() => _deliveryMethod = value);

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Create Order') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Stock') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }
    if (action == 'Follow-ups' || action == 'Follow-Ups') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerPerformanceScreen()),
      );
    }
  }

  void _selectProduct(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected product: $value'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showCreateCompanyPopup() async {
    final customerIdController = TextEditingController(text: 'CUS-2026-AUTO');
    final customerTypeController = TextEditingController();
    final customerNameController = TextEditingController();
    final legalNameController = TextEditingController();
    final displayNameController = TextEditingController();
    final industryController = TextEditingController();
    final categoryController = TextEditingController();
    final customerSinceController = TextEditingController(text: '10-08-2026');
    final statusController = TextEditingController(text: 'Active');

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Basic Information',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Customer identity and profile details.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 720;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _companyDialogGrid(
                                    narrow: narrow,
                                    left: _field(
                                      label: 'Customer ID',
                                      controller: customerIdController,
                                      readOnly: true,
                                    ),
                                    right: _field(
                                      label: 'Customer Type *',
                                      controller: customerTypeController,
                                      hintText: 'Select customer type',
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _companyDialogGrid(
                                    narrow: narrow,
                                    left: _field(
                                      label: 'Customer Name *',
                                      controller: customerNameController,
                                    ),
                                    right: _field(
                                      label: 'Legal Business Name',
                                      controller: legalNameController,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _companyDialogGrid(
                                    narrow: narrow,
                                    left: _field(
                                      label: 'Display Name',
                                      controller: displayNameController,
                                    ),
                                    right: _field(
                                      label: 'Industry',
                                      controller: industryController,
                                      hintText: 'Select industry',
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _companyDialogGrid(
                                    narrow: narrow,
                                    left: _field(
                                      label: 'Customer Category',
                                      controller: categoryController,
                                      hintText: 'Select customer category',
                                    ),
                                    right: _field(
                                      label: 'Customer Since *',
                                      controller: customerSinceController,
                                      readOnly: true,
                                      suffixIcon: Icons.calendar_month_outlined,
                                      onSuffixTap: () async {
                                        final picked = await showDatePicker(
                                          context: dialogContext,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          customerSinceController.text =
                                              '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: narrow
                                        ? double.infinity
                                        : constraints.maxWidth / 2 - 10,
                                    child: _field(
                                      label: 'Status *',
                                      controller: statusController,
                                      hintText: 'Active',
                                      readOnly: true,
                                      suffixIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B4A06),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    customerIdController.dispose();
    customerTypeController.dispose();
    customerNameController.dispose();
    legalNameController.dispose();
    displayNameController.dispose();
    industryController.dispose();
    categoryController.dispose();
    customerSinceController.dispose();
    statusController.dispose();

    if (result == true && mounted) {
      setState(() => _useExistingCompany = false);
    }
  }

  Future<void> _showProductMenu() async {
    final buttonContext = _productButtonKey.currentContext;
    if (buttonContext == null) return;

    final renderBox = buttonContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final selection = await showMenu<_ProductOption>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      items: _productOptions
          .map(
            (product) => PopupMenuItem<_ProductOption>(
              value: product,
              child: SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.sku} • ${product.price}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );

    if (selection != null) {
      _selectProduct(selection.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: widget.useSalesManagerShell
          ? SalesManagerSidebarDrawer(
              currentPage: 'Create Order',
              onSelect: _handleSalesManagerSidebarSelection,
            )
          : const AppDrawer(activeItem: 'Orders'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 14 : 18,
                    14,
                    isMobile ? 14 : 18,
                    10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Orders',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      _roundIconButton(Icons.help_outline_rounded, () {}),
                      const SizedBox(width: 10),
                      _roundIconButton(Icons.notifications_none_rounded, () {}),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0B4A06),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sushil',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Admin',
                                style: TextStyle(
                                  color: Color(0xFF0B4A06),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 18,
                      10,
                      isMobile ? 14 : 18,
                      18,
                    ),
                    child: Column(children: [_mobileOrderForm()]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _mobileOrderForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          title: 'Company',
          subtitle: 'Select an existing company or create a new one.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _radioOption(
                      'Select Existing Company',
                      _useExistingCompany,
                      true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _radioOption(
                      'Create New Company',
                      !_useExistingCompany,
                      false,
                      onTap: _showCreateCompanyPopup,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSearchField(
                controller: _companySearchController,
                hintText: 'Search by name, phone or email...',
                prefixIcon: Icons.search_rounded,
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                hintText: _useExistingCompany
                    ? 'Select a company'
                    : 'Enter new company name',
                trailingIcon: Icons.keyboard_arrow_down_rounded,
                child: PopupMenuButton<String>(
                  onSelected: (value) =>
                      setState(() => _companyController.text = value),
                  offset: const Offset(0, 46),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  itemBuilder: (_) => _companyOptions
                      .map(
                        (company) => PopupMenuItem<String>(
                          value: company,
                          child: Text(company),
                        ),
                      )
                      .toList(),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _companyController.text.isEmpty
                          ? 'Select a company'
                          : _companyController.text,
                      style: TextStyle(
                        color: _companyController.text.isEmpty
                            ? AppColors.textLightMuted
                            : AppColors.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Delivery Date',
          subtitle: 'Select the date for delivery.',
          child: _buildDateField(),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Products',
          subtitle: 'Add products, set selling price and quantity.',
          action: _productActionButton(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Text(
                      'No products added yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Click "Add Product" to start building this order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildNotesField(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _miniStat('Total Quantity', '0 Items')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniStat('Subtotal (Before Discount & GST)', '₹0'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Payment Type',
          subtitle: 'Select how the customer will pay.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _choiceTile(
                      'UPI',
                      _paymentType == 'UPI',
                      () => _selectPaymentType('UPI'),
                      Icons.phone_android_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _choiceTile(
                      'Card',
                      _paymentType == 'Card',
                      () => _selectPaymentType('Card'),
                      Icons.credit_card_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _choiceTile(
                      'Cash',
                      _paymentType == 'Cash',
                      () => _selectPaymentType('Cash'),
                      Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _choiceTile(
                      'COD',
                      _paymentType == 'COD',
                      () => _selectPaymentType('COD'),
                      Icons.local_shipping_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Delivery Method',
          subtitle: 'Select takeaway or assign a delivery boy.',
          child: Column(
            children: [
              _choiceTile(
                'Takeaway Order',
                _deliveryMethod == 'Takeaway Order',
                () => _selectDeliveryMethod('Takeaway Order'),
                Icons.storefront_outlined,
                fullWidth: true,
                subtitle: 'Customer will collect the order.',
              ),
              const SizedBox(height: 10),
              _choiceTile(
                'Choose Delivery Boy',
                _deliveryMethod == 'Choose Delivery Boy',
                () => _selectDeliveryMethod('Choose Delivery Boy'),
                Icons.delivery_dining_outlined,
                fullWidth: true,
                subtitle: 'Assign a delivery partner for doorstep delivery.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Order Summary',
          subtitle: null,
          child: Column(
            children: [
              _summaryRow('Subtotal (Before Discount & GST)', '₹0'),
              const SizedBox(height: 10),
              _summaryRow('Discount', '₹0'),
              const SizedBox(height: 10),
              _summaryRow('GST (0%)', '₹0'),
              const Divider(height: 22),
              _summaryRow('Payment Type', _paymentType),
              const SizedBox(height: 10),
              _summaryRow('Delivery Boy', 'Takeaway / Not assigned'),
              const SizedBox(height: 10),
              _summaryRow(
                'Delivery Date',
                _deliveryDate == null ? '-' : _formatDate(_deliveryDate!),
              ),
              const SizedBox(height: 10),
              _summaryRow('Shipping / Delivery', 'Free'),
              const Divider(height: 22),
              _summaryRow(
                'Total Amount',
                '₹0',
                valueStyle: const TextStyle(
                  color: Color(0xFF0B4A06),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                labelStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _createOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4A06),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Create Order',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFF0B4A06),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please review all details before creating the order.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDeliveryDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _deliveryDate == null
                    ? 'Select date'
                    : _formatDate(_deliveryDate!),
                style: TextStyle(
                  color: _deliveryDate == null
                      ? AppColors.textLightMuted
                      : AppColors.textPrimary,
                  fontSize: 13.5,
                ),
              ),
            ),
            IconButton(
              onPressed: _pickDeliveryDate,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              padding: EdgeInsets.zero,
              splashRadius: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioOption(
    String label,
    bool selected,
    bool value, {
    Future<void> Function()? onTap,
  }) {
    return InkWell(
      onTap: () async {
        if (onTap != null) {
          await onTap();
        } else {
          setState(() => _useExistingCompany = value);
        }
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3FAF0) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF0B4A06) : AppColors.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: selected
                  ? const Color(0xFF0B4A06)
                  : AppColors.textLightMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF9AA1AC),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : IconButton(
                      onPressed: onSuffixTap,
                      icon: Icon(
                        suffixIcon,
                        color: const Color(0xFF9AA1AC),
                        size: 18,
                      ),
                      splashRadius: 18,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _companyDialogGrid({
    required bool narrow,
    required Widget left,
    required Widget right,
  }) {
    if (narrow) {
      return Column(children: [left, const SizedBox(height: 14), right]);
    }

    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF94A3B8),
            size: 20,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0B4A06), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required IconData trailingIcon,
    required Widget child,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          Icon(trailingIcon, color: const Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: _notesController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Add notes for this order (optional)',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _choiceTile(
    String label,
    bool selected,
    VoidCallback onTap,
    IconData icon, {
    bool fullWidth = false,
    String? subtitle,
  }) {
    final tile = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3FAF0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0B4A06) : AppColors.borderStrong,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? const Color(0xFF0B4A06)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!fullWidth)
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 18,
                color: selected
                    ? const Color(0xFF0B4A06)
                    : AppColors.textLightMuted,
              ),
          ],
        ),
      ),
    );

    if (fullWidth) {
      return tile;
    }

    return Expanded(child: tile);
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...(action == null ? const <Widget>[] : <Widget>[action]),
            ],
          ),
          if (title.isNotEmpty) const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _productActionButton() {
    return OutlinedButton.icon(
      key: _productButtonKey,
      onPressed: _showProductMenu,
      icon: const Icon(Icons.add_rounded, size: 16),
      label: const Text('Add Product'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLightMuted,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                labelStyle ??
                const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _ProductOption {
  final String name;
  final String sku;
  final String price;

  const _ProductOption(this.name, this.sku, this.price);
}

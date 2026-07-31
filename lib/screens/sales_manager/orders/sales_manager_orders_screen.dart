import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class SalesManagerOrdersScreen extends StatefulWidget {
  const SalesManagerOrdersScreen({super.key});

  @override
  State<SalesManagerOrdersScreen> createState() =>
      _SalesManagerOrdersScreenState();
}

class _SalesManagerOrdersScreenState extends State<SalesManagerOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = const [
    'All (10)',
    'Draft (1)',
    'Pending (6)',
    'Confirmed (3)',
  ];

  int _selectedTab = 0;

  final List<_OrderRecord> _orders = const [
    _OrderRecord(
      number: 'SO-1023',
      customer: 'Shree Ganesh Traders',
      date: '16 May 2024',
      amount: 'Rs. 25,600',
      status: 'Confirmed',
      color: AppColors.primary,
      icon: Icons.storefront_rounded,
    ),
    _OrderRecord(
      number: 'SO-1022',
      customer: 'Maa Durga Stores',
      date: '18 May 2024',
      amount: 'Rs. 18,450',
      status: 'Pending',
      color: AppColors.orange,
      icon: Icons.local_shipping_rounded,
    ),
    _OrderRecord(
      number: 'SO-1021',
      customer: 'Patel Retailers',
      date: '17 May 2024',
      amount: 'Rs. 22,300',
      status: 'Confirmed',
      color: AppColors.primary,
      icon: Icons.storefront_rounded,
    ),
    _OrderRecord(
      number: 'SO-1020',
      customer: 'S.K. Enterprises',
      date: '16 May 2024',
      amount: 'Rs. 15,600',
      status: 'Pending',
      color: AppColors.orange,
      icon: Icons.local_shipping_rounded,
    ),
    _OrderRecord(
      number: 'SO-1019',
      customer: 'New A One Traders',
      date: '15 May 2024',
      amount: 'Rs. 28,500',
      status: 'Confirmed',
      color: AppColors.primary,
      icon: Icons.person_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateSalesOrderSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _CreateSalesOrderSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedOrders = _visibleOrders();
    final filteredOrders = selectedOrders.where((order) {
      if (query.isEmpty) return true;
      return order.number.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchRow(),
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 14),
                    for (var i = 0; i < filteredOrders.length; i++) ...[
                      _OrderTile(order: filteredOrders[i]),
                      if (i != filteredOrders.length - 1)
                        const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                    _buildFooterButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_OrderRecord> _visibleOrders() {
    switch (_selectedTab) {
      case 1:
        return _orders.take(1).toList();
      case 2:
        return _orders.where((o) => o.status == 'Pending').toList();
      case 3:
        return _orders.where((o) => o.status == 'Confirmed').toList();
      default:
        return _orders;
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 2),
          const Text(
            'Sales Orders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openCreateSalesOrderSheet,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(Icons.add_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.adminSidebarBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: 'Search orders...',
                hintStyle: TextStyle(
                  color: AppColors.textLightMuted,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.adminSidebarBg,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final selected = index == _selectedTab;
        return Padding(
          padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 8),
          child: ChoiceChip(
            label: Text(_tabs[index]),
            selected: selected,
            onSelected: (_) => setState(() => _selectedTab = index),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceSoft,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.65),
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        );
      }),
    );
  }

  Widget _buildFooterButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        onPressed: _openCreateSalesOrderSheet,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.adminSidebarBg,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Create Order',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final _OrderRecord order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = order.status == 'Confirmed';
    final statusColor = isConfirmed ? AppColors.primary : AppColors.orange;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final state =
              context.findAncestorStateOfType<_SalesManagerOrdersScreenState>();
          state?._openCreateSalesOrderSheet();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.adminSidebarBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.icon,
                  color: order.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.number,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customer,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.amount,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLightMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderRecord {
  final String number;
  final String customer;
  final String date;
  final String amount;
  final String status;
  final Color color;
  final IconData icon;

  const _OrderRecord({
    required this.number,
    required this.customer,
    required this.date,
    required this.amount,
    required this.status,
    required this.color,
    required this.icon,
  });
}

class _CreateSalesOrderSheet extends StatefulWidget {
  const _CreateSalesOrderSheet();

  @override
  State<_CreateSalesOrderSheet> createState() => _CreateSalesOrderSheetState();
}

class _CreateSalesOrderSheetState extends State<_CreateSalesOrderSheet> {
  final TextEditingController _searchController = TextEditingController();

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
    _OrderProduct(
      name: 'Wheat Atta 10kg',
      price: 380,
      stock: 60,
      icon: Icons.flatware_rounded,
      quantity: 1,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _itemsTotal {
    return _products.fold<int>(
      0,
      (sum, product) => sum + (product.price * product.quantity),
    );
  }

  int get _discount => 300;

  int get _grandTotal => _itemsTotal - _discount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.96,
      minChildSize: 0.86,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Row(
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
                            'Create Sales Order',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.75),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.75),
                              ),
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
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Shree Ganesh Traders',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Dadar, Mumbai',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textLightMuted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Add Products',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.72),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.adminSidebarBg,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintText: 'Search products...',
                                      hintStyle: TextStyle(
                                        color: AppColors.textLightMuted,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final product in _products) ...[
                            _ProductRow(
                              product: product,
                              onMinus: () {
                                setState(() {
                                  if (product.quantity > 0) {
                                    product.quantity -= 1;
                                  }
                                });
                              },
                              onPlus: () {
                                setState(() {
                                  product.quantity += 1;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.72),
                              ),
                            ),
                            child: Column(
                              children: [
                                _SummaryRow(
                                  label: 'Items (${_products.length})',
                                  value: 'Rs. $_itemsTotal',
                                ),
                                const SizedBox(height: 8),
                                _SummaryRow(
                                  label: 'Discount',
                                  value: '- Rs. $_discount',
                                  valueColor: AppColors.red,
                                ),
                                const Divider(height: 18),
                                _SummaryRow(
                                  label: 'Total Amount',
                                  value: 'Rs. $_grandTotal',
                                  emphasize: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Draft',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit Order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
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
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.5,
          ),
        ),
        Text(value, style: textStyle),
      ],
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

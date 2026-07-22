import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

// Place this file at: lib/screens/purchases/purchases_screen.dart

class _PurchaseItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const _PurchaseItem({required this.name, required this.quantity, required this.unitPrice});

  double get lineTotal => quantity * unitPrice;
}

class _PurchaseInvoice {
  final String poNumber;
  final DateTime date;
  final String supplier;
  final List<_PurchaseItem> items;

  const _PurchaseInvoice({
    required this.poNumber,
    required this.date,
    required this.supplier,
    required this.items,
  });

  double get totalAmount => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get itemCount => items.length;
}

/// Purchase Invoices screen — styled with colored stat chips (Total Amount /
/// Items) inside each card instead of a plain divider + text list, to look
/// distinct from the flat reference layout while keeping the same info.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  // Mock data — replace with your providers / API calls.
  final List<_PurchaseInvoice> _invoices = [
    _PurchaseInvoice(
      poNumber: 'PO-2024-001',
      date: DateTime(2024, 7, 15),
      supplier: 'Prime Manufacturing',
      items: const [
        _PurchaseItem(name: 'Packaged Water (1L)', quantity: 500, unitPrice: 20),
        _PurchaseItem(name: 'Bottle Crates', quantity: 50, unitPrice: 220),
        _PurchaseItem(name: 'Jar Caps (Pack of 10)', quantity: 100, unitPrice: 90),
      ],
    ),
    _PurchaseInvoice(
      poNumber: 'PO-2024-002',
      date: DateTime(2024, 7, 10),
      supplier: 'Bottle Suppliers Inc',
      items: const [
        _PurchaseItem(name: 'Water Jar (20L)', quantity: 300, unitPrice: 45),
        _PurchaseItem(name: 'Dispenser Tap Kit', quantity: 20, unitPrice: 150),
      ],
    ),
  ];

  Future<void> _openInvoiceFormDialog({_PurchaseInvoice? existing, int? index}) async {
    final result = await showDialog<_PurchaseInvoice>(
      context: context,
      builder: (_) => _PurchaseInvoiceFormDialog(existing: existing),
    );
    if (result == null) return;
    setState(() {
      if (index != null) {
        _invoices[index] = result;
      } else {
        _invoices.add(result);
      }
    });
  }

  Future<void> _confirmDelete(_PurchaseInvoice invoice, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete invoice?', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently remove "${invoice.poNumber}" from your purchase records.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _invoices.removeAt(index));
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatMoney(num value) {
    final digits = value.round().toString();
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    final parts = <String>[];
    String rest = digits.substring(0, digits.length - 3);
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Purchases'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Purchases',
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
                              Text('Purchase Invoices',
                                  style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                              SizedBox(height: 4),
                              Text('Manage all your purchase invoices',
                                  style: TextStyle(color: textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openInvoiceFormDialog(),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Invoice'),
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
                    if (_invoices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('No purchase invoices yet.', style: TextStyle(color: textSecondary, fontSize: 13)),
                        ),
                      )
                    else
                      ..._invoices.asMap().entries.map((entry) {
                        final index = entry.key;
                        final invoice = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _invoiceCard(invoice, index),
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

  // ---------------- Invoice card (distinct layout — colored stat chips) ----------------
  Widget _invoiceCard(_PurchaseInvoice invoice, int index) {
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.poNumber,
                        style: const TextStyle(color: textPrimary, fontSize: 15.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(_formatDate(invoice.date), style: const TextStyle(color: textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _openInvoiceFormDialog(existing: invoice, index: index),
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.purple),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.purple.withValues(alpha: 0.08),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _confirmDelete(invoice, index),
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.red),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.red.withValues(alpha: 0.08),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 15, color: textSecondary),
                const SizedBox(width: 6),
                Text(invoice.supplier,
                    style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('₹${_formatMoney(invoice.totalAmount)}',
                          style: const TextStyle(color: AppColors.purple, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Items', style: TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${invoice.itemCount}',
                          style: const TextStyle(color: AppColors.green, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
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

// =====================================================================
// Add / Edit Invoice dialog
// =====================================================================

class _ItemFormRow {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController priceController;

  _ItemFormRow({String name = '', String qty = '', String price = ''})
      : nameController = TextEditingController(text: name),
        qtyController = TextEditingController(text: qty),
        priceController = TextEditingController(text: price);

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }

  double get lineTotal {
    final qty = int.tryParse(qtyController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    return qty * price;
  }
}

class _PurchaseInvoiceFormDialog extends StatefulWidget {
  final _PurchaseInvoice? existing;

  const _PurchaseInvoiceFormDialog({this.existing});

  @override
  State<_PurchaseInvoiceFormDialog> createState() => _PurchaseInvoiceFormDialogState();
}

class _PurchaseInvoiceFormDialogState extends State<_PurchaseInvoiceFormDialog> {
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  late final TextEditingController _supplierController;
  late final TextEditingController _poNumberController;
  late DateTime _date;
  late List<_ItemFormRow> _itemRows;

  String? _supplierError;
  String? _poNumberError;
  String? _itemsError;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _supplierController = TextEditingController(text: existing?.supplier ?? '');
    _poNumberController = TextEditingController(text: existing?.poNumber ?? '');
    _date = existing?.date ?? DateTime.now();

    if (existing != null && existing.items.isNotEmpty) {
      _itemRows = existing.items
          .map((i) => _ItemFormRow(
                name: i.name,
                qty: i.quantity.toString(),
                price: i.unitPrice.toString(),
              ))
          .toList();
    } else {
      _itemRows = [_ItemFormRow()];
    }
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _poNumberController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addItemRow() {
    setState(() => _itemRows.add(_ItemFormRow()));
  }

  void _removeItemRow(int index) {
    setState(() {
      _itemRows[index].dispose();
      _itemRows.removeAt(index);
    });
  }

  double get _totalAmount => _itemRows.fold(0, (sum, row) => sum + row.lineTotal);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final supplier = _supplierController.text.trim();
    final poNumber = _poNumberController.text.trim();

    setState(() {
      _supplierError = supplier.isEmpty ? 'Supplier name is required' : null;
      _poNumberError = poNumber.isEmpty ? 'Invoice number is required' : null;
    });

    final validItems = _itemRows.where((row) {
      final name = row.nameController.text.trim();
      final qty = int.tryParse(row.qtyController.text.trim()) ?? 0;
      return name.isNotEmpty && qty > 0;
    }).toList();

    setState(() {
      _itemsError = validItems.isEmpty ? 'Add at least one item with a name and quantity' : null;
    });

    if (_supplierError != null || _poNumberError != null || _itemsError != null) return;

    final items = validItems
        .map((row) => _PurchaseItem(
              name: row.nameController.text.trim(),
              quantity: int.tryParse(row.qtyController.text.trim()) ?? 0,
              unitPrice: double.tryParse(row.priceController.text.trim()) ?? 0,
            ))
        .toList();

    Navigator.of(context).pop(_PurchaseInvoice(
      poNumber: poNumber,
      date: _date,
      supplier: supplier,
      items: items,
    ));
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_isEditing ? 'Edit Purchase Invoice' : 'Add Purchase Invoice',
                        style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
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
                    _fieldLabel('Supplier Name'),
                    TextField(
                      controller: _supplierController,
                      autofocus: !_isEditing,
                      onChanged: (_) {
                        if (_supplierError != null) setState(() => _supplierError = null);
                      },
                      decoration: _decoration(hint: 'e.g. Prime Manufacturing', errorText: _supplierError),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Invoice Number'),
                              TextField(
                                controller: _poNumberController,
                                onChanged: (_) {
                                  if (_poNumberError != null) setState(() => _poNumberError = null);
                                },
                                decoration: _decoration(hint: 'e.g. PO-2024-003', errorText: _poNumberError),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Date'),
                              GestureDetector(
                                onTap: _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.24)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(_formatDate(_date),
                                            style: const TextStyle(color: textPrimary, fontSize: 14)),
                                      ),
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Items', style: TextStyle(color: textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700)),
                        ),
                        TextButton.icon(
                          onPressed: _addItemRow,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.purple),
                          label: const Text('Add Item', style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    if (_itemsError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(_itemsError!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                      ),
                    ..._itemRows.asMap().entries.map((entry) => _itemRowWidget(entry.key, entry.value)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount',
                              style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                          Text('₹${_totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.purple, fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: const BorderSide(color: AppColors.purple, width: 1.4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
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
                    child: Text(_isEditing ? 'Update Invoice' : 'Add Invoice'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRowWidget(int index, _ItemFormRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: row.nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: _decoration(hint: 'Item name'),
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _itemRows.length > 1 ? () => _removeItemRow(index) : null,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 22,
                    color: _itemRows.length > 1 ? AppColors.red : textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: row.qtyController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: _decoration(hint: 'Qty'),
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: row.priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: _decoration(hint: 'Unit Price'),
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    '₹${row.lineTotal.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.24)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.24)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purple),
      ),
    );
  }
}

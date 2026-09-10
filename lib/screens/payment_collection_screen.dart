import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../models/customer_model.dart';
import '../providers/api_provider.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({
    super.key,
    this.customersUrl,
    this.customerDetailUrlTemplate,
    this.collectPaymentUrl,
    this.authToken,
  });

  final String? customersUrl;
  final String? customerDetailUrlTemplate;
  final String? collectPaymentUrl;
  final String? authToken;

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  List<_PaymentCustomer> _customers = const [];
  _PaymentCustomer? _selectedCustomer;
  String _paymentMode = 'cash';
  bool _loadingCustomers = true;
  bool _loadingDetail = false;
  bool _submitting = false;
  String? _error;

  String get _paymentUrlTemplate =>
      widget.collectPaymentUrl ??
      ApiConstants.baseUrl + ApiEndpoints.customersPaymentsTemplate;

  double get _amountCollected =>
      double.tryParse(_amountController.text.trim()) ?? 0;
  double get _amountDue => _selectedCustomer?.pendingAmount ?? 0;
  double get _remainingAmount =>
      (_amountDue - _amountCollected).clamp(0, double.infinity).toDouble();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loadingCustomers = true;
      _error = null;
    });
    try {
      final customers = await ApiProviderScope.of(context).fetchCustomers();
      if (!mounted) return;
      setState(() {
        _customers = customers.map(_PaymentCustomer.fromModel).toList();
        _loadingCustomers = false;
      });
    } catch (_) {
      setState(() {
        _loadingCustomers = false;
        _error = 'Could not load customers. Please try again.';
      });
    }
  }

  Future<void> _selectCustomer(_PaymentCustomer? customer) async {
    if (customer == null) return;
    setState(() {
      _selectedCustomer = customer;
      _loadingDetail = true;
      _amountController.clear();
    });
    try {
      final detail = await ApiProviderScope.of(
        context,
      ).fetchCustomerById(customer.id.toString());
      final next = _PaymentCustomer.fromModel(detail);
      if (!mounted) return;
      setState(() {
        _selectedCustomer = next;
        _amountController.text = next.pendingAmount > 0
            ? _plainAmount(next.pendingAmount)
            : '';
        _loadingDetail = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load pending amount.')),
      );
    }
  }

  Future<void> _recordCollection() async {
    if (!_formKey.currentState!.validate() || _selectedCustomer == null) return;
    setState(() => _submitting = true);
    try {
      final url = _paymentUrlTemplate.replaceAll(
        '{customer_id}',
        _selectedCustomer!.id.toString(),
      );
      final response = await http.post(
        Uri.parse(url),
        headers: {
          ..._headers,
          ApiConstants.contentTypeHeader: ApiConstants.jsonMimeType,
        },
        body: jsonEncode({
          'customer_id': _selectedCustomer!.id,
          'amount': _amountCollected,
          'payment_amount': _amountCollected,
          'payment_mode': _paymentMode,
          'payment_method': _paymentMode,
          'reference': _referenceController.text.trim(),
          'notes': _notesController.text.trim(),
          'remaining_amount': _remainingAmount,
        }),
      );
      if (!mounted) return;
      if (!_isSuccess(response.statusCode)) throw Exception();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection recorded successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, String> get _headers {
    final token = widget.authToken;
    return {
      ApiConstants.acceptHeader: ApiConstants.jsonMimeType,
      if (token != null && token.isNotEmpty)
        ApiConstants.authorizationHeader:
            ApiConstants.bearerPrefix + ' ' + token,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        backgroundColor: AppColors.deliveryBackground,
        appBar: AppBar(
          title: const Text('Create Collection'),
          backgroundColor: AppColors.deliveryDashboardHeaderEnd,
          foregroundColor: AppColors.surface,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _body(),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    _Footer(
                      busy: _submitting,
                      onCancel: () => Navigator.of(context).maybePop(),
                      onSubmit: _recordCollection,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loadingCustomers) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.6)),
      );
    }
    if (_error != null)
      return _ErrorState(message: _error!, onRetry: _loadCustomers);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Customer'),
        const SizedBox(height: 8),
        DropdownButtonFormField<_PaymentCustomer>(
          value: _selectedCustomer,
          isExpanded: true,
          decoration: _decoration(),
          hint: const Text('Select customer'),
          items: _customers
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _loadingDetail ? null : _selectCustomer,
          validator: (v) => v == null ? 'Please select customer' : null,
        ),
        const SizedBox(height: 16),
        _AmountSummary(
          orderTotal: _amountDue,
          amountDue: _amountDue,
          loading: _loadingDetail,
        ),
        const SizedBox(height: 22),
        const _Label('Payment Mode'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _paymentMode,
          isExpanded: true,
          decoration: _decoration(),
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'upi', child: Text('UPI')),
            DropdownMenuItem(
              value: 'bank_transfer',
              child: Text('Bank Transfer'),
            ),
            DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
            DropdownMenuItem(value: 'card', child: Text('Card')),
          ],
          onChanged: (v) => setState(() => _paymentMode = v ?? 'cash'),
        ),
        const SizedBox(height: 22),
        const _Label('Amount'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          enabled: _selectedCustomer != null && !_loadingDetail,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _decoration(hintText: '0'),
          validator: (value) {
            final amount = double.tryParse((value ?? '').trim());
            if (_selectedCustomer == null) return 'Please select customer';
            if (amount == null || amount <= 0) return 'Enter amount';
            if (amount > _amountDue)
              return 'Amount cannot be more than pending amount';
            return null;
          },
        ),
        const SizedBox(height: 22),
        const _Label('Reference (optional)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _referenceController,
          decoration: _decoration(hintText: 'Txn / cheque / UPI reference'),
        ),
        const SizedBox(height: 22),
        const _Label('Notes (optional)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          minLines: 3,
          maxLines: 4,
          decoration: _decoration(),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Remaining: ' + _formatMoney(_remainingAmount),
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA3AF),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFFBFCFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: _border(const Color(0xFFE1E6EE)),
      enabledBorder: _border(const Color(0xFFE1E6EE)),
      focusedBorder: _border(AppColors.deliveryGreen, width: 1.2),
      errorBorder: _border(const Color(0xFFDC2626)),
      focusedErrorBorder: _border(const Color(0xFFDC2626), width: 1.2),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.busy,
    required this.onCancel,
    required this.onSubmit,
  });
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: busy ? null : onCancel,
            style: TextButton.styleFrom(
              minimumSize: const Size(94, 50),
              foregroundColor: const Color(0xFF172033),
              backgroundColor: const Color(0xFFF4F5F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: busy ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(162, 50),
              backgroundColor: const Color(0xFF064B08),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF9AB99B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Record Collection'),
          ),
        ],
      ),
    );
  }
}

class _AmountSummary extends StatelessWidget {
  const _AmountSummary({
    required this.orderTotal,
    required this.amountDue,
    required this.loading,
  });
  final double orderTotal;
  final double amountDue;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E6EE)),
      ),
      child: loading
          ? const SizedBox(
              height: 58,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AmountRow(label: 'Order Total', value: orderTotal),
                const SizedBox(height: 4),
                _AmountRow(label: 'Amount Due', value: amountDue),
                const SizedBox(height: 12),
                const Text(
                  'Recording a collection does not mark the invoice paid - the accounts team reconciles it.',
                  style: TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          _formatMoney(value),
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 16,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF344054),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFF64748B),
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCustomer {
  const _PaymentCustomer({
    required this.id,
    required this.name,
    required this.pendingAmount,
    required this.raw,
  });
  final dynamic id;
  final String name;
  final double pendingAmount;
  final Map<String, dynamic> raw;

  @override
  bool operator ==(Object other) {
    return other is _PaymentCustomer && other.id.toString() == id.toString();
  }

  @override
  int get hashCode => id.toString().hashCode;

  factory _PaymentCustomer.fromModel(CustomerModel customer) {
    return _PaymentCustomer(
      id: customer.id,
      name: customer.name.trim().isNotEmpty
          ? customer.name
          : 'Unnamed Customer',
      pendingAmount: (customer.outstanding ?? 0).toDouble(),
      raw: const {},
    );
  }
}

bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;
String _plainAmount(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(2);
}

String _formatMoney(double value) {
  final rounded = value.round();
  final source = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final remaining = source.length - i;
    buffer.write(source[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return (rounded < 0 ? '-Rs ' : 'Rs ') + buffer.toString();
}

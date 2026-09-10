import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({
    super.key,
    required this.customersUrl,
    required this.collectPaymentUrl,
    this.authToken,
  });

  final String customersUrl;
  final String collectPaymentUrl;
  final String? authToken;

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  List<_PaymentCustomer> _customers = const [];
  _PaymentCustomer? _selectedCustomer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  double get _collectedAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  double get _remainingAmount {
    final pending = _selectedCustomer?.pendingAmount ?? 0;
    final remaining = pending - _collectedAmount;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(widget.customersUrl),
        headers: _headers,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to load customers');
      }

      final decoded = jsonDecode(response.body);
      final rawCustomers = decoded is List
          ? decoded
          : decoded['data'] is List
              ? decoded['data']
              : decoded['customers'] is List
                  ? decoded['customers']
                  : const [];

      final customers = rawCustomers
          .whereType<Map<String, dynamic>>()
          .map(_PaymentCustomer.fromJson)
          .where((customer) => customer.pendingAmount > 0)
          .toList();

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load customers. Please try again.';
      });
    }
  }

  Future<void> _collectPayment() async {
    if (!_formKey.currentState!.validate() || _selectedCustomer == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final collectPaymentUrl = widget.collectPaymentUrl.replaceAll(
        '{customer_id}',
        _selectedCustomer!.id.toString(),
      );
      final response = await http.post(
        Uri.parse(collectPaymentUrl),
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': _selectedCustomer!.id,
          'amount': _collectedAmount,
          'remaining_amount': _remainingAmount,
          'note': _noteController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to collect payment');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment collected successfully')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment collection failed')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Map<String, String> get _headers {
    final token = widget.authToken;
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.9,
      maxScaleFactor: 1.2,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          title: const Text('Collect Payment'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF172033),
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.6));
    }

    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadCustomers);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SummaryPanel(
            pendingAmount: _selectedCustomer?.pendingAmount ?? 0,
            collectedAmount: _collectedAmount,
            remainingAmount: _remainingAmount,
          ),
          const SizedBox(height: 20),
          _SectionCard(
            children: [
              DropdownButtonFormField<_PaymentCustomer>(
                value: _selectedCustomer,
                isExpanded: true,
                decoration: _inputDecoration(
                  label: 'Customer',
                  icon: Icons.person_outline_rounded,
                ),
                items: _customers
                    .map(
                      (customer) => DropdownMenuItem(
                        value: customer,
                        child: Text(
                          customer.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (customer) {
                  setState(() {
                    _selectedCustomer = customer;
                    _amountController.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a customer' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                enabled: _selectedCustomer != null,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  label: 'Collected Amount',
                  icon: Icons.payments_outlined,
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  final pending = _selectedCustomer?.pendingAmount ?? 0;

                  if (amount == null || amount <= 0) {
                    return 'Enter collected amount';
                  }
                  if (amount > pending) {
                    return 'Amount cannot be more than pending amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: _inputDecoration(
                  label: 'Note',
                  icon: Icons.notes_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _collectPayment,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 22),
              label: Text(_isSubmitting ? 'Collecting...' : 'Collected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6BFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF9DBAF9),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E6BFF), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.pendingAmount,
    required this.collectedAmount,
    required this.remainingAmount,
  });

  final double pendingAmount;
  final double collectedAmount;
  final double remainingAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AmountTile(
                  label: 'Pending',
                  amount: pendingAmount,
                  color: const Color(0xFFFFC857),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AmountTile(
                  label: 'Collected',
                  amount: collectedAmount,
                  color: const Color(0xFF6EE7B7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AmountTile(
            label: 'Remaining',
            amount: remainingAmount,
            color: const Color(0xFF93C5FD),
            isWide: true,
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.amount,
    required this.color,
    this.isWide = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFF64748B),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
  });

  final dynamic id;
  final String name;
  final double pendingAmount;

  factory _PaymentCustomer.fromJson(Map<String, dynamic> json) {
    return _PaymentCustomer(
      id: json['id'] ?? json['customer_id'],
      name: (json['name'] ??
              json['customer_name'] ??
              json['full_name'] ??
              'Unnamed Customer')
          .toString(),
      pendingAmount: _toDouble(
        json['pending_amount'] ??
            json['pendingAmount'] ??
            json['due_amount'] ??
            json['remaining_amount'] ??
            0,
      ),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatAmount(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}

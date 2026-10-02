import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/end_of_day_return_models.dart';
import 'end_of_day_shared.dart';

class StockReturnForm extends StatefulWidget {
  final EndOfDaySession session;
  final String? error;
  final bool isSaving;
  final VoidCallback onDismissError;
  final Future<void> Function(Map<String, double> returns) onSubmit;

  const StockReturnForm({
    super.key,
    required this.session,
    required this.error,
    required this.isSaving,
    required this.onDismissError,
    required this.onSubmit,
  });

  @override
  State<StockReturnForm> createState() => _StockReturnFormState();
}

class _StockReturnFormState extends State<StockReturnForm> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant StockReturnForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id) {
      _disposeControllers();
      _controllers.clear();
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }

  void _syncControllers() {
    for (final item in widget.session.items) {
      _controllers[item.id] = TextEditingController(
        text: qty(item.returnedQuantity),
      );
    }
  }

  bool _hasInvalidReturn() {
    for (final item in widget.session.items) {
      final value = _valueFor(item);
      if (value < 0 || value > item.loadedQuantity) return true;
    }
    return false;
  }

  double _valueFor(EndOfDayStockItem item) {
    final controller = _controllers[item.id];
    return double.tryParse((controller?.text ?? '').trim()) ?? 0;
  }

  Future<void> _submit() async {
    if (_hasInvalidReturn()) {
      setState(() {});
      return;
    }
    final returns = <String, double>{};
    for (final item in widget.session.items) {
      returns[item.id] = _valueFor(item);
    }
    await widget.onSubmit(returns);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.error != null) ...[
          EndOfDayErrorBanner(
            message: widget.error!,
            onDismiss: widget.onDismissError,
          ),
          const SizedBox(height: 12),
        ],
        EndOfDayCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Text(
                  'Stock Return',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE9EDF5)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  children: [
                    for (final item in widget.session.items) ...[
                      _returnRow(item),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: widget.isSaving ? null : _submit,
                    icon: widget.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save End of Day Return'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.55,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _returnRow(EndOfDayStockItem item) {
    final value = _valueFor(item);
    final invalid = value > item.loadedQuantity || value < 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EndOfDayProductImage(imageUrl: item.imageUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName.isEmpty
                          ? 'Unnamed product'
                          : item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 14,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.variantId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Variant: ${item.variantId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuantityChip(
                  label: 'Loaded',
                  value: item.loadedQuantity,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuantityChip(
                  label: 'Delivered',
                  value: item.deliveredQuantity,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _controllers[item.id],
                    enabled: !widget.isSaving,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Return',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (invalid) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.deliveryRed.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Return exceeds loaded quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deliveryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityChip extends StatelessWidget {
  final String label;
  final double value;

  const _QuantityChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            qty(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deliveryGreen,
              fontSize: 13,
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
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

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
              const _ReturnHeader(),
              ...widget.session.items.map(_ReturnRow),
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
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.55),
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

  Widget _ReturnRow(EndOfDayStockItem item) {
    final value = _valueFor(item);
    final invalid = value > item.loadedQuantity || value < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9EDF5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                EndOfDayProductImage(imageUrl: item.imageUrl),
                const SizedBox(width: 8),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.variantId.isEmpty ? '-' : item.variantId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _NumberText(qty(item.loadedQuantity))),
          Expanded(flex: 2, child: _NumberText(qty(item.deliveredQuantity))),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _controllers[item.id],
                    enabled: !widget.isSaving,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '0 - ${qty(item.loadedQuantity)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (invalid) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deliveryRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Return exceeds loaded quantity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.deliveryRed,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnHeader extends StatelessWidget {
  const _ReturnHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Expanded(flex: 4, child: _HeaderText('Product')),
          Expanded(flex: 2, child: _HeaderText('Loaded')),
          Expanded(flex: 2, child: _HeaderText('Delivered')),
          Expanded(flex: 3, child: _HeaderText('Actual Return')),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.deliveryInk,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _NumberText extends StatelessWidget {
  final String text;

  const _NumberText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.deliveryInk,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

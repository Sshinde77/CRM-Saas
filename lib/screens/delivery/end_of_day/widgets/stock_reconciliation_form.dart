import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/end_of_day_return_models.dart';
import 'end_of_day_shared.dart';

class StockReconciliationForm extends StatefulWidget {
  final EndOfDaySession session;
  final String? error;
  final bool isSaving;
  final VoidCallback onDismissError;
  final Future<void> Function({
    required Map<String, double> physicalCounts,
    required String notes,
  }) onSubmit;

  const StockReconciliationForm({
    super.key,
    required this.session,
    required this.error,
    required this.isSaving,
    required this.onDismissError,
    required this.onSubmit,
  });

  @override
  State<StockReconciliationForm> createState() =>
      _StockReconciliationFormState();
}

class _StockReconciliationFormState extends State<StockReconciliationForm> {
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant StockReconciliationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id) {
      _disposeItemControllers();
      _controllers.clear();
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _disposeItemControllers();
    _notesController.dispose();
    super.dispose();
  }

  void _disposeItemControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }

  void _syncControllers() {
    for (final item in widget.session.items) {
      _controllers[item.id] = TextEditingController(
        text: qty(item.expectedClosingQuantity),
      );
    }
  }

  double _valueFor(EndOfDayStockItem item) {
    final controller = _controllers[item.id];
    return double.tryParse((controller?.text ?? '').trim()) ?? 0;
  }

  Future<void> _submit() async {
    final counts = <String, double>{};
    for (final item in widget.session.items) {
      counts[item.id] = _valueFor(item);
    }
    await widget.onSubmit(
      physicalCounts: counts,
      notes: _notesController.text,
    );
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
                  'Physical Count',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE9EDF5)),
              const _ReconcileHeader(),
              ...widget.session.items.map(_ReconcileRow),
            ],
          ),
        ),
        const SizedBox(height: 12),
        EndOfDayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                enabled: !widget.isSaving,
                minLines: 4,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'e.g. 2 units missing/damaged',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
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
                      : const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Save Reconciliation'),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _ReconcileRow(EndOfDayStockItem item) {
    final physical = _valueFor(item);
    final variance = physical - item.expectedClosingQuantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9EDF5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isEmpty ? 'Unnamed product' : item.productName,
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
          Expanded(
            flex: 2,
            child: Text(
              qty(item.expectedClosingQuantity),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
                  '0 - ${qty(item.expectedClosingQuantity)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 3, child: VarianceBadge(variance: variance)),
        ],
      ),
    );
  }
}

class _ReconcileHeader extends StatelessWidget {
  const _ReconcileHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Expanded(flex: 4, child: _HeaderText('Product')),
          Expanded(flex: 2, child: _HeaderText('Expected Closing')),
          Expanded(flex: 3, child: _HeaderText('Physical Count')),
          Expanded(flex: 3, child: _HeaderText('Variance')),
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

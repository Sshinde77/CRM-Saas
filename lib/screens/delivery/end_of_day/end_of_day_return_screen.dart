import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/end_of_day_return_models.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_bottom_navigation.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import 'widgets/end_of_day_empty_state.dart';
import 'widgets/end_of_day_shared.dart';
import 'widgets/reconciliation_summary.dart';
import 'widgets/stock_reconciliation_form.dart';
import 'widgets/stock_return_form.dart';

enum _EndOfDayStep { returnStock, reconcile, summary }

class EndOfDayReturnScreen extends StatefulWidget {
  const EndOfDayReturnScreen({super.key});

  @override
  State<EndOfDayReturnScreen> createState() => _EndOfDayReturnScreenState();
}

class _EndOfDayReturnScreenState extends State<EndOfDayReturnScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<EndOfDaySession?>? _future;
  EndOfDaySession? _session;
  _EndOfDayStep _step = _EndOfDayStep.returnStock;
  final bool _isSavingReturn = false;
  bool _isSavingReconciliation = false;
  String? _returnError;
  String? _reconciliationError;
  List<ReconciliationLine> _summaryLines = const [];
  Map<String, double> _pendingReturns = const {};
  bool _reconciliationCompleted = false;
  bool _didStartLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _load();
      _didStartLoad = true;
    }
  }

  Future<EndOfDaySession?> _load() async {
    final provider = ApiProviderScope.of(context);
    final authMe = await provider.fetchAuthMe();
    final currentUser = provider.currentUser ?? authMe?.user;
    final deliveryPartnerId = currentUser?.id?.trim();
    if (deliveryPartnerId == null || deliveryPartnerId.isEmpty) {
      throw const _EndOfDayException('Delivery partner id is missing.');
    }

    final rawSession = await provider.fetchCurrentVehicleStock(
      deliveryPartnerId,
    );
    if (rawSession == null) return null;
    final session = EndOfDaySession.fromJson(rawSession);
    if (mounted) {
      setState(() => _session = session);
    }
    return session;
  }

  Future<void> _refresh() async {
    final request = _load();
    setState(() => _future = request);
    await request;
  }

  Future<void> _saveReturn(Map<String, double> returns) async {
    final session = _session;
    if (session == null) return;
    setState(() {
      _returnError = null;
      _pendingReturns = Map<String, double>.from(returns);
      _reconciliationCompleted = false;
      _step = _EndOfDayStep.reconcile;
    });
  }

  Future<void> _saveReconciliation({
    required Map<String, double> physicalCounts,
    required String notes,
  }) async {
    final session = _session;
    if (session == null) return;

    setState(() {
      _reconciliationError = null;
      _isSavingReconciliation = true;
    });

    try {
      final payloadItems = session.items.map((item) {
        return {
          'loading_item_id': item.id,
          'product_id': item.productId,
          'variant_id': item.variantId,
          'physical_qty': physicalCounts[item.id] ?? 0,
        };
      }).toList();
      final provider = ApiProviderScope.of(context);
      if (!_reconciliationCompleted) {
        await provider.reconcileVehicleStock(
          sessionId: session.id,
          payload: {'notes': notes.trim(), 'items': payloadItems},
        );
        _reconciliationCompleted = true;
      }

      final returnItems = session.items.map((item) {
        return {
          'product_id': item.productId,
          if (item.variantId.isNotEmpty) 'variant_id': item.variantId,
          'returned_qty': _pendingReturns[item.id] ?? 0,
        };
      }).toList();
      final response = await provider.submitEndOfDayReturn(
        sessionId: session.id,
        items: returnItems,
      );
      final nextSession =
          _sessionFromResponse(response) ??
          session.copyWithItems(
            session.items
                .map(
                  (item) => item.copyWithReturn(
                    _pendingReturns[item.id] ?? 0,
                  ),
                )
                .toList(),
          );

      final lines = session.items.map((item) {
        return ReconciliationLine(
          item: item,
          expected: item.expectedClosingQuantity,
          physical: physicalCounts[item.id] ?? 0,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _session = nextSession;
        _summaryLines = lines;
        _step = _EndOfDayStep.summary;
      });
      _showSnack('Reconciliation saved and vehicle stock closed.');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reconciliationError =
            'Failed to save reconciliation. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSavingReconciliation = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.deliveryGreen,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAF9),
      drawer: const DeliveryPartnerSidebar(
        currentRoute: AppRoutes.deliveryEndOfDay,
      ),
      bottomNavigationBar: const DeliveryBottomNavigation(currentIndex: -1),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<EndOfDaySession?>(
          future: _future,
          builder: (context, snapshot) {
            final session = _session ?? snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData;

            return Column(
              children: [
                DeliveryTopBar(
                  title: _title,
                  subtitle: _subtitle,
                  leadingIcon: _step == _EndOfDayStep.returnStock
                      ? Icons.menu_rounded
                      : Icons.arrow_back_rounded,
                  onLeadingTap: _handleLeadingTap,
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.deliveryGreen,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 116),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: isLoading
                              ? const EndOfDayLoadingState()
                              : snapshot.hasError
                              ? Column(
                                  children: [
                                    EndOfDayErrorBanner(
                                      message: _cleanError(snapshot.error),
                                      onDismiss: () {},
                                    ),
                                    const SizedBox(height: 12),
                                    const EndOfDayEmptyState(),
                                  ],
                                )
                              : session == null || session.items.isEmpty
                              ? const EndOfDayEmptyState()
                              : Column(
                                  children: [
                                    _EndOfDayProgress(
                                      step: _step,
                                      session: session,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStep(session),
                                  ],
                                ),
                        ),
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

  Widget _buildStep(EndOfDaySession session) {
    return switch (_step) {
      _EndOfDayStep.returnStock => StockReturnForm(
        session: session,
        error: _returnError,
        isSaving: _isSavingReturn,
        onDismissError: () => setState(() => _returnError = null),
        onSubmit: _saveReturn,
      ),
      _EndOfDayStep.reconcile => StockReconciliationForm(
        session: session,
        error: _reconciliationError,
        isSaving: _isSavingReconciliation,
        onDismissError: () => setState(() => _reconciliationError = null),
        onSubmit: _saveReconciliation,
      ),
      _EndOfDayStep.summary => ReconciliationSummary(lines: _summaryLines),
    };
  }

  void _handleLeadingTap() {
    if (_step == _EndOfDayStep.returnStock) {
      _scaffoldKey.currentState?.openDrawer();
      return;
    }
    setState(() {
      _step = _step == _EndOfDayStep.summary
          ? _EndOfDayStep.reconcile
          : _EndOfDayStep.returnStock;
    });
  }

  String get _title {
    return switch (_step) {
      _EndOfDayStep.returnStock => 'End of Day Return',
      _EndOfDayStep.reconcile => 'Stock Reconciliation',
      _EndOfDayStep.summary => 'Reconciliation Summary',
    };
  }

  String get _subtitle {
    return switch (_step) {
      _EndOfDayStep.returnStock =>
        'Record returned stock against what was loaded this morning',
      _EndOfDayStep.reconcile =>
        'Count physical stock against expected closing quantity.',
      _EndOfDayStep.summary =>
        'Physical count variance against expected closing stock.',
    };
  }
}

class _EndOfDayProgress extends StatelessWidget {
  final _EndOfDayStep step;
  final EndOfDaySession session;

  const _EndOfDayProgress({required this.step, required this.session});

  int get _stepIndex => switch (step) {
    _EndOfDayStep.returnStock => 0,
    _EndOfDayStep.reconcile => 1,
    _EndOfDayStep.summary => 2,
  };

  @override
  Widget build(BuildContext context) {
    final loaded = session.items.fold<double>(
      0,
      (sum, item) => sum + item.loadedQuantity,
    );
    final delivered = session.items.fold<double>(
      0,
      (sum, item) => sum + item.deliveredQuantity,
    );
    final expected = session.items.fold<double>(
      0,
      (sum, item) => sum + item.expectedClosingQuantity,
    );

    return EndOfDayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _EndOfDayIconBox(icon: Icons.assignment_return_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.vehicleNumber.trim().isEmpty
                          ? 'End of Day Session'
                          : session.vehicleNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 16,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${session.items.length} products to close',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StepPill(step: step),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EndOfDayMetric(
                  label: 'Loaded',
                  value: qty(loaded),
                  color: AppColors.deliveryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EndOfDayMetric(
                  label: 'Delivered',
                  value: qty(delivered),
                  color: AppColors.deliveryOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EndOfDayMetric(
                  label: 'Expected',
                  value: qty(expected),
                  color: AppColors.deliveryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StepDot(label: 'Return', active: _stepIndex >= 0),
              const _StepLine(),
              _StepDot(label: 'Count', active: _stepIndex >= 1),
              const _StepLine(),
              _StepDot(label: 'Summary', active: _stepIndex >= 2),
            ],
          ),
        ],
      ),
    );
  }
}

class _EndOfDayMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _EndOfDayMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
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
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndOfDayIconBox extends StatelessWidget {
  final IconData icon;

  const _EndOfDayIconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.deliveryGreenSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.deliveryGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Icon(icon, color: AppColors.deliveryGreen, size: 20),
    );
  }
}

class _StepPill extends StatelessWidget {
  final _EndOfDayStep step;

  const _StepPill({required this.step});

  @override
  Widget build(BuildContext context) {
    final label = switch (step) {
      _EndOfDayStep.returnStock => 'Return',
      _EndOfDayStep.reconcile => 'Count',
      _EndOfDayStep.summary => 'Done',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.deliveryGreenSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.deliveryGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.deliveryGreen,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;

  const _StepDot({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.deliveryGreen : AppColors.textMuted;
    return Column(
      children: [
        Icon(
          active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: color,
          size: 18,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 18),
        color: AppColors.deliverySurfaceBorder,
      ),
    );
  }
}

EndOfDaySession? _sessionFromResponse(Map<String, dynamic> response) {
  for (final key in const [
    'data',
    'session',
    'vehicle_stock',
    'vehicleStock',
  ]) {
    final value = response[key];
    if (value is Map<String, dynamic>) {
      return EndOfDaySession.fromJson(value);
    }
  }
  return null;
}

String _cleanError(Object? error) {
  final text = error?.toString().trim() ?? '';
  if (text.isEmpty) return 'Something went wrong.';
  return text.replaceFirst('ApiException: ', '');
}

class _EndOfDayException implements Exception {
  final String message;

  const _EndOfDayException(this.message);

  @override
  String toString() => message;
}

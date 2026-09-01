import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/end_of_day_return_models.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
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
  bool _isSavingReturn = false;
  bool _isSavingReconciliation = false;
  String? _returnError;
  String? _reconciliationError;
  List<ReconciliationLine> _summaryLines = const [];
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

    final rawSession = await provider.fetchCurrentVehicleStock(deliveryPartnerId);
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
      _isSavingReturn = true;
    });

    try {
      final payloadItems = session.items.map((item) {
        return {
          'product_id': item.productId,
          'returned_qty': returns[item.id] ?? 0,
        };
      }).toList();
      final response = await ApiProviderScope.of(context).submitEndOfDayReturn(
        sessionId: session.id,
        items: payloadItems,
      );
      final nextSession = _sessionFromResponse(response) ??
          session.copyWithItems(
            session.items
                .map((item) => item.copyWithReturn(returns[item.id] ?? 0))
                .toList(),
          );

      if (!mounted) return;
      setState(() {
        _session = nextSession;
        _step = _EndOfDayStep.reconcile;
      });
      _showSnack('End of day return recorded successfully.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _returnError = 'Failed to save return. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSavingReturn = false);
      }
    }
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
      await ApiProviderScope.of(context).reconcileVehicleStock(
        sessionId: session.id,
        payload: {
          'notes': notes.trim(),
          'items': payloadItems,
        },
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
        _summaryLines = lines;
        _step = _EndOfDayStep.summary;
      });
      _showSnack('Physical stock count has been saved.');
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
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
                                      : _buildStep(session),
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

EndOfDaySession? _sessionFromResponse(Map<String, dynamic> response) {
  for (final key in const ['data', 'session', 'vehicle_stock', 'vehicleStock']) {
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

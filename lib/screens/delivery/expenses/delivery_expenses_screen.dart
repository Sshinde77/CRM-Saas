import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/delivery_expense_model.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../services/api_service.dart';
import '../../../widgets/delivery/delivery_bottom_navigation.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryExpensesScreen extends StatefulWidget {
  const DeliveryExpensesScreen({super.key});

  @override
  State<DeliveryExpensesScreen> createState() => _DeliveryExpensesScreenState();
}

class _DeliveryExpensesScreenState extends State<DeliveryExpensesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late Future<_ExpensePageData> _future;
  bool _didStartLoad = false;
  String _statusFilter = 'All';
  bool _busy = false;

  static const _statusFilters = [
    'All',
    'Pending',
    'Clarification Required',
    'Approved',
    'Reimbursed',
    'Rejected',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _load();
      _didStartLoad = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_ExpensePageData> _load() async {
    final provider = ApiProviderScope.of(context);
    final authMe = await provider.fetchAuthMe();
    final currentUser = provider.currentUser ?? authMe?.user;
    final userId = currentUser?.id?.trim();

    if (userId == null || userId.isEmpty) {
      throw const _ExpenseException('Delivery partner id is missing.');
    }

    final results = await Future.wait([
      provider.fetchExpenseCategories(),
      provider.fetchExpenses(submittedBy: userId),
    ]);

    return _ExpensePageData(
      categories: results[0] as List<String>,
      expenses: results[1] as List<DeliveryExpense>,
      canCreate: provider.can('expenses', 'create'),
      canEdit: provider.can('expenses', 'edit'),
      canDelete: provider.can('expenses', 'delete'),
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  List<DeliveryExpense> _filtered(List<DeliveryExpense> expenses) {
    final query = _searchController.text.trim().toLowerCase();
    return expenses.where((expense) {
      final matchesStatus =
          _statusFilter == 'All' || expense.displayStatus == _statusFilter;
      final matchesQuery =
          query.isEmpty ||
          expense.category.toLowerCase().contains(query) ||
          expense.description.toLowerCase().contains(query) ||
          expense.expenseId.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  Future<void> _openForm(
    _ExpensePageData data, {
    DeliveryExpense? expense,
  }) async {
    if (data.categories.isEmpty) {
      _showSnack('Expense categories are not available yet.');
      return;
    }

    final result = await Navigator.of(context).push<_ExpenseFormResult>(
      MaterialPageRoute(
        builder: (context) => _ExpenseFormPage(
          categories: data.categories,
          initialExpense: expense,
        ),
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final provider = ApiProviderScope.of(context);
      final saved = expense == null
          ? await provider.createExpense(result.request)
          : await provider.updateExpense(
              expenseId: expense.id,
              request: result.request,
            );

      if (result.receiptBytes != null && saved.id.isNotEmpty) {
        await provider.uploadExpenseReceipt(
          expenseId: saved.id,
          fileBytes: result.receiptBytes!,
          fileName: result.receiptName ?? 'receipt.jpg',
        );
      }

      if (!mounted) return;
      _showSnack(expense == null ? 'Expense submitted.' : 'Expense updated.');
      await _refresh();
    } on ApiException catch (error) {
      _showSnack(error.message);
    } catch (error) {
      _showSnack('Expense save failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelExpense(DeliveryExpense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Claim'),
        content: Text('Cancel ${expense.expenseId}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deliveryRed,
            ),
            child: const Text('Cancel Claim'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ApiProviderScope.of(context).deleteExpense(expense.id);
      if (!mounted) return;
      _showSnack('Claim cancelled.');
      await _refresh();
    } on ApiException catch (error) {
      _showSnack(error.message);
    } catch (error) {
      _showSnack('Cancel failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showDetails(_ExpensePageData data, DeliveryExpense expense) {
    showDialog<void>(
      context: context,
      builder: (_) => _ExpenseDetailsDialog(
        expense: expense,
        canEdit: data.canEdit && expense.canUpdate,
        canCancel: data.canDelete && expense.canCancel,
        onEdit: () {
          Navigator.of(context).pop();
          _openForm(data, expense: expense);
        },
        onCancel: () {
          Navigator.of(context).pop();
          _cancelExpense(expense);
        },
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.deliveryBackground,
        drawer: const DeliveryPartnerSidebar(
          currentRoute: AppRoutes.deliveryExpenses,
        ),
        bottomNavigationBar: const DeliveryBottomNavigation(currentIndex: -1),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DeliveryTopBar(
                title: 'Expenses',
                subtitle: 'Track and submit work-related claims',
                leadingIcon: Icons.menu_rounded,
                onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                actions: [
                  DeliveryTopBarAction(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh',
                    onTap: () => _refresh(),
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder<_ExpensePageData>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const _StateView.loading();
                    }
                    if (snapshot.hasError && !snapshot.hasData) {
                      return _StateView.error(
                        message: snapshot.error.toString(),
                        onRetry: _refresh,
                      );
                    }

                    final data = snapshot.data!;
                    final expenses = _filtered(data.expenses);
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.deliveryGreen,
                      child: Stack(
                        children: [
                          ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenSmall,
                              AppSpacing.md,
                              AppSpacing.screenSmall,
                              AppSpacing.xl + 92,
                            ),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 820,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _HeaderCard(
                                        data: data,
                                        onAdd: data.canCreate
                                            ? () => _openForm(data)
                                            : null,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      _MetricsGrid(expenses: data.expenses),
                                      const SizedBox(height: AppSpacing.md),
                                      _FiltersCard(
                                        selectedStatus: _statusFilter,
                                        searchController: _searchController,
                                        onStatusChanged: (value) => setState(
                                          () => _statusFilter = value,
                                        ),
                                        onSearchChanged: (_) => setState(() {}),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      _SectionHeader(
                                        title: 'Expense List',
                                        count: expenses.length,
                                        trailingIcon:
                                            Icons.receipt_long_outlined,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      if (expenses.isEmpty)
                                        const _StateView.empty()
                                      else
                                        ...expenses.map(
                                          (expense) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: _ExpenseCard(
                                              expense: expense,
                                              onDetails: (expense) =>
                                                  _showDetails(data, expense),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_busy)
                            Container(
                              color: Colors.black.withValues(alpha: 0.10),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: AppColors.deliveryGreen,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final _ExpensePageData data;
  final VoidCallback? onAdd;

  const _HeaderCard({required this.data, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;

    return _SurfaceCard(
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Row(
        children: [
          Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F6E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: AppColors.deliveryGreen,
              size: compact ? 18 : 21,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Expense Claims',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: compact ? 14 : 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.expenses.length} Claims',
                  style: TextStyle(
                    color: const Color(0xFF4F5870),
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: onAdd == null
                ? AppColors.deliverySurfaceBorder
                : AppColors.deliveryGreen,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.surface,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<DeliveryExpense> expenses;

  const _MetricsGrid({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final pending = expenses
        .where((expense) => expense.approvalStatus == 'Pending')
        .length;
    final approved = expenses
        .where((expense) => expense.approvalStatus == 'Approved')
        .length;
    final rejected = expenses
        .where((expense) => expense.approvalStatus == 'Rejected')
        .length;
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final rows = [
      _MetricInfo(
        'Pending',
        pending.toString(),
        Icons.timelapse_outlined,
        AppColors.deliveryOrange,
        AppColors.deliveryOrangeSoft,
      ),
      _MetricInfo(
        'Approved',
        approved.toString(),
        Icons.verified_outlined,
        AppColors.deliveryGreen,
        AppColors.deliveryGreenSoft,
      ),
      _MetricInfo(
        'Rejected',
        rejected.toString(),
        Icons.cancel_outlined,
        AppColors.deliveryRed,
        AppColors.deliveryRedSoft,
      ),
      _MetricInfo(
        'Total Claimed',
        _formatMoney(total),
        Icons.currency_rupee_rounded,
        AppColors.deliveryBlue,
        AppColors.deliveryBlueSoft,
      ),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index += 2) ...[
            Row(
              children: [
                Expanded(child: _MetricTile(info: rows[index])),
                const SizedBox(width: 10),
                Expanded(child: _MetricTile(info: rows[index + 1])),
              ],
            ),
            if (index < rows.length - 2) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _MetricInfo info;

  const _MetricTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Row(
        children: [
          _MiniIcon(
            icon: info.icon,
            color: info.color,
            background: info.background,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF586176),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final String selectedStatus;
  final TextEditingController searchController;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;

  const _FiltersCard({
    required this.selectedStatus,
    required this.searchController,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _DeliveryExpensesScreenState._statusFilters.length,
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status =
                    _DeliveryExpensesScreenState._statusFilters[index];
                final selected = status == selectedStatus;
                return ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => onStatusChanged(status),
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.surface
                        : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedColor: AppColors.deliveryGreen,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: selected
                        ? AppColors.deliveryGreen
                        : AppColors.deliverySurfaceBorder,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search category, purpose, or claim id',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 21),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.deliverySurfaceBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.deliveryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final DeliveryExpense expense;
  final ValueChanged<DeliveryExpense> onDetails;

  const _ExpenseCard({
    required this.expense,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(expense.displayStatus);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return InkWell(
      onTap: () => onDetails(expense),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        clipBehavior: Clip.antiAlias,
        decoration: _surfaceDecoration(radius: 12),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ColoredBox(
                color: statusColor,
                child: const SizedBox(width: 3),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 10 : 12,
                10,
                compact ? 10 : 12,
                9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          expense.hasReceipt
                              ? Icons.receipt_long_outlined
                              : Icons.request_quote_outlined,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.expenseId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.deliveryInk,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                _StatusBadge(
                                  status: expense.displayStatus,
                                  compact: compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.textMuted,
                                  size: 11,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${_formatDate(expense.expenseDate)} - ${expense.paymentMode}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _ExpenseCardLabel(
                                        'Category',
                                        compact: compact,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        expense.category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.deliveryInk,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 25,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                  ),
                                  color: const Color(0xFFE2E7F0),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _ExpenseCardLabel(
                                        'Receipt',
                                        compact: compact,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        expense.hasReceipt
                                            ? 'Attached'
                                            : 'No receipt',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.deliveryInk,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.deliveryInk,
                                  size: 17,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatMoney(expense.amount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.deliveryGreen,
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailsDialog extends StatelessWidget {
  final DeliveryExpense expense;
  final bool canEdit;
  final bool canCancel;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _ExpenseDetailsDialog({
    required this.expense,
    required this.canEdit,
    required this.canCancel,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      expense.category,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusBadge(status: expense.displayStatus),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow('Claim ID', expense.expenseId),
              _DetailRow('Amount', _formatMoney(expense.amount)),
              _DetailRow('Payment mode', expense.paymentMode),
              _DetailRow('Expense date', _formatDate(expense.expenseDate)),
              _DetailRow('Submitted on', _formatDateTime(expense.createdAt)),
              _DetailRow('Description', expense.description),
              _DetailRow('Reviewer', expense.approverName ?? '-'),
              _DetailRow('Reviewed on', _formatDateTime(expense.reviewedAt)),
              _DetailRow('Reimbursement', expense.paymentStatus),
              if ((expense.clarificationNote ?? '').isNotEmpty)
                _DetailRow('Clarification note', expense.clarificationNote!),
              if ((expense.rejectReason ?? '').isNotEmpty)
                _DetailRow('Rejection reason', expense.rejectReason!),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: expense.hasReceipt
                    ? () => _openReceipt(context, expense.receiptUrl!)
                    : null,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(expense.hasReceipt ? 'Open receipt' : 'No receipt'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onEdit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.deliveryGreen,
                          foregroundColor: AppColors.surface,
                        ),
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                  if (canCancel) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onCancel,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.deliveryRed,
                          foregroundColor: AppColors.surface,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReceipt(BuildContext context, String receiptUrl) async {
    final uri = Uri.tryParse(_absoluteUrl(receiptUrl));
    if (uri == null || !await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open receipt.')));
    }
  }
}

class _ExpenseFormPage extends StatefulWidget {
  final List<String> categories;
  final DeliveryExpense? initialExpense;

  const _ExpenseFormPage({
    required this.categories,
    required this.initialExpense,
  });

  @override
  State<_ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<_ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  late String _category;
  late String _paymentMode;
  late DateTime _expenseDate;
  Uint8List? _receiptBytes;
  String? _receiptName;

  static const _paymentModes = ['Cash', 'UPI', 'Card', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExpense;
    _category = initial?.category ?? widget.categories.first;
    _paymentMode = initial?.paymentMode ?? _paymentModes.first;
    _expenseDate = initial?.expenseDate ?? DateTime.now();
    _amountController.text = initial == null
        ? ''
        : initial.amount.toStringAsFixed(0);
    _descriptionController.text = initial?.description ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _receiptBytes = bytes;
      _receiptName = file.name;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _expenseDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    Navigator.of(context).pop(
      _ExpenseFormResult(
        request: DeliveryExpenseRequest(
          category: _category,
          amount: amount,
          expenseDate: _expenseDate,
          paymentMode: _paymentMode,
          description: _descriptionController.text.trim(),
        ),
        receiptBytes: _receiptBytes,
        receiptName: _receiptName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialExpense != null;
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        backgroundColor: AppColors.deliveryBackground,
        body: SafeArea(
          child: Column(
            children: [
              DeliveryTopBar(
                title: editing ? 'Update Expense' : 'Add Expense',
                subtitle: 'Submit receipt and claim details',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: () => Navigator.of(context).pop(),
                showNotification: false,
                showProfile: false,
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _SurfaceCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: _category,
                                  decoration: _inputDecoration(
                                    'Expense Category',
                                  ),
                                  items: [
                                    for (final category in widget.categories)
                                      DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _category = value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration('Amount in INR'),
                                  validator: (value) {
                                    final amount = double.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (amount == null || amount <= 0) {
                                      return 'Enter an amount greater than zero.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: _pickDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(
                                      'Expense Date',
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(_formatDate(_expenseDate)),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: _paymentMode,
                                  decoration: _inputDecoration('Payment Mode'),
                                  items: [
                                    for (final mode in _paymentModes)
                                      DropdownMenuItem(
                                        value: mode,
                                        child: Text(mode),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _paymentMode = value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                    'Description / Purpose',
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Describe the expense purpose.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _pickReceipt,
                                    icon: const Icon(
                                      Icons.upload_file_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _receiptName ?? 'Attach receipt image',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: FilledButton(
                                    onPressed: _submit,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.deliveryGreen,
                                      foregroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      editing
                                          ? 'Update Expense'
                                          : 'Submit Expense',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData trailingIcon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$title ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Icon(trailingIcon, color: AppColors.deliveryGreen, size: 20),
      ],
    );
  }
}

class _ExpenseCardLabel extends StatelessWidget {
  final String label;
  final bool compact;

  const _ExpenseCardLabel(this.label, {required this.compact});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: compact ? 8.5 : 9.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _MiniIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const _StatusBadge({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: compact ? 9.5 : 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final bool loading;

  const _StateView._({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
    this.loading = false,
  });

  const _StateView.loading()
    : this._(
        icon: Icons.hourglass_empty_rounded,
        title: 'Loading expenses',
        subtitle: 'Fetching your latest claims.',
        loading: true,
      );

  const _StateView.empty()
    : this._(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses found',
        subtitle: 'New claims will appear here after submission.',
      );

  const _StateView.error({required String message, VoidCallback? onRetry})
    : this._(
        icon: Icons.error_outline_rounded,
        title: 'Expenses could not load',
        subtitle: message,
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _SurfaceCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator(color: AppColors.deliveryGreen)
            else
              Icon(icon, color: AppColors.deliveryGreen, size: 48),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: _surfaceDecoration(),
      child: child,
    );
  }
}

BoxDecoration _surfaceDecoration({double? radius}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius ?? AppSizes.cardRadius),
    border: Border.all(color: AppColors.deliverySurfaceBorder),
    boxShadow: [
      BoxShadow(
        color: AppColors.secondary.withValues(alpha: 0.035),
        blurRadius: 14,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class _ExpensePageData {
  final List<String> categories;
  final List<DeliveryExpense> expenses;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;

  const _ExpensePageData({
    required this.categories,
    required this.expenses,
    required this.canCreate,
    required this.canEdit,
    required this.canDelete,
  });
}

class _ExpenseFormResult {
  final DeliveryExpenseRequest request;
  final Uint8List? receiptBytes;
  final String? receiptName;

  const _ExpenseFormResult({
    required this.request,
    this.receiptBytes,
    this.receiptName,
  });
}

class _MetricInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MetricInfo(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}

class _ExpenseException implements Exception {
  final String message;

  const _ExpenseException(this.message);

  @override
  String toString() => message;
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    isDense: true,
    filled: true,
    fillColor: AppColors.surfaceSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.deliverySurfaceBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.deliveryGreen),
    ),
  );
}

Color _statusColor(String status) {
  return switch (status) {
    'Approved' => AppColors.deliveryGreen,
    'Rejected' => AppColors.deliveryRed,
    'Reimbursed' => AppColors.deliveryBlue,
    'Clarification Required' => AppColors.deliveryViolet,
    _ => AppColors.deliveryOrange,
  };
}

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
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
  return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDate(local)} $hour:$minute';
}

String _formatMoney(double value) {
  final rounded = value.round();
  final digits = rounded.toString();
  if (digits.length <= 3) return 'INR $digits';
  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return 'INR ${parts.join(',')},$last3';
}

String _absoluteUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = ApiConstants.baseUrl.replaceFirst(RegExp(r'/$'), '');
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}

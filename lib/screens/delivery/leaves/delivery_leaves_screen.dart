import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../services/api_service.dart';
import '../../../widgets/delivery/delivery_bottom_navigation.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryLeavesScreen extends StatefulWidget {
  const DeliveryLeavesScreen({super.key});

  @override
  State<DeliveryLeavesScreen> createState() => _DeliveryLeavesScreenState();
}

class _DeliveryLeavesScreenState extends State<DeliveryLeavesScreen> {
  static const String _demoStorageKey = 'saas.leaveDemo.v1';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<_LeaveRequest> _leaves = const [];
  bool _isLoading = true;
  bool _isDemoMode = false;
  bool _didStartLoad = false;
  String? _error;
  String _statusFilter = 'all';
  final Set<String> _busyLeaveIds = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _didStartLoad = true;
      _loadLeaves();
    }
  }

  Future<void> _loadLeaves() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rows = await ApiProviderScope.of(context).fetchMyLeaves();
      if (!mounted) return;
      if (rows.isEmpty) {
        final demoLeaves = await _loadDemoLeaves();
        if (!mounted) return;
        setState(() {
          _leaves = demoLeaves;
          _isDemoMode = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _leaves = rows.map(_LeaveRequest.fromJson).toList();
        _isDemoMode = false;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _leaves = const [];
        _error = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  Future<List<_LeaveRequest>> _loadDemoLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_demoStorageKey);
    if (saved != null && saved.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(_LeaveRequest.fromJson)
              .toList();
        }
      } catch (_) {
        // Fall back to seeded records if saved demo data is malformed.
      }
    }

    final seeded = _seedDemoLeaves();
    await _saveDemoLeaves(seeded);
    return seeded;
  }

  Future<void> _saveDemoLeaves(List<_LeaveRequest> leaves) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _demoStorageKey,
      jsonEncode(leaves.map((leave) => leave.toJson()).toList()),
    );
  }

  Future<void> _openApplySheet() async {
    final created = await showModalBottomSheet<_LeaveRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ApplyLeaveSheet(
          existingLeaves: _leaves,
          onSubmit: _submitLeaveRequest,
        );
      },
    );

    if (created == null || !mounted) return;
    setState(() => _leaves = [created, ..._leaves]);
    if (_isDemoMode) await _saveDemoLeaves(_leaves);
    _showSnack(
      title: 'Leave request submitted',
      message: _isDemoMode
          ? 'Demo leave has been added locally.'
          : 'Your request is pending approval.',
      isError: false,
    );
  }

  Future<_LeaveRequest> _submitLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    if (_isDemoMode) {
      return _LeaveRequest(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        leaveType: leaveType,
        startDate: _dateOnly(startDate),
        endDate: _dateOnly(endDate),
        daysCount: _calculateDaysCount(startDate, endDate),
        reason: reason.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
      );
    }

    final row = await ApiProviderScope.of(context).createLeave(
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
    return _LeaveRequest.fromJson(row);
  }

  Future<void> _cancelLeave(_LeaveRequest leave) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _CancelLeaveDialog(leave: leave),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyLeaveIds.add(leave.id));
    try {
      if (_isDemoMode) {
        final cancelled = leave.copyWith(status: 'cancelled');
        _leaves = _leaves
            .map((item) => item.id == leave.id ? cancelled : item)
            .toList();
        await _saveDemoLeaves(_leaves);
      } else {
        await ApiProviderScope.of(context).deleteLeave(leave.id);
        await _loadLeaves();
      }
      if (!mounted) return;
      _showSnack(
        title: 'Leave request cancelled',
        message: '${leave.leaveTypeLabel} request has been withdrawn.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnack(
        title: 'Unable to cancel',
        message: _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _busyLeaveIds.remove(leave.id));
      }
    }
  }

  void _showDetails(_LeaveRequest leave) {
    showDialog<void>(
      context: context,
      builder: (context) => _LeaveDetailsDialog(leave: leave),
    );
  }

  void _showSnack({
    required String title,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? AppColors.deliveryRed
              : AppColors.deliveryGreen,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(message),
            ],
          ),
        ),
      );
  }

  List<_LeaveRequest> get _visibleLeaves {
    final filtered = _leaves.where((leave) {
      return _statusFilter == 'all' || leave.status == _statusFilter;
    }).toList();
    filtered.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    final visibleLeaves = _visibleLeaves;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.deliveryBackground,
        drawer: const DeliveryPartnerSidebar(
          currentRoute: AppRoutes.deliveryLeaves,
        ),
        bottomNavigationBar: const DeliveryBottomNavigation(currentIndex: -1),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'delivery-leaves-apply',
          onPressed: _openApplySheet,
          backgroundColor: AppColors.deliveryGreen,
          foregroundColor: AppColors.surface,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Apply Leave',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DeliveryTopBar(
                title: 'Leaves',
                subtitle: 'View and manage your leave requests.',
                leadingIcon: Icons.menu_rounded,
                onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                actions: [
                  DeliveryTopBarAction(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh leaves',
                    onTap: _loadLeaves,
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.deliveryGreen,
                  onRefresh: _loadLeaves,
                  child: ListView(
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
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryGrid(leaves: _leaves),
                              const SizedBox(height: AppSpacing.md),
                              _FilterPills(
                                selected: _statusFilter,
                                onChanged: (value) {
                                  setState(() => _statusFilter = value);
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (_isDemoMode) ...[
                                const _DemoNotice(),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              _LeavesPanel(
                                isLoading: _isLoading,
                                error: _error,
                                leaves: visibleLeaves,
                                hasFilters: _statusFilter != 'all',
                                busyLeaveIds: _busyLeaveIds,
                                onRetry: _loadLeaves,
                                onResetFilters: () {
                                  setState(() => _statusFilter = 'all');
                                },
                                onDetails: _showDetails,
                                onCancel: _cancelLeave,
                              ),
                            ],
                          ),
                        ),
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
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.leaves});

  final List<_LeaveRequest> leaves;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryInfo(
        label: 'Pending',
        value: _countStatus('pending').toString(),
        icon: Icons.pending_actions_outlined,
        color: AppColors.deliveryOrange,
        background: AppColors.deliveryOrangeSoft,
      ),
      _SummaryInfo(
        label: 'Approved',
        value: _countStatus('approved').toString(),
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.deliveryGreen,
        background: AppColors.deliveryGreenSoft,
      ),
      _SummaryInfo(
        label: 'Rejected',
        value: _countStatus('rejected').toString(),
        icon: Icons.cancel_outlined,
        color: AppColors.deliveryRed,
        background: AppColors.deliveryRedSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 1 ? 4.4 : 2.8,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemBuilder: (context, index) => _SummaryTile(info: items[index]),
        );
      },
    );
  }

  int _countStatus(String status) {
    return leaves.where((leave) => leave.status == status).length;
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.info});

  final _SummaryInfo info;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _MiniIcon(
            icon: info.icon,
            color: info.color,
            background: info.background,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 18,
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
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in _statusFilters) ...[
            _FilterPill(
              label: item.label,
              selected: selected == item.value,
              onTap: () => onChanged(item.value),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.deliveryGreen : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.pillRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.pillRadius),
            border: Border.all(
              color: selected
                  ? AppColors.deliveryGreen
                  : AppColors.deliverySurfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.surface : AppColors.deliveryInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deliveryBlueSoft,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.deliveryBlue.withValues(alpha: 0.16),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.deliveryBlue,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo mode is active because no leave records were returned.',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeavesPanel extends StatelessWidget {
  const _LeavesPanel({
    required this.isLoading,
    required this.error,
    required this.leaves,
    required this.hasFilters,
    required this.busyLeaveIds,
    required this.onRetry,
    required this.onResetFilters,
    required this.onDetails,
    required this.onCancel,
  });

  final bool isLoading;
  final String? error;
  final List<_LeaveRequest> leaves;
  final bool hasFilters;
  final Set<String> busyLeaveIds;
  final VoidCallback onRetry;
  final VoidCallback onResetFilters;
  final ValueChanged<_LeaveRequest> onDetails;
  final ValueChanged<_LeaveRequest> onCancel;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Leave Requests',
            trailingIcon: Icons.event_busy_outlined,
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const _LoadingState()
          else if (error != null)
            _ErrorState(message: error!, onRetry: onRetry)
          else if (leaves.isEmpty)
            _EmptyState(hasFilters: hasFilters, onReset: onResetFilters)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 720) {
                  return _LeavesTable(
                    leaves: leaves,
                    busyLeaveIds: busyLeaveIds,
                    onDetails: onDetails,
                    onCancel: onCancel,
                  );
                }
                return Column(
                  children: [
                    for (final leave in leaves) ...[
                      _LeaveCard(
                        leave: leave,
                        isBusy: busyLeaveIds.contains(leave.id),
                        onDetails: () => onDetails(leave),
                        onCancel: leave.canCancel
                            ? () => onCancel(leave)
                            : null,
                      ),
                      if (leave != leaves.last)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LeavesTable extends StatelessWidget {
  const _LeavesTable({
    required this.leaves,
    required this.busyLeaveIds,
    required this.onDetails,
    required this.onCancel,
  });

  final List<_LeaveRequest> leaves;
  final Set<String> busyLeaveIds;
  final ValueChanged<_LeaveRequest> onDetails;
  final ValueChanged<_LeaveRequest> onCancel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        dataTextStyle: const TextStyle(
          color: AppColors.deliveryInk,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        columnSpacing: 18,
        horizontalMargin: 8,
        columns: const [
          DataColumn(label: Text('Leave Type')),
          DataColumn(label: Text('Date Range')),
          DataColumn(label: Text('Days')),
          DataColumn(label: Text('Reason')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Requested On')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final leave in leaves)
            DataRow(
              cells: [
                DataCell(Text(leave.leaveTypeLabel)),
                DataCell(Text(leave.dateRangeLabel)),
                DataCell(Text('${leave.daysCount}')),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Text(
                      leave.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(_StatusBadge(status: leave.status)),
                DataCell(Text(leave.requestedOnLabel)),
                DataCell(
                  _RowActions(
                    isBusy: busyLeaveIds.contains(leave.id),
                    canCancel: leave.canCancel,
                    onDetails: () => onDetails(leave),
                    onCancel: () => onCancel(leave),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.leave,
    required this.isBusy,
    required this.onDetails,
    required this.onCancel,
  });

  final _LeaveRequest leave;
  final bool isBusy;
  final VoidCallback onDetails;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final tone = _StatusTone.forStatus(leave.status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniIcon(
                icon: Icons.event_busy_outlined,
                color: tone.foreground,
                background: tone.background,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.leaveTypeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.dateRangeLabel,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: leave.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InlineMetric(label: 'Days', value: '${leave.daysCount}'),
              const SizedBox(width: 10),
              Expanded(
                child: _InlineMetric(
                  label: 'Requested',
                  value: leave.requestedOnLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            leave.reason,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _RowActions(
            isBusy: isBusy,
            canCancel: onCancel != null,
            onDetails: onDetails,
            onCancel: onCancel ?? () {},
          ),
        ],
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.isBusy,
    required this.canCancel,
    required this.onDetails,
    required this.onCancel,
  });

  final bool isBusy;
  final bool canCancel;
  final VoidCallback onDetails;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: isBusy ? null : onDetails,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(92, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.controlRadius),
            ),
          ),
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('Details'),
        ),
        if (canCancel)
          FilledButton.icon(
            onPressed: isBusy ? null : onCancel,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deliveryRed,
              foregroundColor: AppColors.surface,
              minimumSize: const Size(92, 40),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.controlRadius),
              ),
            ),
            icon: isBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel'),
          ),
      ],
    );
  }
}

class _ApplyLeaveSheet extends StatefulWidget {
  const _ApplyLeaveSheet({
    required this.existingLeaves,
    required this.onSubmit,
  });

  final List<_LeaveRequest> existingLeaves;
  final Future<_LeaveRequest> Function({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  })
  onSubmit;

  @override
  State<_ApplyLeaveSheet> createState() => _ApplyLeaveSheetState();
}

class _ApplyLeaveSheetState extends State<_ApplyLeaveSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  String _leaveType = 'casual';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _daysCount {
    final start = _startDate;
    final end = _endDate;
    if (start == null || end == null || end.isBefore(start)) return 0;
    return _calculateDaysCount(start, end);
  }

  bool get _hasOverlap {
    final start = _startDate;
    final end = _endDate;
    if (start == null || end == null || end.isBefore(start)) return false;
    return widget.existingLeaves.any((leave) {
      if (leave.status != 'pending' && leave.status != 'approved') {
        return false;
      }
      return !_dateOnly(end).isBefore(leave.startDate) &&
          !_dateOnly(start).isAfter(leave.endDate);
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = _dateOnly(picked);
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = _dateOnly(picked);
      }
    });
  }

  Future<void> _submit() async {
    final start = _startDate;
    final end = _endDate;
    if (!_formKey.currentState!.validate() || start == null || end == null) {
      return;
    }
    if (end.isBefore(start)) return;

    setState(() => _isSubmitting = true);
    try {
      final leave = await widget.onSubmit(
        leaveType: _leaveType,
        startDate: start,
        endDate: end,
        reason: _reasonController.text,
      );
      if (mounted) Navigator.of(context).pop(leave);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.deliveryRed,
            content: Text(_cleanError(error)),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.58,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.deliverySurfaceBorder,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Apply Leave',
                    style: TextStyle(
                      color: AppColors.deliveryInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _leaveType,
                    decoration: const InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final option in _leaveTypes)
                        DropdownMenuItem(
                          value: option.value,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _leaveType = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Start Date',
                          value: _startDate,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'End Date',
                          value: _endDate,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DayPreview(daysCount: _daysCount, hasOverlap: _hasOverlap),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    minLines: 4,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Enter a leave reason.';
                      if (text.length < 4) return 'Reason is too short.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              AppSizes.buttonHeight,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              AppSizes.buttonHeight,
                            ),
                            backgroundColor: AppColors.deliveryGreen,
                            foregroundColor: AppColors.surface,
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.surface,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Submit Request'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
        ),
        child: Text(
          value == null ? 'Select' : _formatDate(value!),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DayPreview extends StatelessWidget {
  const _DayPreview({required this.daysCount, required this.hasOverlap});

  final int daysCount;
  final bool hasOverlap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasOverlap
            ? AppColors.deliveryOrangeSoft
            : const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: hasOverlap
              ? AppColors.deliveryOrange.withValues(alpha: 0.24)
              : AppColors.deliveryGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasOverlap
                ? Icons.warning_amber_rounded
                : Icons.date_range_outlined,
            color: hasOverlap
                ? AppColors.deliveryOrange
                : AppColors.deliveryGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasOverlap
                  ? 'Selected dates overlap with an active leave request.'
                  : daysCount == 0
                  ? 'Select dates to preview leave duration.'
                  : '$daysCount day${daysCount == 1 ? '' : 's'} selected.',
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveDetailsDialog extends StatelessWidget {
  const _LeaveDetailsDialog({required this.leave});

  final _LeaveRequest leave;

  @override
  Widget build(BuildContext context) {
    final reviewedBy = leave.approverName ?? leave.approvedBy;
    return AlertDialog(
      title: const Text('Leave Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Leave Type', value: leave.leaveTypeLabel),
            _DetailRow(label: 'Status', value: leave.statusLabel),
            _DetailRow(
              label: 'Start Date',
              value: _formatDate(leave.startDate),
            ),
            _DetailRow(label: 'End Date', value: _formatDate(leave.endDate)),
            _DetailRow(label: 'Number of Days', value: '${leave.daysCount}'),
            _DetailRow(label: 'Requested At', value: leave.requestedAtLabel),
            _DetailRow(label: 'Reason', value: leave.reason),
            if (leave.status != 'pending') ...[
              _DetailRow(
                label: 'Reviewed By',
                value: reviewedBy ?? 'Not available',
              ),
              _DetailRow(label: 'Reviewed At', value: leave.reviewedAtLabel),
            ],
            if (leave.status == 'rejected' &&
                (leave.rejectReason ?? '').trim().isNotEmpty)
              _DetailRow(label: 'Rejection Reason', value: leave.rejectReason!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _CancelLeaveDialog extends StatelessWidget {
  const _CancelLeaveDialog({required this.leave});

  final _LeaveRequest leave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Leave Request'),
      content: Text(
        'Cancel your ${leave.leaveTypeLabel} request for ${leave.dateRangeLabel}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep Request'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.deliveryRed,
            foregroundColor: AppColors.surface,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cancel Request'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final tone = _StatusTone.forStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tone.icon, size: 14, color: tone.foreground),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: tone.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.deliveryInk,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailingIcon});

  final String title;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.deliveryInk,
          ),
        ),
        const Spacer(),
        if (trailingIcon != null)
          Icon(trailingIcon, size: 18, color: AppColors.deliveryGreen),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.buttonHeightCompact,
      height: AppSizes.buttonHeightCompact,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.controlRadius),
      ),
      child: Icon(icon, color: color, size: AppSizes.iconSmall),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 250,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.deliveryGreen),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: AppColors.deliveryRed,
          ),
          const SizedBox(height: 10),
          const Text(
            'Leave requests could not load',
            style: TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.onReset});

  final bool hasFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 12),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.deliveryGreenSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.deliveryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasFilters ? 'No matching leave requests' : 'No leave requests',
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Clear filters to view every request.'
                  : 'Your applied leaves will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Reset filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaveRequest {
  const _LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.reason,
    required this.status,
    this.userId,
    this.userName,
    this.userEmail,
    this.approvedBy,
    this.approverName,
    this.rejectReason,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int daysCount;
  final String reason;
  final String status;
  final String? approvedBy;
  final String? approverName;
  final String? rejectReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory _LeaveRequest.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, const ['id', 'leave_id']) ?? '';
    final startDate =
        _readDate(json, const ['startDate', 'start_date', 'from_date']) ??
        DateTime.now();
    final endDate =
        _readDate(json, const ['endDate', 'end_date', 'to_date']) ?? startDate;

    return _LeaveRequest(
      id: id.isEmpty ? 'leave-${startDate.millisecondsSinceEpoch}' : id,
      userId: _readString(json, const ['userId', 'user_id']),
      userName:
          _readString(json, const ['userName', 'user_name']) ??
          _readNestedString(json, 'user', const ['name', 'full_name']),
      userEmail:
          _readString(json, const ['userEmail', 'user_email']) ??
          _readNestedString(json, 'user', const ['email']),
      leaveType: _normalizeValue(
        _readString(json, const ['leaveType', 'leave_type', 'type']) ?? 'other',
      ),
      startDate: _dateOnly(startDate),
      endDate: _dateOnly(endDate),
      daysCount:
          _readInt(json, const ['daysCount', 'days_count', 'number_of_days']) ??
          _calculateDaysCount(startDate, endDate),
      reason: _readString(json, const ['reason', 'description']) ?? '',
      status: _normalizeValue(
        _readString(json, const ['status', 'leave_status']) ?? 'pending',
      ),
      approvedBy: _readString(json, const ['approvedBy', 'approved_by']),
      approverName:
          _readString(json, const ['approverName', 'approver_name']) ??
          _readNestedString(json, 'approver', const ['name', 'full_name']),
      rejectReason: _readString(json, const [
        'rejectReason',
        'reject_reason',
        'rejection_reason',
      ]),
      createdAt: _readDate(json, const [
        'createdAt',
        'created_at',
        'requested_at',
      ]),
      updatedAt: _readDate(json, const [
        'updatedAt',
        'updated_at',
        'reviewed_at',
      ]),
    );
  }

  bool get canCancel => status == 'pending';
  String get leaveTypeLabel => _leaveTypeLabel(leaveType);
  String get statusLabel => _statusLabel(status);
  String get dateRangeLabel =>
      '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  String get requestedOnLabel =>
      createdAt == null ? 'Not available' : _formatDate(createdAt!);
  String get requestedAtLabel =>
      createdAt == null ? 'Not available' : _formatDateTime(createdAt!);
  String get reviewedAtLabel =>
      updatedAt == null ? 'Not available' : _formatDateTime(updatedAt!);

  _LeaveRequest copyWith({String? status}) {
    return _LeaveRequest(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      daysCount: daysCount,
      reason: reason,
      status: status ?? this.status,
      approvedBy: approvedBy,
      approverName: approverName,
      rejectReason: rejectReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'leaveType': leaveType,
      'startDate': _formatApiDate(startDate),
      'endDate': _formatApiDate(endDate),
      'daysCount': daysCount,
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'approverName': approverName,
      'rejectReason': rejectReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class _SummaryInfo {
  const _SummaryInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;
}

class _SelectOption {
  const _SelectOption(this.value, this.label);

  final String value;
  final String label;
}

class _StatusTone {
  const _StatusTone({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;

  factory _StatusTone.forStatus(String status) {
    return switch (status) {
      'pending' => const _StatusTone(
        icon: Icons.pending_actions_outlined,
        foreground: Color(0xFFB7791F),
        background: Color(0xFFFFF7E6),
        border: Color(0xFFFFE0A8),
      ),
      'approved' => const _StatusTone(
        icon: Icons.check_circle_outline_rounded,
        foreground: AppColors.deliveryGreen,
        background: AppColors.deliveryGreenSoft,
        border: Color(0xFFD4EFD3),
      ),
      'rejected' => const _StatusTone(
        icon: Icons.cancel_outlined,
        foreground: AppColors.deliveryRed,
        background: AppColors.deliveryRedSoft,
        border: Color(0xFFF6C7C7),
      ),
      'cancelled' => const _StatusTone(
        icon: Icons.remove_circle_outline_rounded,
        foreground: Color(0xFF64748B),
        background: Color(0xFFF1F5F9),
        border: Color(0xFFE2E8F0),
      ),
      _ => const _StatusTone(
        icon: Icons.info_outline_rounded,
        foreground: Color(0xFF4F5870),
        background: Color(0xFFF1F4F8),
        border: Color(0xFFE1E6EF),
      ),
    };
  }
}

const List<_SelectOption> _leaveTypes = [
  _SelectOption('casual', 'Casual'),
  _SelectOption('sick', 'Sick'),
  _SelectOption('annual', 'Annual'),
  _SelectOption('maternity', 'Maternity'),
  _SelectOption('paternity', 'Paternity'),
  _SelectOption('unpaid', 'Unpaid'),
  _SelectOption('other', 'Other'),
];

const List<_SelectOption> _statusFilters = [
  _SelectOption('all', 'All'),
  _SelectOption('pending', 'Pending'),
  _SelectOption('approved', 'Approved'),
  _SelectOption('rejected', 'Rejected'),
];

List<_LeaveRequest> _seedDemoLeaves() {
  final now = DateTime.now();
  return [
    _LeaveRequest(
      id: 'demo-pending',
      leaveType: 'casual',
      startDate: _dateOnly(now.add(const Duration(days: 4))),
      endDate: _dateOnly(now.add(const Duration(days: 5))),
      daysCount: 2,
      reason: 'Personal work at home.',
      status: 'pending',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    _LeaveRequest(
      id: 'demo-approved',
      leaveType: 'sick',
      startDate: _dateOnly(now.subtract(const Duration(days: 11))),
      endDate: _dateOnly(now.subtract(const Duration(days: 10))),
      daysCount: 2,
      reason: 'Medical rest advised by doctor.',
      status: 'approved',
      approverName: 'Operations Admin',
      createdAt: now.subtract(const Duration(days: 14)),
      updatedAt: now.subtract(const Duration(days: 13)),
    ),
    _LeaveRequest(
      id: 'demo-rejected',
      leaveType: 'annual',
      startDate: _dateOnly(now.add(const Duration(days: 12))),
      endDate: _dateOnly(now.add(const Duration(days: 14))),
      daysCount: 3,
      reason: 'Family travel.',
      status: 'rejected',
      approverName: 'Operations Admin',
      rejectReason: 'Route staffing is already full for these dates.',
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 4)),
    ),
  ];
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int _calculateDaysCount(DateTime start, DateTime end) {
  return _dateOnly(end).difference(_dateOnly(start)).inDays + 1;
}

String _formatDate(DateTime value) {
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
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour > 12
      ? local.hour - 12
      : local.hour == 0
      ? 12
      : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(local)}, $hour:$minute $period';
}

String _formatApiDate(DateTime value) {
  final local = _dateOnly(value);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String _leaveTypeLabel(String value) {
  final normalized = _normalizeValue(value);
  for (final option in _leaveTypes) {
    if (option.value == normalized) return option.label;
  }
  return _titleCase(normalized);
}

String _statusLabel(String value) {
  final normalized = _normalizeValue(value);
  for (final option in _statusFilters) {
    if (option.value == normalized) return option.label;
  }
  if (normalized == 'cancelled') return 'Cancelled';
  return _titleCase(normalized);
}

String _titleCase(String value) {
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _normalizeValue(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String? _readNestedString(
  Map<String, dynamic> json,
  String parentKey,
  List<String> keys,
) {
  final parent = json[parentKey];
  if (parent is! Map<String, dynamic>) return null;
  return _readString(parent, keys);
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}

String _cleanError(Object error) {
  if (error is ApiException) {
    try {
      final decoded = jsonDecode(error.message);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail.trim();
        }
      }
    } catch (_) {
      // Plain API messages need no decoding.
    }
    return error.message;
  }
  return error.toString().trim();
}

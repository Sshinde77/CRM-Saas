import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryAttendanceScreen extends StatefulWidget {
  const DeliveryAttendanceScreen({super.key});

  @override
  State<DeliveryAttendanceScreen> createState() =>
      _DeliveryAttendanceScreenState();
}

class _DeliveryAttendanceScreenState extends State<DeliveryAttendanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<_AttendanceRecord>>? _future;
  final Set<String> _busyTypes = <String>{};
  String? _markError;
  bool _didStartLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _loadAttendance();
      _didStartLoad = true;
    }
  }

  Future<List<_AttendanceRecord>> _loadAttendance() async {
    final rows = await ApiProviderScope.of(context).fetchMyAttendance();
    return rows.map(_AttendanceRecord.fromJson).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _refresh() async {
    final request = _loadAttendance();
    setState(() => _future = request);
    await request;
  }

  Future<void> _markNow(_CheckpointType type) async {
    setState(() {
      _markError = null;
      _busyTypes.add(type.apiValue);
    });

    try {
      await ApiProviderScope.of(context).checkInAttendance(type.apiValue);
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _markError = 'Failed to mark attendance. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _busyTypes.remove(type.apiValue));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAF9),
      drawer: const DeliveryPartnerSidebar(
        currentRoute: AppRoutes.deliveryAttendance,
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<_AttendanceRecord>>(
          future: _future,
          builder: (context, snapshot) {
            final records = snapshot.data ?? const <_AttendanceRecord>[];
            final today = _AttendanceRecord.todayFrom(records);
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData;

            return RefreshIndicator(
              color: AppColors.deliveryGreen,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: DeliveryTopBar(
                      title: 'My Attendance',
                      subtitle:
                          "Record today's checkpoints and review your attendance history",
                      leadingIcon: Icons.menu_rounded,
                      onLeadingTap: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Column(
                            children: [
                              _CheckpointsCard(
                                today: today,
                                error: _markError,
                                busyTypes: _busyTypes,
                                onDismissError: () {
                                  setState(() => _markError = null);
                                },
                                onMarkNow: _markNow,
                              ),
                              const SizedBox(height: 12),
                              _HistoryCard(
                                records: records,
                                isLoading: isLoading,
                                error: snapshot.hasError
                                    ? _cleanError(snapshot.error)
                                    : null,
                                onRetry: _refresh,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckpointsCard extends StatelessWidget {
  final _AttendanceRecord? today;
  final String? error;
  final Set<String> busyTypes;
  final VoidCallback onDismissError;
  final ValueChanged<_CheckpointType> onMarkNow;

  const _CheckpointsCard({
    required this.today,
    required this.error,
    required this.busyTypes,
    required this.onDismissError,
    required this.onMarkNow,
  });

  @override
  Widget build(BuildContext context) {
    final checkpoints = _CheckpointType.values;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.event_available_rounded,
            title: "Today's Checkpoints",
            subtitle: 'Mark your attendance for today',
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: error!, onDismiss: onDismissError),
          ],
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 620;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checkpoints.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: wide ? 4 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 132,
                ),
                itemBuilder: (context, index) {
                  final checkpoint = checkpoints[index];
                  final time = today?.timeFor(checkpoint);
                  return _CheckpointTile(
                    checkpoint: checkpoint,
                    time: _formatTime(time),
                    recorded: time != null,
                    busy: busyTypes.contains(checkpoint.apiValue),
                    onMarkNow: () => onMarkNow(checkpoint),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckpointTile extends StatelessWidget {
  final _CheckpointType checkpoint;
  final String time;
  final bool recorded;
  final bool busy;
  final VoidCallback onMarkNow;

  const _CheckpointTile({
    required this.checkpoint,
    required this.time,
    required this.recorded,
    required this.busy,
    required this.onMarkNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E5EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TintIcon(
                icon: checkpoint.icon,
                color: checkpoint.color,
                background: checkpoint.softColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  checkpoint.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 17,
                color: Color(0xFF566174),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        recorded ? const Color(0xFF065F1B) : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: recorded || busy ? null : onMarkNow,
              icon: busy
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: checkpoint.color,
                      ),
                    )
                  : Icon(
                      recorded
                          ? Icons.check_circle_outline_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                    ),
              label: Text(recorded ? 'Recorded' : 'Mark now'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    recorded ? const Color(0xFF065F1B) : checkpoint.color,
                disabledForegroundColor: const Color(0xFF065F1B),
                side: BorderSide(
                  color: recorded
                      ? const Color(0xFF9FD7AA)
                      : checkpoint.color.withValues(alpha: 0.75),
                ),
                backgroundColor: recorded
                    ? const Color(0xFFF0FAF2)
                    : checkpoint.softColor.withValues(alpha: 0.45),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final List<_AttendanceRecord> records;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRetry;

  const _HistoryCard({
    required this.records,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.event_available_rounded,
            title: 'Attendance History',
            subtitle: 'Your recent attendance records',
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.deliveryGreen,
                ),
              ),
            )
          else if (error != null)
            _HistoryMessage(
              icon: Icons.error_outline_rounded,
              title: 'Attendance could not load',
              message: error!,
              action: 'Retry',
              onAction: onRetry,
            )
          else if (records.isEmpty)
            const _HistoryMessage(
              icon: Icons.event_busy_rounded,
              title: 'No attendance recorded yet',
              message: 'Your attendance history will appear here.',
            )
          else
            _HistoryTable(records: records.take(5).toList()),
        ],
      ),
    );
  }
}

class _HistoryTable extends StatelessWidget {
  final List<_AttendanceRecord> records;

  const _HistoryTable({required this.records});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: Column(
        children: [
          const _HistoryHeaderRow(),
          ...records.map(_HistoryRow.new),
        ],
      ),
    );
  }
}

class _HistoryHeaderRow extends StatelessWidget {
  const _HistoryHeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: _HeaderText('Date')),
          Expanded(flex: 3, child: _HeaderText('Status')),
          Expanded(flex: 3, child: _HeaderText('Check In')),
          Expanded(flex: 3, child: _HeaderText('Check Out')),
          SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final _AttendanceRecord record;

  const _HistoryRow(this.record);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9EDF5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deliveryInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _weekday(record.date),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 3, child: _StatusBadge(status: record.status)),
          Expanded(flex: 3, child: _TimeText(_formatTime(record.checkIn))),
          Expanded(flex: 3, child: _TimeText(_formatTime(record.checkOut))),
          const SizedBox(
            width: 18,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.deliveryInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CardTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TintIcon(
          icon: icon,
          color: const Color(0xFF0D7A24),
          background: const Color(0xFFE9F7EA),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deliveryInk,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _InlineError({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF6B6B)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_rounded,
            color: AppColors.deliveryRed,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB00000),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final Future<void> Function()? onAction;

  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 170),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 34),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.deliveryInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onAction,
                child: Text(action!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TintIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _TintIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'present';
    final color =
        isPresent ? const Color(0xFF0D8C28) : AppColors.deliveryRed;
    final label = isPresent ? 'Present' : 'Absent';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSizes.pillRadius),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 7),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TimeText extends StatelessWidget {
  final String text;

  const _TimeText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: text == '--:-- --' ? AppColors.textMuted : AppColors.deliveryInk,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum _CheckpointType {
  officeCheckIn(
    'office_check_in',
    'Office Check In',
    Icons.login_rounded,
    Color(0xFF0D7A24),
    Color(0xFFE9F7EA),
  ),
  departure(
    'departure',
    'Departure',
    Icons.directions_car_filled_rounded,
    Color(0xFFF97316),
    Color(0xFFFFF4E5),
  ),
  returnToOffice(
    'return_to_office',
    'Return to Office',
    Icons.apartment_rounded,
    Color(0xFF7C3AED),
    Color(0xFFF3E8FF),
  ),
  finalCheckOut(
    'final_check_out',
    'Final Check Out',
    Icons.logout_rounded,
    Color(0xFF2563EB),
    Color(0xFFEAF3FF),
  );

  final String apiValue;
  final String label;
  final IconData icon;
  final Color color;
  final Color softColor;

  const _CheckpointType(
    this.apiValue,
    this.label,
    this.icon,
    this.color,
    this.softColor,
  );
}

class _AttendanceRecord {
  final DateTime date;
  final DateTime? officeCheckIn;
  final DateTime? departure;
  final DateTime? returnToOffice;
  final DateTime? finalCheckOut;
  final String rawStatus;

  const _AttendanceRecord({
    required this.date,
    this.officeCheckIn,
    this.departure,
    this.returnToOffice,
    this.finalCheckOut,
    required this.rawStatus,
  });

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final parsedDate =
        _parseDate(_readString(json, const ['date', 'attendance_date'])) ??
            DateTime.now();
    return _AttendanceRecord(
      date: parsedDate,
      officeCheckIn: _parseDateTime(
        _readString(
          json,
          const ['office_check_in', 'officeCheckIn', 'checkIn', 'check_in'],
        ),
        parsedDate,
      ),
      departure: _parseDateTime(
        _readString(json, const ['departure', 'departure_time']),
        parsedDate,
      ),
      returnToOffice: _parseDateTime(
        _readString(json, const ['return_to_office', 'returnToOffice']),
        parsedDate,
      ),
      finalCheckOut: _parseDateTime(
        _readString(
          json,
          const ['final_check_out', 'finalCheckOut', 'checkOut', 'check_out'],
        ),
        parsedDate,
      ),
      rawStatus: _readString(json, const ['status', 'attendance_status']),
    );
  }

  DateTime? timeFor(_CheckpointType type) {
    return switch (type) {
      _CheckpointType.officeCheckIn => officeCheckIn,
      _CheckpointType.departure => departure,
      _CheckpointType.returnToOffice => returnToOffice,
      _CheckpointType.finalCheckOut => finalCheckOut,
    };
  }

  DateTime? get checkIn => officeCheckIn;

  DateTime? get checkOut => finalCheckOut;

  String get status {
    final normalized = rawStatus.trim().toLowerCase();
    if (normalized.contains('absent')) return 'absent';
    if (officeCheckIn == null && finalCheckOut == null) return 'absent';
    return 'present';
  }

  static _AttendanceRecord? todayFrom(List<_AttendanceRecord> records) {
    final now = DateTime.now();
    for (final record in records) {
      if (record.date.year == now.year &&
          record.date.month == now.month &&
          record.date.day == now.day) {
        return record;
      }
    }
    return null;
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

DateTime? _parseDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

DateTime? _parseDateTime(String value, DateTime fallbackDate) {
  final text = value.trim();
  if (text.isEmpty) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed != null) return parsed;

  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?$',
  ).firstMatch(text);
  if (match == null) return null;

  var hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  final period = match.group(3)?.toUpperCase();
  if (hour == null || minute == null) return null;
  if (period == 'PM' && hour < 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;
  return DateTime(
    fallbackDate.year,
    fallbackDate.month,
    fallbackDate.day,
    hour,
    minute,
  );
}

String _formatTime(DateTime? value) {
  if (value == null) return '--:-- --';
  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
          ? local.hour - 12
          : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
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
  return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
}

String _weekday(DateTime value) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[value.weekday - 1];
}

String _cleanError(Object? error) {
  final text = error?.toString().trim() ?? '';
  if (text.isEmpty) return 'Something went wrong.';
  return text.replaceFirst('ApiException: ', '');
}

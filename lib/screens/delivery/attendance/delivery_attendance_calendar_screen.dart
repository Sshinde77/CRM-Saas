import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../models/delivery_attendance_record.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryAttendanceCalendarScreen extends StatefulWidget {
  final List<DeliveryAttendanceRecord> records;

  const DeliveryAttendanceCalendarScreen({super.key, required this.records});

  @override
  State<DeliveryAttendanceCalendarScreen> createState() =>
      _DeliveryAttendanceCalendarScreenState();
}

class _DeliveryAttendanceCalendarScreenState
    extends State<DeliveryAttendanceCalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  Map<DateTime, DeliveryAttendanceRecord> get _recordsByDate {
    return {
      for (final record in widget.records)
        DateTime(record.date.year, record.date.month, record.date.day): record,
    };
  }

  @override
  void initState() {
    super.initState();
    final latest = widget.records.isNotEmpty
        ? widget.records.first.date
        : DateTime.now();
    _visibleMonth = DateTime(latest.year, latest.month);
    _selectedDate = DateTime(latest.year, latest.month, latest.day);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecord =
        _recordsByDate[DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        )];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Attendance Calendar',
              subtitle: 'Review present, absent and holiday dates',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        children: [
                          _CalendarCard(
                            visibleMonth: _visibleMonth,
                            selectedDate: _selectedDate,
                            recordsByDate: _recordsByDate,
                            onPreviousMonth: () {
                              setState(() {
                                _visibleMonth = DateTime(
                                  _visibleMonth.year,
                                  _visibleMonth.month - 1,
                                );
                              });
                            },
                            onNextMonth: () {
                              setState(() {
                                _visibleMonth = DateTime(
                                  _visibleMonth.year,
                                  _visibleMonth.month + 1,
                                );
                              });
                            },
                            onDateSelected: (date) {
                              setState(() => _selectedDate = date);
                            },
                          ),
                          const SizedBox(height: 12),
                          _DayDetailsCard(
                            selectedDate: _selectedDate,
                            record: selectedRecord,
                          ),
                        ],
                      ),
                    ),
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

enum _DayStatus {
  present('Present', Color(0xFF15803D)),
  absent('Absent', AppColors.deliveryRed),
  holiday('Holiday', Color(0xFFB7791F));

  final String label;
  final Color color;

  const _DayStatus(this.label, this.color);
}

_DayStatus _statusForDate(DateTime date, DeliveryAttendanceRecord? record) {
  if (date.weekday == DateTime.sunday) return _DayStatus.holiday;
  if (record?.isPresent == true) return _DayStatus.present;
  return _DayStatus.absent;
}

class _CalendarCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Map<DateTime, DeliveryAttendanceRecord> recordsByDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.recordsByDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final days = _monthCells(visibleMonth);

    return _SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              _IconButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPreviousMonth,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _monthTitle(visibleMonth),
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap a date to view attendance details',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _IconButton(
                icon: Icons.chevron_right_rounded,
                onTap: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _WeekdayCell('Mon'),
              _WeekdayCell('Tue'),
              _WeekdayCell('Wed'),
              _WeekdayCell('Thu'),
              _WeekdayCell('Fri'),
              _WeekdayCell('Sat'),
              _WeekdayCell('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              mainAxisExtent: 44,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              final inMonth = date.month == visibleMonth.month;
              final key = DateTime(date.year, date.month, date.day);
              final record = recordsByDate[key];
              return _CalendarDayCell(
                date: date,
                inMonth: inMonth,
                selected: isSameDate(date, selectedDate),
                record: record,
                onTap: () => onDateSelected(date),
              );
            },
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendDot(color: Color(0xFF15803D), label: 'Present'),
              SizedBox(width: 12),
              _LegendDot(color: AppColors.deliveryRed, label: 'Absent'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFB7791F), label: 'Sunday Holiday'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool inMonth;
  final bool selected;
  final DeliveryAttendanceRecord? record;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _statusForDate(date, record);
    final color = status.color;
    final fillColor = color.withValues(alpha: 0.11);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: inMonth ? fillColor : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.14),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: inMonth ? color : AppColors.textLightMuted,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayDetailsCard extends StatelessWidget {
  final DateTime selectedDate;
  final DeliveryAttendanceRecord? record;

  const _DayDetailsCard({required this.selectedDate, required this.record});

  @override
  Widget build(BuildContext context) {
    final status = _statusForDate(selectedDate, record);
    final statusColor = status.color;
    final statusLabel = status.label;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatAttendanceDate(selectedDate),
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attendanceWeekday(selectedDate),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.login_rounded,
            label: 'Check in time',
            value: formatAttendanceTime(record?.officeCheckIn),
            color: AppColors.deliveryGreen,
          ),
          _DetailRow(
            icon: Icons.directions_car_filled_rounded,
            label: 'Departure time',
            value: formatAttendanceTime(record?.departure),
            color: AppColors.deliveryOrange,
          ),
          _DetailRow(
            icon: Icons.apartment_rounded,
            label: 'Return to office time',
            value: formatAttendanceTime(record?.returnToOffice),
            color: AppColors.deliveryViolet,
          ),
          _DetailRow(
            icon: Icons.logout_rounded,
            label: 'Check out time',
            value: formatAttendanceTime(record?.finalCheckOut),
            color: AppColors.deliveryBlue,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10, top: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.deliverySurfaceBorder),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: value == '--:-- --'
                  ? AppColors.textMuted
                  : AppColors.deliveryInk,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.deliveryGreenSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.deliveryGreen, size: 24),
        ),
      ),
    );
  }
}

class _WeekdayCell extends StatelessWidget {
  final String label;

  const _WeekdayCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(12),
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

List<DateTime> _monthCells(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final start = firstDay.subtract(Duration(days: firstDay.weekday - 1));
  return List.generate(42, (index) => start.add(Duration(days: index)));
}

String _monthTitle(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

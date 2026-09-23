import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../core/theme/app_sizes.dart';

Future<DateTime?> showAppCalendarDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String title = 'Select Date',
}) {
  final normalizedFirst = _dateOnly(firstDate);
  final normalizedLast = _dateOnly(lastDate);
  final normalizedInitial = _clampDate(
    _dateOnly(initialDate),
    normalizedFirst,
    normalizedLast,
  );

  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black26,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: AppCalendarDatePicker(
            title: title,
            initialDate: normalizedInitial,
            firstDate: normalizedFirst,
            lastDate: normalizedLast,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onSelected: (date) => Navigator.of(dialogContext).pop(date),
          ),
        ),
      );
    },
  );
}

class AppCalendarDatePicker extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onCancel;

  const AppCalendarDatePicker({
    super.key,
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
    required this.onCancel,
  });

  @override
  State<AppCalendarDatePicker> createState() => _AppCalendarDatePickerState();
}

class _AppCalendarDatePickerState extends State<AppCalendarDatePicker> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(widget.initialDate);
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final canGoPrevious = _monthStart(
      _visibleMonth,
    ).isAfter(_monthStart(widget.firstDate));
    final canGoNext = _monthStart(
      _visibleMonth,
    ).isBefore(_monthStart(widget.lastDate));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _MonthButton(
                icon: Icons.chevron_left_rounded,
                enabled: canGoPrevious,
                onTap: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month - 1,
                    );
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _monthTitle(_visibleMonth),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _MonthButton(
                icon: Icons.chevron_right_rounded,
                enabled: canGoNext,
                onTap: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
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
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              mainAxisExtent: 42,
            ),
            itemBuilder: (context, index) {
              final date = _monthCellDate(_visibleMonth, index);
              final enabled =
                  !date.isBefore(widget.firstDate) &&
                  !date.isAfter(widget.lastDate);
              return _DateCell(
                date: date,
                inMonth: date.month == _visibleMonth.month,
                selected: _sameDate(date, _selectedDate),
                today: _sameDate(date, today),
                enabled: enabled,
                onTap: () => setState(() => _selectedDate = date),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed:
                    today.isBefore(widget.firstDate) ||
                        today.isAfter(widget.lastDate)
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = today;
                          _visibleMonth = DateTime(today.year, today.month);
                        });
                      },
                child: const Text(
                  'Today',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: () => widget.onSelected(_selectedDate),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deliveryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(82, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                  ),
                ),
                child: const Text('Select'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool inMonth;
  final bool selected;
  final bool today;
  final bool enabled;
  final VoidCallback onTap;

  const _DateCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.today,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selected
        ? AppColors.deliveryGreen
        : today
        ? AppColors.deliveryBlue
        : AppColors.deliveryInk;
    final textColor = enabled
        ? (inMonth ? activeColor : AppColors.textLightMuted)
        : AppColors.textLightMuted.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.deliveryGreenSoft
                : today
                ? AppColors.deliveryBlueSoft
                : inMonth
                ? const Color(0xFFF6F8FB)
                : const Color(0xFFFBFCFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.deliveryGreen
                  : today
                  ? AppColors.deliveryBlue.withValues(alpha: 0.22)
                  : AppColors.deliverySurfaceBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _MonthButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.deliveryGreenSoft : const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: enabled ? AppColors.deliveryGreen : AppColors.textLightMuted,
            size: 24,
          ),
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _monthStart(DateTime value) {
  return DateTime(value.year, value.month);
}

DateTime _clampDate(DateTime value, DateTime first, DateTime last) {
  if (value.isBefore(first)) return first;
  if (value.isAfter(last)) return last;
  return value;
}

DateTime _monthCellDate(DateTime month, int index) {
  final firstDay = DateTime(month.year, month.month);
  final start = firstDay.subtract(Duration(days: firstDay.weekday - 1));
  return start.add(Duration(days: index));
}

bool _sameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
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

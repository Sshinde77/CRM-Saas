enum DeliveryAttendanceCheckpoint {
  officeCheckIn,
  departure,
  returnToOffice,
  finalCheckOut,
}

class DeliveryAttendanceRecord {
  final DateTime date;
  final DateTime? officeCheckIn;
  final DateTime? departure;
  final DateTime? returnToOffice;
  final DateTime? finalCheckOut;
  final String rawStatus;

  const DeliveryAttendanceRecord({
    required this.date,
    this.officeCheckIn,
    this.departure,
    this.returnToOffice,
    this.finalCheckOut,
    required this.rawStatus,
  });

  factory DeliveryAttendanceRecord.fromJson(Map<String, dynamic> json) {
    final parsedDate =
        _parseDate(_readString(json, const ['date', 'attendance_date'])) ??
        DateTime.now();
    return DeliveryAttendanceRecord(
      date: parsedDate,
      officeCheckIn: _parseDateTime(
        _readString(json, const [
          'office_check_in',
          'officeCheckIn',
          'checkIn',
          'check_in',
        ]),
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
        _readString(json, const [
          'final_check_out',
          'finalCheckOut',
          'checkOut',
          'check_out',
        ]),
        parsedDate,
      ),
      rawStatus: _readString(json, const ['status', 'attendance_status']),
    );
  }

  DateTime? timeFor(DeliveryAttendanceCheckpoint checkpoint) {
    return switch (checkpoint) {
      DeliveryAttendanceCheckpoint.officeCheckIn => officeCheckIn,
      DeliveryAttendanceCheckpoint.departure => departure,
      DeliveryAttendanceCheckpoint.returnToOffice => returnToOffice,
      DeliveryAttendanceCheckpoint.finalCheckOut => finalCheckOut,
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

  bool get isPresent => status == 'present';

  static DeliveryAttendanceRecord? todayFrom(
    List<DeliveryAttendanceRecord> records,
  ) {
    final now = DateTime.now();
    for (final record in records) {
      if (isSameDate(record.date, now)) {
        return record;
      }
    }
    return null;
  }
}

bool isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String formatAttendanceTime(DateTime? value) {
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

String formatAttendanceDate(DateTime value) {
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

String attendanceWeekday(DateTime value) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[value.weekday - 1];
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

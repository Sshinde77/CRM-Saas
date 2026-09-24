class DeliveryExpense {
  final String id;
  final String expenseId;
  final String category;
  final String description;
  final double amount;
  final DateTime? expenseDate;
  final String paymentMode;
  final String? receiptUrl;
  final String approvalStatus;
  final String paymentStatus;
  final String? approverName;
  final DateTime? reviewedAt;
  final String? rejectReason;
  final String? clarificationNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryExpense({
    required this.id,
    required this.expenseId,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    required this.paymentMode,
    required this.receiptUrl,
    required this.approvalStatus,
    required this.paymentStatus,
    required this.approverName,
    required this.reviewedAt,
    required this.rejectReason,
    required this.clarificationNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryExpense.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        json['status'] ??
        json['approval_status'] ??
        json['expense_status'] ??
        'Pending';
    final status = _titleStatus(rawStatus);
    final rawPaymentStatus =
        json['payment_status'] ?? json['reimbursement_status'] ?? 'Unpaid';
    final approvedByUser = json['approved_by_user'];
    final approvedByData = approvedByUser is Map<String, dynamic>
        ? approvedByUser
        : null;

    return DeliveryExpense(
      id: _string(json['id'] ?? json['expense_id']),
      expenseId: _string(
        json['expense_number'] ?? json['expense_id'] ?? json['id'],
        fallback: 'EXP',
      ),
      category: _string(json['category'], fallback: 'Uncategorized'),
      description: _string(json['description'], fallback: '-'),
      amount: _double(json['amount']),
      expenseDate: _date(json['expense_date'] ?? json['date']),
      paymentMode: _titleStatus(
        json['payment_mode'] ?? json['paymentMode'] ?? 'Cash',
      ),
      receiptUrl: _nullableString(
        json['receipt_url'] ?? json['receipt'] ?? json['receiptUrl'],
      ),
      approvalStatus: status,
      paymentStatus: _titleStatus(rawPaymentStatus),
      approverName: _nullableString(
        approvedByData?['name'] ?? json['approver_name'],
      ),
      reviewedAt: _date(json['reviewed_at'] ?? json['approved_at']),
      rejectReason: _nullableString(
        json['reject_reason'] ?? json['rejection_reason'] ?? json['reason'],
      ),
      clarificationNote: _nullableString(
        json['clarification_note'] ??
            json['clarification_reason'] ??
            json['review_note'],
      ),
      createdAt: _date(json['created_at'] ?? json['submitted_at']),
      updatedAt: _date(json['updated_at']),
    );
  }

  String get displayStatus {
    if (approvalStatus == 'Approved' && paymentStatus == 'Paid') {
      return 'Reimbursed';
    }
    return approvalStatus;
  }

  bool get hasReceipt => receiptUrl != null && receiptUrl!.trim().isNotEmpty;
  bool get canCancel => approvalStatus == 'Pending';
  bool get canUpdate => approvalStatus == 'Clarification Required';
}

class DeliveryExpenseRequest {
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String paymentMode;
  final String description;

  const DeliveryExpenseRequest({
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.paymentMode,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final local = expenseDate.toLocal();
    return {
      'category': category,
      'amount': amount,
      'expense_date':
          '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}',
      'payment_mode': paymentMode,
      'description': description,
    };
  }
}

String _string(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _titleStatus(Object? value) {
  final text = _string(
    value,
    fallback: 'Pending',
  ).replaceAll('_', ' ').replaceAll('-', ' ').trim().toLowerCase();
  if (text.isEmpty) return 'Pending';
  return text
      .split(RegExp(r'\s+'))
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

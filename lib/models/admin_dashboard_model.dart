class AdminDashboardData {
  final AdminDashboardSummary summary;
  final AdminDashboardOrders orders;
  final AdminReceivablesPayables receivablesPayables;
  final List<AdminCashflowPoint> cashflow;
  final List<AdminExpenseBreakdownItem> expenseBreakdown;
  final List<AdminSalesTrendPoint> salesTrend;
  final List<AdminTopProduct> topProducts;
  final List<AdminTopCustomer> topCustomers;
  final List<AdminStockWatchItem> stockWatch;
  final List<AdminRecentOrder> recentOrders;

  const AdminDashboardData({
    required this.summary,
    required this.orders,
    required this.receivablesPayables,
    required this.cashflow,
    required this.expenseBreakdown,
    required this.salesTrend,
    required this.topProducts,
    required this.topCustomers,
    required this.stockWatch,
    required this.recentOrders,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final payload =
        _asMap(json['data']) ??
        _asMap(json['dashboard']) ??
        _asMap(json['admin_dashboard']) ??
        json;

    return AdminDashboardData(
      summary: AdminDashboardSummary.fromJson(
        _asMap(payload['summary']) ?? payload,
      ),
      orders: AdminDashboardOrders.fromJson(
        _asMap(payload['orders']) ?? const {},
      ),
      receivablesPayables: AdminReceivablesPayables.fromJson(
        _asMap(payload['receivables_payables']) ??
            _asMap(payload['receivablesPayables']) ??
            const {},
      ),
      cashflow: _mapList(
        payload['cashflow'],
      ).map(AdminCashflowPoint.fromJson).toList(),
      expenseBreakdown: _mapList(
        payload['expense_breakdown'],
      ).map(AdminExpenseBreakdownItem.fromJson).toList(),
      salesTrend: _mapList(
        payload['sales_trend'],
      ).map(AdminSalesTrendPoint.fromJson).toList(),
      topProducts: _mapList(
        payload['top_products'],
      ).map(AdminTopProduct.fromJson).toList(),
      topCustomers: _mapList(
        payload['top_customers'],
      ).map(AdminTopCustomer.fromJson).toList(),
      stockWatch: _mapList(
        payload['stock_watch'],
      ).map(AdminStockWatchItem.fromJson).toList(),
      recentOrders: _mapList(
        payload['recent_orders'],
      ).map(AdminRecentOrder.fromJson).toList(),
    );
  }
}

class AdminDashboardSummary {
  final double todaySales;
  final double monthlyTarget;
  final double monthSales;
  final double purchases;
  final double expenses;
  final double grossProfit;
  final double netProfit;
  final int newCustomers;
  final double salesGrowthPercentage;

  const AdminDashboardSummary({
    required this.todaySales,
    required this.monthlyTarget,
    required this.monthSales,
    required this.purchases,
    required this.expenses,
    required this.grossProfit,
    required this.netProfit,
    required this.newCustomers,
    required this.salesGrowthPercentage,
  });

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummary(
      todaySales: _number(json['today_sales'] ?? json['todaySales']),
      monthlyTarget: _number(json['monthly_target'] ?? json['monthlyTarget']),
      monthSales: _number(
        json['month_sales'] ?? json['monthSales'] ?? json['period_sales'],
      ),
      purchases: _number(json['purchases']),
      expenses: _number(json['expenses']),
      grossProfit: _number(json['gross_profit'] ?? json['grossProfit']),
      netProfit: _number(json['net_profit'] ?? json['netProfit']),
      newCustomers: _number(
        json['new_customers'] ?? json['newCustomers'],
      ).round(),
      salesGrowthPercentage: _number(
        json['sales_growth_percentage'] ?? json['salesGrowthPercentage'],
      ),
    );
  }
}

class AdminDashboardOrders {
  final int total;
  final int delivered;
  final int pending;
  final int cancelled;

  const AdminDashboardOrders({
    required this.total,
    required this.delivered,
    required this.pending,
    required this.cancelled,
  });

  factory AdminDashboardOrders.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOrders(
      total: _number(
        json['total'] ?? json['total_orders'] ?? json['orders'],
      ).round(),
      delivered: _number(json['delivered'] ?? json['completed']).round(),
      pending: _number(json['pending'] ?? json['processing']).round(),
      cancelled: _number(json['cancelled'] ?? json['canceled']).round(),
    );
  }
}

class AdminReceivablesPayables {
  final double receivables;
  final double payables;
  final double overdueReceivables;
  final double overduePayables;

  const AdminReceivablesPayables({
    required this.receivables,
    required this.payables,
    required this.overdueReceivables,
    required this.overduePayables,
  });

  factory AdminReceivablesPayables.fromJson(Map<String, dynamic> json) {
    return AdminReceivablesPayables(
      receivables: _number(json['receivables']),
      payables: _number(json['payables']),
      overdueReceivables: _number(
        json['overdue_receivables'] ?? json['overdueReceivables'],
      ),
      overduePayables: _number(
        json['overdue_payables'] ?? json['overduePayables'],
      ),
    );
  }
}

class AdminCashflowPoint {
  final String date;
  final double inflow;
  final double outflow;

  const AdminCashflowPoint({
    required this.date,
    required this.inflow,
    required this.outflow,
  });

  factory AdminCashflowPoint.fromJson(Map<String, dynamic> json) {
    return AdminCashflowPoint(
      date: _label(json['date'] ?? json['label']),
      inflow: _number(json['inflow'] ?? json['income']),
      outflow: _number(json['outflow'] ?? json['expense']),
    );
  }
}

class AdminExpenseBreakdownItem {
  final String category;
  final double amount;

  const AdminExpenseBreakdownItem({
    required this.category,
    required this.amount,
  });

  factory AdminExpenseBreakdownItem.fromJson(Map<String, dynamic> json) {
    return AdminExpenseBreakdownItem(
      category: _label(json['category'] ?? json['name']),
      amount: _number(json['amount'] ?? json['total']),
    );
  }
}

class AdminSalesTrendPoint {
  final String date;
  final double sales;

  const AdminSalesTrendPoint({required this.date, required this.sales});

  factory AdminSalesTrendPoint.fromJson(Map<String, dynamic> json) {
    return AdminSalesTrendPoint(
      date: _label(json['date'] ?? json['label']),
      sales: _number(json['sales'] ?? json['amount']),
    );
  }
}

class AdminTopProduct {
  final String productName;
  final double salesAmount;
  final double quantity;

  const AdminTopProduct({
    required this.productName,
    required this.salesAmount,
    required this.quantity,
  });

  factory AdminTopProduct.fromJson(Map<String, dynamic> json) {
    return AdminTopProduct(
      productName: _label(
        json['product_name'] ?? json['productName'] ?? json['name'],
      ),
      salesAmount: _number(
        json['sales_amount'] ?? json['salesAmount'] ?? json['sales'],
      ),
      quantity: _number(json['quantity'] ?? json['qty']),
    );
  }
}

class AdminTopCustomer {
  final String customerName;
  final double sales;

  const AdminTopCustomer({required this.customerName, required this.sales});

  factory AdminTopCustomer.fromJson(Map<String, dynamic> json) {
    return AdminTopCustomer(
      customerName: _label(
        json['customer_name'] ?? json['customerName'] ?? json['name'],
      ),
      sales: _number(json['sales'] ?? json['amount'] ?? json['total']),
    );
  }
}

class AdminStockWatchItem {
  final String productName;
  final String status;
  final double stockPercentage;

  const AdminStockWatchItem({
    required this.productName,
    required this.status,
    required this.stockPercentage,
  });

  factory AdminStockWatchItem.fromJson(Map<String, dynamic> json) {
    return AdminStockWatchItem(
      productName: _label(
        json['product_name'] ?? json['productName'] ?? json['name'],
      ),
      status: _label(json['status']).isEmpty
          ? 'Low stock'
          : _label(json['status']),
      stockPercentage: _number(
        json['stock_percentage'] ??
            json['stockPercentage'] ??
            json['percentage'],
      ),
    );
  }
}

class AdminRecentOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String status;
  final String paymentStatus;
  final double total;
  final String date;

  const AdminRecentOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.date,
  });

  factory AdminRecentOrder.fromJson(Map<String, dynamic> json) {
    return AdminRecentOrder(
      id: _label(json['id'] ?? json['_id']),
      orderNumber: _label(
        json['order_number'] ?? json['orderNumber'] ?? json['number'],
      ),
      customerName: _label(
        json['customer_name'] ?? json['customerName'] ?? json['customer'],
      ),
      status: _label(json['status']),
      paymentStatus: _label(json['payment_status'] ?? json['paymentStatus']),
      total: _number(json['total'] ?? json['amount']),
      date: _label(json['date'] ?? json['created_at'] ?? json['createdAt']),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  return _asList(value).map(_asMap).whereType<Map<String, dynamic>>().toList();
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(
          value
              .replaceAll(',', '')
              .replaceAll('Rs.', '')
              .replaceAll('₹', '')
              .trim(),
        ) ??
        0;
  }
  return 0;
}

String _label(dynamic value) => value?.toString().trim() ?? '';

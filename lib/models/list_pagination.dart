import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Per-screen pagination state. Pass explicitly only to the primary list request;
/// lookup requests and other screens keep their own independent state.
class ListPagination extends ChangeNotifier {
  int page = 1;
  int pageSize = 10;
  int total = 0;
  int totalPages = 1;
  bool isLoading = false;
  bool serverPaginated = false;
  Object? _filterKey;
  Object? _observedKey;
  Map<String, String> filters = {};
  bool _disposed = false;

  String get requestKey =>
      query.entries.map((e) => '${e.key}=${e.value}').join('&');

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Map<String, String> get query => {
    ...filters,
    'page': '$page',
    'page_size': '$pageSize',
  };

  void reset() => page = 1;

  /// Called by a screen when its search or filters change.
  bool observe(Object key) {
    final changed = _observedKey != null && _observedKey != key;
    _observedKey = key;
    if (changed) filter(key);
    return changed;
  }

  void filter(Object key) {
    if (_filterKey != key) {
      _filterKey = key;
      reset();
    }
  }

  List<T> local<T>(List<T> items, {Object? filterKey}) {
    if (filterKey != null) filter(filterKey);
    total = items.length;
    totalPages = math.max(1, (total / pageSize).ceil());
    page = page.clamp(1, totalPages);
    final start = math.min((page - 1) * pageSize, total);
    return items.sublist(start, math.min(start + pageSize, total));
  }

  /// Accepts the API's {items,total,page,page_size,total_pages} envelope.
  /// Older endpoints returning an unpaginated array are sliced locally.
  List<T> read<T>(dynamic decoded, List<T> items, {String? requestKey}) {
    if (_disposed || (requestKey != null && requestKey != this.requestKey)) {
      return items;
    }
    // Requests can finish during a FutureBuilder build. Defer footer updates.
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
    Map<dynamic, dynamic> meta = decoded is Map ? decoded : {};
    for (final key in ['meta', 'pagination', 'page_info', 'pageInfo']) {
      if (meta[key] is Map) {
        meta = meta[key] as Map;
        break;
      }
    }
    int? number(List<String> keys) {
      for (final key in keys) {
        final value = int.tryParse('${meta[key]}');
        if (value != null) return value;
      }
      return null;
    }

    final responsePage = number(['page', 'current_page', 'currentPage']);
    final responseTotal = number(['total', 'total_items', 'totalItems']);
    final responsePages = number(['total_pages', 'totalPages', 'last_page']);
    serverPaginated =
        responsePage != null || responsePages != null || responseTotal != null;
    if (!serverPaginated) return local(items);
    page = math.max(1, responsePage ?? page);
    pageSize = math.max(
      1,
      number(['page_size', 'per_page', 'pageSize', 'limit']) ?? pageSize,
    );
    total = math.max(
      0,
      responseTotal ?? ((page - 1) * pageSize + items.length),
    );
    totalPages = math.max(1, responsePages ?? (total / pageSize).ceil());
    return items;
  }
}

import 'package:flutter/material.dart';

import '../models/list_pagination.dart';
import 'list_pagination_bar.dart';

/// Pagination for sample-data lists that do not yet have a list API.
class PaginatedRecords<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, List<T> items) builder;

  const PaginatedRecords({
    super.key,
    required this.items,
    required this.builder,
  });

  @override
  State<PaginatedRecords<T>> createState() => _PaginatedRecordsState<T>();
}

class _PaginatedRecordsState<T> extends State<PaginatedRecords<T>> {
  final _pagination = ListPagination();

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _pagination.local(
      widget.items,
      filterKey: Object.hashAll(widget.items),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.builder(context, items),
        ListPaginationBar(
          pagination: _pagination,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
}

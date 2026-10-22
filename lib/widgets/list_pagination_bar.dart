import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/list_pagination.dart';

class ListPaginationBar extends StatelessWidget {
  final ListPagination pagination;
  final VoidCallback onChanged;
  final bool loading;

  const ListPaginationBar({
    super.key,
    required this.pagination,
    required this.onChanged,
    this.loading = false,
  });

  static List<int?> pageNumbers(int current, int last) {
    final pages = <int>{1, last};
    for (var p = current - 1; p <= current + 1; p++) {
      if (p >= 1 && p <= last) pages.add(p);
    }
    if (current <= 3) {
      for (var p = 1; p <= 4 && p <= last; p++) {
        pages.add(p);
      }
    }
    if (current >= last - 2) {
      for (var p = last - 3; p <= last; p++) {
        if (p > 0) pages.add(p);
      }
    }
    final sorted = pages.toList()..sort();
    final result = <int?>[];
    for (final p in sorted) {
      if (result.isNotEmpty && p - result.last! > 1) result.add(null);
      result.add(p);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ListenableBuilder(
      listenable: pagination,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) =>
            _buildBar(context, constraints.maxWidth),
      ),
    ),
  );

  Widget _buildBar(BuildContext context, double width) {
    final compact = width < 360;
    final busy = loading || pagination.isLoading;
    final first = pagination.total == 0
        ? 0
        : (pagination.page - 1) * pagination.pageSize + 1;
    final last = (pagination.page * pagination.pageSize).clamp(
      0,
      pagination.total,
    );
    void go(int page) {
      if (busy ||
          page < 1 ||
          page > pagination.totalPages ||
          page == pagination.page) {
        return;
      }
      pagination.page = page;
      onChanged();
    }

    Widget button({
      required Widget child,
      required String label,
      required VoidCallback? onPressed,
      bool selected = false,
    }) {
      return Semantics(
        selected: selected,
        child: SizedBox(
          width: compact ? 30 : 36,
          height: compact ? 30 : 36,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: selected
                  ? AppColors.primary
                  : Colors.transparent,
              foregroundColor: selected ? Colors.white : AppColors.primary,
              disabledForegroundColor: AppColors.textLightMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: selected
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.border),
              ),
            ),
            child: Tooltip(message: label, child: child),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 6,
                children: [
                  Text(
                    'Showing $first–$last of ${pagination.total}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (false)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Per page: ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        DropdownButton<int>(
                          value: pagination.pageSize,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          items:
                              ({10, 25, 50, 100, pagination.pageSize}.toList()
                                    ..sort())
                                  .map(
                                    (size) => DropdownMenuItem(
                                      value: size,
                                      child: Text('$size'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: busy
                              ? null
                              : (size) {
                                  if (size == null ||
                                      size == pagination.pageSize) {
                                    return;
                                  }
                                  pagination.pageSize = size;
                                  pagination.reset();
                                  onChanged();
                                },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: width),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      button(
                        child: const Icon(Icons.chevron_left_rounded),
                        label: 'Previous page',
                        onPressed: busy || pagination.page <= 1
                            ? null
                            : () => go(pagination.page - 1),
                      ),
                      for (final p in pageNumbers(
                        pagination.page,
                        pagination.totalPages,
                      )) ...[
                        SizedBox(width: compact ? 3 : 5),
                        if (p == null)
                          SizedBox(
                            width: compact ? 16 : 20,
                            child: const Center(child: Text('…')),
                          )
                        else
                          button(
                            child: Text('$p'),
                            label: 'Page $p',
                            selected: p == pagination.page,
                            onPressed: busy ? null : () => go(p),
                          ),
                      ],
                      SizedBox(width: compact ? 3 : 5),
                      button(
                        child: const Icon(Icons.chevron_right_rounded),
                        label: 'Next page',
                        onPressed:
                            busy || pagination.page >= pagination.totalPages
                            ? null
                            : () => go(pagination.page + 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact page-size selector intended to sit beside a list heading.
class ListPaginationPageSize extends StatelessWidget {
  final ListPagination pagination;
  final VoidCallback onChanged;
  final bool loading;

  const ListPaginationPageSize({
    super.key,
    required this.pagination,
    required this.onChanged,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: pagination,
    builder: (context, _) {
      final busy = loading || pagination.isLoading;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Per page:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 4),
          DropdownButton<int>(
            value: pagination.pageSize,
            isDense: true,
            underline: const SizedBox.shrink(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            items: ({10, 25, 50, 100, pagination.pageSize}.toList()..sort())
                .map(
                  (size) => DropdownMenuItem(value: size, child: Text('$size')),
                )
                .toList(),
            onChanged: busy
                ? null
                : (size) {
                    if (size == null || size == pagination.pageSize) return;
                    pagination.pageSize = size;
                    pagination.reset();
                    onChanged();
                  },
          ),
        ],
      );
    },
  );
}

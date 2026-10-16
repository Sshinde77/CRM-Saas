import 'package:flutter/material.dart';

class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.isLoading = false,
    this.pageSizeOptions = const [10, 20, 50],
  });

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final bool isLoading;
  final List<int> pageSizeOptions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safePages = totalPages < 1 ? 1 : totalPages;
    final safePage = page.clamp(1, safePages);
    final start = total == 0 ? 0 : ((safePage - 1) * pageSize) + 1;
    final end = (safePage * pageSize).clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final info = Text(
            'Showing $start–$end of $total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          );
          final controls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: pageSizeOptions.contains(pageSize)
                      ? pageSize
                      : pageSizeOptions.first,
                  isDense: true,
                  borderRadius: BorderRadius.circular(12),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  items: pageSizeOptions
                      .map(
                        (size) => DropdownMenuItem(
                          value: size,
                          child: Text('$size / page'),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null && value != pageSize) {
                            onPageSizeChanged(value);
                          }
                        },
                ),
              ),
              const SizedBox(width: 8),
              _PageButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous page',
                enabled: !isLoading && safePage > 1,
                onTap: () => onPageChanged(safePage - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$safePage / $safePages',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _PageButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next page',
                enabled: !isLoading && safePage < safePages,
                onTap: () => onPageChanged(safePage + 1),
              ),
            ],
          );

          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [info, const SizedBox(height: 8), controls],
            );
          }
          return Row(children: [info, const Spacer(), controls]);
        },
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      icon: Icon(icon, size: 22),
    );
  }
}

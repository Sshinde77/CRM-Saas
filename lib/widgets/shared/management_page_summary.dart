import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class ManagementKpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const ManagementKpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class ManagementPageSummary extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ManagementKpiData> kpis;
  final VoidCallback? onAdd;

  const ManagementPageSummary({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.kpis,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    assert(kpis.length == 4, 'ManagementPageSummary requires four KPIs.');
    final compact = MediaQuery.sizeOf(context).width < 420;

    return Column(
      children: [
        _SummarySurface(
          padding: EdgeInsets.all(compact ? 10 : 12),
          child: Row(
            children: [
              Container(
                width: compact ? 34 : 38,
                height: compact ? 34 : 38,
                decoration: BoxDecoration(
                  color: AppColors.deliveryGreenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.deliveryGreen,
                  size: compact ? 18 : 21,
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: compact ? 14 : 16,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF4F5870),
                        fontSize: compact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onAdd != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: AppColors.deliveryGreen,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.surface,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SummarySurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _KpiTile(data: kpis[0])),
                  const SizedBox(width: 10),
                  Expanded(child: _KpiTile(data: kpis[1])),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _KpiTile(data: kpis[2])),
                  const SizedBox(width: 10),
                  Expanded(child: _KpiTile(data: kpis[3])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final ManagementKpiData data;

  const _KpiTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF586176),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySurface extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _SummarySurface({required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deliveryCardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

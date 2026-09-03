import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/end_of_day_return_models.dart';
import '../../../../routes/app_router.dart';
import 'end_of_day_shared.dart';

class ReconciliationSummary extends StatelessWidget {
  final List<ReconciliationLine> lines;

  const ReconciliationSummary({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    final totalExpected = lines.fold<double>(
      0,
      (sum, line) => sum + line.expected,
    );
    final totalPhysical = lines.fold<double>(
      0,
      (sum, line) => sum + line.physical,
    );
    final netVariance = totalPhysical - totalExpected;

    return Column(
      children: [
        EndOfDayCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Text(
                  'Variance by Product',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE9EDF5)),
              const _SummaryHeader(),
              ...lines.map(_SummaryRow.new),
            ],
          ),
        ),
        const SizedBox(height: 12),
        EndOfDayCard(
          child: Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.inventory_2_outlined,
                  label: 'Total Expected',
                  value: qty(totalExpected),
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.fact_check_outlined,
                  label: 'Total Physical',
                  value: qty(totalPhysical),
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.sync_alt_rounded,
                  label: 'Net Variance',
                  value: netVariance > 0
                      ? '+${qty(netVariance)}'
                      : qty(netVariance),
                  subValue: netVariance == 0
                      ? 'Matched'
                      : netVariance > 0
                      ? 'Surplus'
                      : 'Shortage',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.deliveryVehicleStock,
                (route) => false,
              );
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Expanded(flex: 4, child: _HeaderText('Product')),
          Expanded(flex: 2, child: _HeaderText('Expected')),
          Expanded(flex: 2, child: _HeaderText('Physical')),
          Expanded(flex: 3, child: _HeaderText('Variance')),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final ReconciliationLine line;

  const _SummaryRow(this.line);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9EDF5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.productName.isEmpty
                      ? 'Unnamed product'
                      : line.item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.item.variantId.isEmpty ? '-' : line.item.variantId,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _NumberText(qty(line.expected))),
          Expanded(flex: 2, child: _NumberText(qty(line.physical))),
          Expanded(flex: 3, child: VarianceBadge(variance: line.variance)),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D7A24)),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.deliveryInk,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (subValue != null)
          Text(
            subValue!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.deliveryInk,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _NumberText extends StatelessWidget {
  final String text;

  const _NumberText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.deliveryInk,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

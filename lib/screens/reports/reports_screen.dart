import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedPeriod = 'This Month';
  String _selectedFormat = 'PDF';

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final List<_ReportCardData> _reports = const [
    _ReportCardData(
      title: 'Sales Report',
      description: 'Track revenue, orders, and performance trends for the selected period.',
      icon: Icons.point_of_sale_rounded,
      accent: AppColors.green,
      highlights: [
        _ReportHighlight('Revenue', 'Rs 4.8L'),
        _ReportHighlight('Orders', '328'),
        _ReportHighlight('Growth', '+12.4%'),
      ],
    ),
    _ReportCardData(
      title: 'Inventory Report',
      description: 'Review stock movement, low stock alerts, and available inventory.',
      icon: Icons.inventory_2_rounded,
      accent: AppColors.purple,
      highlights: [
        _ReportHighlight('Products', '182'),
        _ReportHighlight('Low Stock', '14'),
        _ReportHighlight('Out of Stock', '3'),
      ],
    ),
    _ReportCardData(
      title: 'Customer Report',
      description: 'See customer activity, repeat buyers, and top account summaries.',
      icon: Icons.groups_rounded,
      accent: AppColors.blue,
      highlights: [
        _ReportHighlight('Customers', '1,245'),
        _ReportHighlight('Repeat Rate', '68%'),
        _ReportHighlight('New This Month', '84'),
      ],
    ),
    _ReportCardData(
      title: 'Purchase Report',
      description: 'Monitor purchase invoices, suppliers, and procurement totals.',
      icon: Icons.receipt_long_rounded,
      accent: AppColors.orange,
      highlights: [
        _ReportHighlight('Invoices', '64'),
        _ReportHighlight('Suppliers', '19'),
        _ReportHighlight('Spend', 'Rs 2.1L'),
      ],
    ),
  ];

  void _downloadReport(String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$reportName download started as $_selectedFormat for $_selectedPeriod'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadAllReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All reports download started as $_selectedFormat for $_selectedPeriod'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Reports'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Reports',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reports',
                                style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Generate and download business reports in one place',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _downloadAllReports,
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChipField(
                            label: 'Period',
                            value: _selectedPeriod,
                            items: const ['Today', 'This Week', 'This Month', 'This Year'],
                            onChanged: (value) => setState(() => _selectedPeriod = value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterChipField(
                            label: 'Format',
                            value: _selectedFormat,
                            items: const ['PDF', 'CSV', 'Excel'],
                            onChanged: (value) => setState(() => _selectedFormat = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reports.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: crossAxisCount == 2 ? 1.35 : 1.15,
                          ),
                          itemBuilder: (context, index) {
                            return _ReportCard(
                              data: _reports[index],
                              selectedFormat: _selectedFormat,
                              selectedPeriod: _selectedPeriod,
                              onDownload: () => _downloadReport(_reports[index].title),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterChipField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                borderRadius: BorderRadius.circular(14),
                dropdownColor: AppColors.primary,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
                items: items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) onChanged(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _ReportCardData data;
  final String selectedPeriod;
  final String selectedFormat;
  final VoidCallback onDownload;

  const _ReportCard({
    required this.data,
    required this.selectedPeriod,
    required this.selectedFormat,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: data.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.highlights
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: TextStyle(color: data.accent, fontSize: 14.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$selectedPeriod - $selectedFormat',
                    style: TextStyle(color: data.accent, fontSize: 12.5, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: data.accent,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCardData {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final List<_ReportHighlight> highlights;

  const _ReportCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.highlights,
  });
}

class _ReportHighlight {
  final String label;
  final String value;

  const _ReportHighlight(this.label, this.value);
}

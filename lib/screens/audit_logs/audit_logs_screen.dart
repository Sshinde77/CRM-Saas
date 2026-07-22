import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _selectedFilter = 'All';

  final List<_AuditLogEntry> _entries = const [
    _AuditLogEntry(
      type: 'Created',
      module: 'User',
      title: 'New user profile created',
      detail: 'Priya Patel was added to the admin directory.',
      actor: 'Amit Sharma',
      time: 'Today, 02:30 PM',
      icon: Icons.person_add_alt_1_rounded,
      accent: AppColors.green,
    ),
    _AuditLogEntry(
      type: 'Updated',
      module: 'Product',
      title: 'Product information updated',
      detail: 'AquaPure 1L price and stock threshold were changed.',
      actor: 'Amit Sharma',
      time: 'Today, 01:15 PM',
      icon: Icons.inventory_2_rounded,
      accent: AppColors.blue,
    ),
    _AuditLogEntry(
      type: 'Created',
      module: 'Order',
      title: 'New order created',
      detail: 'Order #1245 was placed from the mobile storefront.',
      actor: 'Priya Patel',
      time: 'Today, 12:00 PM',
      icon: Icons.receipt_long_rounded,
      accent: AppColors.purple,
    ),
    _AuditLogEntry(
      type: 'Alert',
      module: 'Stock',
      title: 'Low stock warning triggered',
      detail: '500ml bottles dropped below the minimum threshold.',
      actor: 'System',
      time: 'Today, 11:45 AM',
      icon: Icons.warning_amber_rounded,
      accent: AppColors.orange,
    ),
  ];

  List<_AuditLogEntry> get _visibleEntries {
    if (_selectedFilter == 'All') return _entries;
    return _entries.where((entry) => entry.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Audit Logs'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Audit Logs',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerSection(),
                    const SizedBox(height: 18),
                    _summaryStrip(),
                    const SizedBox(height: 18),
                    _filterChips(),
                    const SizedBox(height: 18),
                    if (entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No audit logs found for this filter.',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...entries.asMap().entries.map(
                            (entry) => Padding(
                              padding: EdgeInsets.only(bottom: entry.key == entries.length - 1 ? 0 : 14),
                              child: _auditCard(entry.value),
                            ),
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

  Widget _headerSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit Logs',
                style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Track creation, updates, and alerts across the system',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.purple, AppColors.blue]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Live trail',
            style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _summaryStrip() {
    final created = _entries.where((e) => e.type == 'Created').length;
    final updated = _entries.where((e) => e.type == 'Updated').length;
    final alerts = _entries.where((e) => e.type == 'Alert').length;

    return Row(
      children: [
        Expanded(child: _miniStat('Created', '$created', AppColors.green, Icons.add_circle_outline_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _miniStat('Updated', '$updated', AppColors.blue, Icons.sync_alt_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _miniStat('Alerts', '$alerts', AppColors.orange, Icons.report_problem_outlined)),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: accent),
              const Spacer(),
              Text(value, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _filterChips() {
    final filters = ['All', 'Created', 'Updated', 'Alert'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map((label) {
        final selected = _selectedFilter == label;
        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _selectedFilter = label),
          labelStyle: TextStyle(
            color: selected ? AppColors.primary : textPrimary,
            fontWeight: FontWeight.w700,
          ),
          selectedColor: AppColors.purple,
          backgroundColor: AppColors.surfaceSoft,
          side: BorderSide(color: selected ? AppColors.purple : AppColors.secondary.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        );
      }).toList(),
    );
  }

  Widget _auditCard(_AuditLogEntry entry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: entry.accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: entry.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(entry.icon, color: entry.accent, size: 24),
              ),
              const SizedBox(height: 10),
              Container(
                width: 2,
                height: 68,
                decoration: BoxDecoration(
                  color: entry.accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: entry.accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        entry.type,
                        style: TextStyle(color: entry.accent, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.module,
                        style: const TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.time,
                      style: const TextStyle(color: textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.title,
                  style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.detail,
                  style: const TextStyle(color: textSecondary, fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16, color: entry.accent),
                    const SizedBox(width: 6),
                    Text(
                      'By ${entry.actor}',
                      style: TextStyle(color: entry.accent, fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogEntry {
  final String type;
  final String module;
  final String title;
  final String detail;
  final String actor;
  final String time;
  final IconData icon;
  final Color accent;

  const _AuditLogEntry({
    required this.type,
    required this.module,
    required this.title,
    required this.detail,
    required this.actor,
    required this.time,
    required this.icon,
    required this.accent,
  });
}

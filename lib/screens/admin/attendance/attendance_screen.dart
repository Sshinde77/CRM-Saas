import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _roleFilters = const [
    'All Roles',
    'Admin',
    'Sales Officer',
    'Delivery Partner',
    'Accountant',
  ];

  final List<String> _employeeFilters = const [
    'All Employees',
    'Present',
    'On Leave',
    'Week Off',
  ];

  final List<String> _dateFilters = const [
    'Today',
    'This Week',
    'This Month',
  ];

  final List<String> _statusFilters = const [
    'Status: All',
    'Present',
    'Late',
    'Leave',
    'Week Off',
  ];

  String _selectedRole = 'All Roles';
  String _selectedEmployee = 'All Employees';
  String _selectedDate = 'Today';
  String _selectedStatus = 'Status: All';
  String _query = '';
  int _currentPage = 0;

  final List<_AttendanceRecord> _records = const [
    _AttendanceRecord(
      initials: 'AS',
      name: 'Anita Sharma',
      userId: 'usr-2',
      role: 'Admin',
      dateLabel: '17 Jul 2026',
      dayLabel: 'Fri',
      status: 'Present',
      checkIn: '09:29 AM',
      checkInBadge: 'On time',
      checkOut: '06:33 PM',
      workHours: '9h 04m',
      accentColor: Color(0xFF0B4A06),
    ),
    _AttendanceRecord(
      initials: 'VS',
      name: 'Vikram Singh',
      userId: 'usr-3',
      role: 'Sales Officer',
      dateLabel: '17 Jul 2026',
      dayLabel: 'Fri',
      status: 'Present',
      checkIn: '09:38 AM',
      checkInBadge: 'Late',
      checkOut: '07:20 PM',
      workHours: '9h 42m',
      accentColor: Color(0xFF0B4A06),
    ),
    _AttendanceRecord(
      initials: 'SK',
      name: 'Suresh Kumar',
      userId: 'usr-4',
      role: 'Delivery Partner',
      dateLabel: '17 Jul 2026',
      dayLabel: 'Fri',
      status: 'Present',
      checkIn: '07:58 AM',
      checkInBadge: 'On time',
      checkOut: '08:20 PM',
      workHours: '12h 22m',
      accentColor: Color(0xFF0B4A06),
    ),
    _AttendanceRecord(
      initials: 'PN',
      name: 'Priya Nair',
      userId: 'usr-5',
      role: 'Accountant',
      dateLabel: '17 Jul 2026',
      dayLabel: 'Fri',
      status: 'Present',
      checkIn: '09:27 AM',
      checkInBadge: 'On time',
      checkOut: '06:30 PM',
      workHours: '9h 03m',
      accentColor: Color(0xFF0B4A06),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_AttendanceRecord> get _filteredRecords {
    final query = _query.trim().toLowerCase();
    return _records.where((record) {
      final matchesQuery =
          query.isEmpty ||
          record.name.toLowerCase().contains(query) ||
          record.userId.toLowerCase().contains(query) ||
          record.role.toLowerCase().contains(query);

      final matchesRole =
          _selectedRole == 'All Roles' || record.role == _selectedRole;

      final matchesStatus =
          _selectedStatus == 'Status: All' || record.status == _selectedStatus;

      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  Future<void> _download() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance export is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Attendance'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Attendance',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 1100;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Column(
                      children: [
                        _buildStatsGrid(isCompact: isCompact),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                                child: isCompact
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildFilterRow(isCompact: true),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(child: _buildSearchField()),
                                              const SizedBox(width: 10),
                                              _buildIconButton(
                                                icon: Icons.refresh_rounded,
                                                onPressed: () => setState(() {}),
                                              ),
                                              const SizedBox(width: 10),
                                              _buildOutlinedButton(
                                                icon: Icons.filter_alt_outlined,
                                                label: 'More Filters',
                                                onPressed: () {},
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: _buildDownloadButton(),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: _buildFilterRow(isCompact: false)),
                                          const SizedBox(width: 12),
                                          _buildDownloadButton(),
                                        ],
                                      ),
                              ),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                                child: isCompact
                                    ? _buildCompactList(records)
                                    : _buildTable(records),
                              ),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                                child: Row(
                                  children: [
                                    Text(
                                      'Showing 1 to ${records.isEmpty ? 0 : records.length} of ${records.length} entries',
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        _buildPagerButton(icon: Icons.chevron_left_rounded, active: false),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF0B4A06),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '1',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildPagerButton(icon: Icons.chevron_right_rounded, active: false),
                                        const SizedBox(width: 14),
                                        _buildRowsPerPage(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid({required bool isCompact}) {
    final cards = [
      _StatCardData(
        title: 'Total Staff',
        value: '4',
        subtitle: 'All roles',
        icon: Icons.group_outlined,
        iconColor: const Color(0xFF0B4A06),
        iconBg: const Color(0xFFEAF5EA),
      ),
      _StatCardData(
        title: 'Present Today',
        value: '4',
        subtitle: '100.00% of total',
        icon: Icons.calendar_month_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEAF2FF),
      ),
      _StatCardData(
        title: 'On Leave',
        value: '0',
        subtitle: '0.00% of total',
        icon: Icons.schedule_outlined,
        iconColor: const Color(0xFFF97316),
        iconBg: const Color(0xFFFFF3E8),
      ),
      _StatCardData(
        title: 'Week Off',
        value: '0',
        subtitle: '0.00% of total',
        icon: Icons.work_outline_rounded,
        iconColor: const Color(0xFF1E5A1A),
        iconBg: const Color(0xFFEFF6EE),
      ),
      _StatCardData(
        title: 'Avg. Working Hours',
        value: '10h 03m',
        subtitle: 'Today',
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFF6B7280),
        iconBg: const Color(0xFFF3F4F6),
      ),
    ];

    if (isCompact) {
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cards
            .map(
              (card) => SizedBox(
                width: (MediaQuery.of(context).size.width - 54) / 2,
                child: _StatCard(card: card),
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 14),
              child: _StatCard(card: cards[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterRow({required bool isCompact}) {
    final widgets = [
      _buildDropdown(label: _selectedRole, items: _roleFilters, onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedRole = value);
      }),
      _buildDropdown(label: _selectedEmployee, items: _employeeFilters, onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedEmployee = value);
      }),
      _buildDropdown(label: _selectedDate, items: _dateFilters, onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedDate = value);
      }),
      _buildDropdown(label: _selectedStatus, items: _statusFilters, onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedStatus = value);
      }),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets
            .map((widget) => Padding(padding: const EdgeInsets.only(bottom: 10), child: widget))
            .toList(),
      );
    }

    return Row(
      children: [
        ...widgets,
        const SizedBox(width: 10),
        _buildIconButton(
          icon: Icons.refresh_rounded,
          onPressed: () => setState(() {}),
        ),
        const SizedBox(width: 10),
        _buildOutlinedButton(
          icon: Icons.filter_alt_outlined,
          label: 'More Filters',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 170,
      height: 42,
      child: DropdownButtonFormField<String>(
        value: label,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 42,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          backgroundColor: const Color(0xFFF8FAFC),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: const Color(0xFFF8FAFC),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: _download,
        icon: const Icon(Icons.file_download_outlined, size: 18),
        label: const Text('Download'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: const Color(0xFFF8FAFC),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildRowsPerPage() {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<String>(
        value: '10 / page',
        items: const [
          DropdownMenuItem(value: '10 / page', child: Text('10 / page')),
          DropdownMenuItem(value: '25 / page', child: Text('25 / page')),
        ],
        onChanged: (_) {},
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }

  Widget _buildPagerButton({required IconData icon, required bool active}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0B4A06) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 18, color: active ? Colors.white : AppColors.textSecondary),
    );
  }

  Widget _buildTable(List<_AttendanceRecord> records) {
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No attendance records found.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: const [
              SizedBox(width: 34, child: Checkbox(value: false, onChanged: null)),
              SizedBox(width: 260, child: _AttendanceHeaderLabel('EMPLOYEE')),
              SizedBox(width: 180, child: _AttendanceHeaderLabel('ROLE')),
              SizedBox(width: 130, child: _AttendanceHeaderLabel('DATE')),
              SizedBox(width: 120, child: _AttendanceHeaderLabel('STATUS')),
              SizedBox(width: 160, child: _AttendanceHeaderLabel('CHECK IN')),
              SizedBox(width: 140, child: _AttendanceHeaderLabel('CHECK OUT')),
              SizedBox(width: 120, child: _AttendanceHeaderLabel('WORK HOURS')),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...records.map(_buildAttendanceRow),
      ],
    );
  }

  Widget _buildAttendanceRow(_AttendanceRecord record) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 34,
            child: Checkbox(value: false, onChanged: null),
          ),
          SizedBox(
            width: 260,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF3F4F6),
                  child: Text(
                    record.initials,
                    style: const TextStyle(
                      color: Color(0xFF0B4A06),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.userId,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              record.role,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.dateLabel,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.dayLabel,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: _StatusPill(label: record.status),
          ),
          SizedBox(
            width: 160,
            child: Row(
              children: [
                Text(
                  record.checkIn,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                _MiniTag(label: record.checkInBadge, isGood: record.checkInBadge == 'On time'),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              record.checkOut,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              record.workHours,
              style: const TextStyle(
                color: Color(0xFF0B4A06),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (_) {},
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'view', child: Text('View')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactList(List<_AttendanceRecord> records) {
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'No attendance records found.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: records.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFF3F4F6),
                      child: Text(
                        record.initials,
                        style: const TextStyle(
                          color: Color(0xFF0B4A06),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.name,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            record.userId,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (_) {},
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'view', child: Text('View')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MiniInfo(label: 'Role', value: record.role),
                    _MiniInfo(label: 'Date', value: record.dateLabel),
                    _MiniInfo(label: 'Status', value: record.status),
                    _MiniInfo(label: 'Check In', value: record.checkIn),
                    _MiniInfo(label: 'Check Out', value: record.checkOut),
                    _MiniInfo(label: 'Hours', value: record.workHours),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AttendanceRecord {
  final String initials;
  final String name;
  final String userId;
  final String role;
  final String dateLabel;
  final String dayLabel;
  final String status;
  final String checkIn;
  final String checkInBadge;
  final String checkOut;
  final String workHours;
  final Color accentColor;

  const _AttendanceRecord({
    required this.initials,
    required this.name,
    required this.userId,
    required this.role,
    required this.dateLabel,
    required this.dayLabel,
    required this.status,
    required this.checkIn,
    required this.checkInBadge,
    required this.checkOut,
    required this.workHours,
    required this.accentColor,
  });
}

class _StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData card;

  const _StatCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: card.iconBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: card.iconBg),
            ),
            child: Icon(card.icon, color: card.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card.value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  card.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _AttendanceHeaderLabel extends StatelessWidget {
  final String label;

  const _AttendanceHeaderLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final isGood = lower == 'present' || lower == 'on time';
    final bg = isGood ? const Color(0xFFEAF7ED) : const Color(0xFFFFF4E5);
    final fg = isGood ? const Color(0xFF0B4A06) : const Color(0xFFB45309);
    final dot = isGood ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: dot),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final bool isGood;

  const _MiniTag({required this.label, required this.isGood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isGood ? const Color(0xFFEAF7ED) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isGood ? const Color(0xFF0B4A06) : const Color(0xFFB45309),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

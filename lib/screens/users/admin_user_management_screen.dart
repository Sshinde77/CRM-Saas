import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ---- Theme colours (kept consistent with the rest of the app) ----
  static const Color bg = AppColors.primary;
  static const Color teal = AppColors.teal;
  static const Color green = AppColors.green;
  static const Color purple = AppColors.purple;
  static const Color blue = AppColors.blue;
  static const Color orange = AppColors.orange;
  static const Color red = AppColors.red;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tabIndex = 0;

  final List<_UserItem> _users = [
    _UserItem('Anita Sharma', 'admin@demo.com'),
    _UserItem('Vikram Singh', 'sales@demo.com'),
    _UserItem('Suresh Kumar', 'delivery@demo.com'),
    _UserItem('Priya Nair', 'accountant@demo.com'),
  ];

  final List<String> _roles = [
    'Super Admin',
    'Admin',
    'Sales Officer',
    'Delivery Partner',
    'Accountant',
    'Warehouse Manager',
  ];
  String _selectedRole = 'Sales Officer';

  final List<String> _modules = const [
    'Products',
    'Inventory',
    'Purchases',
    'Sales',
    'Customers',
    'Payments',
    'Expenses',
    'Reports',
  ];

  late final Map<String, Map<String, List<bool>>> _permissions = {
    'Super Admin': {for (final m in _modules) m: [true, true, true, true]},
    'Admin': {for (final m in _modules) m: [true, true, true, false]},
    'Sales Officer': {
      'Products': [true, false, false, false],
      'Inventory': [true, false, false, false],
      'Purchases': [false, false, false, false],
      'Sales': [true, true, true, false],
      'Customers': [true, true, true, false],
      'Payments': [false, false, false, false],
      'Expenses': [false, false, false, false],
      'Reports': [true, false, false, false],
    },
    'Delivery Partner': {
      'Products': [true, false, false, false],
      'Inventory': [true, false, false, false],
      'Purchases': [false, false, false, false],
      'Sales': [true, false, false, false],
      'Customers': [false, false, false, false],
      'Payments': [false, false, false, false],
      'Expenses': [false, false, false, false],
      'Reports': [false, false, false, false],
    },
    'Accountant': {
      'Products': [false, false, false, false],
      'Inventory': [false, false, false, false],
      'Purchases': [true, false, false, false],
      'Sales': [true, false, false, false],
      'Customers': [false, false, false, false],
      'Payments': [true, true, true, false],
      'Expenses': [true, true, true, false],
      'Reports': [true, false, false, false],
    },
    'Warehouse Manager': {
      'Products': [true, false, false, false],
      'Inventory': [true, true, true, false],
      'Purchases': [true, false, false, false],
      'Sales': [false, false, false, false],
      'Customers': [false, false, false, false],
      'Payments': [false, false, false, false],
      'Expenses': [false, false, false, false],
      'Reports': [false, false, false, false],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const AppDrawer(activeItem: 'User Management'),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Management',
                        style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Manage users, roles, and permissions. New users log in with the demo password (demo123).',
                        style: TextStyle(color: textSecondary, fontSize: 12.5)),
                    const SizedBox(height: 18),
                    _buildTabSwitcher(),
                    const SizedBox(height: 18),
                    if (_tabIndex == 0) _buildUsersSection() else _buildRolesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Top bar ----------------
  // ---------------- Top bar ----------------
  Widget _buildTopBar(BuildContext context) {
    return AdminTopBar(
      title: 'User Management',
      leadingIcon: Icons.menu_rounded,
      onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
    );
  }

  Widget _iconBadge(IconData icon, Color bgColor, Color fg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 19),
    );
  }

  // ---------------- Users / Roles tab switcher ----------------
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _tabButton('Users', 0),
          _tabButton('Roles & Permissions', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: active
                ? [BoxShadow(color: textPrimary.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? purple : textSecondary,
              fontSize: 13.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _openAddUserDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [purple, blue]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 17),
                  SizedBox(width: 8),
                  Text('Add User',
                      style: TextStyle(color: AppColors.primary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _CardContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('User', style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('Email', style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: textPrimary.withOpacity(0.08), height: 1),
              ..._users.map(_userRow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _userRow(_UserItem user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: purple.withOpacity(0.14), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline, size: 19, color: purple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.name,
                    style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              user.email,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesSection() {
    final permissions = _permissions[_selectedRole]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._roles.map(_roleChip),
            _createCustomRoleChip(),
          ],
        ),
        const SizedBox(height: 20),
        _CardContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Permissions - $_selectedRole', style: const TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  _permHeaderCell('View'),
                  _permHeaderCell('Create'),
                  _permHeaderCell('Edit'),
                  _permHeaderCell('Delete'),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: textPrimary.withOpacity(0.08), height: 1),
              ..._modules.map((module) => _permissionRow(module, permissions[module]!)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleChip(String role) {
    final active = role == _selectedRole;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(colors: [purple, blue]) : null,
          color: active ? null : textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(role,
            style: TextStyle(
                color: active ? AppColors.primary : textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _openAddUserDialog() async {
    final result = await showDialog<_UserItem>(
      context: context,
      barrierColor: textPrimary.withOpacity(0.25),
      builder: (_) => _AddUserDialog(roles: _roles, initialRole: _selectedRole),
    );
    if (result == null) return;
    setState(() => _users.add(result));
  }

  Future<void> _openCreateRoleDialog() async {
    final name = await showDialog<String>(
      context: context,
      barrierColor: textPrimary.withOpacity(0.25),
      builder: (_) => const _CreateRoleDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    final roleName = name.trim();
    setState(() {
      if (!_roles.contains(roleName)) _roles.add(roleName);
      _permissions[roleName] = {for (final m in _modules) m: [false, false, false, false]};
      _selectedRole = roleName;
    });
  }

  Widget _createCustomRoleChip() {
    return GestureDetector(
      onTap: _openCreateRoleDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: purple.withOpacity(0.35)),
          color: purple.withOpacity(0.04),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 16, color: purple),
            const SizedBox(width: 6),
            Text('Create Custom Role', style: TextStyle(color: purple, fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _permHeaderCell(String label) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _permissionRow(String module, List<bool> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(module, style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
          ),
          for (var i = 0; i < 4; i++)
            Expanded(
              child: Center(
                child: _permCheckbox(
                  value: values[i],
                  onChanged: (v) => setState(() => values[i] = v),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _permCheckbox({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: value ? blue : Colors.transparent,
          border: Border.all(color: value ? blue : textPrimary.withOpacity(0.22), width: 1.5),
        ),
        child: value ? const Icon(Icons.check_rounded, size: 15, color: AppColors.primary) : null,
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _CardContainer({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.primary.withOpacity(0.55),
            border: Border.all(color: AppColors.primary.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2A2E).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _UserItem {
  final String name;
  final String email;
  const _UserItem(this.name, this.email);
}


import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

/// Admin "User Management" screen — glassmorphism redesign on a white background.
/// Two sections, switchable via a pill tab control:
/// 1. Users               — table of all users with their email.
/// 2. Roles & Permissions — pick a role, then toggle View/Create/Edit/Delete per module.
class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ---- Theme colours (kept consistent with the rest of the app) ----
  static const Color bg = Color(0xFFFFFFFF);
  static const Color teal = Color(0xFF1FA2B0);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFFB923C);
  static const Color red = Color(0xFFEF4444);

  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

  int _tabIndex = 0; // 0 = Users, 1 = Roles & Permissions

  // ---- Users ----
  final List<_UserItem> _users = const [
    _UserItem('Anita Sharma', 'admin@demo.com'),
    _UserItem('Vikram Singh', 'sales@demo.com'),
    _UserItem('Suresh Kumar', 'delivery@demo.com'),
    _UserItem('Priya Nair', 'accountant@demo.com'),
  ];

  // ---- Roles ----
  final List<String> _roles = const [
    'Super Admin',
    'Admin',
    'Sales Officer',
    'Delivery Partner',
    'Accountant',
    'Warehouse Manager',
  ];
  String _selectedRole = 'Sales Officer';

  // ---- Modules × [View, Create, Edit, Delete] ----
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

  // Mock permission matrix — replace with data from your backend.
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
      body: Stack(
        children: [
          Positioned(top: -60, left: -70, child: _glowBlob(purple, 220)),
          Positioned(top: 220, right: -90, child: _glowBlob(blue, 240)),
          Positioned(bottom: -80, left: 20, child: _glowBlob(teal, 200)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
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
    );
  }

  // ---------------- Top bar ----------------
  Widget _buildTopBar(BuildContext context) {
    return _GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: _iconBadge(Icons.menu, textPrimary.withOpacity(0.06), textPrimary),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _iconBadge(Icons.notifications_none_rounded, textPrimary.withOpacity(0.06), textPrimary),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [purple, blue]),
            ),
            alignment: Alignment.center,
            child: const Text('AS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color bg, Color fg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 19),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.20), blurRadius: 100, spreadRadius: 30),
        ],
      ),
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
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: active
                ? [BoxShadow(color: textPrimary.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: active ? purple : textSecondary,
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }

  // ---------------- Users section ----------------
  Widget _buildUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              // TODO: open your Add User form / dialog.
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [purple, blue]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: purple.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 17),
                  SizedBox(width: 8),
                  Text('Add User',
                      style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text('User',
                          style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 4,
                      child: Text('Email',
                          style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: textPrimary.withOpacity(0.08), height: 1),
              ..._users.map((u) => _userRow(u)),
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
                  child: Icon(Icons.person_outline, size: 19, color: purple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(user.name,
                      style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(user.email,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ---------------- Roles & Permissions section ----------------
  Widget _buildRolesSection() {
    final permissions = _permissions[_selectedRole]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._roles.map((role) => _roleChip(role)),
            _createCustomRoleChip(),
          ],
        ),
        const SizedBox(height: 20),
        _GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Permissions — $_selectedRole',
                  style: const TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
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
          boxShadow: active
              ? [BoxShadow(color: purple.withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 5))]
              : [],
        ),
        child: Text(role,
            style: TextStyle(
                color: active ? Colors.white : textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _createCustomRoleChip() {
    return GestureDetector(
      onTap: () {
        // TODO: open a "create custom role" form.
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: purple.withOpacity(0.35), style: BorderStyle.solid),
          color: purple.withOpacity(0.04),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16, color: purple),
            const SizedBox(width: 6),
            Text('Create Custom Role',
                style: TextStyle(color: purple, fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _permHeaderCell(String label) {
    return Expanded(
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _permissionRow(String module, List<bool> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(module,
                style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
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
        child: value ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
      ),
    );
  }
}

// ---------------- Reusable Glass Container (matches app-wide styling) ----------------
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _GlassContainer({
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
            color: Colors.white.withOpacity(0.55),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
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
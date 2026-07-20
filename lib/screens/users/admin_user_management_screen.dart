import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color teal = Color(0xFF1FA2B0);
  static const Color red = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

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
        child: Container(
          color: bg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 18),
                const Text('User Management', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Manage users, roles, and permissions. New users log in with the demo password (demo123).',
                  style: TextStyle(color: textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 18),
                _buildTabSwitcher(),
                const SizedBox(height: 18),
                if (_tabIndex == 0) _buildUsersSection() else _buildRolesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return _CardContainer(
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
            child: const Text('AS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
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
                  Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 17),
                  SizedBox(width: 8),
                  Text('Add User', style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
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
        child: Text(
          role,
          style: TextStyle(
            color: active ? Colors.white : textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        child: value ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2A2E).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UserItem {
  final String name;
  final String email;
  final String role;

  const _UserItem(this.name, this.email, [this.role = 'Sales Officer']);
}

class _CreateRoleDialog extends StatefulWidget {
  const _CreateRoleDialog();

  @override
  State<_CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<_CreateRoleDialog> {
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _errorText = 'Please enter a role name');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE6E8EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Create Custom Role', style: TextStyle(color: textPrimary, fontSize: 19, fontWeight: FontWeight.w800)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: textPrimary.withOpacity(0.06), shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: textPrimary.withOpacity(0.08), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Role Name', style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: textPrimary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _errorText != null ? Colors.redAccent.withOpacity(0.6) : textPrimary.withOpacity(0.08),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(color: textPrimary, fontSize: 14.5),
                      onChanged: (_) {
                        if (_errorText != null) setState(() => _errorText = null);
                      },
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'e.g. Route Supervisor',
                        hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(_errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    'You can configure module permissions for this role right after creating it.',
                    style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Divider(color: textPrimary.withOpacity(0.08), height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      decoration: BoxDecoration(
                        color: textPrimary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [purple, blue]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Create Role', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddUserDialog extends StatefulWidget {
  final List<String> roles;
  final String initialRole;

  const _AddUserDialog({required this.roles, required this.initialRole});

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late String _role;
  String? _nameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _role = widget.roles.contains(widget.initialRole) ? widget.initialRole : widget.roles.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    setState(() {
      _nameError = name.isEmpty ? 'Please enter a name' : null;
      _emailError = email.isEmpty ? 'Please enter an email' : (!emailValid ? 'Enter a valid email address' : null);
    });
    if (_nameError != null || _emailError != null) return;

    Navigator.of(context).pop(_UserItem(name, email, _role));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE6E8EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Add User', style: TextStyle(color: textPrimary, fontSize: 19, fontWeight: FontWeight.w800)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: textPrimary.withOpacity(0.06), shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: textPrimary.withOpacity(0.08), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Name'),
                  _textField(
                    controller: _nameController,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 18),
                  _fieldLabel('Email'),
                  _textField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: 18),
                  _fieldLabel('Role'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: textPrimary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: textPrimary.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _role,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
                        style: const TextStyle(color: textPrimary, fontSize: 14.5),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        items: widget.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _role = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                      children: const [
                        TextSpan(text: 'This account will be able to log in immediately with the demo password ('),
                        TextSpan(text: 'demo123', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                        TextSpan(text: ').'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Divider(color: textPrimary.withOpacity(0.08), height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      decoration: BoxDecoration(
                        color: textPrimary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [purple, blue]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Add User', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: textPrimary.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText != null ? Colors.redAccent.withOpacity(0.6) : textPrimary.withOpacity(0.08),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(color: textPrimary, fontSize: 14.5),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
      ],
    );
  }
}

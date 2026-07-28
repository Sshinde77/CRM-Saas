import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/soft_action_button.dart';

class AdminUserManagementScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdminUserManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ApiService _apiService;
  late Future<List<AppUser>> _usersFuture;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  int _tabIndex = 0;

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
    for (final role in _roles)
      role: {
        for (final module in _modules) module: [true, false, false, false],
      },
  };

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _usersFuture = _apiService.fetchUsers();
    _tabIndex = widget.initialTabIndex.clamp(0, 1).toInt();
  }

  @override
  void dispose() {
    _apiService.close();
    super.dispose();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _apiService.fetchUsers();
    });
  }

  String _formatRole(String? role) {
    final value = role?.trim() ?? '';
    if (value.isEmpty) return 'No role assigned';

    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatJoinedDate(DateTime? createdAt) {
    if (createdAt == null) return 'Unknown join date';

    final local = createdAt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Joined ${local.day} ${months[local.month - 1]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: AppDrawer(
        activeItem: 'User Management',
        activeSubItem: _tabIndex == 0 ? 'Users' : 'Roles',
      ),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'User Management',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage users, roles, and permissions',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    _buildTabSwitcher(),
                    const SizedBox(height: 18),
                    if (_tabIndex == 0)
                      _buildUsersSection()
                    else
                      _buildRolesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.purple : textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return FutureBuilder<List<AppUser>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      snapshot.hasData
                          ? 'Users (${snapshot.data!.length})'
                          : 'Users',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshUsers,
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.purple,
                    tooltip: 'Refresh users',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openAddUserDialog,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.purple),
                  ),
                )
              else if (snapshot.hasError)
                _buildUsersError(snapshot.error.toString())
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No users available.',
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                )
              else
                ...snapshot.data!.map(_buildUserTile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersError(String message) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.cloud_off_rounded, color: textSecondary, size: 40),
        const SizedBox(height: 10),
        const Text(
          'Could not load users',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _refreshUsers, child: const Text('Retry')),
      ],
    );
  }

  Widget _buildUserTile(AppUser user) {
    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name
              .trim()
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.trim().isEmpty ? 'Unnamed user' : user.name,
                  style: const TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email.trim().isEmpty ? 'No email' : user.email,
                  style: const TextStyle(color: textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetaChip(
                      icon: Icons.badge_outlined,
                      label: _formatRole(user.role),
                    ),
                    if ((user.phone ?? '').trim().isNotEmpty)
                      _buildMetaChip(
                        icon: Icons.call_outlined,
                        label: user.phone!.trim(),
                      ),
                    _buildMetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: _formatJoinedDate(user.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (user.isActive != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (user.isActive! ? AppColors.green : AppColors.red)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                user.isActive! ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: user.isActive! ? AppColors.green : AppColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
            ..._roles.map(_buildRoleChip),
            SoftActionButton(
              label: 'Create Role',
              icon: Icons.add_rounded,
              onPressed: _openCreateRoleDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permissions - $_selectedRole',
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ..._modules.map(
                (module) => _buildPermissionRow(module, permissions[module]!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    final active = _selectedRole == role;
    return ChoiceChip(
      label: Text(role),
      selected: active,
      onSelected: (_) => setState(() => _selectedRole = role),
      selectedColor: AppColors.purple.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: active ? AppColors.purple : textSecondary,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  Widget _buildPermissionRow(String module, List<bool> values) {
    const labels = ['View', 'Create', 'Edit', 'Delete'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module,
            style: const TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(labels.length, (index) {
              return FilterChip(
                label: Text(labels[index]),
                selected: values[index],
                onSelected: (selected) {
                  setState(() => values[index] = selected);
                },
                selectedColor: AppColors.purple.withValues(alpha: 0.12),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAddUserDialog() async {
    final user = await showDialog<_DialogUserItem>(
      context: context,
      builder: (_) => const _AddUserDialog(),
    );
    if (user == null) return;
    _showMessage('Local add user dialog is not connected to the backend yet.');
  }

  Future<void> _openCreateRoleDialog() async {
    final roleName = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateRoleDialog(),
    );
    if (roleName == null || roleName.trim().isEmpty) return;
    final trimmed = roleName.trim();
    if (_roles.contains(trimmed)) return;
    setState(() {
      _roles.add(trimmed);
      _permissions[trimmed] = {
        for (final module in _modules) module: [false, false, false, false],
      };
      _selectedRole = trimmed;
    });
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DialogUserItem {
  final String name;
  final String email;

  const _DialogUserItem(this.name, this.email);
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primary,
      title: const Text('Add User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final email = _emailController.text.trim();
            if (name.isEmpty || email.isEmpty) return;
            Navigator.of(context).pop(_DialogUserItem(name, email));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _CreateRoleDialog extends StatefulWidget {
  const _CreateRoleDialog();

  @override
  State<_CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<_CreateRoleDialog> {
  final TextEditingController _roleController = TextEditingController();

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primary,
      title: const Text('Create Role'),
      content: TextField(
        controller: _roleController,
        decoration: const InputDecoration(labelText: 'Role name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pop(_roleController.text.trim()),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

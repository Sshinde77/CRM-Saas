import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/soft_action_button.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';

  final List<_UserRecord> _users = [
    _UserRecord(
      name: 'Anita Sharma',
      role: 'Super Admin',
      status: 'Active',
      email: 'anita@demo.com',
      phone: '+91 98220 33445',
    ),
    _UserRecord(
      name: 'Vikram Singh',
      role: 'Sales Officer',
      status: 'Active',
      email: 'vikram@demo.com',
      phone: '+91 98765 43210',
    ),
    _UserRecord(
      name: 'Suresh Kumar',
      role: 'Delivery Partner',
      status: 'Inactive',
      email: 'suresh@demo.com',
      phone: '+91 98111 22334',
    ),
    _UserRecord(
      name: 'Priya Nair',
      role: 'Accountant',
      status: 'Active',
      email: 'priya@demo.com',
      phone: '+91 98700 11009',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_UserRecord> get _filteredUsers {
    return _users.where((user) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return user.name.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.status.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.toLowerCase().contains(query);
    }).toList();
  }

  int get _activeUserCount =>
      _users.where((user) => user.status == 'Active').length;

  Future<void> _openUserDialog({_UserRecord? existing, int? index}) async {
    final result = await showDialog<_UserRecord>(
      context: context,
      builder: (_) => _UserFormDialog(existing: existing),
    );
    if (result == null) return;

    setState(() {
      if (index != null) {
        _users[index] = result;
      } else {
        _users.add(result);
      }
    });
  }

  Future<void> _confirmDelete(_UserRecord user, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete user?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove ${user.name} from the user list.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _users.removeAt(index));
    }
  }

  void _showUserDetails(_UserRecord user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Role', user.role),
              _detailRow('Status', user.status),
              _detailRow('Email', user.email),
              _detailRow('Phone', user.phone),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(
        activeItem: 'User Management',
        activeSubItem: 'Users',
      ),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Users',
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
                                'User Directory',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Search, add, and manage user accounts',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SoftActionButton(
                          label: 'Add User',
                          icon: Icons.person_add_alt_1_rounded,
                          onPressed: () => _openUserDialog(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildSearchField(),
                    const SizedBox(height: 16),
                    _buildUserList(users),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
      child: Row(
        children: [
          Expanded(
            child: _statTile(
              label: 'Total Users',
              value: '${_users.length}',
              icon: Icons.people_alt_outlined,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statTile(
              label: 'Active Users',
              value: '$_activeUserCount',
              icon: Icons.verified_user_outlined,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search users by name, role, email or phone',
        prefixIcon: const Icon(Icons.search, color: textSecondary),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.24),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.24),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      ),
    );
  }

  Widget _buildUserList(List<_UserRecord> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users',
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (users.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No users match your search.',
                style: TextStyle(color: textSecondary),
              ),
            ),
          )
        else
          ...users.asMap().entries.map((entry) {
            final index = _users.indexOf(entry.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _userCard(entry.value, index),
            );
          }),
      ],
    );
  }

  Widget _userCard(_UserRecord user, int index) {
    final statusColor = user.status == 'Active'
        ? AppColors.green
        : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(user.status, statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoText('Role', user.role)),
              const SizedBox(width: 12),
              Expanded(child: _infoText('Phone', user.phone)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoText('Email', user.email)),
              const SizedBox(width: 12),
              Expanded(child: _infoText('Status', user.status)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(
                icon: Icons.visibility_outlined,
                label: 'View',
                color: AppColors.blue,
                onTap: () => _showUserDetails(user),
              ),
              const SizedBox(width: 8),
              _actionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: AppColors.purple,
                onTap: () => _openUserDialog(existing: user, index: index),
              ),
              const SizedBox(width: 8),
              _actionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: AppColors.red,
                onTap: () => _confirmDelete(user, index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _UserRecord {
  final String name;
  final String role;
  final String status;
  final String email;
  final String phone;

  const _UserRecord({
    required this.name,
    required this.role,
    required this.status,
    required this.email,
    required this.phone,
  });
}

class _UserFormDialog extends StatefulWidget {
  final _UserRecord? existing;

  const _UserFormDialog({this.existing});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> _roles = const [
    'Super Admin',
    'Admin',
    'Sales Officer',
    'Delivery Partner',
    'Accountant',
    'Warehouse Manager',
  ];

  late String _role;
  late String _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController.text = existing?.name ?? '';
    _emailController.text = existing?.email ?? '';
    _phoneController.text = existing?.phone ?? '';
    _role = existing?.role ?? _roles.first;
    _status = existing?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.existing == null ? 'Add User' : 'Edit User',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.secondary, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Name'),
                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration(hint: 'Enter user name'),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Role'),
                    _dropdownField(
                      _role,
                      _roles,
                      (value) => setState(() => _role = value),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Status'),
                    _dropdownField(_status, const [
                      'Active',
                      'Inactive',
                    ], (value) => setState(() => _status = value)),
                    const SizedBox(height: 16),
                    _fieldLabel('Email'),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(hint: 'name@example.com'),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Phone'),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(hint: '+91 00000 00000'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.secondary, height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final phone = _phoneController.text.trim();
                      if (name.isEmpty || email.isEmpty || phone.isEmpty)
                        return;
                      Navigator.of(context).pop(
                        _UserRecord(
                          name: name,
                          role: _role,
                          status: _status,
                          email: email,
                          phone: phone,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    child: Text(
                      widget.existing == null ? 'Add User' : 'Save Changes',
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
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.purple),
      ),
    );
  }

  Widget _dropdownField(
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.24)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ),
    );
  }
}

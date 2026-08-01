import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/soft_action_button.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late final ApiService _apiService;
  late Future<List<AppUser>> _usersFuture;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _usersFuture = _apiService.fetchUsers();
  }

  @override
  void dispose() {
    _apiService.close();
    _searchController.dispose();
    super.dispose();
  }

  List<AppUser> _filteredUsers(List<AppUser> users) {
    return users.where((user) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }

      return user.name.toLowerCase().contains(query) ||
          _formatRole(user.role).toLowerCase().contains(query) ||
          _statusLabel(user).toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.phone ?? '').toLowerCase().contains(query);
    }).toList();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _apiService.fetchUsers();
    });
  }

  String _formatRole(String? role) {
    final value = role?.trim() ?? '';
    if (value.isEmpty) {
      return 'No role assigned';
    }

    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _statusLabel(AppUser user) {
    return user.isActive == true ? 'Active' : 'Inactive';
  }

  Future<void> _openUserDialog({AppUser? existing, int? index}) async {
    final result = await showDialog<_DialogUserRecord>(
      context: context,
      builder: (_) => _UserFormDialog(existing: existing),
    );
    if (result == null) {
      return;
    }

    _showMessage(
      existing == null
          ? 'Add user is not connected to the backend yet.'
          : 'Edit user is not connected to the backend yet.',
    );
  }

  Future<void> _confirmDelete(AppUser user, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete user?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove ${user.name.trim().isEmpty ? 'this user' : user.name} from the user list.',
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
      _showMessage('Delete user is not connected to the backend yet.');
    }
  }

  void _showUserDetails(AppUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
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
                user.name.trim().isEmpty ? 'Unnamed user' : user.name,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Role', _formatRole(user.role)),
              _detailRow('Status', _statusLabel(user)),
              _detailRow(
                'Email',
                user.email.trim().isEmpty ? 'No email' : user.email,
              ),
              _detailRow(
                'Phone',
                (user.phone ?? '').trim().isEmpty
                    ? 'No phone'
                    : user.phone!.trim(),
              ),
            ],
          ),
        );
      },
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
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
              child: FutureBuilder<List<AppUser>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  final allUsers = snapshot.data ?? const <AppUser>[];
                  final users = _filteredUsers(allUsers);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                'Users',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _addUserButton(),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: _buildSearchField()),
                            const SizedBox(width: 12),
                            _filterButton(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (snapshot.hasError)
                          _buildUsersError(snapshot.error.toString())
                        else
                          _buildUserList(users, allUsers),
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

  Widget _addUserButton() {
    return ElevatedButton.icon(
      onPressed: () => _openUserDialog(),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add User'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8, right: 4),
            child: Icon(Icons.search_rounded, color: textPrimary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 46,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderStrong),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return Tooltip(
      message: 'Refresh users',
      child: InkWell(
        onTap: _refreshUsers,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderStrong),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.filter_list_rounded,
            color: textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildUsersError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: textSecondary, size: 42),
          const SizedBox(height: 12),
          const Text(
            'Could not load users',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SoftActionButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: _refreshUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<AppUser> users, List<AppUser> allUsers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allUsers.isEmpty)
          _emptyUsers('No users available.')
        else if (users.isEmpty)
          _emptyUsers('No users match your search.')
        else
          ...users.asMap().entries.map((entry) {
            final index = allUsers.indexOf(entry.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _userCard(entry.value, index),
            );
          }),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'Total Users: ',
            children: [
              TextSpan(
                text: '${users.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _emptyUsers(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: textSecondary, fontSize: 15),
        ),
      ),
    );
  }

  Widget _userCard(AppUser user, int index) {
    final displayName = user.name.trim().isEmpty ? 'Unnamed user' : user.name;
    final displayEmail = user.email.trim().isEmpty ? 'No email' : user.email;
    final displayPhone = (user.phone ?? '').trim().isEmpty
        ? 'No phone'
        : user.phone!.trim();
    final initials = displayName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final avatarAsset = 'assets/avatar${(index % 3) + 1}.png';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              avatarAsset,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                _contactLine(Icons.phone_outlined, displayPhone),
                const SizedBox(height: 6),
                _contactLine(Icons.mail_outline_rounded, displayEmail),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _dateChip(user.createdAt),
              const SizedBox(height: 14),
              Row(
                children: [
                  _actionButton(
                    icon: Icons.visibility_rounded,
                    label: 'View',
                    color: AppColors.primary,
                    backgroundColor: AppColors.statusActiveBg,
                    onTap: () => _showUserDetails(user),
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: textPrimary,
                    backgroundColor: const Color(0xFFF3F5F8),
                    onTap: () => _openUserDialog(existing: user, index: index),
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: AppColors.red,
                    backgroundColor: const Color(0xFFFFEBEB),
                    onTap: () => _confirmDelete(user, index),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateChip(DateTime? date) {
    final label = date == null ? 'No date' : _formatShortDate(date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusActiveBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _DialogUserRecord {
  final String name;
  final String role;
  final String status;
  final String email;
  final String phone;

  const _DialogUserRecord({
    required this.name,
    required this.role,
    required this.status,
    required this.email,
    required this.phone,
  });
}

class _UserFormDialog extends StatefulWidget {
  final AppUser? existing;

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
    _role = existing == null ? _roles.first : _formatDialogRole(existing.role);
    _status = existing?.isActive == false ? 'Inactive' : 'Active';
  }

  String _formatDialogRole(String? role) {
    final value = role?.trim() ?? '';
    if (value.isEmpty) {
      return _roles.first;
    }

    final formatted = value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');

    return _roles.contains(formatted) ? formatted : _roles.first;
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
      backgroundColor: AppColors.background,
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
                      if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                        return;
                      }
                      Navigator.of(context).pop(
                        _DialogUserRecord(
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
                      foregroundColor: Colors.white,
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
            if (selected != null) {
              onChanged(selected);
            }
          },
        ),
      ),
    );
  }
}

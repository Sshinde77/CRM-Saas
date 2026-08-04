import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/soft_action_button.dart';
import 'add_staff_screen.dart';

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
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddStaffScreen(
          userId: existing?.id,
          existingUser: existing,
        ),
      ),
    );
    if (created == true) {
      _refreshUsers();
    }
  }

  Future<void> _openAddStaffScreen() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddStaffScreen(),
      ),
    );
    if (created == true) {
      _refreshUsers();
    }
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

  Future<void> _changeStatus(AppUser user) async {
    final targetStatus = user.isActive == true ? 'Inactive' : 'Active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change status?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Set ${user.name.trim().isEmpty ? 'this user' : user.name} to $targetStatus?',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showMessage('Status update is not connected to the backend yet.');
    }
  }

  Future<void> _resetPassword(AppUser user) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset password',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a new password for ${user.name.trim().isEmpty ? 'this user' : user.name}.',
              style: const TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'New password',
                filled: true,
                fillColor: AppColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderStrong),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderStrong),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showMessage('Reset password is not connected to the backend yet.');
    }
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
      drawer: const AppDrawer(activeItem: 'Staff', activeSubItem: 'Users'),
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
      onPressed: _openAddStaffScreen,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add Staff'),
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
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: textPrimary,
                    backgroundColor: const Color(0xFFF3F5F8),
                    onTap: () => _openUserDialog(existing: user, index: index),
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Change Status',
                    color: textPrimary,
                    backgroundColor: const Color(0xFFF3F5F8),
                    onTap: () => _changeStatus(user),
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.key_outlined,
                    label: 'Reset Password',
                    color: textPrimary,
                    backgroundColor: const Color(0xFFF3F5F8),
                    onTap: () => _resetPassword(user),
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
}

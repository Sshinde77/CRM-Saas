import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
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
  static const Color _headerGreen = Color(0xFF0D3B07);
  static const Color _cardBorder = Color(0xFFE3E7EC);
  static const Color _cardBg = Colors.white;
  static const List<String> _statusFilters = [
    'All',
    'Accountant',
    'Delivery Partner',
    'Sales Officer',
    'HR',
  ];

  String _query = '';
  String _selectedStatusFilter = 'All';
  int _currentPage = 0;
  static const int _pageSize = 6;

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
      final roleLabel = _formatRole(user.role);
      final matchesQuery = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          roleLabel.toLowerCase().contains(query) ||
          _statusLabel(user).toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.phone ?? '').toLowerCase().contains(query);

      final matchesStatus = _selectedStatusFilter == 'All' ||
          roleLabel == _selectedStatusFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<AppUser> _pagedUsers(List<AppUser> users) {
    final start = _currentPage * _pageSize;
    if (start >= users.length) {
      return const <AppUser>[];
    }

    final end = (start + _pageSize).clamp(0, users.length);
    return users.sublist(start, end);
  }

  void _setStatusFilter(String value) {
    setState(() {
      _selectedStatusFilter = value;
      _currentPage = 0;
    });
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
        builder: (_) =>
            AddStaffScreen(userId: existing?.id, existingUser: existing),
      ),
    );
    if (created == true) {
      _refreshUsers();
    }
  }

  Future<void> _openAddStaffScreen() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddStaffScreen()));
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
    final isCurrentlyActive = user.isActive == true;
    final nextIsActive = !isCurrentlyActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 16, 14),
        contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Change Status',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(false),
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, color: textSecondary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current status',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.name.trim().isEmpty
                          ? '?'
                          : user.name.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email.trim().isEmpty ? 'No email' : user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentlyActive
                          ? const Color(0xFFE9F8EF)
                          : const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isCurrentlyActive
                            ? const Color(0xFFBFE8CC)
                            : const Color(0xFFF0C6C6),
                      ),
                    ),
                    child: Text(
                      isCurrentlyActive ? 'active' : 'inactive',
                      style: TextStyle(
                        color: isCurrentlyActive
                            ? const Color(0xFF107C41)
                            : AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              nextIsActive
                  ? 'This will change the user to active.'
                  : 'This will change the user to inactive.',
              style: const TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary900,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              nextIsActive ? 'Set Active' : 'Set Inactive',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.updateUserStatus(
          userId: user.id,
          request: UpdateUserStatusRequest(isActive: nextIsActive),
        );
        _showMessage(
          nextIsActive
              ? 'User activated successfully.'
              : 'User deactivated successfully.',
        );
        _refreshUsers();
      } catch (error) {
        _showMessage(error.toString());
      }
    }
  }

  Future<void> _resetPassword(AppUser user) async {
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResetPasswordDialog(user: user),
    );

    if (password == null || password.trim().isEmpty) {
      return;
    }

    try {
      await _apiService.resetUserPassword(
        userId: user.id,
        request: ResetUserPasswordRequest(newPassword: password.trim()),
      );
      _showMessage('Password reset successfully.');
    } catch (error) {
      _showMessage(error.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Staff', activeSubItem: 'Users'),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  final allUsers = snapshot.data ?? const <AppUser>[];
                  final users = _filteredUsers(allUsers);
                  final pageUsers = _pagedUsers(users);
                  final totalCount = users.length;
                  final pageCount =
                      totalCount == 0 ? 1 : ((totalCount - 1) ~/ _pageSize) + 1;
                  final currentPage = _currentPage.clamp(0, pageCount - 1);
                  if (currentPage != _currentPage) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _currentPage = currentPage);
                      }
                    });
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _buildSearchRow(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatusDropdown()),
                          const SizedBox(width: 12),
                          _addUserButton(),
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
                        _buildStaffList(
                          pageUsers,
                          totalCount,
                          currentPage,
                          pageCount,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.menu_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Staff',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D4F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {
                _query = value;
                _currentPage = 0;
              }),
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search staff',
                hintStyle: const TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 10, right: 4),
                  child: Icon(Icons.search_rounded, color: textSecondary, size: 20),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 42,
                  minHeight: 46,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _showFilterMenu,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.filter_alt_outlined,
              color: textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return SizedBox(
      height: 48,
      child: DropdownButtonFormField<String>(
        initialValue: _selectedStatusFilter,
        items: _statusFilters
            .map(
              (value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          _setStatusFilter(value);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
        style: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Future<void> _showFilterMenu() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statusFilters
                .map(
                  (item) => ListTile(
                    onTap: () => Navigator.of(context).pop(item),
                    title: Text(
                      item,
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: _selectedStatusFilter == item
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (selection != null) {
      _setStatusFilter(selection);
    }
  }

  Widget _buildStaffList(
    List<AppUser> users,
    int totalCount,
    int currentPage,
    int pageCount,
  ) {
    if (users.isEmpty) {
      return _emptyUsers(
        _query.isNotEmpty || _selectedStatusFilter != 'All'
            ? 'No staff match your filters.'
            : 'No staff available.',
      );
    }

    final start = totalCount == 0 ? 0 : currentPage * _pageSize;
    final end = totalCount == 0 ? 0 : start + users.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...users.asMap().entries.map((entry) {
          final index = start + entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _userCard(entry.value, index),
          );
        }),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${start + 1} to $end of $totalCount',
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _pageButton(
              icon: Icons.chevron_left_rounded,
              enabled: currentPage > 0,
              onTap: () {
                if (currentPage <= 0) return;
                setState(() => _currentPage = currentPage - 1);
              },
            ),
            const SizedBox(width: 10),
            _pageButton(
              icon: Icons.chevron_right_rounded,
              enabled: currentPage < pageCount - 1,
              onTap: () {
                if (currentPage >= pageCount - 1) return;
                setState(() => _currentPage = currentPage + 1);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _cardBorder),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? textPrimary : AppColors.textLightMuted,
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
    final roleLabel = _formatRole(user.role);
    final initials = displayName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final avatarColors = <Color>[
      const Color(0xFFEAF5D9),
      const Color(0xFFE9EEFF),
      const Color(0xFFFCEFD9),
      const Color(0xFFF4E8FF),
      const Color(0xFFE6F8F3),
      const Color(0xFFFFE8EE),
    ];
    final avatarBg = avatarColors[index % avatarColors.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<_StaffAction>(
                      tooltip: 'Staff actions',
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case _StaffAction.edit:
                            _openUserDialog(existing: user, index: index);
                            break;
                          case _StaffAction.status:
                            _changeStatus(user);
                            break;
                          case _StaffAction.resetPassword:
                            _resetPassword(user);
                            break;
                          case _StaffAction.delete:
                            _confirmDelete(user, index);
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _StaffAction.edit,
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: _StaffAction.status,
                          child: Text('Change Status'),
                        ),
                        PopupMenuItem(
                          value: _StaffAction.resetPassword,
                          child: Text('Reset Password'),
                        ),
                        PopupMenuItem(
                          value: _StaffAction.delete,
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _roleChip(roleLabel),
                    _statusChip(user.isActive == true),
                    _dateChip(user.createdAt),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String role) {
    final normalized = role.toLowerCase();
    Color bg;
    Color fg;

    if (normalized.contains('admin')) {
      bg = const Color(0xFFEAF0FF);
      fg = const Color(0xFF3662D6);
    } else if (normalized.contains('accountant')) {
      bg = const Color(0xFFFFF0DC);
      fg = const Color(0xFFCE7A00);
    } else if (normalized.contains('sales')) {
      bg = const Color(0xFFEAF5D9);
      fg = const Color(0xFF4E8210);
    } else {
      bg = const Color(0xFFF4E8FF);
      fg = const Color(0xFF7A49C4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.statusActiveBg : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active
              ? AppColors.statusActiveText
              : AppColors.statusInactiveText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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

enum _StaffAction { edit, status, resetPassword, delete }

class _ResetPasswordDialog extends StatefulWidget {
  final AppUser user;

  const _ResetPasswordDialog({required this.user});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(_newPasswordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userName = user.name.trim().isEmpty ? 'Unnamed user' : user.name;
    final userEmail = user.email.trim().isEmpty ? 'No email' : user.email;

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 16, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderStrong),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resetting password for',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.borderStrong,
                                ),
                              ),
                              child: Text(
                                userName.isEmpty
                                    ? '?'
                                    : userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
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
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _fieldLabel('New Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: _passwordDecoration(
                          hint: 'Enter new password',
                          obscure: _obscureNewPassword,
                          onToggle: () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel('Confirm Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (value.trim() !=
                              _newPasswordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: _passwordDecoration(
                          hint: 'Confirm password',
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.borderStrong),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary900,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
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
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

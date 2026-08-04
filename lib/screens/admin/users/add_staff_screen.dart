import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../models/auth_models.dart';
import '../../../models/role_model.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';

class AddStaffScreen extends StatefulWidget {
  final String? userId;
  final AppUser? existingUser;

  const AddStaffScreen({super.key, this.userId, this.existingUser});

  bool get isEditMode => (userId ?? existingUser?.id ?? '').trim().isNotEmpty;

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  Future<List<RoleModel>>? _rolesFuture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RoleModel? _selectedRole;
  AppUser? _editingUser;
  bool _sendNotification = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isLoadingEditUser = false;
  String? _editLoadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rolesFuture ??= ApiProviderScope.of(context).fetchRoles();
    if (widget.isEditMode && _editingUser == null && !_isLoadingEditUser) {
      _loadEditUser();
    }
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingUser;
    if (existing != null) {
      _applyUser(existing);
    }
  }

  @override
  void dispose() {
    _apiService.close();
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _effectiveUserId =>
      (widget.userId ?? widget.existingUser?.id ?? '').trim();

  String get _title => widget.isEditMode ? 'Edit Staff' : 'Add Staff';

  String get _submitLabel =>
      widget.isEditMode ? 'Save Changes' : 'Add New Staff';

  bool get _showPasswordField => !widget.isEditMode;

  String _roleSlugFromLabel(String role) {
    return role
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> _loadEditUser() async {
    final userId = _effectiveUserId;
    if (userId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingEditUser = true;
      _editLoadError = null;
    });

    try {
      final user = await _apiService.fetchUserById(userId);
      if (!mounted) {
        return;
      }
      _applyUser(user);
      setState(() => _editingUser = user);
    } catch (error) {
      if (mounted) {
        setState(() => _editLoadError = error.toString());
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEditUser = false);
      }
    }
  }

  void _applyUser(AppUser user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _usernameController.text = user.username ?? '';
    _phoneController.text = user.phone ?? '';

    final roleDetail = user.roleDetail;
    if (roleDetail != null && roleDetail.id.trim().isNotEmpty) {
      _selectedRole = RoleModel(
        id: roleDetail.id,
        name: roleDetail.name,
        isDefault: roleDetail.isDefault,
        permissions: const {},
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      if (widget.isEditMode) {
        final userId = _effectiveUserId;
        if (userId.isEmpty) {
          throw const ApiException(message: 'Missing user id.');
        }

        await _apiService.updateUser(
          userId: userId,
          request: UpdateUserRequest(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
        );
      } else {
        final selectedRole = _selectedRole;
        await _apiService.createUser(
          request: CreateUserRequest(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            roleId: selectedRole?.id.trim() ?? '',
            role: selectedRole == null
                ? ''
                : _roleSlugFromLabel(selectedRole.name),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        widget.isEditMode
            ? 'Staff updated successfully.'
            : 'Staff created successfully.',
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: _title,
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 980;

                    final profilePanel = _profilePanel();
                    final formPanel = _formPanel(wide: wide);

                    if (wide) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.borderStrong.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 340, child: profilePanel),
                            const SizedBox(width: 18),
                            Expanded(child: formPanel),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        profilePanel,
                        const SizedBox(height: 16),
                        formPanel,
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Picture',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add an optional image to make staff records easier to scan.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => _showMessage('Photo upload is not connected yet.'),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 315,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderStrong.withValues(alpha: 0.55),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderStrong.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Upload Photo',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PNG or JPG',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formPanel({required bool wide}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isEditMode) ...[
            if (_isLoadingEditUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  minHeight: 2,
                ),
              ),
            if (_editLoadError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  _editLoadError!,
                  style: const TextStyle(
                    color: AppColors.statusInactiveText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
          _sectionHeader('1', 'Basic information'),
          const SizedBox(height: 18),
          if (wide) ...[
            Row(
              children: [
                Expanded(
                  child: _fieldBlock(
                    'Name',
                    _textField(
                      controller: _nameController,
                      hintText: 'Enter staff name',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _fieldBlock(
                    'Email',
                    _textField(
                      controller: _emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _fieldBlock(
                    'Username',
                    _textField(
                      controller: _usernameController,
                      hintText: 'Enter username',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _fieldBlock(
                    'Phone Number',
                    _textField(
                      controller: _phoneController,
                      hintText: '+91 00000 00000',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
              ],
            ),
            if (_showPasswordField) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _fieldBlock('Password', _passwordField())),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ],
          ] else ...[
            _fieldBlock(
              'Name',
              _textField(
                controller: _nameController,
                hintText: 'Enter staff name',
              ),
            ),
            const SizedBox(height: 16),
            _fieldBlock(
              'Email',
              _textField(
                controller: _emailController,
                hintText: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 16),
            _fieldBlock(
              'Username',
              _textField(
                controller: _usernameController,
                hintText: 'Enter username',
              ),
            ),
            const SizedBox(height: 16),
            _fieldBlock(
              'Phone Number',
              _textField(
                controller: _phoneController,
                hintText: '+91 00000 00000',
                keyboardType: TextInputType.phone,
              ),
            ),
            if (_showPasswordField) ...[
              const SizedBox(height: 16),
              _fieldBlock('Password', _passwordField()),
            ],
          ],
          const SizedBox(height: 22),
          if (widget.isEditMode) ...[
            FutureBuilder<List<RoleModel>>(
              future: _rolesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _selectedRole == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      minHeight: 2,
                    ),
                  );
                }

                final roles = snapshot.data ?? const <RoleModel>[];
                final currentRoleId = _selectedRole?.id.trim();
                final safeRoleId = roles.any((role) => role.id == currentRoleId)
                    ? currentRoleId
                    : (roles.isNotEmpty ? roles.first.id : null);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Role'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: safeRoleId,
                      items: roles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role.id,
                              child: Text(role.name),
                            ),
                          )
                          .toList(),
                      onChanged: null,
                      decoration: _inputDecoration(''),
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            _sectionHeader('2', 'Role and invitation'),
            const SizedBox(height: 18),
            FutureBuilder<List<RoleModel>>(
              future: _rolesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _selectedRole == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      minHeight: 2,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Could not load roles: ${snapshot.error}',
                      style: const TextStyle(
                        color: AppColors.statusInactiveText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final roles = snapshot.data ?? const <RoleModel>[];
                if (roles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'No roles available for this organization.',
                      style: TextStyle(
                        color: AppColors.statusInactiveText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (roles.isNotEmpty && _selectedRole == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedRole == null && roles.isNotEmpty) {
                      setState(() => _selectedRole = roles.first);
                    }
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Role'),
                    const SizedBox(height: 8),
                    _roleDropdown(roles),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            _notificationRow(),
          ],
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _submitLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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

  Widget _fieldBlock(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_fieldLabel(label), const SizedBox(height: 8), field],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hintText),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(
        'Enter password',
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _roleDropdown(List<RoleModel> roles) {
    final selectedRole = _selectedRole;
    return DropdownButtonFormField<String>(
      initialValue: selectedRole?.id,
      onChanged: (value) {
        if (value != null) {
          final match = roles.firstWhere(
            (role) => role.id == value,
            orElse: () => roles.first,
          );
          setState(() => _selectedRole = match);
        }
      },
      decoration: _inputDecoration(''),
      items: roles
          .map(
            (role) => DropdownMenuItem<String>(
              value: role.id,
              child: Text(role.name),
            ),
          )
          .toList(),
    );
  }

  Widget _notificationRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.25),
        ),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _sendNotification,
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'Send a notification to the user for this new role.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        onChanged: (value) {
          setState(() => _sendNotification = value ?? false);
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      filled: true,
      fillColor: AppColors.surfaceSoft.withValues(alpha: 0.28),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.borderStrong.withValues(alpha: 0.45),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.borderStrong.withValues(alpha: 0.45),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class NewRoleResult {
  final String name;
  final int modulesCount;
  final String accessLevel;

  const NewRoleResult({
    required this.name,
    required this.modulesCount,
    required this.accessLevel,
  });
}

class NewRoleScreen extends StatefulWidget {
  const NewRoleScreen({super.key});

  @override
  State<NewRoleScreen> createState() => _NewRoleScreenState();
}

class _NewRoleScreenState extends State<NewRoleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _roleNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _workspaces = const [
    'Sales',
    'Operations',
    'Finance',
    'Support',
    'Admin',
  ];

  final List<String> _dataScopes = const [
    'Own records only',
    'Team records only',
    'All records',
  ];

  static const List<String> _permissionColumns = [
    'View',
    'Create',
    'Edit',
    'Delete',
    'Approve',
    'Export',
    'Download',
  ];

  static const List<String> _modules = [
    'Dashboard',
    'Product & Categories',
    'Inventory',
    'Vehicle Stock',
    'Customers',
    'Leads',
    'Quotations',
    'Suppliers',
    'Sales Orders',
    'Sales Returns',
    'Purchases',
    'Deliveries',
    'Invoices',
    'Payments',
    'Payment Receipts',
    'Expenses',
    'Attendance',
    'Reports',
    'GST',
    'Users & Roles',
    'Settings',
  ];

  final Map<String, Set<String>> _modulePermissions = {
    for (final module in _modules) module: <String>{},
  };

  String _selectedWorkspace = 'Sales';
  String _selectedDataScope = 'Own records only';

  @override
  void dispose() {
    _roleNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool? _allSelectionValue(String module) {
    final selected = _modulePermissions[module] ?? <String>{};
    if (selected.isEmpty) return false;
    if (selected.length == _permissionColumns.length) return true;
    return null;
  }

  void _toggleAll(String module, bool? checked) {
    setState(() {
      _modulePermissions[module] = checked == true
          ? _permissionColumns.toSet()
          : <String>{};
    });
  }

  void _togglePermission(String module, String permission, bool? checked) {
    setState(() {
      final current = _modulePermissions[module] ?? <String>{};
      if (checked == true) {
        current.add(permission);
      } else {
        current.remove(permission);
      }
      _modulePermissions[module] = current;
    });
  }

  int _selectedModuleCount() {
    return _modulePermissions.values
        .where((permissions) => permissions.isNotEmpty)
        .length;
  }

  String _accessLevelLabel() {
    final count = _selectedModuleCount();
    if (count == 0) return 'Limited';
    if (count == _modules.length) return 'Full';
    return 'Custom';
  }

  void _createRole() {
    final roleName = _roleNameController.text.trim();
    if (roleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a role name.')),
      );
      return;
    }

    Navigator.of(context).pop(
      NewRoleResult(
        name: roleName,
        modulesCount: _selectedModuleCount(),
        accessLevel: _accessLevelLabel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Roles & Permissions'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Roles & Permissions',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 1100;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: isCompact
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Create a new role',
                                                  style: TextStyle(
                                                    color: Color(0xFF111827),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Configure module-level permissions for staff assigned to this role.',
                                                  style: TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 13.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.textPrimary,
                                              backgroundColor: const Color(
                                                0xFFF3F4F6,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                            ),
                                            child: const Text('Back to Roles'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Create a new role',
                                              style: TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Configure module-level permissions for staff assigned to this role.',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors.textPrimary,
                                          backgroundColor: const Color(
                                            0xFFF3F4F6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Back to Roles'),
                                      ),
                                    ],
                                  ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                            child: _buildFormFields(isCompact: isCompact),
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                            child: Row(
                              children: const [
                                Text(
                                  'Permissions',
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 1520,
                                ),
                                child: _buildPermissionsTable(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                            child: Row(
                              children: [
                                const Spacer(),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: _createRole,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Create Role'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B4A06),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFormFields({required bool isCompact}) {
    final formGap = isCompact ? 14.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isCompact
            ? Column(
                children: [
                  _buildTextField(
                    label: 'Role Name *',
                    controller: _roleNameController,
                    hintText: 'Enter role name',
                  ),
                  SizedBox(height: formGap),
                  _buildDropdownField(
                    label: 'Workspaces',
                    value: _selectedWorkspace,
                    items: _workspaces,
                    onChanged: (value) => setState(
                      () => _selectedWorkspace = value ?? _selectedWorkspace,
                    ),
                  ),
                  SizedBox(height: formGap),
                  _buildDropdownField(
                    label: 'Data Scope',
                    value: _selectedDataScope,
                    items: _dataScopes,
                    onChanged: (value) => setState(
                      () => _selectedDataScope = value ?? _selectedDataScope,
                    ),
                  ),
                  SizedBox(height: formGap),
                  _buildTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    hintText: 'Optional',
                    maxLines: 2,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Role Name *',
                      controller: _roleNameController,
                      hintText: 'Enter role name',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Workspaces',
                      value: _selectedWorkspace,
                      items: _workspaces,
                      onChanged: (value) => setState(
                        () => _selectedWorkspace = value ?? _selectedWorkspace,
                      ),
                    ),
                  ),
                ],
              ),
        if (!isCompact) ...[
          SizedBox(height: formGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Data Scope',
                  value: _selectedDataScope,
                  items: _dataScopes,
                  onChanged: (value) => setState(
                    () => _selectedDataScope = value ?? _selectedDataScope,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hintText: 'Optional',
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
            ),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0B4A06),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0B4A06),
                width: 1.2,
              ),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPermissionsTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildPermissionHeaderRow(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ..._modules.map(
            (module) => Column(
              children: [
                _buildPermissionRow(module),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionHeaderRow() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 260,
            child: Text(
              'MODULES',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
          ),
          const SizedBox(
            width: 74,
            child: Center(
              child: Text(
                'ALL',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          ),
          ..._permissionColumns.map(
            (permission) => SizedBox(
              width: 108,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    permission.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 16,
                    color: Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String module) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: Text(
              module,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 74,
            child: Center(
              child: Checkbox(
                value: _allSelectionValue(module),
                tristate: true,
                onChanged: (value) => _toggleAll(module, value),
                activeColor: const Color(0xFF0B4A06),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          ..._permissionColumns.map(
            (permission) => SizedBox(
              width: 108,
              child: Center(
                child: Checkbox(
                  value:
                      _modulePermissions[module]?.contains(permission) ?? false,
                  onChanged: (value) =>
                      _togglePermission(module, permission, value),
                  activeColor: const Color(0xFF0B4A06),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

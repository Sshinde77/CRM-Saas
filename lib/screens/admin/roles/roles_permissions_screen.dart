import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'new_role_screen.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<_RoleRecord> _roles = [
    const _RoleRecord(
      name: 'Accountant',
      accessSummary: '9 modules - Limited',
      isDefault: true,
      icon: Icons.shield_outlined,
      accentColor: Color(0xFF1F6D2A),
    ),
    const _RoleRecord(
      name: 'Delivery Partner',
      accessSummary: '7 modules - Limited',
      isDefault: true,
      icon: Icons.local_shipping_outlined,
      accentColor: Color(0xFF1F6D2A),
    ),
    const _RoleRecord(
      name: 'Sales Officer',
      accessSummary: '6 modules - Limited',
      isDefault: true,
      icon: Icons.badge_outlined,
      accentColor: Color(0xFF1F6D2A),
    ),
    const _RoleRecord(
      name: 'HR',
      accessSummary: '17 modules - Limited',
      isDefault: false,
      icon: Icons.groups_2_outlined,
      accentColor: Color(0xFF1F6D2A),
    ),
  ];

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_RoleRecord> get _filteredRoles {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return _roles;
    }

    return _roles.where((role) {
      return role.name.toLowerCase().contains(query) ||
          role.accessSummary.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openNewRoleScreen() async {
    final result = await Navigator.of(context).push<NewRoleResult>(
      MaterialPageRoute(builder: (_) => const NewRoleScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _roles.insert(
          0,
          _RoleRecord(
            name: result.name,
            accessSummary: '${result.modulesCount} modules - ${result.accessLevel}',
            isDefault: false,
            icon: Icons.admin_panel_settings_outlined,
            accentColor: const Color(0xFF1F6D2A),
          ),
        );
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _openRoleActions(_RoleRecord role) {
    _showMessage('${role.name} actions are coming soon.');
  }

  @override
  Widget build(BuildContext context) {
    final roles = _filteredRoles;

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
                  final isCompact = constraints.maxWidth < 980;
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
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                            child: isCompact
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Roles & Permissions',
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Create custom roles and configure module-level access for staff.',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: _buildNewRoleButton(compact: true),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildSearchField(),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Roles & Permissions',
                                              style: TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Create custom roles and configure module-level access for staff.',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildNewRoleButton(compact: false),
                                    ],
                                  ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          if (!isCompact)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  SizedBox(
                                    width: 360,
                                    child: _buildSearchField(),
                                  ),
                                ],
                              ),
                            ),
                          if (!isCompact)
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: isCompact
                                ? _buildCompactList(roles)
                                : _buildTable(roles),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                            child: Row(
                              children: [
                                Text(
                                  roles.isEmpty
                                      ? '0 to 0 of 0'
                                      : '1 to ${roles.length} of ${roles.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Roles',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
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

  Widget _buildNewRoleButton({required bool compact}) {
    return SizedBox(
      height: compact ? 34 : 36,
      child: ElevatedButton.icon(
        onPressed: _openNewRoleScreen,
        icon: Icon(Icons.add, size: compact ? 16 : 17),
        label: const Text('New Role'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B4A06),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: TextStyle(
            fontSize: compact ? 12.5 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search roles',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            borderSide: const BorderSide(color: Color(0xFF0B4A06), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(List<_RoleRecord> roles) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: const [
              SizedBox(width: 480, child: _HeaderLabel('ROLE')),
              Expanded(child: _HeaderLabel('ACCESS')),
              SizedBox(width: 72, child: _HeaderLabel('ACTION')),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...roles.map(
          (role) => _RoleRow(
            role: role,
            onActionTap: () => _openRoleActions(role),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactList(List<_RoleRecord> roles) {
    if (roles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'No roles found.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: roles
          .map(
            (role) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: role.accentColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(role.icon, color: role.accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    role.name,
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (role.isDefault) const _DefaultPill(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              role.accessSummary,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (_) => _openRoleActions(role),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        icon: const Icon(Icons.more_vert_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RoleRecord {
  final String name;
  final String accessSummary;
  final bool isDefault;
  final IconData icon;
  final Color accentColor;

  const _RoleRecord({
    required this.name,
    required this.accessSummary,
    required this.isDefault,
    required this.icon,
    required this.accentColor,
  });
}

class _RoleRow extends StatelessWidget {
  final _RoleRecord role;
  final VoidCallback onActionTap;

  const _RoleRow({required this.role, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: role.accentColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(role.icon, color: role.accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 420,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    role.name,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (role.isDefault) const _DefaultPill(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              role.accessSummary,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (_) => onActionTap(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultPill extends StatelessWidget {
  const _DefaultPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6ECD9)),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          color: Color(0xFF0B4A06),
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;

  const _HeaderLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.9,
      ),
    );
  }
}

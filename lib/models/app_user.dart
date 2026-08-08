class AppUser {
  const AppUser({
    required this.id,
    this.organizationId,
    required this.name,
    required this.email,
    this.username,
    this.role,
    this.systemRole,
    this.roleId,
    this.roleDetail,
    this.phone,
    this.isActive,
    this.createdAt,
    this.profilePhoto,
  });

  final String id;
  final String? organizationId;
  final String name;
  final String email;
  final String? username;
  final String? role;
  final String? systemRole;
  final String? roleId;
  final UserRoleDetail? roleDetail;
  final String? phone;
  final bool? isActive;
  final DateTime? createdAt;
  final String? profilePhoto;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      organizationId: json['organization_id']?.toString(),
      name: (json['name'] ?? json['full_name'] ?? json['admin_name'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      username: json['username']?.toString(),
      role: json['role']?.toString(),
      systemRole: json['system_role']?.toString(),
      roleId: json['role_id']?.toString(),
      roleDetail: json['role_detail'] is Map<String, dynamic>
          ? UserRoleDetail.fromJson(json['role_detail'] as Map<String, dynamic>)
          : null,
      phone: json['phone']?.toString(),
      isActive: json['is_active'] as bool?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      profilePhoto: json['profile_photo']?.toString().trim().isEmpty == true
          ? null
          : json['profile_photo']?.toString(),
    );
  }
}

class UserRoleDetail {
  const UserRoleDetail({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  final String id;
  final String name;
  final bool isDefault;

  factory UserRoleDetail.fromJson(Map<String, dynamic> json) {
    return UserRoleDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isDefault: json['is_default'] == true,
    );
  }
}

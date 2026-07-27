class AppUser {
  const AppUser({
    required this.id,
    this.organizationId,
    required this.name,
    required this.email,
    this.role,
    this.phone,
    this.isActive,
    this.createdAt,
  });

  final String id;
  final String? organizationId;
  final String name;
  final String email;
  final String? role;
  final String? phone;
  final bool? isActive;
  final DateTime? createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      organizationId: json['organization_id']?.toString(),
      name: (json['name'] ?? json['full_name'] ?? json['admin_name'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      role: json['role']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['is_active'] as bool?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class RoleModel {
  const RoleModel({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.permissions,
  });

  final String id;
  final String name;
  final bool isDefault;
  final Map<String, dynamic> permissions;

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isDefault: json['is_default'] == true,
      permissions: json['permissions'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              json['permissions'] as Map<String, dynamic>,
            )
          : const {},
    );
  }
}

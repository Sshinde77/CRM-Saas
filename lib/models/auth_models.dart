class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterOrganizationRequest {
  final String organizationName;
  final String businessType;
  final String gstNumber;
  final String panNumber;
  final String address;
  final String phone;
  final String email;
  final String financialYear;
  final String logoUrl;
  final String adminName;
  final String password;
  final String role;

  const RegisterOrganizationRequest({
    required this.organizationName,
    required this.businessType,
    required this.gstNumber,
    required this.panNumber,
    required this.address,
    required this.phone,
    required this.email,
    required this.financialYear,
    required this.logoUrl,
    required this.adminName,
    required this.password,
    this.role = 'admin',
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_name': organizationName,
      'business_type': businessType,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'address': address,
      'phone': phone,
      'email': email,
      'financial_year': financialYear,
      'logo_url': logoUrl,
      'admin_name': adminName,
      'password': password,
      'role': role,
    };
  }
}

class CurrentUserProfile {
  final String name;
  final String role;
  final String? email;

  const CurrentUserProfile({
    required this.name,
    required this.role,
    this.email,
  });

  factory CurrentUserProfile.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] ?? json['full_name'] ?? json['admin_name'])
        ?.toString();
    final rawRole = (json['role'] ?? json['user_role'])?.toString();
    final rawEmail = json['email']?.toString();

    return CurrentUserProfile(
      name: (rawName == null || rawName.trim().isEmpty)
          ? 'User'
          : rawName.trim(),
      role: _formatRole(rawRole),
      email: rawEmail?.trim().isEmpty == true ? null : rawEmail?.trim(),
    );
  }

  static String _formatRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return '';
    }

    return role
        .trim()
        .split('_')
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }
}

class AuthSession {
  final String accessToken;
  final String? refreshToken;
  final String message;
  final CurrentUserProfile? user;

  const AuthSession({
    required this.accessToken,
    required this.message,
    this.refreshToken,
    this.user,
  });
}

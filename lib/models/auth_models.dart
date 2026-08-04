import 'plan_model.dart';

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
  final String? shippingAddress;
  final String? website;
  final String? invoicePrefix;
  final String phone;
  final String email;
  final String financialYear;
  final String? logoUrl;
  final String adminName;
  final String password;
  final String role;

  const RegisterOrganizationRequest({
    required this.organizationName,
    required this.businessType,
    required this.gstNumber,
    required this.panNumber,
    required this.address,
    this.shippingAddress,
    this.website,
    this.invoicePrefix,
    required this.phone,
    required this.email,
    required this.financialYear,
    this.logoUrl,
    required this.adminName,
    required this.password,
    this.role = 'admin',
  });

  bool get hasExtendedFields =>
      _hasValue(shippingAddress) ||
      _hasValue(website) ||
      _hasValue(invoicePrefix);

  Map<String, dynamic> toJson({bool includeExtendedFields = true}) {
    final payload = <String, dynamic>{
      'organization_name': organizationName,
      'business_type': businessType,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'address': address,
      'phone': phone,
      'email': email,
      'financial_year': financialYear,
      'admin_name': adminName,
      'password': password,
      'role': role,
    };

    if (_hasValue(logoUrl)) {
      payload['logo_url'] = logoUrl!.trim();
    }

    if (includeExtendedFields) {
      if (_hasValue(shippingAddress)) {
        payload['shipping_address'] = shippingAddress!.trim();
      }
      if (_hasValue(website)) {
        payload['website'] = website!.trim();
      }
      if (_hasValue(invoicePrefix)) {
        payload['invoice_prefix'] = invoicePrefix!.trim();
      }
    }

    return payload;
  }

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class CreateUserRequest {
  final String name;
  final String email;
  final String username;
  final String phone;
  final String password;
  final String roleId;
  final String role;

  const CreateUserRequest({
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
    required this.password,
    required this.roleId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'password': password,
      'role_id': roleId,
      'role': role,
    };
  }
}

class UpdateUserRequest {
  final String name;
  final String email;
  final String username;
  final String phone;

  const UpdateUserRequest({
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
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

class TrialStatus {
  final int? daysLeft;
  final DateTime? createdAt;
  final DateTime? endsAt;

  const TrialStatus({
    required this.daysLeft,
    required this.createdAt,
    required this.endsAt,
  });

  bool get shouldShowDialog => daysLeft != null;
  bool get isExpired => (daysLeft ?? 1) <= 0;

  double get progress {
    final created = createdAt;
    final ends = endsAt;
    if (created != null && ends != null && ends.isAfter(created)) {
      final total = ends.difference(created).inSeconds;
      final elapsed = DateTime.now()
          .toUtc()
          .difference(created.toUtc())
          .inSeconds;
      return (elapsed / total).clamp(0.0, 1.0);
    }

    final remaining = daysLeft;
    if (remaining == null) {
      return 0;
    }
    const fallbackTrialDays = 7;
    return ((fallbackTrialDays - remaining) / fallbackTrialDays).clamp(
      0.0,
      1.0,
    );
  }

  factory TrialStatus.fromAuthMeJson(Map<String, dynamic> json) {
    final organization = json['organization'];
    if (organization is! Map<String, dynamic>) {
      return const TrialStatus(daysLeft: null, createdAt: null, endsAt: null);
    }

    return TrialStatus(
      daysLeft: _tryParseInt(organization['trial_days_left']),
      createdAt: _tryParseDateTime(organization['created_at']?.toString()),
      endsAt: _tryParseDateTime(organization['trial_ends_at']?.toString()),
    );
  }

  static int? _tryParseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

class AuthMeOrganization {
  final String id;
  final String name;
  final String? status;
  final String? planId;
  final PlanModel? plan;
  final int? trialDaysLeft;
  final DateTime? trialEndsAt;

  const AuthMeOrganization({
    required this.id,
    required this.name,
    required this.status,
    required this.planId,
    required this.plan,
    required this.trialDaysLeft,
    required this.trialEndsAt,
  });

  factory AuthMeOrganization.fromJson(Map<String, dynamic> json) {
    final planJson = json['plan'];
    return AuthMeOrganization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString(),
      planId: json['plan_id']?.toString(),
      plan: planJson is Map<String, dynamic>
          ? PlanModel.fromJson(planJson)
          : null,
      trialDaysLeft: TrialStatus._tryParseInt(json['trial_days_left']),
      trialEndsAt: TrialStatus._tryParseDateTime(
        json['trial_ends_at']?.toString(),
      ),
    );
  }
}

class AuthMeResponse {
  final CurrentUserProfile? user;
  final AuthMeOrganization? organization;
  final bool fullAccess;
  final Map<String, dynamic> permissions;

  const AuthMeResponse({
    required this.user,
    required this.organization,
    required this.fullAccess,
    required this.permissions,
  });

  factory AuthMeResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final organizationJson = json['organization'];

    return AuthMeResponse(
      user: userJson is Map<String, dynamic>
          ? CurrentUserProfile.fromJson(userJson)
          : null,
      organization: organizationJson is Map<String, dynamic>
          ? AuthMeOrganization.fromJson(organizationJson)
          : null,
      fullAccess: json['full_access'] == true,
      permissions: json['permissions'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              json['permissions'] as Map<String, dynamic>,
            )
          : const {},
    );
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

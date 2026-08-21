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

class OrganizationSettingsRequest {
  final Map<String, dynamic> fields;

  const OrganizationSettingsRequest({required this.fields});

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    for (final entry in fields.entries) {
      final key = entry.key.trim();
      final value = entry.value;
      if (key.isEmpty) {
        continue;
      }

      if (value == null) {
        payload[key] = null;
        continue;
      }

      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        payload[key] = trimmed;
        continue;
      }

      if (value is List) {
        if (value.isEmpty) continue;
        payload[key] = value;
        continue;
      }

      if (value is Map) {
        if (value.isEmpty) continue;
        payload[key] = value;
        continue;
      }

      payload[key] = value;
    }
    return payload;
  }
}

class CreateUserRequest {
  final String? name;
  final String? email;
  final String? username;
  final String? phone;
  final String? password;
  final String? confirmPassword;
  final String? employeeId;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? maritalStatus;
  final String? bloodGroup;
  final String? nationality;
  final String? alternateMobileNumber;
  final String? personalEmail;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? emergencyContactRelationship;
  final String? currentAddress;
  final String? permanentAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? pinZipCode;
  final String? designation;
  final String? reportingManagerId;
  final String? employmentType;
  final DateTime? dateOfJoining;
  final DateTime? dateOfExit;
  final String? workLocation;
  final String? shift;
  final String? employeeStatus;
  final num? basicSalary;
  final String? bankName;
  final String? accountNumber;
  final String? ifscSwiftCode;
  final String? accountHolderName;
  final String? upiId;
  final String? profilePhoto;
  final String? identityProofType;
  final String? identityProofFile;
  final String? resumeCv;
  final String? offerLetter;
  final String? appointmentLetter;
  final String? experienceCertificates;
  final String? educationalCertificates;
  final List<String>? skills;
  final String? language;
  final String? timeZone;
  final String? status;
  final String? roleId;
  final String? role;

  const CreateUserRequest({
    this.name,
    this.email,
    this.username,
    this.phone,
    this.password,
    this.confirmPassword,
    this.employeeId,
    this.firstName,
    this.lastName,
    this.displayName,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.bloodGroup,
    this.nationality,
    this.alternateMobileNumber,
    this.personalEmail,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.emergencyContactRelationship,
    this.currentAddress,
    this.permanentAddress,
    this.city,
    this.state,
    this.country,
    this.pinZipCode,
    this.designation,
    this.reportingManagerId,
    this.employmentType,
    this.dateOfJoining,
    this.dateOfExit,
    this.workLocation,
    this.shift,
    this.employeeStatus,
    this.basicSalary,
    this.bankName,
    this.accountNumber,
    this.ifscSwiftCode,
    this.accountHolderName,
    this.upiId,
    this.profilePhoto,
    this.identityProofType,
    this.identityProofFile,
    this.resumeCv,
    this.offerLetter,
    this.appointmentLetter,
    this.experienceCertificates,
    this.educationalCertificates,
    this.skills,
    this.language,
    this.timeZone,
    this.status,
    this.roleId,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    _putIfNotBlank(payload, 'name', name);
    _putIfNotBlank(payload, 'email', email);
    _putIfNotBlank(payload, 'username', username);
    _putIfNotBlank(payload, 'phone', phone);
    _putIfNotBlank(payload, 'password', password);
    _putIfNotBlank(payload, 'confirm_password', confirmPassword);
    _putIfNotBlank(payload, 'employee_id', employeeId);
    _putIfNotBlank(payload, 'first_name', firstName);
    _putIfNotBlank(payload, 'last_name', lastName);
    _putIfNotBlank(payload, 'display_name', displayName);
    _putIfNotBlank(payload, 'gender', gender);
    if (dateOfBirth != null) {
      payload['date_of_birth'] = dateOfBirth!.toUtc().toIso8601String();
    }
    _putIfNotBlank(payload, 'marital_status', maritalStatus);
    _putIfNotBlank(payload, 'blood_group', bloodGroup);
    _putIfNotBlank(payload, 'nationality', nationality);
    _putIfNotBlank(payload, 'alternate_mobile_number', alternateMobileNumber);
    _putIfNotBlank(payload, 'personal_email', personalEmail);
    _putIfNotBlank(payload, 'emergency_contact_name', emergencyContactName);
    _putIfNotBlank(payload, 'emergency_contact_number', emergencyContactNumber);
    _putIfNotBlank(
      payload,
      'emergency_contact_relationship',
      emergencyContactRelationship,
    );
    _putIfNotBlank(payload, 'current_address', currentAddress);
    _putIfNotBlank(payload, 'permanent_address', permanentAddress);
    _putIfNotBlank(payload, 'city', city);
    _putIfNotBlank(payload, 'state', state);
    _putIfNotBlank(payload, 'country', country);
    _putIfNotBlank(payload, 'pin_zip_code', pinZipCode);
    _putIfNotBlank(payload, 'designation', designation);
    _putIfNotBlank(payload, 'reporting_manager_id', reportingManagerId);
    _putIfNotBlank(payload, 'employment_type', employmentType);
    if (dateOfJoining != null) {
      payload['date_of_joining'] = dateOfJoining!.toUtc().toIso8601String();
    }
    if (dateOfExit != null) {
      payload['date_of_exit'] = dateOfExit!.toUtc().toIso8601String();
    }
    _putIfNotBlank(payload, 'work_location', workLocation);
    _putIfNotBlank(payload, 'shift', shift);
    _putIfNotBlank(payload, 'employee_status', employeeStatus);
    if (basicSalary != null) {
      payload['basic_salary'] = basicSalary;
    }
    _putIfNotBlank(payload, 'bank_name', bankName);
    _putIfNotBlank(payload, 'account_number', accountNumber);
    _putIfNotBlank(payload, 'ifsc_swift_code', ifscSwiftCode);
    _putIfNotBlank(payload, 'account_holder_name', accountHolderName);
    _putIfNotBlank(payload, 'upi_id', upiId);
    _putIfNotBlank(payload, 'profile_photo', profilePhoto);
    _putIfNotBlank(payload, 'identity_proof_type', identityProofType);
    _putIfNotBlank(payload, 'identity_proof_file', identityProofFile);
    _putIfNotBlank(payload, 'resume_cv', resumeCv);
    _putIfNotBlank(payload, 'offer_letter', offerLetter);
    _putIfNotBlank(payload, 'appointment_letter', appointmentLetter);
    _putIfNotBlank(payload, 'experience_certificates', experienceCertificates);
    _putIfNotBlank(
      payload,
      'educational_certificates',
      educationalCertificates,
    );
    if (skills != null && skills!.isNotEmpty) {
      payload['skills'] = skills;
    }
    _putIfNotBlank(payload, 'language', language);
    _putIfNotBlank(payload, 'time_zone', timeZone);
    _putIfNotBlank(payload, 'status', status);
    _putIfNotBlank(payload, 'role_id', roleId);
    _putIfNotBlank(payload, 'role', role);
    return payload;
  }
}

class UpdateUserRequest {
  final String? name;
  final String? email;
  final String? username;
  final String? phone;
  final String? employeeId;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? maritalStatus;
  final String? bloodGroup;
  final String? nationality;
  final String? alternateMobileNumber;
  final String? personalEmail;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? emergencyContactRelationship;
  final String? currentAddress;
  final String? permanentAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? pinZipCode;
  final String? designation;
  final String? reportingManagerId;
  final String? employmentType;
  final DateTime? dateOfJoining;
  final DateTime? dateOfExit;
  final String? workLocation;
  final String? shift;
  final String? employeeStatus;
  final num? basicSalary;
  final String? bankName;
  final String? accountNumber;
  final String? ifscSwiftCode;
  final String? accountHolderName;
  final String? upiId;
  final String? profilePhoto;
  final String? identityProofType;
  final String? identityProofFile;
  final String? resumeCv;
  final String? offerLetter;
  final String? appointmentLetter;
  final String? experienceCertificates;
  final String? educationalCertificates;
  final List<String>? skills;
  final String? language;
  final String? timeZone;
  final String? status;

  const UpdateUserRequest({
    this.name,
    this.email,
    this.username,
    this.phone,
    this.employeeId,
    this.firstName,
    this.lastName,
    this.displayName,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.bloodGroup,
    this.nationality,
    this.alternateMobileNumber,
    this.personalEmail,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.emergencyContactRelationship,
    this.currentAddress,
    this.permanentAddress,
    this.city,
    this.state,
    this.country,
    this.pinZipCode,
    this.designation,
    this.reportingManagerId,
    this.employmentType,
    this.dateOfJoining,
    this.dateOfExit,
    this.workLocation,
    this.shift,
    this.employeeStatus,
    this.basicSalary,
    this.bankName,
    this.accountNumber,
    this.ifscSwiftCode,
    this.accountHolderName,
    this.upiId,
    this.profilePhoto,
    this.identityProofType,
    this.identityProofFile,
    this.resumeCv,
    this.offerLetter,
    this.appointmentLetter,
    this.experienceCertificates,
    this.educationalCertificates,
    this.skills,
    this.language,
    this.timeZone,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    _putIfNotBlank(payload, 'name', name);
    _putIfNotBlank(payload, 'email', email);
    _putIfNotBlank(payload, 'username', username);
    _putIfNotBlank(payload, 'phone', phone);
    _putIfNotBlank(payload, 'employee_id', employeeId);
    _putIfNotBlank(payload, 'first_name', firstName);
    _putIfNotBlank(payload, 'last_name', lastName);
    _putIfNotBlank(payload, 'display_name', displayName);
    _putIfNotBlank(payload, 'gender', gender);
    if (dateOfBirth != null) {
      payload['date_of_birth'] = dateOfBirth!.toUtc().toIso8601String();
    }
    _putIfNotBlank(payload, 'marital_status', maritalStatus);
    _putIfNotBlank(payload, 'blood_group', bloodGroup);
    _putIfNotBlank(payload, 'nationality', nationality);
    _putIfNotBlank(payload, 'alternate_mobile_number', alternateMobileNumber);
    _putIfNotBlank(payload, 'personal_email', personalEmail);
    _putIfNotBlank(payload, 'emergency_contact_name', emergencyContactName);
    _putIfNotBlank(payload, 'emergency_contact_number', emergencyContactNumber);
    _putIfNotBlank(
      payload,
      'emergency_contact_relationship',
      emergencyContactRelationship,
    );
    _putIfNotBlank(payload, 'current_address', currentAddress);
    _putIfNotBlank(payload, 'permanent_address', permanentAddress);
    _putIfNotBlank(payload, 'city', city);
    _putIfNotBlank(payload, 'state', state);
    _putIfNotBlank(payload, 'country', country);
    _putIfNotBlank(payload, 'pin_zip_code', pinZipCode);
    _putIfNotBlank(payload, 'designation', designation);
    _putIfNotBlank(payload, 'reporting_manager_id', reportingManagerId);
    _putIfNotBlank(payload, 'employment_type', employmentType);
    if (dateOfJoining != null) {
      payload['date_of_joining'] = dateOfJoining!.toUtc().toIso8601String();
    }
    if (dateOfExit != null) {
      payload['date_of_exit'] = dateOfExit!.toUtc().toIso8601String();
    }
    _putIfNotBlank(payload, 'work_location', workLocation);
    _putIfNotBlank(payload, 'shift', shift);
    _putIfNotBlank(payload, 'employee_status', employeeStatus);
    if (basicSalary != null) {
      payload['basic_salary'] = basicSalary;
    }
    _putIfNotBlank(payload, 'bank_name', bankName);
    _putIfNotBlank(payload, 'account_number', accountNumber);
    _putIfNotBlank(payload, 'ifsc_swift_code', ifscSwiftCode);
    _putIfNotBlank(payload, 'account_holder_name', accountHolderName);
    _putIfNotBlank(payload, 'upi_id', upiId);
    _putIfNotBlank(payload, 'profile_photo', profilePhoto);
    _putIfNotBlank(payload, 'identity_proof_type', identityProofType);
    _putIfNotBlank(payload, 'identity_proof_file', identityProofFile);
    _putIfNotBlank(payload, 'resume_cv', resumeCv);
    _putIfNotBlank(payload, 'offer_letter', offerLetter);
    _putIfNotBlank(payload, 'appointment_letter', appointmentLetter);
    _putIfNotBlank(payload, 'experience_certificates', experienceCertificates);
    _putIfNotBlank(
      payload,
      'educational_certificates',
      educationalCertificates,
    );
    if (skills != null && skills!.isNotEmpty) {
      payload['skills'] = skills;
    }
    _putIfNotBlank(payload, 'language', language);
    _putIfNotBlank(payload, 'time_zone', timeZone);
    _putIfNotBlank(payload, 'status', status);
    return payload;
  }
}

class UpdateUserStatusRequest {
  final bool isActive;

  const UpdateUserStatusRequest({required this.isActive});

  Map<String, dynamic> toJson() {
    return {'is_active': isActive};
  }
}

class ResetUserPasswordRequest {
  final String newPassword;

  const ResetUserPasswordRequest({required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'new_password': newPassword};
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'current_password': currentPassword, 'new_password': newPassword};
  }
}

void _putIfNotBlank(Map<String, dynamic> payload, String key, String? value) {
  final trimmed = value?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    payload[key] = trimmed;
  }
}

class CurrentUserProfile {
  final String? id;
  final String name;
  final String role;
  final String? email;
  final String? profilePhoto;

  const CurrentUserProfile({
    this.id,
    required this.name,
    required this.role,
    this.email,
    this.profilePhoto,
  });

  factory CurrentUserProfile.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['user_id'] ?? json['userId'];
    final rawName = (json['name'] ?? json['full_name'] ?? json['admin_name'])
        ?.toString();
    final rawRole = (json['role'] ?? json['user_role'])?.toString();
    final rawEmail = json['email']?.toString();
    final rawProfilePhoto = json['profile_photo']?.toString();

    return CurrentUserProfile(
      id: rawId?.trim().isEmpty == true ? null : rawId?.trim(),
      name: (rawName == null || rawName.trim().isEmpty)
          ? 'User'
          : rawName.trim(),
      role: _formatRole(rawRole),
      email: rawEmail?.trim().isEmpty == true ? null : rawEmail?.trim(),
      profilePhoto: rawProfilePhoto?.trim().isEmpty == true
          ? null
          : rawProfilePhoto?.trim(),
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
  final String? dataScope;
  final Map<String, dynamic> permissions;

  const AuthMeResponse({
    required this.user,
    required this.organization,
    required this.fullAccess,
    required this.dataScope,
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
      dataScope: json['data_scope']?.toString(),
      permissions: json['permissions'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              json['permissions'] as Map<String, dynamic>,
            )
          : const {},
    );
  }

  bool can(String module, String action) {
    if (fullAccess) return true;

    final modulePermissions = permissions[module];
    if (modulePermissions is! Map) return false;

    final permission = modulePermissions[action];
    if (permission is bool) return permission;
    return permission?.toString().trim().toLowerCase() == 'true';
  }

  bool canView(String module) => can(module, 'view');
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

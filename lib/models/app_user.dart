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
    this.identityProofType,
    this.identityProofFile,
    this.resumeCv,
    this.offerLetter,
    this.appointmentLetter,
    this.skills,
    this.language,
    this.timeZone,
    this.status,
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
  final String? identityProofType;
  final String? identityProofFile;
  final String? resumeCv;
  final String? offerLetter;
  final String? appointmentLetter;
  final List<String>? skills;
  final String? language;
  final String? timeZone;
  final String? status;

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
      employeeId: json['employee_id']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      displayName: json['display_name']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: DateTime.tryParse(json['date_of_birth']?.toString() ?? ''),
      maritalStatus: json['marital_status']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      nationality: json['nationality']?.toString(),
      alternateMobileNumber: json['alternate_mobile_number']?.toString(),
      personalEmail: json['personal_email']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactNumber: json['emergency_contact_number']?.toString(),
      emergencyContactRelationship: json['emergency_contact_relationship']
          ?.toString(),
      currentAddress: json['current_address']?.toString(),
      permanentAddress: json['permanent_address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      pinZipCode: json['pin_zip_code']?.toString(),
      designation: json['designation']?.toString(),
      reportingManagerId: json['reporting_manager_id']?.toString(),
      employmentType: json['employment_type']?.toString(),
      dateOfJoining: DateTime.tryParse(
        json['date_of_joining']?.toString() ?? '',
      ),
      dateOfExit: DateTime.tryParse(json['date_of_exit']?.toString() ?? ''),
      workLocation: json['work_location']?.toString(),
      shift: json['shift']?.toString(),
      employeeStatus: json['employee_status']?.toString(),
      basicSalary: num.tryParse(json['basic_salary']?.toString() ?? ''),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscSwiftCode: json['ifsc_swift_code']?.toString(),
      accountHolderName: json['account_holder_name']?.toString(),
      upiId: json['upi_id']?.toString(),
      identityProofType: json['identity_proof_type']?.toString(),
      identityProofFile: json['identity_proof_file']?.toString(),
      resumeCv: json['resume_cv']?.toString(),
      offerLetter: json['offer_letter']?.toString(),
      appointmentLetter: json['appointment_letter']?.toString(),
      skills: (json['skills'] as List?)
          ?.map((value) => value?.toString())
          .whereType<String>()
          .toList(),
      language: json['language']?.toString(),
      timeZone: json['time_zone']?.toString(),
      status: json['status']?.toString(),
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

import 'dart:typed_data';

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../models/auth_models.dart';
import '../../../models/role_model.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  Future<List<RoleModel>>? _rolesFuture;
  Future<List<AppUser>>? _usersFuture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _alternatePhoneController =
      TextEditingController();
  final TextEditingController _personalEmailController =
      TextEditingController();
  final TextEditingController _officialEmailController =
      TextEditingController();
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactNumberController =
      TextEditingController();
  final TextEditingController _emergencyContactRelationshipController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _reportingManagerController =
      TextEditingController();
  final TextEditingController _employmentTypeController =
      TextEditingController();
  final TextEditingController _dateOfJoiningController =
      TextEditingController();
  final TextEditingController _dateOfExitController = TextEditingController();
  final TextEditingController _workLocationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _basicSalaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  RoleModel? _selectedRole;
  String? _selectedReportingManagerId;
  bool _sendNotification = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _isLoadingEditUser = false;
  String? _editLoadError;
  int _currentStep = 0;
  String? _selectedLanguage;
  String? _selectedTimeZone;
  String? _selectedShift;
  String _selectedEmployeeStatus = 'Active';
  String _selectedStatus = 'Active';
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedBloodGroup;
  String? _selectedNationality;
  String? _selectedEmergencyContactRelationship;
  String? _selectedIdentityProofType;
  String? _selectedBankName;
  Uint8List? _photoBytes;
  Uint8List? _identityProofBytes;
  Uint8List? _resumeBytes;
  Uint8List? _offerLetterBytes;
  Uint8List? _appointmentLetterBytes;
  Uint8List? _experienceCertificatesBytes;
  Uint8List? _educationalCertificatesBytes;

  static const List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  static const List<String> _maritalOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];
  static const List<String> _bloodOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  static const List<String> _nationalityOptions = [
    'Indian',
    'American',
    'British',
    'Canadian',
    'Other',
  ];
  static const List<String> _bankOptions = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Bank of Baroda',
    'Punjab National Bank',
  ];
  static const List<String> _relationshipOptions = [
    'Father',
    'Mother',
    'Spouse',
    'Sibling',
    'Son',
    'Daughter',
    'Guardian',
    'Relative',
    'Friend',
    'Other',
  ];
  static const List<String> _identityProofOptions = [
    'Aadhaar',
    'PAN',
    'Passport',
    'Driving Licence',
    'Voter ID',
    'Other',
  ];
  static const List<String> _languageOptions = [
    'English',
    'Hindi',
    'Marathi',
    'Gujarati',
    'Tamil',
  ];
  static const List<String> _timeZoneOptions = [
    'Asia/Kolkata',
    'UTC',
    'Europe/London',
    'America/New_York',
    'Asia/Singapore',
  ];
  static const List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Suspended',
    'Locked',
  ];
  static const List<String> _employeeStatusOptions = [
    'Active',
    'Probation',
    'On Leave',
    'Notice Period',
    'Resigned',
    'Terminated',
  ];

  static const List<_StaffWizardStep> _steps = [
    _StaffWizardStep('Basic Information', Icons.person_outline_rounded),
    _StaffWizardStep('Contact Information', Icons.call_outlined),
    _StaffWizardStep('Address Information', Icons.location_on_outlined),
    _StaffWizardStep('Employment Information', Icons.work_outline_rounded),
    _StaffWizardStep('Login & Security', Icons.lock_outline_rounded),
    _StaffWizardStep('Payroll Information', Icons.payments_outlined),
    _StaffWizardStep('Uploads', Icons.upload_file_outlined),
    _StaffWizardStep('System Preferences', Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _rolesFuture = _apiService.fetchRoles().then((roles) {
      if (!mounted) {
        return roles;
      }
      if (_selectedRole == null && roles.isNotEmpty) {
        final salesOfficerRole = roles.firstWhere(
          (role) => role.name.trim().toLowerCase() == 'sales officer',
          orElse: () => roles.first,
        );
        setState(() => _selectedRole = salesOfficerRole);
      }
      return roles;
    });
    _usersFuture = _apiService.fetchUsers();

    final existing = widget.existingUser;
    if (existing != null) {
      _applyUser(existing);
    }

    if (widget.isEditMode) {
      _loadEditUser();
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
    _employeeIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _dobController.dispose();
    _alternatePhoneController.dispose();
    _personalEmailController.dispose();
    _officialEmailController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    _emergencyContactRelationshipController.dispose();
    _addressController.dispose();
    _permanentAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    _designationController.dispose();
    _reportingManagerController.dispose();
    _employmentTypeController.dispose();
    _dateOfJoiningController.dispose();
    _dateOfExitController.dispose();
    _workLocationController.dispose();
    _salaryController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderController.dispose();
    _upiIdController.dispose();
    _basicSalaryController.dispose();
    _skillsController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _effectiveUserId =>
      (widget.userId ?? widget.existingUser?.id ?? '').trim();

  String get _title => widget.isEditMode ? 'Edit Staff' : 'Add Staff';

  String get _submitLabel =>
      widget.isEditMode ? 'Save Changes' : 'Add New Staff';

  String _roleSlugFromLabel(String role) {
    return role
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  DateTime? _parseFlexibleDate(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    final iso = DateTime.tryParse(text);
    if (iso != null) {
      return iso;
    }

    final parts = text.split(RegExp(r'[-/]'));
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime.utc(year, month, day);
  }

  String? _slugifyValue(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String? _matchOptionValue(String? value, List<String> options) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    if (options.contains(text)) {
      return text;
    }

    final normalized = _slugifyValue(text);
    if (normalized == null) {
      return text;
    }

    for (final option in options) {
      if (_slugifyValue(option) == normalized) {
        return option;
      }
    }

    return text;
  }

  String _dateText(DateTime? value) {
    if (value == null) {
      return '';
    }
    return _formatDateForInput(value.toLocal());
  }

  List<String>? _skillsList() {
    final skills = _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
    return skills.isEmpty ? null : skills;
  }

  Future<void> _loadEditUser() async {
    final userId = _effectiveUserId;
    if (userId.isEmpty) return;

    setState(() {
      _isLoadingEditUser = true;
      _editLoadError = null;
    });

    try {
      final user = await _apiService.fetchUserById(userId);
      if (!mounted) return;
      _applyUser(user);
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

  Future<void> _pickPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
      });
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to upload photo: $error');
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBytes = null;
    });
  }

  Future<void> _pickUploadFile(_StaffUploadSlot slot) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        switch (slot) {
          case _StaffUploadSlot.identityProof:
            _identityProofBytes = bytes;
            break;
          case _StaffUploadSlot.resumeCv:
            _resumeBytes = bytes;
            break;
          case _StaffUploadSlot.offerLetter:
            _offerLetterBytes = bytes;
            break;
          case _StaffUploadSlot.appointmentLetter:
            _appointmentLetterBytes = bytes;
            break;
          case _StaffUploadSlot.experienceCertificates:
            _experienceCertificatesBytes = bytes;
            break;
          case _StaffUploadSlot.educationalCertificates:
            _educationalCertificatesBytes = bytes;
            break;
        }
      });
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to upload file: $error');
      }
    }
  }

  void _removeUploadFile(_StaffUploadSlot slot) {
    setState(() {
      switch (slot) {
        case _StaffUploadSlot.identityProof:
          _identityProofBytes = null;
          break;
        case _StaffUploadSlot.resumeCv:
          _resumeBytes = null;
          break;
        case _StaffUploadSlot.offerLetter:
          _offerLetterBytes = null;
          break;
        case _StaffUploadSlot.appointmentLetter:
          _appointmentLetterBytes = null;
          break;
        case _StaffUploadSlot.experienceCertificates:
          _experienceCertificatesBytes = null;
          break;
        case _StaffUploadSlot.educationalCertificates:
          _educationalCertificatesBytes = null;
          break;
      }
    });
  }

  void _applyUser(AppUser user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _officialEmailController.text = user.email;
    _personalEmailController.text = user.personalEmail ?? user.email;
    _usernameController.text = user.username ?? user.email;
    _phoneController.text = user.phone ?? '';
    _employeeIdController.text = user.employeeId ?? '';
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _displayNameController.text = user.displayName ?? user.name;
    _dobController.text = _dateText(user.dateOfBirth);
    _alternatePhoneController.text = user.alternateMobileNumber ?? '';
    _emergencyContactNameController.text = user.emergencyContactName ?? '';
    _emergencyContactNumberController.text = user.emergencyContactNumber ?? '';
    _emergencyContactRelationshipController.text =
        user.emergencyContactRelationship ?? '';
    _addressController.text = user.currentAddress ?? '';
    _permanentAddressController.text = user.permanentAddress ?? '';
    _cityController.text = user.city ?? '';
    _stateController.text = user.state ?? '';
    _countryController.text = user.country ?? '';
    _pinCodeController.text = user.pinZipCode ?? '';
    _designationController.text = user.designation ?? '';
    _reportingManagerController.text = user.reportingManagerId ?? '';
    _employmentTypeController.text =
        _matchOptionValue(user.employmentType, const [
          'Full Time',
          'Part Time',
          'Contract',
          'Intern',
          'Temporary',
        ]) ??
        '';
    _dateOfJoiningController.text = _dateText(user.dateOfJoining);
    _dateOfExitController.text = _dateText(user.dateOfExit);
    _workLocationController.text = user.workLocation ?? '';
    _basicSalaryController.text = user.basicSalary?.toString() ?? '';
    _accountNumberController.text = user.accountNumber ?? '';
    _ifscCodeController.text = user.ifscSwiftCode ?? '';
    _accountHolderController.text = user.accountHolderName ?? '';
    _upiIdController.text = user.upiId ?? '';
    _skillsController.text = user.skills?.join(', ') ?? '';
    _selectedGender = _matchOptionValue(user.gender, _genderOptions);
    _selectedMaritalStatus = _matchOptionValue(
      user.maritalStatus,
      _maritalOptions,
    );
    _selectedBloodGroup = _matchOptionValue(user.bloodGroup, _bloodOptions);
    _selectedNationality = _matchOptionValue(
      user.nationality,
      _nationalityOptions,
    );
    _selectedShift = _matchOptionValue(user.shift, const [
      'Morning',
      'Day',
      'Night',
      'Flexible',
    ]);
    _selectedEmployeeStatus =
        _matchOptionValue(user.employeeStatus, _employeeStatusOptions) ??
        _selectedEmployeeStatus;
    _selectedStatus =
        _matchOptionValue(user.status, _statusOptions) ?? _selectedStatus;
    _selectedBankName = _matchOptionValue(user.bankName, _bankOptions);
    _selectedLanguage = _matchOptionValue(user.language, _languageOptions);
    _selectedTimeZone = _matchOptionValue(user.timeZone, _timeZoneOptions);
    _selectedEmergencyContactRelationship = _matchOptionValue(
      user.emergencyContactRelationship,
      _relationshipOptions,
    );
    _selectedIdentityProofType = _matchOptionValue(
      user.identityProofType,
      _identityProofOptions,
    );
    _selectedReportingManagerId = user.reportingManagerId;

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

  Future<Map<String, String?>> _uploadSelectedFiles() async {
    Future<String?> uploadIfPresent(Uint8List? bytes, String fileName) async {
      final fileBytes = bytes;
      if (fileBytes == null || fileBytes.isEmpty) {
        return null;
      }

      final uploadedUrl = await _apiService.uploadFile(
        fileBytes: fileBytes,
        fileName: fileName,
      );
      if (uploadedUrl == null || uploadedUrl.trim().isEmpty) {
        throw const ApiException(message: 'File upload did not return a URL.');
      }
      return uploadedUrl.trim();
    }

    return {
      'profile_photo': await uploadIfPresent(_photoBytes, 'profile-photo.png'),
      'identity_proof_file': await uploadIfPresent(
        _identityProofBytes,
        'identity-proof.png',
      ),
      'resume_cv': await uploadIfPresent(_resumeBytes, 'resume-cv.png'),
      'offer_letter': await uploadIfPresent(
        _offerLetterBytes,
        'offer-letter.png',
      ),
      'appointment_letter': await uploadIfPresent(
        _appointmentLetterBytes,
        'appointment-letter.png',
      ),
      'experience_certificates': await uploadIfPresent(
        _experienceCertificatesBytes,
        'experience-certificates.png',
      ),
      'educational_certificates': await uploadIfPresent(
        _educationalCertificatesBytes,
        'educational-certificates.png',
      ),
    };
  }

  UpdateUserRequest _buildUpdateUserRequest(
    Map<String, String?> uploadedFiles,
  ) {
    return UpdateUserRequest(
      name:
          _nullableText(_displayNameController.text) ??
          _nullableText(
            '${_firstNameController.text} ${_lastNameController.text}',
          ) ??
          _nullableText(_nameController.text),
      email:
          _nullableText(_officialEmailController.text) ??
          _nullableText(_personalEmailController.text),
      username: _nullableText(_usernameController.text),
      phone: _nullableText(_phoneController.text),
      employeeId: _nullableText(_employeeIdController.text),
      firstName: _nullableText(_firstNameController.text),
      lastName: _nullableText(_lastNameController.text),
      displayName: _nullableText(_displayNameController.text),
      gender: _slugifyValue(_selectedGender),
      dateOfBirth: _parseFlexibleDate(_dobController.text),
      maritalStatus: _slugifyValue(_selectedMaritalStatus),
      bloodGroup: _nullableText(_selectedBloodGroup),
      nationality: _nullableText(_selectedNationality),
      alternateMobileNumber: _nullableText(_alternatePhoneController.text),
      personalEmail: _nullableText(_personalEmailController.text),
      emergencyContactName: _nullableText(_emergencyContactNameController.text),
      emergencyContactNumber: _nullableText(
        _emergencyContactNumberController.text,
      ),
      emergencyContactRelationship: _nullableText(
        _emergencyContactRelationshipController.text,
      ),
      currentAddress: _nullableText(_addressController.text),
      permanentAddress: _nullableText(_permanentAddressController.text),
      city: _nullableText(_cityController.text),
      state: _nullableText(_stateController.text),
      country: _nullableText(_countryController.text),
      pinZipCode: _nullableText(_pinCodeController.text),
      designation: _nullableText(_designationController.text),
      reportingManagerId: _selectedReportingManagerId,
      employmentType: _slugifyValue(_employmentTypeController.text),
      dateOfJoining: _parseFlexibleDate(_dateOfJoiningController.text),
      dateOfExit: _parseFlexibleDate(_dateOfExitController.text),
      workLocation: _nullableText(_workLocationController.text),
      shift: _slugifyValue(_selectedShift),
      employeeStatus: _slugifyValue(_selectedEmployeeStatus),
      basicSalary: num.tryParse(_basicSalaryController.text.trim()),
      bankName: _nullableText(_selectedBankName),
      accountNumber: _nullableText(_accountNumberController.text),
      ifscSwiftCode: _nullableText(_ifscCodeController.text),
      accountHolderName: _nullableText(_accountHolderController.text),
      upiId: _nullableText(_upiIdController.text),
      profilePhoto: uploadedFiles['profile_photo'],
      identityProofType: _nullableText(_selectedIdentityProofType),
      identityProofFile: uploadedFiles['identity_proof_file'],
      resumeCv: uploadedFiles['resume_cv'],
      offerLetter: uploadedFiles['offer_letter'],
      appointmentLetter: uploadedFiles['appointment_letter'],
      experienceCertificates: uploadedFiles['experience_certificates'],
      educationalCertificates: uploadedFiles['educational_certificates'],
      skills: _skillsList(),
      language: _nullableText(_selectedLanguage),
      timeZone: _nullableText(_selectedTimeZone),
      status: _slugifyValue(_selectedStatus),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final uploadedFiles = await _uploadSelectedFiles();
      if (widget.isEditMode) {
        final userId = _effectiveUserId;
        if (userId.isEmpty) {
          throw const ApiException(message: 'Missing user id.');
        }

        await _apiService.updateUser(
          userId: userId,
          request: _buildUpdateUserRequest(uploadedFiles),
        );
      } else {
        final selectedRole = _selectedRole;
        await _apiService.createUser(
          request: CreateUserRequest(
            name:
                _nullableText(_displayNameController.text) ??
                _nullableText(
                  '${_firstNameController.text} ${_lastNameController.text}',
                ),
            email:
                _nullableText(_officialEmailController.text) ??
                _nullableText(_personalEmailController.text),
            username: _nullableText(_usernameController.text),
            phone: _nullableText(_phoneController.text),
            password: _nullableText(_passwordController.text),
            confirmPassword:
                _nullableText(_confirmPasswordController.text) ??
                _nullableText(_passwordController.text),
            employeeId: _nullableText(_employeeIdController.text),
            firstName: _nullableText(_firstNameController.text),
            lastName: _nullableText(_lastNameController.text),
            displayName: _nullableText(_displayNameController.text),
            gender: _slugifyValue(_selectedGender),
            dateOfBirth: _parseFlexibleDate(_dobController.text),
            maritalStatus: _slugifyValue(_selectedMaritalStatus),
            bloodGroup: _nullableText(_selectedBloodGroup),
            nationality: _nullableText(_selectedNationality),
            alternateMobileNumber: _nullableText(
              _alternatePhoneController.text,
            ),
            personalEmail: _nullableText(_personalEmailController.text),
            emergencyContactName: _nullableText(
              _emergencyContactNameController.text,
            ),
            emergencyContactNumber: _nullableText(
              _emergencyContactNumberController.text,
            ),
            emergencyContactRelationship: _nullableText(
              _emergencyContactRelationshipController.text,
            ),
            currentAddress: _nullableText(_addressController.text),
            permanentAddress: _nullableText(_permanentAddressController.text),
            city: _nullableText(_cityController.text),
            state: _nullableText(_stateController.text),
            country: _nullableText(_countryController.text),
            pinZipCode: _nullableText(_pinCodeController.text),
            designation: _nullableText(_designationController.text),
            reportingManagerId: _selectedReportingManagerId,
            employmentType:
                _slugifyValue(_employmentTypeController.text) ?? 'full_time',
            dateOfJoining: _parseFlexibleDate(_dateOfJoiningController.text),
            dateOfExit: _parseFlexibleDate(_dateOfExitController.text),
            workLocation: _nullableText(_workLocationController.text),
            shift: _slugifyValue(_selectedShift),
            employeeStatus: _slugifyValue(_selectedEmployeeStatus),
            basicSalary: num.tryParse(_basicSalaryController.text.trim()),
            bankName: _nullableText(_selectedBankName),
            accountNumber: _nullableText(_accountNumberController.text),
            ifscSwiftCode: _nullableText(_ifscCodeController.text),
            accountHolderName: _nullableText(_accountHolderController.text),
            upiId: _nullableText(_upiIdController.text),
            profilePhoto: uploadedFiles['profile_photo'],
            identityProofType: _nullableText(_selectedIdentityProofType),
            identityProofFile: uploadedFiles['identity_proof_file'],
            resumeCv: uploadedFiles['resume_cv'],
            offerLetter: uploadedFiles['offer_letter'],
            appointmentLetter: uploadedFiles['appointment_letter'],
            experienceCertificates: uploadedFiles['experience_certificates'],
            educationalCertificates: uploadedFiles['educational_certificates'],
            skills: _skillsList(),
            language: _nullableText(_selectedLanguage),
            timeZone: _nullableText(_selectedTimeZone),
            status: _slugifyValue(_selectedStatus),
            roleId: _nullableText(selectedRole?.id),
            role: selectedRole == null
                ? null
                : _nullableText(_roleSlugFromLabel(selectedRole.name)),
          ),
        );
      }

      if (!mounted) return;
      _nameController.text = _displayNameController.text.trim().isEmpty
          ? '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                .trim()
          : _displayNameController.text.trim();
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

  void _nextStep() {
    if (_currentStep >= _steps.length - 1) {
      _submit();
      return;
    }
    setState(() => _currentStep += 1);
  }

  void _previousStep() {
    if (_currentStep <= 0) return;
    setState(() => _currentStep -= 1);
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

                    final stepperPanel = _buildStepperPanel(wide: wide);
                    final contentPanel = _buildContentPanel(wide: wide);

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
                            SizedBox(width: 300, child: stepperPanel),
                            const SizedBox(width: 18),
                            Expanded(child: contentPanel),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        stepperPanel,
                        const SizedBox(height: 16),
                        contentPanel,
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

  Widget _buildStepperPanel({required bool wide}) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff Setup',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Complete the staff profile in 8 steps.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_steps.length, (index) {
                final step = _steps[index];
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                final isLast = index == _steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _currentStep = index),
                      borderRadius: BorderRadius.circular(999),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isActive || isCompleted
                                  ? AppColors.primary
                                  : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : Icon(
                                    step.icon,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _stepShortLabel(step.title),
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: 56,
                          height: 2,
                          color: index < _currentStep
                              ? AppColors.primary
                              : const Color(0xFFD8DFE6),
                        ),
                      ),
                    if (!isLast) const SizedBox(width: 2),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _stepShortLabel(String title) {
    switch (title) {
      case 'Basic Information':
        return 'Basic Info';
      case 'Contact Information':
        return 'Contact Info';
      case 'Address Information':
        return 'Address';
      case 'Employment Information':
        return 'Employment';
      case 'Login & Security':
        return 'Login';
      case 'Payroll Information':
        return 'Payroll';
      case 'System Preferences':
        return 'Preferences';
      default:
        return title;
    }
  }

  Widget _buildContentPanel({required bool wide}) {
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
          _stepHeader(_steps[_currentStep]),
          const SizedBox(height: 18),
          _buildStepBody(wide: wide),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : (_currentStep == 0
                          ? () => Navigator.of(context).pop()
                          : _previousStep),
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
                child: Text(
                  _currentStep == 0 ? 'Cancel' : 'Back',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _nextStep,
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
                        _currentStep == _steps.length - 1
                            ? _submitLabel
                            : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepHeader(_StaffWizardStep step) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${_currentStep + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          step.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStepBody({required bool wide}) {
    switch (_currentStep) {
      case 0:
        return _basicInformationCard(wide: wide);
      case 1:
        return _contactInformationCard(wide: wide);
      case 2:
        return _addressInformationCard(wide: wide);
      case 3:
        return _employmentInformationCard(wide: wide);
      case 4:
        return _loginSecurityCard(wide: wide);
      case 5:
        return _payrollInformationCard(wide: wide);
      case 6:
        return _uploadsInformationCard(wide: wide);
      case 7:
      default:
        return _systemPreferencesCard(wide: wide);
    }
  }

  Widget _twoColumnFields({
    required bool wide,
    required List<Widget> children,
  }) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map(
            (child) => SizedBox(
              width:
                  (MediaQuery.of(context).size.width > 1200
                          ? 1200
                          : MediaQuery.of(context).size.width) /
                      2 -
                  32,
              child: child,
            ),
          )
          .toList(),
    );
  }

  Widget _basicInformationCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'Basic Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Employee identity and personal profile details.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _photoUploadCard(),
          const SizedBox(height: 16),
          _fieldBlock(
            'First Name *',
            _textField(controller: _firstNameController, hintText: ''),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Last Name *',
            _textField(controller: _lastNameController, hintText: ''),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Display Name',
            _textField(controller: _displayNameController, hintText: ''),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Gender',
            _dropdownField(
              value: _selectedGender,
              hintText: 'Select...',
              items: _genderOptions,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Date of Birth',
            _dateField(controller: _dobController, hintText: 'Select date'),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Marital Status',
            _dropdownField(
              value: _selectedMaritalStatus,
              hintText: 'Select...',
              items: _maritalOptions,
              onChanged: (value) =>
                  setState(() => _selectedMaritalStatus = value),
            ),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Blood Group',
            _dropdownField(
              value: _selectedBloodGroup,
              hintText: 'Select...',
              items: _bloodOptions,
              onChanged: (value) => setState(() => _selectedBloodGroup = value),
            ),
          ),
          const SizedBox(height: 16),
          _fieldBlock(
            'Nationality',
            _dropdownField(
              value: _selectedNationality,
              hintText: 'Select...',
              items: _nationalityOptions,
              onChanged: (value) =>
                  setState(() => _selectedNationality = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactInformationCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'Contact Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Primary, secondary, and emergency contact details.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _fieldBlock(
                'Mobile Number *',
                _textField(
                  controller: _phoneController,
                  hintText: '',
                  keyboardType: TextInputType.phone,
                ),
              ),
              _fieldBlock(
                'Alternate Mobile Number',
                _textField(
                  controller: _alternatePhoneController,
                  hintText: '',
                  keyboardType: TextInputType.phone,
                ),
              ),
              _fieldBlock(
                'Personal Email',
                _textField(
                  controller: _personalEmailController,
                  hintText: '',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              _fieldBlock(
                'Official Email *',
                _textField(
                  controller: _officialEmailController,
                  hintText: '',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              _fieldBlock(
                'Emergency Contact Name',
                _textField(
                  controller: _emergencyContactNameController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'Emergency Contact Number',
                _textField(
                  controller: _emergencyContactNumberController,
                  hintText: '',
                  keyboardType: TextInputType.phone,
                ),
              ),
              _fieldBlock(
                'Emergency Contact Relationship',
                DropdownButtonFormField<String>(
                  initialValue: _selectedEmergencyContactRelationship,
                  isExpanded: true,
                  menuMaxHeight: 280,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textLightMuted,
                  ),
                  hint: const Text(
                    'Select...',
                    style: TextStyle(color: AppColors.textLightMuted),
                  ),
                  decoration: _inputDecoration(''),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  items: _relationshipOptions
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEmergencyContactRelationship = value;
                      _emergencyContactRelationshipController.text =
                          value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressInformationCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'Address Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Residential and regional address details.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _fieldBlock(
                'Current Address',
                _textField(
                  controller: _addressController,
                  hintText: '',
                  maxLines: 4,
                ),
              ),
              _fieldBlock(
                'Permanent Address',
                _textField(
                  controller: _permanentAddressController,
                  hintText: '',
                  maxLines: 4,
                ),
              ),
              CSCPicker(
                layout: Layout.vertical,
                showStates: true,
                showCities: true,
                flagState: CountryFlag.DISABLE,
                currentCountry: _countryController.text,
                currentState: _stateController.text,
                currentCity: _cityController.text,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.surfaceSoft.withValues(alpha: 0.28),
                  border: Border.all(
                    color: AppColors.borderStrong.withValues(alpha: 0.25),
                  ),
                ),
                disabledDropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.surfaceSoft.withValues(alpha: 0.28),
                  border: Border.all(
                    color: AppColors.borderStrong.withValues(alpha: 0.25),
                  ),
                ),
                selectedItemStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                dropdownHeadingStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                dropdownItemStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                dropdownDialogRadius: 12,
                searchBarRadius: 12,
                countryDropdownLabel: 'Select Country',
                stateDropdownLabel: 'Select State',
                cityDropdownLabel: 'Select City',
                countrySearchPlaceholder: 'Search country',
                stateSearchPlaceholder: 'Search state',
                citySearchPlaceholder: 'Search city',
                onCountryChanged: (value) {
                  setState(() {
                    _countryController.text = value;
                    _stateController.clear();
                    _cityController.clear();
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    _stateController.text = value ?? '';
                    _cityController.clear();
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    _cityController.text = value ?? '';
                  });
                },
              ),
              _fieldBlock(
                'PIN/ZIP Code',
                _textField(
                  controller: _pinCodeController,
                  hintText: '',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _employmentInformationCard({required bool wide}) {
    return FutureBuilder<List<RoleModel>>(
      future: _rolesFuture,
      builder: (context, rolesSnapshot) {
        final roles = rolesSnapshot.data ?? const <RoleModel>[];
        return FutureBuilder<List<AppUser>>(
          future: _usersFuture,
          builder: (context, usersSnapshot) {
            final users = usersSnapshot.data ?? const <AppUser>[];

            return Container(
              width: double.infinity,
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
                  const Text(
                    'Employment Information',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Role, reporting, joining, location, and employee status.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.borderStrong),
                  const SizedBox(height: 18),
                  _twoColumnFields(
                    wide: wide,
                    children: [
                      _fieldBlock(
                        'Role *',
                        rolesSnapshot.connectionState == ConnectionState.waiting
                            ? _loadingField()
                            : _roleDropdown(roles),
                      ),
                      _fieldBlock(
                        'Designation *',
                        _textField(
                          controller: _designationController,
                          hintText: '',
                        ),
                      ),
                      _fieldBlock(
                        'Reporting Manager',
                        usersSnapshot.connectionState == ConnectionState.waiting
                            ? _loadingField()
                            : _reportingManagerDropdown(users),
                      ),
                      _fieldBlock(
                        'Employment Type *',
                        _dropdownField<String>(
                          value: _employmentTypeController.text.isEmpty
                              ? null
                              : _employmentTypeController.text,
                          hintText: 'Select...',
                          items: const [
                            'Full Time',
                            'Part Time',
                            'Contract',
                            'Intern',
                            'Temporary',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _employmentTypeController.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      _fieldBlock(
                        'Date of Joining *',
                        _dateField(
                          controller: _dateOfJoiningController,
                          hintText: 'dd-mm-yyyy',
                        ),
                      ),
                      _fieldBlock(
                        'Date of Exit',
                        _dateField(
                          controller: _dateOfExitController,
                          hintText: 'dd-mm-yyyy',
                        ),
                      ),
                      _fieldBlock(
                        'Work Location',
                        _textField(
                          controller: _workLocationController,
                          hintText: '',
                        ),
                      ),
                      _fieldBlock(
                        'Shift',
                        _dropdownField<String>(
                          value: _selectedShift,
                          hintText: 'Select...',
                          items: const ['Morning', 'Day', 'Night', 'Flexible'],
                          onChanged: (value) {
                            setState(() => _selectedShift = value);
                          },
                        ),
                      ),
                      _fieldBlock(
                        'Employment Status *',
                        _dropdownField<String>(
                          value: _selectedEmployeeStatus,
                          hintText: '',
                          items: const [
                            'Active',
                            'Probation',
                            'On Leave',
                            'Notice Period',
                            'Resigned',
                            'Terminated',
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedEmployeeStatus = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _payrollInformationCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'Payroll Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Salary bank and payment details.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _fieldBlock(
                'Basic Salary',
                _textField(
                  controller: _basicSalaryController,
                  hintText: '',
                  keyboardType: TextInputType.number,
                ),
              ),
              _fieldBlock(
                'Bank Name',
                _dropdownField<String>(
                  value: _selectedBankName,
                  hintText: 'Select...',
                  items: _bankOptions,
                  onChanged: (value) {
                    setState(() => _selectedBankName = value);
                  },
                ),
              ),
              _fieldBlock(
                'Account Number',
                _textField(
                  controller: _accountNumberController,
                  hintText: '',
                  keyboardType: TextInputType.number,
                ),
              ),
              _fieldBlock(
                'IFSC/SWIFT Code',
                _textField(controller: _ifscCodeController, hintText: ''),
              ),
              _fieldBlock(
                'Account Holder Name',
                _textField(controller: _accountHolderController, hintText: ''),
              ),
              _fieldBlock(
                'UPI ID',
                _textField(controller: _upiIdController, hintText: ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loginSecurityCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'Login & Security',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Authentication credentials and invitation settings.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _fieldBlock(
                'Username *',
                _textField(
                  controller: _usernameController,
                  hintText: '',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              _fieldBlock('Password *', _passwordField()),
              _fieldBlock('Confirm Password *', _confirmPasswordField()),
              _securityNotificationCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityNotificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        checkColor: Colors.white,
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

  Widget _photoUploadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Photo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _profilePhotoPreview(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _removePhoto,
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.borderStrong),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePhotoPreview() {
    final content = _photoBytes == null
        ? const Center(
            child: Text(
              'Preview',
              style: TextStyle(
                color: AppColors.textLightMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Image.memory(
            _photoBytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

    return Center(
      child: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderStrong.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }

  Widget _uploadsInformationCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'Uploads',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Compliance, onboarding, and qualification documents.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _staffUploadCard(
                title: 'Identity Proof *',
                secondaryWidget: _dropdownField<String>(
                  value: _selectedIdentityProofType,
                  hintText: 'Select...',
                  items: _identityProofOptions,
                  onChanged: (value) {
                    setState(() => _selectedIdentityProofType = value);
                  },
                ),
                bytes: _identityProofBytes,
                onUpload: () => _pickUploadFile(_StaffUploadSlot.identityProof),
                onRemove: () =>
                    _removeUploadFile(_StaffUploadSlot.identityProof),
              ),
              _staffUploadCard(
                title: 'Resume/CV',
                mimeHint: 'application/pdf,image/*',
                bytes: _resumeBytes,
                onUpload: () => _pickUploadFile(_StaffUploadSlot.resumeCv),
                onRemove: () => _removeUploadFile(_StaffUploadSlot.resumeCv),
              ),
              _staffUploadCard(
                title: 'Offer Letter',
                mimeHint: 'application/pdf,image/*',
                bytes: _offerLetterBytes,
                onUpload: () => _pickUploadFile(_StaffUploadSlot.offerLetter),
                onRemove: () => _removeUploadFile(_StaffUploadSlot.offerLetter),
              ),
              _staffUploadCard(
                title: 'Appointment Letter',
                mimeHint: 'application/pdf,image/*',
                bytes: _appointmentLetterBytes,
                onUpload: () =>
                    _pickUploadFile(_StaffUploadSlot.appointmentLetter),
                onRemove: () =>
                    _removeUploadFile(_StaffUploadSlot.appointmentLetter),
              ),
              _staffUploadCard(
                title: 'Experience Certificates',
                mimeHint: 'application/pdf,image/*',
                bytes: _experienceCertificatesBytes,
                onUpload: () =>
                    _pickUploadFile(_StaffUploadSlot.experienceCertificates),
                onRemove: () =>
                    _removeUploadFile(_StaffUploadSlot.experienceCertificates),
              ),
              _staffUploadCard(
                title: 'Educational Certificates',
                mimeHint: 'application/pdf,image/*',
                bytes: _educationalCertificatesBytes,
                onUpload: () =>
                    _pickUploadFile(_StaffUploadSlot.educationalCertificates),
                onRemove: () =>
                    _removeUploadFile(_StaffUploadSlot.educationalCertificates),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _fieldBlock(
            'Skills',
            _textField(
              controller: _skillsController,
              hintText: 'Separate skills with commas',
            ),
          ),
        ],
      ),
    );
  }

  Widget _systemPreferencesCard({required bool wide}) {
    return Container(
      width: double.infinity,
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
          const Text(
            'System Preferences',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Application language, timezone, and account status.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _fieldBlock(
                'Language',
                _dropdownField<String>(
                  value: _selectedLanguage,
                  hintText: 'Select...',
                  items: _languageOptions,
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value),
                ),
              ),
              _fieldBlock(
                'Time Zone',
                _dropdownField<String>(
                  value: _selectedTimeZone,
                  hintText: 'Select...',
                  items: _timeZoneOptions,
                  onChanged: (value) =>
                      setState(() => _selectedTimeZone = value),
                ),
              ),
              _fieldBlock(
                'Status *',
                _dropdownField<String>(
                  value: _selectedStatus,
                  hintText: 'Select...',
                  items: _statusOptions,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _staffUploadCard({
    required String title,
    String? mimeHint,
    Widget? secondaryWidget,
    required Uint8List? bytes,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3EA)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final preview = Container(
            width: compact ? double.infinity : 120,
            height: compact ? 110 : 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E4E8)),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: bytes == null
                ? const Text(
                    'Preview',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Image.memory(bytes, fit: BoxFit.cover),
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CAD84),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: bytes == null ? null : onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9CA3AF),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (secondaryWidget != null) ...[
                const SizedBox(height: 10),
                secondaryWidget,
              ] else if (mimeHint != null && mimeHint.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  mimeHint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              actions,
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [preview, const SizedBox(height: 12), details],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              const SizedBox(width: 16),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }

  Widget _fieldLabel(String label) {
    final requiredMark = label.contains('*');
    final cleaned = label.replaceAll('*', '').trim();
    return requiredMark
        ? RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: cleaned),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
              ],
            ),
          )
        : Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          );
  }

  Widget _dropdownField<T>({
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      isExpanded: true,
      menuMaxHeight: 280,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textLightMuted,
      ),
      hint: hintText == null
          ? null
          : Text(
              hintText,
              style: const TextStyle(color: AppColors.textLightMuted),
            ),
      decoration: _inputDecoration(''),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                '$item',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
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
    int maxLines = 1,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _inputDecoration(hintText, suffixIcon: suffixIcon),
    );
  }

  Widget _dateField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return _textField(
      controller: controller,
      hintText: hintText,
      readOnly: true,
      onTap: () => _pickDate(controller),
      suffixIcon: IconButton(
        onPressed: () => _pickDate(controller),
        icon: const Icon(
          Icons.calendar_month_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _loadingField() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.45),
        ),
      ),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _roleDropdown(List<RoleModel> roles) {
    final selectedRole = _selectedRole;
    final initialRoleId = roles.any((role) => role.id == selectedRole?.id)
        ? selectedRole?.id
        : null;
    return DropdownButtonFormField<String>(
      initialValue: initialRoleId,
      isExpanded: true,
      menuMaxHeight: 280,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textLightMuted,
      ),
      hint: const Text(
        'Select...',
        style: TextStyle(color: AppColors.textLightMuted),
      ),
      decoration: _inputDecoration(''),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: roles
          .map(
            (role) => DropdownMenuItem<String>(
              value: role.id,
              child: Text(
                role.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          setState(() => _selectedRole = null);
          return;
        }

        final match = roles.firstWhere(
          (role) => role.id == value,
          orElse: () => roles.first,
        );
        setState(() => _selectedRole = match);
      },
    );
  }

  Widget _reportingManagerDropdown(List<AppUser> users) {
    final selectedId = _selectedReportingManagerId;
    final initialUserId = users.any((user) => user.id == selectedId)
        ? selectedId
        : null;
    return DropdownButtonFormField<String>(
      initialValue: initialUserId,
      isExpanded: true,
      menuMaxHeight: 280,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textLightMuted,
      ),
      hint: const Text(
        'Select...',
        style: TextStyle(color: AppColors.textLightMuted),
      ),
      decoration: _inputDecoration(''),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: users
          .map(
            (user) => DropdownMenuItem<String>(
              value: user.id,
              child: Text(
                user.name.trim().isNotEmpty ? user.name : user.email,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          setState(() {
            _selectedReportingManagerId = null;
            _reportingManagerController.clear();
          });
          return;
        }

        final selectedUser = users.firstWhere(
          (user) => user.id == value,
          orElse: () => users.first,
        );
        setState(() {
          _selectedReportingManagerId = selectedUser.id;
          _reportingManagerController.text = selectedUser.name;
        });
      },
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

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: _inputDecoration(
        '',
        suffixIcon: IconButton(
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initialDate = _parseFlexibleDate(controller.text) ?? DateTime.now();
    final today = DateTime.now();
    final earliest = DateTime(1900, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: earliest,
      lastDate: today,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      controller.text = _formatDateForInput(picked);
    });
  }

  String _formatDateForInput(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
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

class _StaffWizardStep {
  final String title;
  final IconData icon;

  const _StaffWizardStep(this.title, this.icon);
}

enum _StaffUploadSlot {
  identityProof,
  resumeCv,
  offerLetter,
  appointmentLetter,
  experienceCertificates,
  educationalCertificates,
}

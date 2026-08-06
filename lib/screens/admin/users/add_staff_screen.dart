import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../models/auth_models.dart';
import '../../../models/role_model.dart';
import '../../../providers/api_provider.dart';
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
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _designationController =
      TextEditingController(text: 'Sales Officer');
  final TextEditingController _reportingManagerController =
      TextEditingController();
  final TextEditingController _employmentTypeController =
      TextEditingController();
  final TextEditingController _dateOfJoiningController =
      TextEditingController();
  final TextEditingController _dateOfExitController =
      TextEditingController();
  final TextEditingController _workLocationController =
      TextEditingController();
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
  AppUser? _editingUser;
  bool _sendNotification = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _isLoadingEditUser = false;
  String? _editLoadError;
  int _currentStep = 0;
  String? _selectedLanguage;
  String? _selectedTimeZone;
  String _selectedStatus = 'Active';
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedBloodGroup;
  String? _selectedNationality;
  String? _selectedBankName;
  Uint8List? _photoBytes;
  String? _photoName;
  Uint8List? _identityProofBytes;
  String? _identityProofName;
  Uint8List? _resumeBytes;
  String? _resumeName;
  Uint8List? _offerLetterBytes;
  String? _offerLetterName;
  Uint8List? _appointmentLetterBytes;
  String? _appointmentLetterName;
  Uint8List? _experienceCertificatesBytes;
  String? _experienceCertificatesName;
  Uint8List? _educationalCertificatesBytes;
  String? _educationalCertificatesName;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rolesFuture ??= ApiProviderScope.of(context).fetchRoles();
    if (widget.isEditMode && _editingUser == null && !_isLoadingEditUser) {
      _loadEditUser();
    }
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingUser;
    if (existing != null) {
      _applyUser(existing);
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
      setState(() => _editingUser = user);
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
        _photoName = picked.name;
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
      _photoName = null;
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
            _identityProofName = picked.name;
            break;
          case _StaffUploadSlot.resumeCv:
            _resumeBytes = bytes;
            _resumeName = picked.name;
            break;
          case _StaffUploadSlot.offerLetter:
            _offerLetterBytes = bytes;
            _offerLetterName = picked.name;
            break;
          case _StaffUploadSlot.appointmentLetter:
            _appointmentLetterBytes = bytes;
            _appointmentLetterName = picked.name;
            break;
          case _StaffUploadSlot.experienceCertificates:
            _experienceCertificatesBytes = bytes;
            _experienceCertificatesName = picked.name;
            break;
          case _StaffUploadSlot.educationalCertificates:
            _educationalCertificatesBytes = bytes;
            _educationalCertificatesName = picked.name;
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
          _identityProofName = null;
          break;
        case _StaffUploadSlot.resumeCv:
          _resumeBytes = null;
          _resumeName = null;
          break;
        case _StaffUploadSlot.offerLetter:
          _offerLetterBytes = null;
          _offerLetterName = null;
          break;
        case _StaffUploadSlot.appointmentLetter:
          _appointmentLetterBytes = null;
          _appointmentLetterName = null;
          break;
        case _StaffUploadSlot.experienceCertificates:
          _experienceCertificatesBytes = null;
          _experienceCertificatesName = null;
          break;
        case _StaffUploadSlot.educationalCertificates:
          _educationalCertificatesBytes = null;
          _educationalCertificatesName = null;
          break;
      }
    });
  }

  void _applyUser(AppUser user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _officialEmailController.text = user.email;
    _personalEmailController.text = user.email;
    _usernameController.text = user.username ?? user.email;
    _phoneController.text = user.phone ?? '';
    _displayNameController.text = user.name;

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

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      if (widget.isEditMode) {
        final userId = _effectiveUserId;
        if (userId.isEmpty) {
          throw const ApiException(message: 'Missing user id.');
        }

        await _apiService.updateUser(
          userId: userId,
          request: UpdateUserRequest(
            name: _nameController.text.trim(),
            email: _officialEmailController.text.trim(),
            username: _usernameController.text.trim().isEmpty
                ? _officialEmailController.text.trim()
                : _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
        );
      } else {
        final selectedRole = _selectedRole;
        await _apiService.createUser(
          request: CreateUserRequest(
            name: _nameController.text.trim(),
            email: _officialEmailController.text.trim(),
            username: _usernameController.text.trim().isEmpty
                ? _officialEmailController.text.trim()
                : _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            roleId: selectedRole?.id.trim() ?? '',
            role: selectedRole == null
                ? ''
                : _roleSlugFromLabel(selectedRole.name),
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
                                        color: AppColors.primary
                                            .withValues(alpha: 0.18),
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
              width: (MediaQuery.of(context).size.width > 1200
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _photoUploadCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: _fieldBlock(
                  'Employee ID *',
                  _textField(
                    controller: _employeeIdController,
                    hintText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _twoColumnFields(
            wide: wide,
            children: [
              _fieldBlock(
                'First Name *',
                _textField(
                  controller: _firstNameController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'Last Name *',
                _textField(
                  controller: _lastNameController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'Display Name',
                _textField(
                  controller: _displayNameController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'Gender',
                _dropdownField(
                  value: _selectedGender,
                  hintText: 'Select...',
                  items: _genderOptions,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
              ),
              _fieldBlock(
                'Date of Birth',
                _textField(
                  controller: _dobController,
                  hintText: 'dd-mm-yyyy',
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
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
              _fieldBlock(
                'Blood Group',
                _dropdownField(
                  value: _selectedBloodGroup,
                  hintText: 'Select...',
                  items: _bloodOptions,
                  onChanged: (value) =>
                      setState(() => _selectedBloodGroup = value),
                ),
              ),
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
                _textField(
                  controller: _emergencyContactRelationshipController,
                  hintText: '',
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
              _fieldBlock(
                'City',
                _textField(
                  controller: _cityController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'State',
                _textField(
                  controller: _stateController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'Country',
                _dropdownField<String>(
                  value: null,
                  hintText: 'Select...',
                  items: const [
                    'India',
                    'United States',
                    'United Kingdom',
                    'Canada',
                    'Australia',
                  ],
                  onChanged: (_) {},
                ),
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
                'Designation *',
                _dropdownField<String>(
                  value: _designationController.text.isEmpty
                      ? null
                      : _designationController.text,
                  hintText: 'Select...',
                  items: const [
                    'Sales Officer',
                    'Accountant',
                    'Admin',
                    'Manager',
                    'HR',
                    'Director',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _designationController.text = value ?? '';
                    });
                  },
                ),
              ),
              _fieldBlock(
                'Reporting Manager',
                _textField(
                  controller: _reportingManagerController,
                  hintText: 'Select...',
                ),
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
                _textField(
                  controller: _dateOfJoiningController,
                  hintText: 'dd-mm-yyyy',
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _fieldBlock(
                'Date of Exit',
                _textField(
                  controller: _dateOfExitController,
                  hintText: 'dd-mm-yyyy',
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
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
                  value: null,
                  hintText: 'Select...',
                  items: const [
                    'Morning',
                    'Day',
                    'Night',
                    'Flexible',
                  ],
                  onChanged: (_) {},
                ),
              ),
              _fieldBlock(
                'Employee Status *',
                _dropdownField<String>(
                  value: 'Active',
                  hintText: '',
                  items: const ['Active', 'Inactive', 'Suspended'],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
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
                _textField(
                  controller: _ifscCodeController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'Account Holder Name',
                _textField(
                  controller: _accountHolderController,
                  hintText: '',
                ),
              ),
              _fieldBlock(
                'UPI ID',
                _textField(
                  controller: _upiIdController,
                  hintText: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loginSecurityCard({required bool wide}) {
    if (_usernameController.text.trim().isEmpty &&
        _officialEmailController.text.trim().isNotEmpty) {
      _usernameController.text = _officialEmailController.text.trim();
    }

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
              _fieldBlock(
                'Password *',
                _passwordField(),
              ),
              _fieldBlock(
                'Confirm Password *',
                _confirmPasswordField(),
              ),
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
        checkColor: AppColors.primary,
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
        border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.35)),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderStrong.withValues(alpha: 0.45),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _photoBytes == null
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
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            ],
          ),
        ],
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
                title: 'Identity Proofs *',
                mimeHint: 'application/pdf,image/*',
                bytes: _identityProofBytes,
                onUpload: () => _pickUploadFile(_StaffUploadSlot.identityProof),
                onRemove: () => _removeUploadFile(_StaffUploadSlot.identityProof),
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
                onUpload: () => _pickUploadFile(
                  _StaffUploadSlot.experienceCertificates,
                ),
                onRemove: () => _removeUploadFile(
                  _StaffUploadSlot.experienceCertificates,
                ),
              ),
              _staffUploadCard(
                title: 'Educational Certificates',
                mimeHint: 'application/pdf,image/*',
                bytes: _educationalCertificatesBytes,
                onUpload: () => _pickUploadFile(
                  _StaffUploadSlot.educationalCertificates,
                ),
                onRemove: () => _removeUploadFile(
                  _StaffUploadSlot.educationalCertificates,
                ),
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
    required String mimeHint,
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
                : Image.memory(bytes!, fit: BoxFit.cover),
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
              const SizedBox(height: 4),
              Text(
                mimeHint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              actions,
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                preview,
                const SizedBox(height: 12),
                details,
              ],
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

  Widget _infoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      decoration: _inputDecoration(hintText, suffixIcon: suffixIcon),
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

  Widget _roleDropdown(List<RoleModel> roles) {
    final selectedRole = _selectedRole;
    return DropdownButtonFormField<String>(
      initialValue: selectedRole?.id,
      onChanged: (value) {
        if (value != null) {
          final match = roles.firstWhere(
            (role) => role.id == value,
            orElse: () => roles.first,
          );
          setState(() => _selectedRole = match);
        }
      },
      decoration: _inputDecoration('Select role'),
      items: roles
          .map(
            (role) => DropdownMenuItem<String>(
              value: role.id,
              child: Text(role.name),
            ),
          )
          .toList(),
    );
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

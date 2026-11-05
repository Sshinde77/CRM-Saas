import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_user.dart';
import '../../models/auth_models.dart';
import '../../providers/api_provider.dart';
import '../../services/push_notification_service.dart';
import '../../widgets/app_calendar_date_picker.dart';
import '../../widgets/customer_avatar.dart';
import '../../widgets/delivery/delivery_image_upload_field.dart';
import '../../widgets/delivery/delivery_top_bar.dart';

/// Shared "My Profile" screen used by the Sales Manager and Delivery Partner
/// roles. Shows account, additional, organization and notification details
/// backed by the real user/session data.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];
  static const List<String> _bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  ApiProvider? _api;
  bool _loading = true;
  String? _loadError;
  AppUser? _user;
  AuthMeResponse? _authMe;
  Map<String, dynamic>? _organization;

  final ImagePicker _imagePicker = ImagePicker();
  bool _uploadingPhoto = false;

  bool _editingDetails = false;
  bool _savingDetails = false;
  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _displayNameC = TextEditingController();
  final _alternateMobileC = TextEditingController();
  final _personalEmailC = TextEditingController();
  final _emergencyNameC = TextEditingController();
  final _emergencyNumberC = TextEditingController();
  final _emergencyRelationC = TextEditingController();
  final _currentAddressC = TextEditingController();
  final _permanentAddressC = TextEditingController();
  final _cityC = TextEditingController();
  final _stateC = TextEditingController();
  final _countryC = TextEditingController();
  final _pinZipC = TextEditingController();
  final _languageC = TextEditingController();
  final _timeZoneC = TextEditingController();
  String? _gender;
  String? _maritalStatus;
  String? _bloodGroup;
  DateTime? _dob;

  final _currentPasswordC = TextEditingController();
  final _newPasswordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _changingPassword = false;

  bool? _pushPermissionGranted;
  bool _requestingPushPermission = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_api != null) return;
    _api = ApiProviderScope.of(context);
    _load();
    _loadPushStatus();
  }

  @override
  void dispose() {
    _firstNameC.dispose();
    _lastNameC.dispose();
    _displayNameC.dispose();
    _alternateMobileC.dispose();
    _personalEmailC.dispose();
    _emergencyNameC.dispose();
    _emergencyNumberC.dispose();
    _emergencyRelationC.dispose();
    _currentAddressC.dispose();
    _permanentAddressC.dispose();
    _cityC.dispose();
    _stateC.dispose();
    _countryC.dispose();
    _pinZipC.dispose();
    _languageC.dispose();
    _timeZoneC.dispose();
    _currentPasswordC.dispose();
    _newPasswordC.dispose();
    _confirmPasswordC.dispose();
    super.dispose();
  }

  Future<void> _loadPushStatus() async {
    final granted = await PushNotificationService.instance.hasPermission();
    if (mounted) setState(() => _pushPermissionGranted = granted);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final authMe = await _api!.fetchAuthMe(force: true);
      final meUser = authMe?.user;
      if (meUser == null || (meUser.id ?? '').trim().isEmpty) {
        throw StateError('Could not load the current user from the me API.');
      }
      final meUserData = <String, dynamic>{
        ...meUser.rawData,
        'id': meUser.id,
        'name': meUser.rawData['name'] ?? meUser.name,
        'email': meUser.rawData['email'] ?? meUser.email,
        'role': meUser.rawData['role'] ?? meUser.role,
        'profile_photo': meUser.rawData['profile_photo'] ?? meUser.profilePhoto,
      };
      final user = AppUser.fromJson(meUserData);
      Map<String, dynamic>? organization;
      try {
        organization = await _api!.service.fetchOrganizationMe();
      } catch (_) {
        organization = null;
      }
      if (!mounted) return;
      setState(() {
        _authMe = authMe;
        _user = user;
        _organization = organization;
        _loading = false;
      });
      _populateFormFromUser(user);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  void _populateFormFromUser(AppUser user) {
    _firstNameC.text = user.firstName ?? '';
    _lastNameC.text = user.lastName ?? '';
    _displayNameC.text = user.displayName ?? '';
    _alternateMobileC.text = user.alternateMobileNumber ?? '';
    _personalEmailC.text = user.personalEmail ?? '';
    _emergencyNameC.text = user.emergencyContactName ?? '';
    _emergencyNumberC.text = user.emergencyContactNumber ?? '';
    _emergencyRelationC.text = user.emergencyContactRelationship ?? '';
    _currentAddressC.text = user.currentAddress ?? '';
    _permanentAddressC.text = user.permanentAddress ?? '';
    _cityC.text = user.city ?? '';
    _stateC.text = user.state ?? '';
    _countryC.text = user.country ?? '';
    _pinZipC.text = user.pinZipCode ?? '';
    _languageC.text = user.language ?? '';
    _timeZoneC.text = user.timeZone ?? '';
    _gender = _optionOrNull(user.gender, _genderOptions);
    _maritalStatus = _optionOrNull(user.maritalStatus, _maritalStatusOptions);
    _bloodGroup = _optionOrNull(user.bloodGroup, _bloodGroupOptions);
    _dob = user.dateOfBirth;
  }

  String? _optionOrNull(String? value, List<String> options) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    for (final option in options) {
      if (option.toLowerCase() == trimmed.toLowerCase()) return option;
    }
    return null;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showAppCalendarDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
      title: 'Date of Birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickProfilePhoto() async {
    if (_uploadingPhoto) return;
    final user = _user;
    if (user == null) return;
    final image = await showDeliveryImageSourcePicker(
      context: context,
      picker: _imagePicker,
      title: 'Update profile photo',
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    final Uint8List bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _uploadingPhoto = true);
    try {
      final uploaded = await _api!.uploadGenericFile(
        fileBytes: bytes,
        fileName: image.name,
      );
      final updated = await _api!.updateUser(
        userId: user.id,
        request: UpdateUserRequest(
          profilePhoto: uploaded.url ?? uploaded.fileId,
        ),
      );
      if (!mounted) return;
      setState(() => _user = updated);
      _showSnack('Profile photo updated');
    } catch (error) {
      if (mounted) _showSnack('Could not update photo: $error');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _saveDetails() async {
    final user = _user;
    if (user == null || _savingDetails) return;
    setState(() => _savingDetails = true);
    try {
      final updated = await _api!.updateUser(
        userId: user.id,
        request: UpdateUserRequest(
          firstName: _firstNameC.text,
          lastName: _lastNameC.text,
          displayName: _displayNameC.text,
          gender: _gender,
          dateOfBirth: _dob,
          maritalStatus: _maritalStatus,
          bloodGroup: _bloodGroup,
          alternateMobileNumber: _alternateMobileC.text,
          personalEmail: _personalEmailC.text,
          emergencyContactName: _emergencyNameC.text,
          emergencyContactNumber: _emergencyNumberC.text,
          emergencyContactRelationship: _emergencyRelationC.text,
          currentAddress: _currentAddressC.text,
          permanentAddress: _permanentAddressC.text,
          city: _cityC.text,
          state: _stateC.text,
          country: _countryC.text,
          pinZipCode: _pinZipC.text,
          language: _languageC.text,
          timeZone: _timeZoneC.text,
        ),
      );
      if (!mounted) return;
      setState(() {
        _user = updated;
        _editingDetails = false;
      });
      _populateFormFromUser(updated);
      _showSnack('Profile updated');
    } catch (error) {
      if (mounted) _showSnack('Could not save changes: $error');
    } finally {
      if (mounted) setState(() => _savingDetails = false);
    }
  }

  Future<void> _changePassword() async {
    if (_changingPassword) return;
    final current = _currentPasswordC.text;
    final next = _newPasswordC.text;
    final confirm = _confirmPasswordC.text;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      _showSnack('Fill in all password fields.');
      return;
    }
    if (next.length < 8) {
      _showSnack('New password must be at least 8 characters.');
      return;
    }
    if (next != confirm) {
      _showSnack('New password and confirmation do not match.');
      return;
    }

    setState(() => _changingPassword = true);
    try {
      await _api!.service.changePassword(
        request: ChangePasswordRequest(
          currentPassword: current,
          newPassword: next,
        ),
      );
      if (!mounted) return;
      _currentPasswordC.clear();
      _newPasswordC.clear();
      _confirmPasswordC.clear();
      _showSnack('Password changed successfully');
    } catch (error) {
      if (mounted) _showSnack('Could not change password: $error');
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _enablePushNotifications() async {
    if (_requestingPushPermission) return;
    setState(() => _requestingPushPermission = true);
    try {
      await PushNotificationService.instance.registerForSignedInUser();
      final granted = await PushNotificationService.instance.hasPermission();
      if (mounted) setState(() => _pushPermissionGranted = granted);
    } finally {
      if (mounted) setState(() => _requestingPushPermission = false);
    }
  }

  Future<void> _openOrganizationOnMap(String address) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': address,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      body: SafeArea(
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Profile',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
              showNotification: false,
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null && _user == null
                  ? _ErrorState(message: _loadError!, onRetry: _load)
                  : RefreshIndicator(
                      color: AppColors.deliveryGreen,
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: Column(
                                children: [
                                  _buildHeaderCard(),
                                  const SizedBox(height: 12),
                                  _buildAccountDetailsCard(),
                                  const SizedBox(height: 12),
                                  _buildAdditionalDetailsCard(),
                                  const SizedBox(height: 12),
                                  _buildChangePasswordCard(),
                                  if (_organization != null) ...[
                                    const SizedBox(height: 12),
                                    _buildOrganizationCard(),
                                  ],
                                  const SizedBox(height: 12),
                                  _buildNotificationsCard(),
                                  const SizedBox(height: 12),
                                  _buildFooterStats(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final user = _user!;
    final displayName = (user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : user.name);
    final roleLabel = user.roleDetail?.name ?? user.role ?? 'User';
    final isActive = user.isActive != false;

    return _CardContainer(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomerAvatar(
                  name: displayName,
                  photoUrl: user.profilePhoto,
                  size: 88,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.deliveryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: _uploadingPhoto
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.deliveryInk,
            ),
          ),
          if ((user.email).trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.email,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _StatusChip(
                label: isActive ? 'Active' : 'Inactive',
                color: isActive
                    ? AppColors.deliveryGreen
                    : AppColors.deliveryRed,
              ),
              _StatusChip(label: roleLabel, color: AppColors.primary900),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard() {
    final user = _user!;
    final roleLabel = user.roleDetail?.name ?? user.role ?? 'User';
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Account Details'),
          const SizedBox(height: 16),
          _DetailGrid(
            rows: [
              _DetailField('Phone', user.phone ?? '-', Icons.call_outlined),
              _DetailField('Role', roleLabel, Icons.verified_user_outlined),
              _DetailField(
                'Joined',
                _formatDate(user.createdAt),
                Icons.calendar_today_outlined,
              ),
              _DetailField('User ID', user.id, Icons.tag_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    final user = _user!;
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _CardTitle('Additional Details')),
              if (!_editingDetails)
                TextButton.icon(
                  onPressed: () => setState(() => _editingDetails = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.deliveryGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _editingDetails
              ? _buildAdditionalDetailsForm()
              : _DetailGrid(
                  rows: [
                    _DetailField('First Name', user.firstName ?? '-'),
                    _DetailField('Last Name', user.lastName ?? '-'),
                    _DetailField('Display Name', user.displayName ?? '-'),
                    _DetailField('Gender', user.gender ?? '-'),
                    _DetailField(
                      'Date of Birth',
                      _formatDate(user.dateOfBirth),
                    ),
                    _DetailField('Marital Status', user.maritalStatus ?? '-'),
                    _DetailField('Blood Group', user.bloodGroup ?? '-'),
                    _DetailField(
                      'Alternate Mobile',
                      user.alternateMobileNumber ?? '-',
                    ),
                    _DetailField('Personal Email', user.personalEmail ?? '-'),
                    _DetailField(
                      'Emergency Contact Name',
                      user.emergencyContactName ?? '-',
                    ),
                    _DetailField(
                      'Emergency Contact Number',
                      user.emergencyContactNumber ?? '-',
                    ),
                    _DetailField(
                      'Emergency Relationship',
                      user.emergencyContactRelationship ?? '-',
                    ),
                    _DetailField('Current Address', user.currentAddress ?? '-'),
                    _DetailField(
                      'Permanent Address',
                      user.permanentAddress ?? '-',
                    ),
                    _DetailField('City', user.city ?? '-'),
                    _DetailField('State', user.state ?? '-'),
                    _DetailField('Country', user.country ?? '-'),
                    _DetailField('Pin/Zip Code', user.pinZipCode ?? '-'),
                    _DetailField('Language', user.language ?? '-'),
                    _DetailField('Time Zone', user.timeZone ?? '-'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormRow2(
          _FormField('First Name', _firstNameC),
          _FormField('Last Name', _lastNameC),
        ),
        const SizedBox(height: 12),
        _FormRow2(
          _FormField('Display Name', _displayNameC),
          _DropdownField(
            label: 'Gender',
            value: _gender,
            options: _genderOptions,
            onChanged: (value) => setState(() => _gender = value),
          ),
        ),
        const SizedBox(height: 12),
        _FormRow2(
          _DateField(label: 'Date of Birth', value: _dob, onTap: _pickDob),
          _DropdownField(
            label: 'Marital Status',
            value: _maritalStatus,
            options: _maritalStatusOptions,
            onChanged: (value) => setState(() => _maritalStatus = value),
          ),
        ),
        const SizedBox(height: 12),
        _FormRow2(
          _DropdownField(
            label: 'Blood Group',
            value: _bloodGroup,
            options: _bloodGroupOptions,
            onChanged: (value) => setState(() => _bloodGroup = value),
          ),
          _FormField(
            'Alternate Mobile',
            _alternateMobileC,
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 12),
        _FormRow2(
          _FormField(
            'Personal Email',
            _personalEmailC,
            keyboardType: TextInputType.emailAddress,
          ),
          _FormField('Emergency Contact Name', _emergencyNameC),
        ),
        const SizedBox(height: 12),
        _FormRow2(
          _FormField(
            'Emergency Contact Number',
            _emergencyNumberC,
            keyboardType: TextInputType.phone,
          ),
          _FormField('Emergency Relationship', _emergencyRelationC),
        ),
        const SizedBox(height: 12),
        _textField('Current Address', _currentAddressC, maxLines: 2),
        const SizedBox(height: 12),
        _textField('Permanent Address', _permanentAddressC, maxLines: 2),
        const SizedBox(height: 12),
        _FormRow2(_FormField('City', _cityC), _FormField('State', _stateC)),
        const SizedBox(height: 12),
        _FormRow2(
          _FormField('Country', _countryC),
          _FormField('Pin/Zip Code', _pinZipC),
        ),
        const SizedBox(height: 12),
        _FormRow2(
          _FormField('Language', _languageC),
          _FormField('Time Zone', _timeZoneC),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: _savingDetails
                  ? null
                  : () {
                      setState(() => _editingDetails = false);
                      _populateFormFromUser(_user!);
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _savingDetails ? null : _saveDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deliveryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _savingDetails
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangePasswordCard() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Change Password'),
          const SizedBox(height: 16),
          _passwordField(
            'Current Password',
            _currentPasswordC,
            _obscureCurrent,
            () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 14),
          _passwordField(
            'New Password',
            _newPasswordC,
            _obscureNew,
            () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 14),
          _passwordField(
            'Confirm New Password',
            _confirmPasswordC,
            _obscureConfirm,
            () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _changingPassword ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _changingPassword
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Change Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard() {
    final org = _organization!;
    String text(List<String> keys) {
      for (final key in keys) {
        final value = org[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return '-';
    }

    final address = text(['address', 'billing_address']);
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Organization'),
          const SizedBox(height: 16),
          _DetailGrid(
            rows: [
              _DetailField('Name', text(['name'])),
              _DetailField('Business Type', text(['business_type'])),
              _DetailField('Email', text(['email'])),
              _DetailField('Phone', text(['phone'])),
              _DetailField('GST Number', text(['gst_number'])),
              _DetailField('PAN Number', text(['pan_number'])),
              _DetailField('Financial Year', text(['financial_year'])),
              _DetailField(
                'Created',
                _formatDate(DateTime.tryParse(text(['created_at', 'created']))),
              ),
            ],
          ),
          if (address != '-') ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deliveryCardSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deliverySurfaceBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: AppColors.deliveryInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _openOrganizationOnMap(address),
                          child: Text(
                            'View on Map',
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: AppColors.deliveryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    final granted = _pushPermissionGranted == true;
    return _CardContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: granted
                  ? AppColors.deliveryGreenSoft
                  : AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              granted
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: granted ? AppColors.deliveryGreen : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Push Notifications',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.deliveryInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: granted ? 'On' : 'Off',
                      color: granted
                          ? AppColors.deliveryGreen
                          : AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Turn this on to get notifications for things that need your attention.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                if (!granted) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _requestingPushPermission
                          ? null
                          : _enablePushNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _requestingPushPermission
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enable notifications'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStats() {
    final organizationInfo = _authMe?.organization;
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.credit_card_rounded,
            label: 'Plan',
            value: organizationInfo?.plan?.name ?? '-',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.shield_outlined,
            label: 'Status',
            value: organizationInfo?.status ?? '-',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.event_outlined,
            label: 'Trial Ends',
            value: _formatDate(organizationInfo?.trialEndsAt),
          ),
        ),
      ],
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.bodyStrong,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deliveryCardSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deliveryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyStrong,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deliveryCardSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deliveryGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _FormField(this.label, this.controller, {this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyStrong,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deliveryCardSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deliveryGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          style: AppTextStyles.body.copyWith(color: AppColors.deliveryInk),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deliveryCardSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deliveryGreen),
            ),
          ),
          hint: const Text('Select'),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.deliveryCardSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.deliverySurfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  value == null ? 'Select date' : _formatDate(value),
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: value == null
                        ? AppColors.textLightMuted
                        : AppColors.deliveryInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FormRow2 extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _FormRow2(this.first, this.second);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 14),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.fieldLabel);
  }
}

class _DetailField {
  final String label;
  final String value;
  final IconData? icon;

  const _DetailField(this.label, this.value, [this.icon]);
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailField> rows;

  const _DetailGrid({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i != 0) const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rows[i].icon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      rows[i].icon,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 5,
                  child: Text(
                    rows[i].label,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: Text(
                    rows[i].value.trim().isEmpty ? '-' : rows[i].value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: AppColors.deliveryInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;

  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.sectionHeading.copyWith(
        color: AppColors.deliveryInk,
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyStrong.copyWith(color: color),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.deliveryGreen),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value.trim().isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.deliveryInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: AppColors.textLightMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load your profile',
              style: AppTextStyles.screenHeading,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
}

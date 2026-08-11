// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import 'additional_information_screen.dart';
import 'business_settings_screen.dart';
import 'documents_screen.dart';
import 'general_information_screen.dart';
import 'company_settings_constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Color _titleColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _cardBg = Colors.white;
  static const Color _accent = Color(0xFF0B4D08);
  final ApiService _apiService = ApiService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _currentUserId;
  bool _didLoadInitialData = false;

  final TextEditingController _legalNameController = TextEditingController(
    text: 'lol',
  );
  final TextEditingController _ownerController = TextEditingController(
    text: 'Sushil',
  );
  final TextEditingController _mobileController = TextEditingController(
    text: '9986547856',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'testing@gmail.com',
  );

  String? _selectedIndustry;
  String _selectedStatus = 'Active';
  String _selectedDesignation = 'Admin';
  String _savedLegalName = 'lol';
  String _savedOwnerName = 'Sushil';
  String _savedMobileNumber = '9986547856';
  String _savedEmail = 'testing@gmail.com';
  String? _savedIndustry;
  String _savedStatus = 'Active';
  String _savedDesignation = 'Admin';
  String? _savedAuthorizedPhotoUrl;
  String? _savedLogoUrl;
  bool _isEditing = false;
  bool _accountDetailsExpanded = true;
  bool _authorizedPersonExpanded = true;
  final List<String> _statusOptions = const [
    'Active',
    'Inactive',
    'Suspended',
    'Locked',
  ];
  final List<String> _designationOptions = const [
    'Owner',
    'Director',
    'Admin',
    'Manager',
    'Accountant',
    'Sales Officer',
  ];

  @override
  void dispose() {
    _legalNameController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentUserId = _resolveCurrentUserId();
    if (_didLoadInitialData) return;
    _didLoadInitialData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            if (isMobile) {
              return _buildMobileDashboard();
            }

            return Column(
              children: [
                AdminTopBar(
                  title: 'Account',
                  leadingIcon: Icons.arrow_back_rounded,
                  onLeadingTap: () => Navigator.of(context).maybePop(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _actionButton(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _SectionCard(
                        number: 1,
                        title: 'Account Details',
                        subtitle: 'Company account classification and status.',
                        expanded: _accountDetailsExpanded,
                        onToggle: () {
                          setState(
                            () =>
                                _accountDetailsExpanded = !_accountDetailsExpanded,
                          );
                        },
                        child: _accountDetailsExpanded
                            ? Column(
                                children: [
                                  _fieldBlock(
                                    label: 'Legal Name',
                                    child: _textField(
                                      controller: _legalNameController,
                                      enabled: _isEditing,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _fieldBlock(
                                    label: 'Industry',
                                    child: _dropdownField(
                                      value: _selectedIndustry,
                                      hintText: 'Select industry',
                                      items: kIndustryOptions,
                                      enabled: _isEditing,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _selectedIndustry = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _fieldBlock(
                                    label: 'Status',
                                    child: _dropdownField(
                                      value: _selectedStatus,
                                      items: _statusOptions,
                                      enabled: _isEditing,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _selectedStatus = value);
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        number: 2,
                        title: 'Authorized Person',
                        subtitle: 'Authorized representative contact and identity.',
                        expanded: _authorizedPersonExpanded,
                        onToggle: () {
                          setState(
                            () => _authorizedPersonExpanded =
                                !_authorizedPersonExpanded,
                          );
                        },
                        child: _authorizedPersonExpanded
                            ? Column(
                                children: [
                                  _fieldBlock(
                                    label: 'Owner/Director Name',
                                    child: _textField(
                                      controller: _ownerController,
                                      enabled: _isEditing,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _fieldBlock(
                                    label: 'Designation',
                                    child: _dropdownField(
                                      value: _selectedDesignation,
                                      items: _designationOptions,
                                      enabled: _isEditing,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(
                                          () => _selectedDesignation = value,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _fieldBlock(
                                    label: 'Mobile Number',
                                    child: _textField(
                                      controller: _mobileController,
                                      keyboardType: TextInputType.phone,
                                      enabled: _isEditing,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _fieldBlock(
                                    label: 'Email',
                                    child: _textField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      enabled: _isEditing,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileDashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        _mobileHeader(),
        const SizedBox(height: 14),
        _mobileOverviewCard(),
        const SizedBox(height: 14),
        _mobileMetricsGrid(),
        const SizedBox(height: 14),
        _mobileProfileCompletionCard(),
        const SizedBox(height: 14),
        _mobileAuthorizedPersonCard(),
        const SizedBox(height: 14),
        _mobileDocumentsCard(),
        const SizedBox(height: 14),
        _mobileCompanyAddressesCard(),
        const SizedBox(height: 14),
        _mobileRecentActivityCard(),
        const SizedBox(height: 14),
        _mobileQuickActionsCard(),
      ],
    );
  }

  Widget _mobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: _titleColor),
            ),
            const SizedBox(width: 2),
            const Text(
              'Account',
              style: TextStyle(
                color: _titleColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _mobileOverviewCard() {
    final company = _savedLegalName.trim().isEmpty ? 'Company' : _savedLegalName;
    final industry = _savedIndustry?.trim().isNotEmpty == true ? _savedIndustry! : 'Beverages';
    final companyType = _selectedDesignation.isEmpty ? 'LLP' : _selectedDesignation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                  color: const Color(0xFFF8FAFC),
                ),
                alignment: Alignment.center,
                child: _companyAvatar(company),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company,
                            style: const TextStyle(
                              color: _titleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _statusChip(_savedStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Company profile and organization information.',
                      style: TextStyle(
                        color: _mutedColor,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),
          _miniOverviewRow(
            'Company Code',
            'CMP-cc2af8a3-2114-4eb1-a89a...',
          ),
          const SizedBox(height: 10),
          _miniOverviewRow('Industry', industry),
          const SizedBox(height: 10),
          _miniOverviewRow('Company Type', companyType),
          const SizedBox(height: 10),
          _miniOverviewRow('Registration Date', 'Not set'),
          const SizedBox(height: 10),
          _miniOverviewRow('Plan', 'Enterprise'),
        ],
      ),
    );
  }

  Widget _companyAvatar(String company) {
    final initial = company.isNotEmpty ? company[0].toUpperCase() : 'C';
    final logoUrl = _savedLogoUrl?.trim();

    if (logoUrl == null || logoUrl.isEmpty) {
      return Text(
        initial,
        style: const TextStyle(
          color: _accent,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        logoUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: _accent,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _authorizedPersonAvatar() {
    final initial =
        _savedOwnerName.isNotEmpty ? _savedOwnerName[0].toUpperCase() : 'S';
    final photoUrl = _savedAuthorizedPhotoUrl?.trim();

    if (photoUrl == null || photoUrl.isEmpty) {
      return Text(
        initial,
        style: const TextStyle(
          color: _accent,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            initial,
            style: const TextStyle(
              color: _accent,
              fontWeight: FontWeight.w800,
            ),
          );
        },
      ),
    );
  }

  Widget _mobileMetricsGrid() {
    final metrics = [
      _MobileMetric('Employees', '0', 'Total Employees', Icons.groups_outlined, const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
      _MobileMetric('Branches', '0', 'Total Branches', Icons.apartment_outlined, const Color(0xFFFFEDD5), const Color(0xFFF97316)),
      _MobileMetric('Active Users', '0', 'System Users', Icons.person_outline_rounded, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
      _MobileMetric('Documents', '1', 'Uploaded Files', Icons.description_outlined, const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
      _MobileMetric('Storage Used', '4 files', 'Company Documents', Icons.storage_rounded, const Color(0xFFF3E8FF), const Color(0xFF7C3AED)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE3EA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: metric.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, color: metric.iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric.label,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metric.value,
                      style: const TextStyle(
                        color: _titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metric.subtitle,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileProfileCompletionCard() {
    return _dashboardCard(
      title: 'Profile Completion',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.89,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF16A34A),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: Center(
                    child: Text(
                      '89%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Needs Attention',
                  style: TextStyle(
                    color: _titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Complete the missing items to improve company readiness.',
                  style: TextStyle(
                    color: _mutedColor,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Missing Information',
                  style: TextStyle(
                    color: _titleColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text('- GST Certificate', style: TextStyle(color: _mutedColor, fontSize: 11.5)),
                Text('- PAN Card', style: TextStyle(color: _mutedColor, fontSize: 11.5)),
                SizedBox(height: 8),
                _profileCompletionAction(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileAuthorizedPersonCard() {
    return _dashboardCard(
      title: 'Authorized Person',
      trailing: _statusChip('Verified'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFF3F4F6),
                child: _authorizedPersonAvatar(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _savedOwnerName,
                      style: const TextStyle(
                        color: _titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _savedDesignation,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _savedEmail,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _savedMobileNumber,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniActionButton(
                  label: 'View Details',
                  foreground: _titleColor,
                  background: Colors.white,
                  borderColor: const Color(0xFFD8DFD8),
                  onTap: () => _openGeneralInformation(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniActionButton(
                  label: 'Edit',
                  foreground: Colors.white,
                  background: _accent,
                  borderColor: _accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileDocumentsCard() {
    final docs = [
      ('GST Certificate', 'Pending'),
      ('PAN Card', 'Pending'),
      ('Incorporation Certificate', 'Pending'),
      ('Trade License', 'Pending'),
      ('MSME Certificate', 'Pending'),
    ];

    return _dashboardCard(
      title: 'Documents Overview',
      trailing: const Icon(Icons.content_copy_outlined, color: Color(0xFF94A3B8), size: 18),
      child: Column(
        children: [
          ...docs.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      doc.$1,
                      style: const TextStyle(
                        color: _titleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _statusChip(doc.$2, compact: true, accent: const Color(0xFFF97316)),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _openDocuments,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                'View All Documents',
                style: TextStyle(
                  color: _accent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileCompanyAddressesCard() {
    return _dashboardCard(
      title: 'Company Addresses',
      trailing: const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registered Office',
                  style: TextStyle(
                    color: _titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _savedLegalName,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mumbai, Maharashtra, India',
                  style: TextStyle(color: _mutedColor, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Branch/Warehouse Address',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _savedLegalName,
                  style: const TextStyle(color: _mutedColor, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Icon(Icons.location_pin, color: Color(0xFFEF4444), size: 34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileRecentActivityCard() {
    final items = [
      ('Company profile updated', 'Today'),
      ('Billing information checked', 'Recent'),
      ('Authorized person updated', 'Recent'),
      ('Documents reviewed', 'Recent'),
    ];

    return _dashboardCard(
      title: 'Recent Activity',
      trailing: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _openAdditionalInformation,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Text(
            'View All',
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3FAF0),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: _accent, size: 15),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: _titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$2,
                          style: const TextStyle(color: _mutedColor, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileQuickActionsCard() {
    return _dashboardCard(
      title: 'Quick Actions',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
        children: [
          _quickActionTile(
            'Edit Profile',
            Icons.edit_outlined,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
            onTap: () => _openGeneralInformation(),
          ),
          _quickActionTile(
            'Upload Document',
            Icons.cloud_upload_outlined,
            const Color(0xFFE0E7FF),
            const Color(0xFF4F46E5),
            onTap: _openDocuments,
          ),
          _quickActionTile(
            'Invite User',
            Icons.person_add_alt_1_outlined,
            const Color(0xFFF3E8FF),
            const Color(0xFF7C3AED),
            onTap: _openAdditionalInformation,
          ),
          _quickActionTile(
            'View Reports',
            Icons.bar_chart_outlined,
            const Color(0xFFFFEDD5),
            const Color(0xFFF97316),
            onTap: _openBusinessSettings,
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile(
    String label,
    IconData icon,
    Color background,
    Color color,
    {required VoidCallback onTap}
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE3EA)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGeneralInformation() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GeneralInformationScreen(),
      ),
    );
    if (!mounted) return;
    await _loadOrganizationSettings();
  }

  void _openDocuments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DocumentsScreen(),
      ),
    );
  }

  void _openAdditionalInformation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdditionalInformationScreen(),
      ),
    );
  }

  void _openBusinessSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BusinessSettingsScreen(),
      ),
    );
  }

  Widget _miniOverviewRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _titleColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(
    String label, {
    bool compact = false,
    Color accent = const Color(0xFF16A34A),
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: compact ? 10.5 : 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _miniActionButton({
    required String label,
    required Color foreground,
    required Color background,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCompletionAction() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openGeneralInformation(),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          'Complete Now',
          style: TextStyle(
            color: _accent,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _fieldBlock({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _actionButton() {
    final editing = _isEditing;
    return ElevatedButton.icon(
      onPressed: () async {
        if (editing) {
          await _saveSettings();
          return;
        }
        setState(() => _isEditing = true);
      },
      icon: Icon(editing ? Icons.save_outlined : Icons.edit_outlined, size: 18),
      label: Text(editing ? 'Save' : 'Edit'),
      style: ElevatedButton.styleFrom(
        backgroundColor: editing ? _accent : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : _titleColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      final organizationPayload = <String, dynamic>{};
      _putIfNotBlank(
        organizationPayload,
        'legal_name',
        _legalNameController.text,
      );
      _putIfNotBlank(organizationPayload, 'industry', _selectedIndustry);
      _putIfNotBlank(
        organizationPayload,
        'auth_person_name',
        _ownerController.text,
      );
      _putIfNotBlank(
        organizationPayload,
        'auth_person_designation',
        _selectedDesignation,
      );
      _putIfNotBlank(
        organizationPayload,
        'auth_person_mobile',
        _mobileController.text,
      );
      _putIfNotBlank(
        organizationPayload,
        'auth_person_email',
        _emailController.text,
      );
      _putIfNotBlank(
        organizationPayload,
        'company_status',
        _apiStatusValue(_selectedStatus),
      );

      final userPayload = <String, dynamic>{};
      _putIfNotBlank(userPayload, 'name', _ownerController.text);
      _putIfNotBlank(userPayload, 'display_name', _ownerController.text);
      _putIfNotBlank(userPayload, 'email', _emailController.text);
      _putIfNotBlank(userPayload, 'phone', _mobileController.text);
      _putIfNotBlank(userPayload, 'designation', _selectedDesignation);
      _putIfNotBlank(userPayload, 'status', _apiStatusValue(_selectedStatus));
      _putIfNotBlank(
        userPayload,
        'employee_status',
        _apiStatusValue(_selectedStatus),
      );

      final userId = await _getCurrentUserId();
      if (userId.trim().isEmpty) {
        throw const ApiException(message: 'Missing user id.');
      }

      final tasks = <Future<dynamic>>[];
      if (organizationPayload.isNotEmpty) {
        tasks.add(
          _apiService.updateOrganizationSettings(
            request: OrganizationSettingsRequest(fields: organizationPayload),
          ),
        );
      }
      if (userPayload.isNotEmpty) {
        tasks.add(
          _apiService.updateUser(
            userId: userId,
            request: UpdateUserRequest(
              name: _ownerController.text,
              displayName: _ownerController.text,
              email: _emailController.text,
              phone: _mobileController.text,
              designation: _selectedDesignation,
              status: _apiStatusValue(_selectedStatus),
              employeeStatus: _apiStatusValue(_selectedStatus),
            ),
          ),
        );
      }

      await Future.wait(tasks);

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save changes: $error')));
    }
  }

  Future<void> _loadOrganizationSettings() async {
    try {
      final data = await _apiService.fetchOrganizationSettingsView();
      if (!mounted) return;
      setState(() {
        _applyOrganizationData(data);
      });
    } catch (_) {
      // Keep defaults if the organization profile cannot be loaded.
    }
  }

  void _applyOrganizationData(Map<String, dynamic> data) {
    final legalName =
        _readString(data, 'legal_name') ?? _readString(data, 'name');
    final industry = _readString(data, 'industry');
    final ownerName = _readString(data, 'auth_person_name');
    final designation = _readString(data, 'auth_person_designation');
    final mobile =
        _readString(data, 'auth_person_mobile') ?? _readString(data, 'phone');
    final email =
        _readString(data, 'auth_person_email') ?? _readString(data, 'email');
    final companyStatus = _readString(data, 'company_status');
    final authorizedPhotoUrl =
        _readString(data, 'auth_person_photo_url') ??
        _readString(data, 'profile_picture_url');
    final logoUrl = _readString(data, 'logo_url');

    if (legalName != null) {
      _legalNameController.text = legalName;
      _savedLegalName = legalName;
    }
    if (industry != null) {
      final matchedIndustry = _matchOption(kIndustryOptions, industry);
      _selectedIndustry = matchedIndustry;
      _savedIndustry = _selectedIndustry;
    }
    if (ownerName != null) {
      _ownerController.text = ownerName;
      _savedOwnerName = ownerName;
    }
    if (designation != null) {
      final matchedDesignation = _matchOption(_designationOptions, designation);
      if (matchedDesignation != null) {
        _selectedDesignation = matchedDesignation;
      }
      _savedDesignation = _selectedDesignation;
    }
    if (mobile != null) {
      _mobileController.text = mobile;
      _savedMobileNumber = mobile;
    }
    if (email != null) {
      _emailController.text = email;
      _savedEmail = email;
    }
    if (companyStatus != null) {
      final matchedStatus = _matchOption(_statusOptions, companyStatus);
      if (matchedStatus != null) {
        _selectedStatus = matchedStatus;
      }
      _savedStatus = _selectedStatus;
    }
    _savedAuthorizedPhotoUrl = authorizedPhotoUrl;
    _savedLogoUrl = logoUrl;
  }

  String? _readString(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _matchOption(List<String> options, String value) {
    for (final option in options) {
      if (option.trim().toLowerCase() == value.trim().toLowerCase()) {
        return option;
      }
    }
    return null;
  }

  void _putIfNotBlank(Map<String, dynamic> payload, String key, String? value) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      payload[key] = trimmed;
    }
  }

  String? _resolveCurrentUserId() {
    final apiProvider = ApiProviderScope.maybeOf(context);
    final currentId = apiProvider?.currentUser?.id?.trim();
    if (currentId != null && currentId.isNotEmpty) {
      return currentId;
    }
    return _currentUserId;
  }

  Future<String> _getCurrentUserId() async {
    final cached = _currentUserId?.trim();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final apiProvider = ApiProviderScope.maybeOf(context);
    if (apiProvider == null) {
      return '';
    }

    final providerId = apiProvider.currentUser?.id?.trim();
    if (providerId != null && providerId.isNotEmpty) {
      _currentUserId = providerId;
      return providerId;
    }

    try {
      final profile = await apiProvider.fetchCurrentUserProfile(force: true);
      final fetchedId = profile?.id?.trim();
      if (fetchedId != null && fetchedId.isNotEmpty) {
        _currentUserId = fetchedId;
        return fetchedId;
      }
    } catch (_) {
      // Leave empty so the caller surfaces a missing-id error.
    }

    return '';
  }

  String _apiStatusValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return normalized;
    }
    if (normalized == 'active') return 'active';
    if (normalized == 'inactive') return 'inactive';
    if (normalized == 'suspended') return 'suspended';
    if (normalized == 'locked') return 'locked';
    return normalized;
  }

  Widget _textField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(fontSize: 15, color: _titleColor),
      decoration: _fieldDecoration(),
    );
  }

  Widget _dropdownField<T>({
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool enabled = false,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      menuMaxHeight: 260,
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF98A2B3)),
      hint: hintText == null
          ? null
          : Text(hintText, style: const TextStyle(color: Color(0xFF98A2B3))),
      style: const TextStyle(fontSize: 15, color: _titleColor),
      decoration: _fieldDecoration(),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                '$item',
                style: const TextStyle(
                  fontSize: 15,
                  color: _titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8DFD8), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8DFD8), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accent, width: 2),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B4D08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: _AccountScreenState._titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: _AccountScreenState._mutedColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF667085),
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[const SizedBox(height: 20), child],
        ],
      ),
    );
  }
}

class _MobileMetric {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _MobileMetric(
    this.label,
    this.value,
    this.subtitle,
    this.icon,
    this.iconBg,
    this.iconColor,
  );
}

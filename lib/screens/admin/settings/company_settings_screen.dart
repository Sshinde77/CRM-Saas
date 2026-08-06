import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import 'account_screen.dart';
import 'additional_information_screen.dart';
import 'billing_screen.dart';
import 'branding_identity_screen.dart';
import 'business_settings_screen.dart';
import 'change_password_screen.dart';
import 'documents_screen.dart';
import 'general_information_screen.dart';
import 'online_presence_screen.dart';
import '../../../widgets/admin/app_drawer.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_CompanySettingsSection> _sections = [
    _CompanySettingsSection(
      label: 'Account',
      subtitle: 'Manage admin and company account details',
      icon: Icons.person_outline_rounded,
      iconBg: Color(0xFFEAF5D9),
      iconColor: Color(0xFF567F19),
    ),
    _CompanySettingsSection(
      label: 'General Information',
      subtitle: 'View and update basic company info',
      icon: Icons.apartment_outlined,
      iconBg: Color(0xFFE6F1FF),
      iconColor: Color(0xFF3775D6),
    ),
    _CompanySettingsSection(
      label: 'Billing',
      subtitle: 'Manage payment methods and billing history',
      icon: Icons.credit_card_outlined,
      iconBg: Color(0xFFFFF0D9),
      iconColor: Color(0xFFDB8A00),
    ),
    _CompanySettingsSection(
      label: 'Branding & Identity',
      subtitle: 'Update logo, colors and brand identity',
      icon: Icons.palette_outlined,
      iconBg: Color(0xFFF2E6FF),
      iconColor: Color(0xFF8A50D1),
    ),
    _CompanySettingsSection(
      label: 'Online Presence',
      subtitle: 'Manage website and social links',
      icon: Icons.language_outlined,
      iconBg: Color(0xFFE4F7F4),
      iconColor: Color(0xFF1E9C90),
    ),
    _CompanySettingsSection(
      label: 'Business Settings',
      subtitle: 'Configure business preferences',
      icon: Icons.settings_outlined,
      iconBg: Color(0xFFFFF2E7),
      iconColor: Color(0xFFF18A1A),
    ),
    _CompanySettingsSection(
      label: 'Documents',
      subtitle: 'Upload and manage company documents',
      icon: Icons.folder_outlined,
      iconBg: Color(0xFFEAF0FF),
      iconColor: Color(0xFF5479E4),
    ),
    _CompanySettingsSection(
      label: 'Additional Information',
      subtitle: 'Manage extra company preferences',
      icon: Icons.tune_rounded,
      iconBg: Color(0xFFE9F7F2),
      iconColor: Color(0xFF1E9C90),
    ),
    _CompanySettingsSection(
      label: 'Notifications',
      subtitle: 'Manage all notification preferences',
      icon: Icons.notifications_none_rounded,
      iconBg: Color(0xFFFFECEF),
      iconColor: Color(0xFFFF4D6D),
    ),
    _CompanySettingsSection(
      label: 'Change Password',
      subtitle: 'Update your login password securely',
      icon: Icons.lock_outline_rounded,
      iconBg: Color(0xFFF3E8FF),
      iconColor: Color(0xFF8A50D1),
    ),
    _CompanySettingsSection(
      label: 'Support',
      subtitle: 'Get help, report issues, and contact support',
      icon: Icons.support_agent_rounded,
      iconBg: Color(0xFFE6F7F1),
      iconColor: Color(0xFF1E9C90),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Company Settings'),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _buildCompletionCard(),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'BUSINESS SETTINGS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ..._sections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SettingsTile(
                        section: section,
                        onTap: () {
                          if (section.label == 'Account') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AccountScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'General Information') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GeneralInformationScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Billing') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BillingScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Branding & Identity') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const BrandingIdentityScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Online Presence') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OnlinePresenceScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Business Settings') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const BusinessSettingsScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Documents') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DocumentsScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Additional Information') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdditionalInformationScreen(),
                              ),
                            );
                            return;
                          }

                          if (section.label == 'Change Password') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${section.label} opened'),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(18),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Company Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5D9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Color(0xFF567F19),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Completion',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '80% completed',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLightMuted,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _CompanySettingsSection {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _CompanySettingsSection({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class _SettingsTile extends StatelessWidget {
  final _CompanySettingsSection section;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: section.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  section.icon,
                  color: section.iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      section.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLightMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

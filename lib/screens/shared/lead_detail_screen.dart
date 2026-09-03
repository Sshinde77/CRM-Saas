import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../models/lead_detail_model.dart';
import '../../providers/api_provider.dart';
import '../../widgets/admin/admin_top_bar.dart';
import '../../widgets/admin/app_drawer.dart';
import '../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../admin/customers/customers_screen.dart';
import '../admin/leads/admin_leads_screen.dart';
import '../admin/orders/admin_orders_screen.dart';
import '../admin/orders/new_admin_order_screen.dart';
import '../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../sales_manager/performance/sales_manager_performance_screen.dart';
import '../sales_manager/stock/sales_manager_stock_screen.dart';
import '../sales_manager/visits/sales_manager_visits_screen.dart';

class LeadDetailScreen extends StatefulWidget {
  final String leadId;
  final bool useSalesManagerShell;

  const LeadDetailScreen({
    super.key,
    required this.leadId,
    this.useSalesManagerShell = false,
  });

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;
  LeadDetailModel? _lead;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadLead();
      }
    });
  }

  Future<void> _loadLead() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payload = await _apiProvider.fetchLeadById(widget.leadId);
      if (!mounted) return;
      setState(() {
        _lead = LeadDetailModel.fromJson(payload);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Create Order') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NewAdminOrderScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Stock') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }
    if (action == 'Follow-ups' || action == 'Follow-Ups') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
        ),
      );
    }
  }

  Future<void> _copyValue(String label, String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '-') return;
    await Clipboard.setData(ClipboardData(text: normalized));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied')));
  }

  Future<void> _launchExternal(Uri uri, String failureMessage) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failureMessage)));
  }

  Future<void> _callLead(String phone) async {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.isEmpty || sanitized == '-') return;
    await _launchExternal(Uri.parse('tel:$sanitized'), 'Unable to place call.');
  }

  Future<void> _emailLead(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty || normalized == '-') return;
    await _launchExternal(
      Uri(
        scheme: 'mailto',
        path: normalized,
        queryParameters: {'subject': 'Regarding your enquiry'},
      ),
      'Unable to open email app.',
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    await _launchExternal(
      Uri.parse('https://wa.me/$digits'),
      'Unable to open WhatsApp.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: widget.useSalesManagerShell
          ? SalesManagerSidebarDrawer(
              currentPage: 'Leads',
              onSelect: _handleSalesManagerSidebarSelection,
            )
          : const AppDrawer(activeItem: 'Leads'),
      body: SafeArea(
        child: Column(
          children: [
            widget.useSalesManagerShell
                ? const SalesManagerTopBar(title: 'Lead Details')
                : AdminTopBar(
                    title: 'Lead Details',
                    leadingIcon: Icons.menu_rounded,
                    onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _errorMessage != null
                  ? _LeadDetailErrorState(
                      message: _errorMessage!,
                      onRetry: _loadLead,
                    )
                  : _lead == null
                  ? _LeadDetailErrorState(
                      message: 'Lead details are unavailable.',
                      onRetry: _loadLead,
                    )
                  : _buildBody(context, _lead!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LeadDetailModel lead) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final tileWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(lead, compact),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        child: _buildSectionCard(
                          title: 'Contact Snapshot',
                          subtitle: 'Primary communication details',
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Mobile',
                                value: lead.phone,
                                onCopy: () =>
                                    _copyValue('Mobile number', lead.phone),
                              ),
                              _buildInfoTile(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: lead.email,
                                onCopy: () => _copyValue('Email', lead.email),
                              ),
                              _buildInfoTile(
                                icon: Icons.location_on_outlined,
                                label: 'Address',
                                value: lead.address,
                              ),
                              _buildInfoTile(
                                icon: Icons.apartment_outlined,
                                label: 'Region',
                                value: _joinedNonEmpty([
                                  lead.city,
                                  lead.state,
                                  lead.country,
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildSectionCard(
                          title: 'Lead Qualification',
                          subtitle: 'Source, intent and deal context',
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.campaign_outlined,
                                label: 'Lead Source',
                                value: lead.source,
                              ),
                              _buildInfoTile(
                                icon: Icons.inventory_2_outlined,
                                label: 'Interested Product',
                                value: lead.interestedProduct,
                              ),
                              _buildInfoTile(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Budget',
                                value: lead.budget,
                              ),
                              _buildInfoTile(
                                icon: Icons.flag_outlined,
                                label: 'Priority',
                                value: lead.priority,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildSectionCard(
                          title: 'Ownership & Timeline',
                          subtitle: 'Sales handling and activity markers',
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.person_outline_rounded,
                                label: 'Assigned To',
                                value: lead.assignedTo,
                              ),
                              _buildInfoTile(
                                icon: Icons.people_outline_rounded,
                                label: 'Existing Customer',
                                value: lead.existingCustomer,
                              ),
                              _buildInfoTile(
                                icon: Icons.event_available_outlined,
                                label: 'Next Follow-up',
                                value: _formatDate(lead.followUpDate),
                              ),
                              _buildInfoTile(
                                icon: Icons.timelapse_rounded,
                                label: 'Expected Closing',
                                value: _formatDate(lead.expectedClosingDate),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _buildSectionCard(
                          title: 'System Details',
                          subtitle: 'Identifiers and backend timestamps',
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.badge_outlined,
                                label: 'Lead ID',
                                value: lead.id.isEmpty ? '-' : lead.id,
                                onCopy: lead.id.isEmpty
                                    ? null
                                    : () => _copyValue('Lead ID', lead.id),
                              ),
                              _buildInfoTile(
                                icon: Icons.confirmation_number_outlined,
                                label: 'Lead Code',
                                value: lead.leadCode,
                                onCopy: lead.leadCode == '-'
                                    ? null
                                    : () => _copyValue(
                                        'Lead code',
                                        lead.leadCode,
                                      ),
                              ),
                              _buildInfoTile(
                                icon: Icons.schedule_rounded,
                                label: 'Created',
                                value: _formatDate(lead.createdAt),
                              ),
                              _buildInfoTile(
                                icon: Icons.update_rounded,
                                label: 'Updated',
                                value: _formatDate(lead.updatedAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Notes',
                    subtitle:
                        'Context captured during lead creation or follow-up',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        lead.notes.trim().isEmpty ? '-' : lead.notes,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(LeadDetailModel lead, bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FCF6), Color(0xFFEEF6EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _smallActionButton(
                icon: Icons.arrow_back_rounded,
                label: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              _statusChip(lead.status),
            ],
          ),
          const SizedBox(height: 14),
          compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityBlock(lead),
                    const SizedBox(height: 14),
                    _buildActionPanel(lead, compact),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildIdentityBlock(lead)),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: _buildActionPanel(lead, compact)),
                  ],
                ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricTile(
                label: 'Assigned',
                value: lead.assignedTo,
                icon: Icons.person_outline_rounded,
              ),
              _metricTile(
                label: 'Source',
                value: lead.source,
                icon: Icons.ads_click_outlined,
              ),
              _metricTile(
                label: 'Product',
                value: lead.interestedProduct,
                icon: Icons.widgets_outlined,
              ),
              _metricTile(
                label: 'Updated',
                value: _relativeTime(
                  lead.updatedAt.isEmpty ? lead.createdAt : lead.updatedAt,
                ),
                icon: Icons.update_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityBlock(LeadDetailModel lead) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(lead),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead.displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lead.companyName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _compactBadge(icon: Icons.phone_outlined, value: lead.phone),
                  _compactBadge(icon: Icons.email_outlined, value: lead.email),
                  if (lead.leadCode != '-')
                    _compactBadge(
                      icon: Icons.confirmation_number_outlined,
                      value: lead.leadCode,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(LeadDetailModel lead, bool compact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _smallActionButton(
                icon: Icons.call_outlined,
                label: 'Call',
                onTap: lead.phone == '-' ? null : () => _callLead(lead.phone),
              ),
              _smallActionButton(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                onTap: lead.email == '-' ? null : () => _emailLead(lead.email),
              ),
              _smallActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'WhatsApp',
                onTap: lead.phone == '-'
                    ? null
                    : () => _openWhatsApp(lead.phone),
              ),
              _smallActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onTap: _loadLead,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Created ${_formatDate(lead.createdAt)}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!compact) const SizedBox(height: 4),
          Text(
            'Status stays visible and actions remain reachable on small screens.',
            style: const TextStyle(
              color: AppColors.textLightMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.content_copy_rounded,
                  size: 15,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 148),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: onTap == null ? Colors.white54 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: onTap == null
                    ? AppColors.textLightMuted
                    : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: onTap == null
                      ? AppColors.textLightMuted
                      : AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactBadge({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final normalized = status.trim().toLowerCase();
    Color background = AppColors.surfaceSoft;
    Color foreground = AppColors.primary;

    if (normalized.contains('follow')) {
      background = const Color(0xFFF2F6EE);
      foreground = AppColors.blue;
    } else if (normalized.contains('hot')) {
      background = const Color(0xFFE9F5E4);
      foreground = AppColors.primary900;
    } else if (normalized.contains('closed') || normalized.contains('won')) {
      background = AppColors.statusActiveBg;
      foreground = AppColors.statusActiveText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.trim().isEmpty ? 'New' : status,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _avatar(LeadDetailModel lead) {
    Widget fallback() {
      return Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.surfaceSoft, AppColors.activeMenuBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          lead.initials,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (lead.avatarUrl.trim().isEmpty) {
      return fallback();
    }

    return ClipOval(
      child: Image.network(
        lead.avatarUrl,
        width: 62,
        height: 62,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      ),
    );
  }
}

class _LeadDetailErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LeadDetailErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(String rawValue) {
  final parsed = DateTime.tryParse(rawValue);
  if (parsed == null) return rawValue.trim().isEmpty ? '-' : rawValue;

  const months = <String>[
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

  return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
}

String _relativeTime(String rawValue) {
  final parsed = DateTime.tryParse(rawValue);
  if (parsed == null) return '-';

  final diff = DateTime.now().difference(parsed);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

String _joinedNonEmpty(List<String> values) {
  final items = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty && value != '-')
      .toList();
  return items.isEmpty ? '-' : items.join(', ');
}

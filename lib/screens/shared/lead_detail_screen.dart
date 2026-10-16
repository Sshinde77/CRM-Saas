import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_user.dart';
import '../../models/lead_detail_model.dart';
import '../../providers/api_provider.dart';
import '../../widgets/customer_avatar.dart';
import '../../widgets/admin/admin_top_bar.dart';
import '../../widgets/admin/app_drawer.dart';
import '../../widgets/app_calendar_date_picker.dart';
import '../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../admin/customers/customers_screen.dart';
import '../admin/customers/customer_details_screen.dart';
import '../admin/leads/admin_leads_screen.dart';
import '../admin/orders/admin_orders_screen.dart';
import '../admin/orders/new_admin_order_screen.dart';
import '../admin/quotations/admin_quotations_screen.dart';
import '../sales_manager/leads/add_lead_screen.dart';
import '../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../sales_manager/performance/sales_manager_performance_screen.dart';
import '../sales_manager/stock/sales_manager_stock_screen.dart';
import '../sales_manager/visits/sales_manager_visits_screen.dart';
import 'map_location_view_screen.dart';

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
  List<AppUser> _assignableStaff = [];
  final List<_LocalFollowUp> _localFollowUps = [];
  final List<_LocalVisit> _localVisits = [];
  int _selectedTab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadLead();
    });
  }

  Future<void> _loadLead() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payload = await _apiProvider.fetchLeadById(widget.leadId);
      final staff = await _loadAssignableStaff();
      if (!mounted) return;
      setState(() {
        _lead = LeadDetailModel.fromJson(payload);
        _assignableStaff = staff;
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

  Future<List<AppUser>> _loadAssignableStaff() async {
    try {
      final users = await _apiProvider.fetchAssignableUsers();
      if (users.isNotEmpty) return users;
    } catch (_) {}

    final currentUser = _apiProvider.currentUser;
    if (currentUser?.id == null || currentUser!.id!.trim().isEmpty) {
      return const [];
    }
    return [
      AppUser(
        id: currentUser.id!.trim(),
        name: currentUser.name,
        email: currentUser.email ?? '',
        role: currentUser.role,
        isActive: true,
      ),
    ];
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
    if (action == 'Quotations' || action == 'Quotation') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const AdminQuotationsScreen(useSalesManagerShell: true),
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
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
  }

  Future<void> _callLead(String phone) async {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.isEmpty || sanitized == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available.')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to call $phone')));
    }
  }

  Future<void> _emailLead(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty || normalized == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address not available.')),
      );
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: normalized,
      queryParameters: {'subject': 'Regarding your enquiry'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open email client.')),
      );
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty || digits == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available for WhatsApp.'),
        ),
      );
      return;
    }
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open WhatsApp.')));
    }
  }

  void _openMap(LeadDetailModel lead) {
    final address = lead.address.trim();
    final city = lead.city.trim();
    final fullLocation = address == '-'
        ? city
        : (city.isEmpty || city == '-' ? address : '$address, $city');
    if (fullLocation.isEmpty || fullLocation == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address location not available.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapLocationViewScreen(
          latitude: 28.6139,
          longitude: 77.2090,
          title: lead.displayName,
          subtitle: fullLocation,
        ),
      ),
    );
  }

  Future<void> _openEditLead(LeadDetailModel lead) async {
    if (lead.id.trim().isEmpty) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddLeadScreen(leadId: lead.id)),
    );
    if (updated == true && mounted) {
      await _loadLead();
    }
  }

  Future<void> _updateLeadStatus(LeadDetailModel lead) async {
    var selectedStatus = _manualStatusValue(lead.status);
    final nextStatus = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.deliveryOrangeSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.swap_horizontal_circle_outlined,
                            color: AppColors.deliveryOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Update Lead Status',
                            style: TextStyle(
                              color: AppColors.deliveryInk,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.deliveryCardSoft,
                        borderRadius: BorderRadius.circular(
                          AppSizes.inputRadius,
                        ),
                        border: Border.all(
                          color: AppColors.deliverySurfaceBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          items: const ['New', 'Contacted', 'Qualified', 'Lost']
                              .map(
                                (status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: AppColors.deliveryInk,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() => selectedStatus = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.deliverySurfaceBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.controlRadius,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deliveryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.controlRadius,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () =>
                                Navigator.of(context).pop(selectedStatus),
                            child: const Text(
                              'Save Status',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (nextStatus == null || nextStatus == lead.status) return;
    try {
      await _apiProvider.updateLead(
        leadId: lead.id,
        request: {'lead_status': nextStatus.toLowerCase()},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead status updated successfully')),
      );
      await _loadLead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    }
  }

  Future<void> _addNote(LeadDetailModel lead) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Follow-up Note',
            style: TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.deliveryInk,
            ),
            decoration: InputDecoration(
              hintText: 'Enter notes, client feedback or next steps...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.deliveryCardSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                borderSide: const BorderSide(
                  color: AppColors.deliverySurfaceBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                borderSide: const BorderSide(
                  color: AppColors.deliverySurfaceBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                borderSide: const BorderSide(color: AppColors.deliveryGreen),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deliveryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (note == null || note.trim().isEmpty) return;

    final stampedNote = '[${_formatDateTime(DateTime.now())}] ${note.trim()}';
    final existing = lead.notes.trim();
    final notes = existing.isEmpty || existing == '-'
        ? stampedNote
        : '$stampedNote\n\n$existing';

    try {
      await _apiProvider.updateLead(leadId: lead.id, request: {'notes': notes});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note added successfully')));
      await _loadLead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add note: $error')));
    }
  }

  Future<void> _openCustomer(LeadDetailModel lead) async {
    final customerId = lead.customerId.trim();
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer detail is unavailable.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(customerId: customerId),
      ),
    );
  }

  Future<void> _openFollowUpForm() async {
    final result = await showDialog<_LocalFollowUp>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _FollowUpSheet(staff: _assignableStaff),
    );
    if (result != null && mounted) {
      setState(() => _localFollowUps.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up scheduled successfully')),
      );
    }
  }

  Future<void> _openVisitForm(LeadDetailModel lead) async {
    final result = await showDialog<_VisitFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _VisitSheet(staff: _assignableStaff),
    );
    if (result != null && mounted) {
      final visit = _LocalVisit(
        visitType: result.visitTypeLabel,
        purpose: result.purpose,
        notes: result.notes,
        outcome: result.outcome,
        createdAt: DateTime.now(),
      );
      setState(() => _localVisits.insert(0, visit));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visit logged successfully')),
      );
    }
  }

  Future<void> _openConvertForm(LeadDetailModel lead) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) =>
          _ConvertLeadSheet(lead: lead, staff: _assignableStaff),
    );
    if (result == null) return;

    try {
      final response = await _apiProvider.convertLeadToCustomer(
        leadId: lead.id,
        request: result,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead converted to customer successfully'),
        ),
      );
      await _loadLead();

      final customerId = _responseCustomerId(response);
      if (customerId.isNotEmpty && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CustomerDetailsScreen(customerId: customerId),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to convert lead: $error')));
    }
  }

  String _responseCustomerId(Map<String, dynamic> response) {
    final data = response['data'];
    final customer = response['customer'];
    final candidates = [
      response['customer_id'],
      response['customerId'],
      customer is Map<String, dynamic> ? customer['id'] : null,
      data is Map<String, dynamic> ? data['customer_id'] : null,
      data is Map<String, dynamic> ? data['customerId'] : null,
      data is Map<String, dynamic> ? data['id'] : null,
      response['id'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
    }
    return '';
  }

  // ignore: unused_element
  Color _resolveStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('new')) return AppColors.deliveryGreen;
    if (s.contains('contacted')) return AppColors.deliveryCustomerOrders;
    if (s.contains('qualified') || s.contains('converted')) {
      return AppColors.deliveryGreen;
    }
    if (s.contains('lost')) return AppColors.textMuted;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    final lead = _lead;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Theme(
        data: Theme.of(context).copyWith(textTheme: AppTextStyles.textTheme),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.deliveryBackground,
          drawer: widget.useSalesManagerShell
              ? SalesManagerSidebarDrawer(
                  currentPage: 'Leads',
                  onSelect: _handleSalesManagerSidebarSelection,
                )
              : const AppDrawer(activeItem: 'Leads'),
          bottomNavigationBar:
              lead == null || _isLoading || _errorMessage != null
              ? null
              : _buildBottomActionBar(lead),
          body: SafeArea(
            child: Column(
              children: [
                widget.useSalesManagerShell
                    ? SalesManagerTopBar(
                        title: 'Lead Details',
                        leadingIcon: Icons.arrow_back_rounded,
                        onLeadingTap: () => Navigator.of(context).maybePop(),
                      )
                    : AdminTopBar(
                        title: 'Lead Details',
                        leadingIcon: Icons.arrow_back_rounded,
                        onLeadingTap: () => Navigator.of(context).maybePop(),
                        actions: [
                          if (lead != null) ...[
                            Tooltip(
                              message: 'Edit lead',
                              child: InkWell(
                                onTap: () => _openEditLead(lead),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Tooltip(
                            message: 'Refresh lead',
                            child: InkWell(
                              onTap: _loadLead,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                Expanded(
                  child: _isLoading && lead == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _errorMessage != null && lead == null
                      ? _buildErrorView()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _loadLead,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 920,
                                  ),
                                  child: Column(
                                    children: [
                                      _ProfileCard(
                                        lead: lead!,
                                        onCall: () => _callLead(lead.phone),
                                        onWhatsApp: () =>
                                            _openWhatsApp(lead.phone),
                                        onEmail: () => _emailLead(lead.email),
                                        onMap: () => _openMap(lead),
                                        onEdit: () => _openEditLead(lead),
                                        onStatus: () => _updateLeadStatus(lead),
                                      ),
                                      const SizedBox(height: 12),
                                      _MetricsSection(lead: lead),
                                      const SizedBox(height: 12),
                                      _ActivityPanel(
                                        selected: _selectedTab,
                                        onSelected: (val) =>
                                            setState(() => _selectedTab = val),
                                        followUpsCount: _localFollowUps.length,
                                        visitsCount: _localVisits.length,
                                        child: _buildTabBody(lead),
                                      ),
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
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.deliveryRed,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Unable to load lead details.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deliveryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _loadLead,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(LeadDetailModel lead) {
    switch (_selectedTab) {
      case 0:
        return _OverviewSection(lead: lead, onCopy: _copyValue);
      case 1:
        return _FollowUpsSection(
          items: _localFollowUps,
          onAdd: _openFollowUpForm,
        );
      case 2:
        return _VisitsSection(
          items: _localVisits,
          onAdd: () => _openVisitForm(lead),
        );
      case 3:
      default:
        return _NotesSection(lead: lead, onAddNote: () => _addNote(lead));
    }
  }

  Widget _buildBottomActionBar(LeadDetailModel lead) {
    final normalizedStatus = lead.status.trim().toLowerCase();
    final hasCustomer =
        lead.customerId.trim().isNotEmpty ||
        normalizedStatus.contains('converted');
    final isLost = normalizedStatus.contains('lost');

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 66,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
              top: BorderSide(color: AppColors.deliverySurfaceBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomActionButton(
                        icon: Icons.playlist_add_check_rounded,
                        label: 'Add Follow-up',
                        onTap: _openFollowUpForm,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BottomActionButton(
                        icon: Icons.location_on_outlined,
                        label: 'Log Visit',
                        onTap: () => _openVisitForm(lead),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BottomActionButton(
                        icon: hasCustomer
                            ? Icons.visibility_outlined
                            : Icons.person_add_alt_1_outlined,
                        label: hasCustomer ? 'View Customer' : 'Convert',
                        filled: true,
                        onTap: hasCustomer
                            ? () => _openCustomer(lead)
                            : isLost
                            ? null
                            : () => _openConvertForm(lead),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final LeadDetailModel lead;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onEmail;
  final VoidCallback onMap;
  final VoidCallback onEdit;
  final VoidCallback onStatus;

  const _ProfileCard({
    required this.lead,
    required this.onCall,
    required this.onWhatsApp,
    required this.onEmail,
    required this.onMap,
    required this.onEdit,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final company = lead.companyName.isEmpty || lead.companyName == '-'
        ? 'Independent Client'
        : lead.companyName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 7),
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
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: CustomerAvatar(
                  name: lead.displayName,
                  photoUrl: lead.avatarUrl,
                  size: 64,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.business_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _StatusBadge(label: lead.status, color: Colors.white),
                        if (lead.priority.isNotEmpty && lead.priority != '-')
                          _PriorityBadge(priority: lead.priority),
                        if (lead.leadCode.isNotEmpty && lead.leadCode != '-')
                          _LeadCodePill(code: lead.leadCode),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DateSummary(
                    label: 'Created',
                    value: _formatDate(lead.createdAt),
                    light: true,
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                Expanded(
                  child: _DateSummary(
                    label: 'Next follow-up',
                    value: lead.followUpDate.isEmpty || lead.followUpDate == '-'
                        ? 'Not scheduled'
                        : _formatDate(lead.followUpDate),
                    light: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _RoundAction(
                icon: Icons.call_rounded,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.14),
                enabled: lead.phone.trim().isNotEmpty && lead.phone != '-',
                tooltip: 'Call lead',
                onTap: onCall,
              ),
              _RoundAction(
                icon: FontAwesomeIcons.whatsapp,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.14),
                enabled: lead.phone.trim().isNotEmpty && lead.phone != '-',
                tooltip: 'WhatsApp',
                onTap: onWhatsApp,
              ),
              _RoundAction(
                icon: Icons.email_outlined,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.14),
                enabled: lead.email.trim().isNotEmpty && lead.email != '-',
                tooltip: 'Send email',
                onTap: onEmail,
              ),
              _RoundAction(
                icon: Icons.location_on_rounded,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.14),
                enabled: lead.address.trim().isNotEmpty && lead.address != '-',
                tooltip: 'View on map',
                onTap: onMap,
              ),
              _RoundAction(
                icon: Icons.swap_horizontal_circle_outlined,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.14),
                enabled: true,
                tooltip: 'Update status',
                onTap: onStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSummary extends StatelessWidget {
  final String label;
  final String value;
  final bool light;

  const _DateSummary({
    required this.label,
    required this.value,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: light ? Colors.white70 : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: light ? Colors.white : AppColors.deliveryInk,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? background;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  const _RoundAction({
    required this.icon,
    required this.color,
    this.background,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled
            ? (background ?? color.withValues(alpha: .10))
            : AppColors.deliveryCardSoft,
        shape: CircleBorder(
          side: BorderSide(
            color: enabled
                ? color.withValues(alpha: .24)
                : AppColors.deliverySurfaceBorder,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 19,
              color: enabled ? color : AppColors.textLightMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final LeadDetailModel lead;

  const _MetricsSection({required this.lead});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _MetricInfo(
        'Budget',
        lead.budget.isEmpty || lead.budget == '-' ? 'Not set' : lead.budget,
        Icons.account_balance_wallet_outlined,
        AppColors.deliveryGreen,
        AppColors.deliveryGreenSoft,
      ),
      _MetricInfo(
        'Product',
        lead.interestedProduct.isEmpty || lead.interestedProduct == '-'
            ? 'General'
            : lead.interestedProduct,
        Icons.inventory_2_outlined,
        AppColors.deliveryBlue,
        AppColors.deliveryBlueSoft,
      ),
      _MetricInfo(
        'Source',
        lead.source.isEmpty || lead.source == '-' ? 'Direct' : lead.source,
        Icons.campaign_outlined,
        AppColors.deliveryOrange,
        AppColors.deliveryOrangeSoft,
      ),
      _MetricInfo(
        'Assigned',
        lead.assignedTo.isEmpty || lead.assignedTo == '-'
            ? 'Unassigned'
            : lead.assignedTo,
        Icons.person_outline_rounded,
        AppColors.primary,
        AppColors.surfaceSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 68,
          ),
          itemBuilder: (_, index) => _MetricTile(info: rows[index]),
        );
      },
    );
  }
}

class _MetricInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MetricInfo(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}

class _MetricTile extends StatelessWidget {
  final _MetricInfo info;

  const _MetricTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: info.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(info.icon, color: info.color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 13.5,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF586176),
                    fontSize: 10.5,
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
}

class _ActivityPanel extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  final int followUpsCount;
  final int visitsCount;
  final Widget child;

  const _ActivityPanel({
    required this.selected,
    required this.onSelected,
    required this.followUpsCount,
    required this.visitsCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'Overview',
      'Follow-ups ($followUpsCount)',
      'Visits ($visitsCount)',
      'Notes & History',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selected == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Material(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.deliveryCardSoft,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => onSelected(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.deliverySurfaceBorder,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.deliveryInk,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final LeadDetailModel lead;
  final Future<void> Function(String label, String value) onCopy;

  const _OverviewSection({required this.lead, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailSectionCard(
          title: 'Contact Information',
          icon: Icons.contact_phone_outlined,
          children: [
            _InfoRow(
              label: 'Phone',
              value: lead.phone,
              onCopy: () => onCopy('Phone', lead.phone),
            ),
            _InfoRow(
              label: 'Email',
              value: lead.email,
              onCopy: () => onCopy('Email', lead.email),
            ),
            _InfoRow(
              label: 'Address',
              value: lead.address,
              onCopy: () => onCopy('Address', lead.address),
            ),
            _InfoRow(
              label: 'Region',
              value: _joinedNonEmpty([lead.city, lead.state, lead.country]),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _DetailSectionCard(
          title: 'Lead Qualification',
          icon: Icons.checklist_rounded,
          children: [
            _InfoRow(label: 'Source', value: lead.source),
            _InfoRow(
              label: 'Interested Product',
              value: lead.interestedProduct,
            ),
            _InfoRow(label: 'Budget', value: lead.budget),
            _InfoRow(label: 'Priority', value: lead.priority),
            _InfoRow(label: 'Lead Type', value: lead.leadType),
            _InfoRow(label: 'Segment', value: lead.segment),
          ],
        ),
        const SizedBox(height: 10),
        _DetailSectionCard(
          title: 'Ownership & Timeline',
          icon: Icons.badge_outlined,
          children: [
            _InfoRow(label: 'Assigned To', value: lead.assignedTo),
            _InfoRow(label: 'Existing Customer', value: lead.existingCustomer),
            _InfoRow(
              label: 'Next Follow-up',
              value: _formatDate(lead.followUpDate),
            ),
            _InfoRow(
              label: 'Expected Closing',
              value: _formatDate(lead.expectedClosingDate),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _DetailSectionCard(
          title: 'System Information',
          icon: Icons.info_outline_rounded,
          children: [
            _InfoRow(
              label: 'Lead ID',
              value: lead.id,
              onCopy: () => onCopy('Lead ID', lead.id),
            ),
            _InfoRow(
              label: 'Lead Code',
              value: lead.leadCode,
              onCopy: () => onCopy('Lead Code', lead.leadCode),
            ),
            _InfoRow(label: 'Created', value: _formatDate(lead.createdAt)),
            _InfoRow(label: 'Updated', value: _formatDate(lead.updatedAt)),
          ],
        ),
      ],
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.deliveryGreen),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.deliverySurfaceBorder),
          const SizedBox(height: 6),
          ...List.generate(children.length, (index) {
            return Column(
              children: [
                children[index],
                if (index < children.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.deliverySurfaceBorder,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _InfoRow({required this.label, required this.value, this.onCopy});

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty || value == '-'
        ? 'Not set'
        : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onCopy != null && displayValue != 'Not set') ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FollowUpsSection extends StatelessWidget {
  final List<_LocalFollowUp> items;
  final VoidCallback onAdd;

  const _FollowUpsSection({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scheduled Follow-ups',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.deliveryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Add Follow-up',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          _EmptyTabState(
            icon: Icons.playlist_add_check_rounded,
            label: 'No follow-ups recorded yet',
            actionLabel: 'Schedule First Follow-up',
            onAction: onAdd,
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deliveryCardSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.deliveryCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_note_rounded,
                          size: 16,
                          color: AppColors.deliveryCustomerOrders,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.deliveryInk,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _PriorityBadge(priority: item.priority),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(item.dueAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.assigneeName.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.assigneeName,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VisitsSection extends StatelessWidget {
  final List<_LocalVisit> items;
  final VoidCallback onAdd;

  const _VisitsSection({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recorded Visits',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.deliveryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Log Visit',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          _EmptyTabState(
            icon: Icons.location_on_outlined,
            label: 'No visits logged yet',
            actionLabel: 'Log First Client Visit',
            onAction: onAdd,
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deliveryCardSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.deliveryCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pin_drop_rounded,
                          size: 16,
                          color: AppColors.deliveryGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.visitType,
                            style: const TextStyle(
                              color: AppColors.deliveryInk,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const _StatusBadge(
                          label: 'Completed',
                          color: AppColors.deliveryGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(item.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (item.purpose.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Purpose: ${item.purpose}',
                        style: const TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (item.outcome.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Outcome: ${item.outcome}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  final LeadDetailModel lead;
  final VoidCallback onAddNote;

  const _NotesSection({required this.lead, required this.onAddNote});

  @override
  Widget build(BuildContext context) {
    final rawNotes = lead.notes.trim();
    final hasNotes = rawNotes.isNotEmpty && rawNotes != '-';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notes & History',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: onAddNote,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.deliveryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Add Note',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!hasNotes)
          _EmptyTabState(
            icon: Icons.notes_rounded,
            label: 'No notes added yet',
            actionLabel: 'Add First Note',
            onAction: onAddNote,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deliveryCardSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.deliveryCardBorder),
            ),
            child: Text(
              rawNotes,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyTabState({
    required this.icon,
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.deliveryGreenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.deliveryGreen, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deliveryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final background = filled && enabled
        ? AppColors.deliveryGreen
        : AppColors.surface;
    final foreground = filled && enabled
        ? Colors.white
        : enabled
        ? AppColors.deliveryInk
        : AppColors.textLightMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled && enabled
                  ? AppColors.deliveryGreen
                  : AppColors.deliverySurfaceBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label.isEmpty ? 'New' : label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final p = priority.toLowerCase();
    final color = p.contains('high') || p.contains('urgent')
        ? AppColors.deliveryRed
        : p.contains('med')
        ? AppColors.deliveryOrange
        : AppColors.deliveryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LeadCodePill extends StatelessWidget {
  final String code;

  const _LeadCodePill({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    border: Border.all(color: AppColors.deliverySurfaceBorder),
    boxShadow: const [
      BoxShadow(color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );
}

// -------------------------------------------------------------
// Sheet & Dialog Components
// -------------------------------------------------------------

class _SheetShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SheetShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.deliverySurfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.deliveryGreenSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.deliveryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.deliveryInk,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: AppColors.deliverySurfaceBorder,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowUpSheet extends StatefulWidget {
  final List<AppUser> staff;

  const _FollowUpSheet({required this.staff});

  @override
  State<_FollowUpSheet> createState() => _FollowUpSheetState();
}

class _FollowUpSheetState extends State<_FollowUpSheet> {
  final _titleController = TextEditingController(text: 'General Follow-up');
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _dueTime = const TimeOfDay(hour: 11, minute: 0);
  String _priority = 'medium';
  String? _assigneeId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAppCalendarDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      title: 'Follow-up Date',
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Schedule Follow-up',
      icon: Icons.playlist_add_check_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Title *'),
          _inputField(_titleController, hint: 'Follow-up title'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Date *'),
                    InkWell(
                      onTap: _pickDate,
                      child: _pickerBox(
                        _apiDate(_dueDate),
                        Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Time *'),
                    InkWell(
                      onTap: _pickTime,
                      child: _pickerBox(
                        _formatTime(_dueTime),
                        Icons.access_time_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _fieldLabel('Priority'),
          _dropdownBox<String>(
            value: _priority,
            items: const ['low', 'medium', 'high', 'urgent'],
            itemLabel: (v) => v[0].toUpperCase() + v.substring(1),
            onChanged: (v) => setState(() => _priority = v ?? 'medium'),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Assignee'),
          _dropdownBox<String?>(
            value: _assigneeId,
            items: [null, ...widget.staff.map((u) => u.id)],
            itemLabel: (v) {
              if (v == null) return 'Select Staff';
              return widget.staff.where((u) => u.id == v).firstOrNull?.name ??
                  v;
            },
            onChanged: (v) => setState(() => _assigneeId = v),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Description / Requirements'),
          _inputField(
            _descriptionController,
            hint: 'Optional details...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.deliverySurfaceBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) return;
                    final dueAt = _combineDateTime(_dueDate, _dueTime);
                    Navigator.pop(
                      context,
                      _LocalFollowUp(
                        title: title,
                        description: _descriptionController.text.trim(),
                        dueAt: dueAt,
                        priority: _priority,
                        assigneeName:
                            widget.staff
                                .where((u) => u.id == _assigneeId)
                                .firstOrNull
                                ?.name ??
                            'Assigned Staff',
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deliveryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Schedule',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitSheet extends StatefulWidget {
  final List<AppUser> staff;

  const _VisitSheet({required this.staff});

  @override
  State<_VisitSheet> createState() => _VisitSheetState();
}

class _VisitSheetState extends State<_VisitSheet> {
  final _purposeController = TextEditingController(text: 'Product Demo');
  final _notesController = TextEditingController();
  final _outcomeController = TextEditingController();
  String _visitType = 'lead';

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Log Client Visit',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Visit Type'),
          _dropdownBox<String>(
            value: _visitType,
            items: const ['lead', 'customer', 'supplier'],
            itemLabel: (v) => v[0].toUpperCase() + v.substring(1),
            onChanged: (v) => setState(() => _visitType = v ?? 'lead'),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Purpose *'),
          _inputField(_purposeController, hint: 'Visit objective'),
          const SizedBox(height: 12),
          _fieldLabel('Notes & Discussion'),
          _inputField(
            _notesController,
            hint: 'Key discussion points...',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _fieldLabel('Outcome'),
          _inputField(_outcomeController, hint: 'e.g. Requested quotation'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.deliverySurfaceBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final purpose = _purposeController.text.trim();
                    if (purpose.isEmpty) return;
                    Navigator.pop(
                      context,
                      _VisitFormResult(
                        visitType: _visitType,
                        visitTypeLabel:
                            _visitType[0].toUpperCase() +
                            _visitType.substring(1),
                        purpose: purpose,
                        notes: _notesController.text.trim(),
                        outcome: _outcomeController.text.trim(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deliveryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Log Visit',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConvertLeadSheet extends StatefulWidget {
  final LeadDetailModel lead;
  final List<AppUser> staff;

  const _ConvertLeadSheet({required this.lead, required this.staff});

  @override
  State<_ConvertLeadSheet> createState() => _ConvertLeadSheetState();
}

class _ConvertLeadSheetState extends State<_ConvertLeadSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _gstController;
  late final TextEditingController _addressController;
  String _customerType = 'business';
  String? _salesOfficerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.lead.companyName == '-'
          ? widget.lead.displayName
          : widget.lead.companyName,
    );
    _contactController = TextEditingController(text: widget.lead.contactName);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _emailController = TextEditingController(text: widget.lead.email);
    _gstController = TextEditingController();
    _addressController = TextEditingController(
      text: widget.lead.address == '-' ? '' : widget.lead.address,
    );
    _salesOfficerId = widget.staff
        .where((u) => u.name == widget.lead.assignedTo)
        .firstOrNull
        ?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Convert to Customer',
      icon: Icons.person_add_alt_1_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Business / Shop Name *'),
          _inputField(_nameController, hint: 'Customer business name'),
          const SizedBox(height: 12),
          _fieldLabel('Primary Contact Person'),
          _inputField(_contactController, hint: 'Contact name'),
          const SizedBox(height: 12),
          _fieldLabel('Phone Number *'),
          _inputField(
            _phoneController,
            hint: '10-digit mobile',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _fieldLabel('Email Address'),
          _inputField(
            _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _fieldLabel('Customer Type'),
          _dropdownBox<String>(
            value: _customerType,
            items: const [
              'business',
              'retail',
              'wholesale',
              'distributor',
              'individual',
            ],
            itemLabel: (v) => v[0].toUpperCase() + v.substring(1),
            onChanged: (v) => setState(() => _customerType = v ?? 'business'),
          ),
          const SizedBox(height: 12),
          _fieldLabel('GST Number'),
          _inputField(_gstController, hint: 'GSTIN (Optional)'),
          const SizedBox(height: 12),
          _fieldLabel('Address'),
          _inputField(
            _addressController,
            hint: 'Billing & Delivery Address',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _fieldLabel('Assigned Sales Officer'),
          _dropdownBox<String?>(
            value: _salesOfficerId,
            items: [null, ...widget.staff.map((u) => u.id)],
            itemLabel: (v) {
              if (v == null) return 'Select Staff';
              return widget.staff.where((u) => u.id == v).firstOrNull?.name ??
                  v;
            },
            onChanged: (v) => setState(() => _salesOfficerId = v),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.deliverySurfaceBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final phone = _phoneController.text.trim();
                    if (name.isEmpty || phone.isEmpty) return;
                    Navigator.pop(context, {
                      'name': name,
                      'contact_person': _contactController.text.trim(),
                      'phone': phone,
                      'email': _emailController.text.trim(),
                      'customer_type': _customerType,
                      'gst_number': _gstController.text.trim(),
                      'billing_address': _addressController.text.trim(),
                      'delivery_address': _addressController.text.trim(),
                      if (_salesOfficerId != null)
                        'assigned_sales_officer_id': _salesOfficerId,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deliveryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Convert',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Sheet Helper UI Widgets
// -------------------------------------------------------------

Widget _fieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.deliveryInk,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget _inputField(
  TextEditingController controller, {
  required String hint,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: const TextStyle(
      fontSize: 13,
      color: AppColors.deliveryInk,
      fontWeight: FontWeight.w600,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: AppColors.deliveryCardSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.deliverySurfaceBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.deliverySurfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        borderSide: const BorderSide(color: AppColors.deliveryGreen),
      ),
    ),
  );
}

Widget _dropdownBox<T>({
  required T value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.deliveryCardSoft,
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      border: Border.all(color: AppColors.deliverySurfaceBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.deliveryInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget _pickerBox(String text, IconData icon) {
  return Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.deliveryCardSoft,
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      border: Border.all(color: AppColors.deliverySurfaceBorder),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.deliveryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.deliveryInk,
            ),
          ),
        ),
      ],
    ),
  );
}

// -------------------------------------------------------------
// Models and Formatters
// -------------------------------------------------------------

class _LocalFollowUp {
  final String title;
  final String description;
  final DateTime dueAt;
  final String priority;
  final String assigneeName;

  const _LocalFollowUp({
    required this.title,
    required this.description,
    required this.dueAt,
    required this.priority,
    required this.assigneeName,
  });
}

class _LocalVisit {
  final String visitType;
  final String purpose;
  final String notes;
  final String outcome;
  final DateTime createdAt;

  const _LocalVisit({
    required this.visitType,
    required this.purpose,
    required this.notes,
    required this.outcome,
    required this.createdAt,
  });
}

class _VisitFormResult {
  final String visitType;
  final String visitTypeLabel;
  final String purpose;
  final String notes;
  final String outcome;

  const _VisitFormResult({
    required this.visitType,
    required this.visitTypeLabel,
    required this.purpose,
    required this.notes,
    required this.outcome,
  });
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

String _apiDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatTime(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final meridiem = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $meridiem';
}

DateTime _combineDateTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String _formatDateTime(DateTime value) {
  final hour = value.hour == 0 || value.hour == 12 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final meridiem = value.hour >= 12 ? 'pm' : 'am';
  return '${_formatDate(value.toIso8601String())}, $hour:$minute $meridiem';
}

String _joinedNonEmpty(List<String> values) {
  final items = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty && value != '-')
      .toList();
  return items.isEmpty ? '-' : items.join(', ');
}

String _manualStatusValue(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'contacted') return 'Contacted';
  if (normalized == 'qualified') return 'Qualified';
  if (normalized == 'lost') return 'Lost';
  return 'New';
}

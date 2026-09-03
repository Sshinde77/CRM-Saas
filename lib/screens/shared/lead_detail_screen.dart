import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../models/app_user.dart';
import '../../models/lead_detail_model.dart';
import '../../providers/api_provider.dart';
import '../../widgets/admin/admin_top_bar.dart';
import '../../widgets/admin/app_drawer.dart';
import '../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../admin/customers/customers_screen.dart';
import '../admin/customers/customer_details_screen.dart';
import '../admin/leads/admin_leads_screen.dart';
import '../admin/orders/admin_orders_screen.dart';
import '../admin/orders/new_admin_order_screen.dart';
import '../sales_manager/leads/add_lead_screen.dart';
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
  List<AppUser> _assignableStaff = [];
  final List<_LocalFollowUp> _localFollowUps = [];
  final List<_LocalVisit> _localVisits = [];

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
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Lead Status',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceSoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: const ['New', 'Contacted', 'Qualified', 'Lost']
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(selectedStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save Status'),
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

    if (nextStatus == null || nextStatus == lead.status) return;
    try {
      await _apiProvider.updateLead(
        leadId: lead.id,
        request: {'lead_status': nextStatus.toLowerCase()},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lead status updated')));
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Note'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Add a follow-up note or requirement...',
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
      await _apiProvider.updateLead(
        leadId: lead.id,
        request: {'notes': notes},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note added')));
      await _loadLead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add note: $error')),
      );
    }
  }

  void _showUnavailable(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _putIfNotBlank(Map<String, dynamic> payload, String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) payload[key] = trimmed;
  }

  String _responseVisitId(Map<String, dynamic> response) {
    final data = response['data'];
    final visit = response['visit'];
    final candidates = [
      response['visit_id'],
      response['visitId'],
      visit is Map<String, dynamic> ? visit['id'] : null,
      data is Map<String, dynamic> ? data['visit_id'] : null,
      data is Map<String, dynamic> ? data['visitId'] : null,
      data is Map<String, dynamic> ? data['id'] : null,
      response['id'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
    }
    return '';
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
      data is Map<String, dynamic> && data['customer'] is Map<String, dynamic>
          ? (data['customer'] as Map<String, dynamic>)['id']
          : null,
      data is Map<String, dynamic> ? data['id'] : null,
      response['id'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
    }
    return '';
  }

  Future<void> _openCustomer(LeadDetailModel lead) async {
    final customerId = lead.customerId.trim();
    if (customerId.isEmpty) {
      _showUnavailable('Customer detail is unavailable for this lead.');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(
          customerId: customerId,
        ),
      ),
    );
  }

  Future<void> _openFollowUpForm() async {
    final result = await showDialog<_LocalFollowUp>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _FollowUpSheet(staff: _assignableStaff),
    );
    if (result == null || !mounted) return;
    setState(() => _localFollowUps.insert(0, result));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Follow-up added')));
  }

  Future<void> _openVisitForm(LeadDetailModel lead) async {
    final result = await showDialog<_VisitFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _VisitSheet(staff: _assignableStaff),
    );
    if (result == null) return;

    try {
      final visitPayload = <String, dynamic>{
        'visit_date': DateTime.now().toIso8601String(),
        'visit_type': result.visitType,
        'status': 'completed',
        'lead_id': lead.id,
      };
      _putIfNotBlank(visitPayload, 'purpose', result.purpose);
      _putIfNotBlank(visitPayload, 'notes', result.notes);
      _putIfNotBlank(visitPayload, 'outcome', result.outcome);

      final visitResponse = await _apiProvider.createVisit(
        request: visitPayload,
      );
      final visitId = _responseVisitId(visitResponse);

      if (result.followUp != null && visitId.isNotEmpty) {
        await _apiProvider.createVisitFollowUp(
          visitId: visitId,
          request: result.followUp!.toApi(),
        );
      }

      if (!mounted) return;
      setState(() {
        _localVisits.insert(
          0,
          _LocalVisit(
            visitType: result.visitTypeLabel,
            purpose: result.purpose,
            notes: result.notes,
            outcome: result.outcome,
            createdAt: DateTime.now(),
            followUpTitle: result.followUp?.title,
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.followUp == null
                ? 'Visit logged'
                : 'Visit and follow-up task saved',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to log visit: $error')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lead converted')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to convert lead: $error')),
      );
    }
  }

  Widget _buildBottomActionBar(LeadDetailModel lead) {
    final normalizedStatus = lead.status.trim().toLowerCase();
    final hasCustomer =
        lead.customerId.trim().isNotEmpty || normalizedStatus.contains('converted');
    final isLost = normalizedStatus.contains('lost');

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
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
                label: hasCustomer ? 'View Customer' : 'Convert to Customer',
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
      bottomNavigationBar: _lead == null || _isLoading || _errorMessage != null
          ? null
          : _buildBottomActionBar(_lead!),
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
                  _buildJourneyCard(lead),
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
                              _buildInfoTile(
                                icon: Icons.business_center_outlined,
                                label: 'Lead Type',
                                value: lead.leadType,
                              ),
                              _buildInfoTile(
                                icon: Icons.segment_outlined,
                                label: 'Segment',
                                value: lead.segment,
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
                    title: 'Lead Information',
                    subtitle: 'Complete read-only lead profile',
                    child: _buildLeadInformationGrid(lead, compact),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Notes / Requirements',
                    subtitle:
                        'Context captured during lead creation or follow-up',
                    trailing: _smallActionButton(
                      icon: Icons.add_rounded,
                      label: 'Add Note',
                      onTap: () => _addNote(lead),
                    ),
                    child: _buildNotesList(lead),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Activity Timeline',
                    subtitle: 'Derived from current lead milestones',
                    child: _buildActivityTimeline(lead),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Activities',
                    subtitle: 'Follow-ups and visits linked to this lead',
                    child: _buildActivitiesPlaceholder(),
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
    final isConverted = lead.status.trim().toLowerCase().contains('converted');
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
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () => _openEditLead(lead),
              ),
              if (!isConverted)
                _smallActionButton(
                  icon: Icons.swap_horizontal_circle_outlined,
                  label: 'Status',
                  onTap: () => _updateLeadStatus(lead),
                ),
              _smallActionButton(
                icon: Icons.add_comment_outlined,
                label: 'Note',
                onTap: () => _addNote(lead),
              ),
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

  Widget _buildJourneyCard(LeadDetailModel lead) {
    final stages = const ['New', 'Contacted', 'Qualified', 'Converted'];
    final normalized = lead.status.trim().toLowerCase();
    final isLost = normalized.contains('lost');
    final currentIndex = isLost
        ? -1
        : stages.indexWhere(
            (stage) => stage.toLowerCase() == normalized,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lead Journey',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              if (compact) {
                return Column(
                  children: [
                    for (var i = 0; i < stages.length; i++)
                      _JourneyStep(
                        label: stages[i],
                        active: !isLost && i == currentIndex,
                        completed: !isLost && currentIndex > i,
                        lost: isLost && i == 0,
                        vertical: true,
                      ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < stages.length; i++) ...[
                    Expanded(
                      child: _JourneyStep(
                        label: stages[i],
                        active: !isLost && i == currentIndex,
                        completed: !isLost && currentIndex > i,
                        lost: isLost && i == 0,
                      ),
                    ),
                    if (i != stages.length - 1)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            height: 2,
                            color: _journeyLineColor(i, currentIndex, isLost),
                          ),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
          if (isLost) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: const Text(
                'This lead was marked Lost.',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _journeyLineColor(int lineIndex, int currentIndex, bool isLost) {
    if (isLost) return AppColors.border;
    return currentIndex > lineIndex ? AppColors.primary900 : AppColors.border;
  }

  Widget _buildLeadInformationGrid(LeadDetailModel lead, bool compact) {
    final products = _splitProducts(lead.interestedProduct);
    final fields = [
      _buildInfoTile(
        icon: Icons.campaign_outlined,
        label: 'Source',
        value: lead.source,
      ),
      _buildInfoTile(
        icon: Icons.person_outline_rounded,
        label: 'Assigned Salesperson',
        value: lead.assignedTo,
      ),
      _buildInfoTile(
        icon: Icons.verified_outlined,
        label: 'Status',
        value: lead.status,
      ),
      _buildInfoTile(
        icon: Icons.business_center_outlined,
        label: 'Lead Type',
        value: lead.leadType,
      ),
      _buildInfoTile(
        icon: Icons.segment_outlined,
        label: 'Segment',
        value: lead.segment,
      ),
      _buildInfoTile(
        icon: Icons.schedule_rounded,
        label: 'Created Date',
        value: _formatDate(lead.createdAt),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 0,
          children: [
            for (final field in fields)
              SizedBox(width: compact ? double.infinity : 340, child: field),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Interested Products',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        products.isEmpty
            ? const Text(
                '-',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final product in products)
                    Chip(
                      label: Text(product),
                      labelStyle: const TextStyle(
                        color: AppColors.primary900,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                      backgroundColor: AppColors.activeMenuBg,
                      side: const BorderSide(color: AppColors.border),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
      ],
    );
  }

  Widget _buildNotesList(LeadDetailModel lead) {
    final notes = _parseNotes(lead.notes);
    if (notes.isEmpty) {
      return const _EmptyInlineState(
        icon: Icons.sticky_note_2_outlined,
        text: 'No notes added yet.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < notes.length; i++) ...[
          _NoteCard(note: notes[i]),
          if (i != notes.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildActivityTimeline(LeadDetailModel lead) {
    final events = <_TimelineEvent>[
      if (lead.createdAt.trim().isNotEmpty)
        _TimelineEvent(
          icon: Icons.add_circle_outline_rounded,
          title: 'Lead created',
          subtitle: lead.displayName,
          time: _formatDate(lead.createdAt),
        ),
      if (lead.assignedTo.trim().isNotEmpty && lead.assignedTo != '-')
        _TimelineEvent(
          icon: Icons.assignment_ind_outlined,
          title: 'Lead assigned',
          subtitle: lead.assignedTo,
          time: _formatDate(lead.createdAt),
        ),
      if (lead.status.trim().isNotEmpty)
        _TimelineEvent(
          icon: Icons.flag_outlined,
          title: 'Current status: ${lead.status}',
          subtitle: _statusSubtitle(lead.status),
          time: _formatDate(
            lead.updatedAt.isEmpty ? lead.createdAt : lead.updatedAt,
          ),
        ),
      if (lead.followUpDate.trim().isNotEmpty)
        _TimelineEvent(
          icon: Icons.event_available_outlined,
          title: 'Next follow-up planned',
          subtitle: 'Follow-up with the prospect',
          time: _formatDate(lead.followUpDate),
        ),
    ];

    if (events.isEmpty) {
      return const _EmptyInlineState(
        icon: Icons.timeline_outlined,
        text: 'No activity recorded yet.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _TimelineTile(event: events[i], isLast: i == events.length - 1),
      ],
    );
  }

  Widget _buildActivitiesPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_localFollowUps.isEmpty && _localVisits.isEmpty)
          const _ActivityTabsPlaceholder()
        else ...[
          if (_localFollowUps.isNotEmpty) ...[
            const _ActivityGroupTitle('Follow-ups'),
            const SizedBox(height: 8),
            for (final item in _localFollowUps) ...[
              _FollowUpCard(item: item),
              const SizedBox(height: 8),
            ],
          ],
          if (_localVisits.isNotEmpty) ...[
            const SizedBox(height: 4),
            const _ActivityGroupTitle('Visits'),
            const SizedBox(height: 8),
            for (final item in _localVisits) ...[
              _VisitCard(item: item),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
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

    if (normalized.contains('lost')) {
      background = const Color(0xFFFFE4E6);
      foreground = const Color(0xFFB91C1C);
    } else if (normalized.contains('converted')) {
      background = AppColors.statusActiveBg;
      foreground = AppColors.statusActiveText;
    } else if (normalized.contains('qualified')) {
      background = const Color(0xFFE9F5E4);
      foreground = AppColors.primary900;
    } else if (normalized.contains('contact') || normalized.contains('follow')) {
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

class _JourneyStep extends StatelessWidget {
  final String label;
  final bool active;
  final bool completed;
  final bool lost;
  final bool vertical;

  const _JourneyStep({
    required this.label,
    required this.active,
    required this.completed,
    required this.lost,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = lost
        ? const Color(0xFFDC2626)
        : active || completed
        ? AppColors.primary
        : AppColors.textLightMuted;
    final bg = lost
        ? const Color(0xFFFFE4E6)
        : active || completed
        ? AppColors.activeMenuBg
        : AppColors.surfaceSoft;
    final icon = lost
        ? Icons.close_rounded
        : completed || active
        ? Icons.check_rounded
        : Icons.circle_outlined;

    return Padding(
      padding: EdgeInsets.only(bottom: vertical ? 10 : 0),
      child: vertical
          ? Row(
              children: [
                _journeyCircle(bg, color, icon),
                const SizedBox(width: 10),
                Expanded(child: _journeyLabel(color)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _journeyCircle(bg, color, icon),
                const SizedBox(height: 10),
                _journeyLabel(color),
              ],
            ),
    );
  }

  Widget _journeyCircle(Color bg, Color color, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _journeyLabel(Color color) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
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
    final background = filled && enabled ? AppColors.primary : Colors.white;
    final foreground = filled && enabled
        ? Colors.white
        : enabled
        ? AppColors.primary
        : AppColors.textLightMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: filled && enabled ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
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

class _FollowUpSheet extends StatefulWidget {
  final List<AppUser> staff;

  const _FollowUpSheet({required this.staff});

  @override
  State<_FollowUpSheet> createState() => _FollowUpSheetState();
}

class _FollowUpSheetState extends State<_FollowUpSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  String _priority = 'medium';
  String? _assigneeId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now();
    _dueTime = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Add Follow-up',
      icon: Icons.playlist_add_check_rounded,
      child: Column(
        children: [
          _SheetTextField(
            label: 'Follow-up Title *',
            hint: 'e.g. Call to confirm quantity',
            controller: _titleController,
            errorText: _error,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Description',
            hint: 'Add action notes',
            controller: _descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DatePickerTile(
                  label: 'Due Date',
                  value: _formatDate(_dueDate.toIso8601String()),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DatePickerTile(
                  label: 'Due Time',
                  value: _formatTime(_dueTime),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SheetDropdown<String>(
            label: 'Priority',
            value: _priority,
            items: const ['low', 'medium', 'high', 'urgent'],
            itemLabel: _priorityLabel,
            onChanged: (value) => setState(() => _priority = value ?? 'medium'),
          ),
          const SizedBox(height: 12),
          _SheetDropdown<String>(
            label: 'Assignee',
            value: _assigneeId,
            hint: 'Defaults to you if left blank',
            items: widget.staff.map((user) => user.id).toList(),
            itemLabel: (id) => _staffName(id, widget.staff),
            onChanged: (value) => setState(() => _assigneeId = value),
          ),
          const SizedBox(height: 18),
          _SheetActions(
            primaryLabel: 'Add Follow-up',
            onPrimary: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _dueTime);
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Enter a follow-up task title.');
      return;
    }
    Navigator.of(context).pop(
      _LocalFollowUp(
        title: title,
        description: _descriptionController.text.trim(),
        dueAt: _combineDateTime(_dueDate, _dueTime),
        priority: _priority,
        assigneeName: _staffName(_assigneeId, widget.staff),
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
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  String _visitType = 'site_visit';
  bool _createTask = false;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  String _priority = 'medium';
  String? _assigneeId;
  String? _taskError;

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now();
    _dueTime = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    _outcomeController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Log Visit',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _SheetDropdown<String>(
            label: 'Visit Type',
            value: _visitType,
            items: const ['site_visit', 'meeting', 'call', 'audit'],
            itemLabel: _visitTypeLabel,
            onChanged: (value) =>
                setState(() => _visitType = value ?? 'site_visit'),
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Purpose',
            hint: 'e.g. Requirement check',
            controller: _purposeController,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Notes',
            hint: 'Visit notes',
            controller: _notesController,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Outcome',
            hint: 'What happened during the visit?',
            controller: _outcomeController,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _createTask,
            activeColor: AppColors.primary,
            title: const Text(
              'Create Follow-up Task',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onChanged: (value) =>
                setState(() => _createTask = value ?? false),
          ),
          if (_createTask) ...[
            _SheetTextField(
              label: 'Task Title *',
              hint: 'Call to confirm quantity',
              controller: _taskTitleController,
              errorText: _taskError,
            ),
            const SizedBox(height: 12),
            _SheetTextField(
              label: 'Action / Notes',
              hint: 'Discuss next action',
              controller: _taskDescriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Due Date',
                    value: _formatDate(_dueDate.toIso8601String()),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DatePickerTile(
                    label: 'Due Time',
                    value: _formatTime(_dueTime),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SheetDropdown<String>(
              label: 'Priority',
              value: _priority,
              items: const ['low', 'medium', 'high', 'urgent'],
              itemLabel: _priorityLabel,
              onChanged: (value) =>
                  setState(() => _priority = value ?? 'medium'),
            ),
            const SizedBox(height: 12),
            _SheetDropdown<String>(
              label: 'Assignee',
              value: _assigneeId,
              hint: 'Defaults to you if left blank',
              items: widget.staff.map((user) => user.id).toList(),
              itemLabel: (id) => _staffName(id, widget.staff),
              onChanged: (value) => setState(() => _assigneeId = value),
            ),
          ],
          const SizedBox(height: 18),
          _SheetActions(primaryLabel: 'Save Visit', onPrimary: _submit),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _dueTime);
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _submit() {
    _VisitFollowUpRequest? followUp;
    if (_createTask) {
      final title = _taskTitleController.text.trim();
      if (title.isEmpty) {
        setState(() => _taskError = 'Enter a follow-up task title.');
        return;
      }
      followUp = _VisitFollowUpRequest(
        title: title,
        description: _taskDescriptionController.text.trim(),
        dueAt: _combineDateTime(_dueDate, _dueTime),
        priority: _priority,
        assigneeId: _assigneeId,
      );
    }
    Navigator.of(context).pop(
      _VisitFormResult(
        visitType: _visitType,
        visitTypeLabel: _visitTypeLabel(_visitType),
        purpose: _purposeController.text.trim(),
        notes: _notesController.text.trim(),
        outcome: _outcomeController.text.trim(),
        followUp: followUp,
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
  late final TextEditingController _creditLimitController;
  late final TextEditingController _openingBalanceController;
  late final TextEditingController _mapsController;
  late final TextEditingController _billingAddressController;
  late final TextEditingController _deliveryAddressController;
  late final TextEditingController _notesController;
  String _customerType = 'business';
  String _status = 'active';
  String? _category;
  String? _salesOfficerId;
  late DateTime _customerSince;
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead.companyName == '-'
        ? widget.lead.displayName
        : widget.lead.companyName);
    _contactController = TextEditingController(text: widget.lead.contactName);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _emailController = TextEditingController(text: widget.lead.email);
    _gstController = TextEditingController();
    _creditLimitController = TextEditingController();
    _openingBalanceController = TextEditingController();
    _mapsController = TextEditingController();
    _billingAddressController = TextEditingController(text: widget.lead.address == '-' ? '' : widget.lead.address);
    _deliveryAddressController = TextEditingController(text: widget.lead.address == '-' ? '' : widget.lead.address);
    _notesController = TextEditingController(text: widget.lead.notes == '-' ? '' : widget.lead.notes);
    _customerSince = DateTime.now();
    _salesOfficerId = _matchingStaffId(widget.lead.assignedTo, widget.staff);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _creditLimitController.dispose();
    _openingBalanceController.dispose();
    _mapsController.dispose();
    _billingAddressController.dispose();
    _deliveryAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Convert to Customer',
      icon: Icons.person_add_alt_1_outlined,
      child: Column(
        children: [
          _SheetTextField(
            label: 'Business / Customer Name *',
            hint: 'Customer name',
            controller: _nameController,
            errorText: _nameError,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Primary Contact Person',
            hint: 'Contact person',
            controller: _contactController,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Phone *',
            hint: 'Phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Email',
            hint: 'Email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetDropdown<String>(
                  label: 'Customer Type',
                  value: _customerType,
                  items: const [
                    'individual',
                    'business',
                    'government',
                    'dealer',
                    'distributor',
                    'vendor',
                  ],
                  itemLabel: _titleCase,
                  onChanged: (value) =>
                      setState(() => _customerType = value ?? 'business'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetDropdown<String>(
                  label: 'Status',
                  value: _status,
                  items: const ['active', 'inactive', 'blacklisted', 'prospect'],
                  itemLabel: _titleCase,
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'active'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DatePickerTile(
                  label: 'Customer Since',
                  value: _apiDate(_customerSince),
                  onTap: _pickCustomerSince,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetDropdown<String>(
                  label: 'Category',
                  value: _category,
                  hint: 'No category',
                  items: const [
                    'Retail',
                    'Wholesale',
                    'Corporate',
                    'VIP',
                    'Dealer',
                    'Distributor',
                  ],
                  itemLabel: (value) => value,
                  onChanged: (value) => setState(() => _category = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SheetDropdown<String>(
            label: 'Assigned Sales Officer',
            value: _salesOfficerId,
            hint: 'Defaults to current assignment',
            items: widget.staff.map((user) => user.id).toList(),
            itemLabel: (id) => _staffName(id, widget.staff),
            onChanged: (value) => setState(() => _salesOfficerId = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetTextField(
                  label: 'GST Number',
                  hint: 'GST number',
                  controller: _gstController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetTextField(
                  label: 'Maps Location',
                  hint: '19.076,72.877 or Maps URL',
                  controller: _mapsController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetTextField(
                  label: 'Credit Limit',
                  hint: '0.00',
                  controller: _creditLimitController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetTextField(
                  label: 'Opening Balance',
                  hint: '0.00',
                  controller: _openingBalanceController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Billing Address',
            hint: 'Billing address',
            controller: _billingAddressController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Delivery Address',
            hint: 'Delivery address',
            controller: _deliveryAddressController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _SheetTextField(
            label: 'Notes',
            hint: 'Customer notes',
            controller: _notesController,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          _SheetActions(primaryLabel: 'Convert', onPrimary: _submit),
        ],
      ),
    );
  }

  Future<void> _pickCustomerSince() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customerSince,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _customerSince = picked);
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(() {
        _nameError = name.isEmpty ? 'Business / customer name is required.' : null;
        _phoneError = phone.isEmpty ? 'Phone is required.' : null;
      });
      return;
    }

    final payload = <String, dynamic>{
      'name': name,
      'phone': phone,
      'customer_type': _customerType,
      'status': _status,
      'customer_since': _apiDate(_customerSince),
    };
    _putPayload(payload, 'primary_contact_person', _contactController.text);
    _putPayload(payload, 'email', _emailController.text);
    _putPayload(payload, 'gst_number', _gstController.text);
    _putPayload(payload, 'category', _category);
    _putPayload(payload, 'assigned_sales_officer_id', _salesOfficerId);
    _putPayload(payload, 'billing_address', _billingAddressController.text);
    _putPayload(payload, 'delivery_address', _deliveryAddressController.text);
    _putPayload(payload, 'notes', _notesController.text);
    _putNumber(payload, 'credit_limit', _creditLimitController.text);
    _putNumber(payload, 'opening_balance', _openingBalanceController.text);

    final coords = _parseCoordinates(_mapsController.text);
    if (coords != null) {
      payload['maps_latitude'] = coords.latitude;
      payload['maps_longitude'] = coords.longitude;
    }

    Navigator.of(context).pop(payload);
  }
}

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
    final size = MediaQuery.sizeOf(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableWidth = math.max(320.0, size.width - 28);
    final availableHeight = math.max(320.0, size.height - keyboardInset - 56);
    final side = math.min(math.min(availableWidth, availableHeight), 560.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      backgroundColor: Colors.transparent,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Center(
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.activeMenuBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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

class _SheetTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? errorText;

  const _SheetTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetFieldLabel(
      label: label,
      errorText: errorText,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: _sheetInputDecoration(hint, errorText: errorText),
      ),
    );
  }
}

class _SheetDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String? hint;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetFieldLabel(
      label: label,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: _sheetInputDecoration(hint ?? 'Select'),
        items: [
          if (hint != null)
            DropdownMenuItem<T>(
              value: null,
              child: Text(hint!, overflow: TextOverflow.ellipsis),
            ),
          ...items.map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _SheetFieldLabel extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const _SheetFieldLabel({
    required this.label,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetFieldLabel(
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
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

class _SheetActions extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onPrimary;

  const _SheetActions({required this.primaryLabel, required this.onPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onPrimary,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}

class _ActivityGroupTitle extends StatelessWidget {
  final String text;

  const _ActivityGroupTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final _LocalFollowUp item;

  const _FollowUpCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _ActivityRecordCard(
      icon: Icons.playlist_add_check_rounded,
      title: item.title,
      badge: _priorityLabel(item.priority),
      lines: [
        _formatDateTime(item.dueAt),
        if (item.assigneeName.isNotEmpty) item.assigneeName,
        if (item.description.isNotEmpty) item.description,
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  final _LocalVisit item;

  const _VisitCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _ActivityRecordCard(
      icon: Icons.location_on_outlined,
      title: item.visitType,
      badge: 'Completed',
      lines: [
        _formatDateTime(item.createdAt),
        if (item.purpose.isNotEmpty) item.purpose,
        if (item.notes.isNotEmpty) item.notes,
        if (item.outcome.isNotEmpty) 'Outcome: ${item.outcome}',
        if ((item.followUpTitle ?? '').isNotEmpty)
          'Follow-up: ${item.followUpTitle}',
      ],
    );
  }
}

class _ActivityRecordCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final List<String> lines;

  const _ActivityRecordCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _MiniBadge(badge),
                  ],
                ),
                const SizedBox(height: 5),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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

class _MiniBadge extends StatelessWidget {
  final String text;

  const _MiniBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.activeMenuBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary900,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final _ParsedNote note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.timestamp.isNotEmpty) ...[
                  Text(
                    note.timestamp,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  note.text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
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

class _TimelineTile extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;

  const _TimelineTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.activeMenuBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(event.icon, size: 16, color: AppColors.primary),
            ),
            if (!isLast)
              Container(width: 2, height: 32, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (event.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          event.subtitle,
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
                const SizedBox(width: 8),
                Text(
                  event.time,
                  style: const TextStyle(
                    color: AppColors.textLightMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
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

class _ActivityTabsPlaceholder extends StatelessWidget {
  const _ActivityTabsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _EmptyInlineState(
              icon: Icons.playlist_add_check_rounded,
              text: 'No follow-ups for this lead yet.',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _EmptyInlineState(
              icon: Icons.location_on_outlined,
              text: 'No visits recorded for this lead yet.',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInlineState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyInlineState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParsedNote {
  final String timestamp;
  final String text;

  const _ParsedNote({required this.timestamp, required this.text});
}

class _TimelineEvent {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _TimelineEvent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

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
  final String? followUpTitle;

  const _LocalVisit({
    required this.visitType,
    required this.purpose,
    required this.notes,
    required this.outcome,
    required this.createdAt,
    this.followUpTitle,
  });
}

class _VisitFormResult {
  final String visitType;
  final String visitTypeLabel;
  final String purpose;
  final String notes;
  final String outcome;
  final _VisitFollowUpRequest? followUp;

  const _VisitFormResult({
    required this.visitType,
    required this.visitTypeLabel,
    required this.purpose,
    required this.notes,
    required this.outcome,
    this.followUp,
  });
}

class _VisitFollowUpRequest {
  final String title;
  final String description;
  final DateTime dueAt;
  final String priority;
  final String? assigneeId;

  const _VisitFollowUpRequest({
    required this.title,
    required this.description,
    required this.dueAt,
    required this.priority,
    this.assigneeId,
  });

  Map<String, dynamic> toApi() {
    final payload = <String, dynamic>{
      'title': title,
      'due_date': dueAt.toIso8601String(),
      'priority': priority,
    };
    _putPayload(payload, 'description', description);
    _putPayload(payload, 'assigned_to_id', assigneeId);
    return payload;
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

String _manualStatusValue(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'contacted') return 'Contacted';
  if (normalized == 'qualified') return 'Qualified';
  if (normalized == 'lost') return 'Lost';
  return 'New';
}

String _statusSubtitle(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized.contains('converted')) return 'Lead has been converted.';
  if (normalized.contains('qualified')) return 'Lead is ready for conversion.';
  if (normalized.contains('contact')) return 'Prospect has been contacted.';
  if (normalized.contains('lost')) return 'Lead is no longer active.';
  return 'Lead is newly captured.';
}

List<String> _splitProducts(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty && item != '-')
      .toList();
}

List<_ParsedNote> _parseNotes(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == '-') return const [];
  return trimmed
      .split(RegExp(r'\n\s*\n'))
      .map((entry) {
        final text = entry.trim();
        final match = RegExp(r'^\[(.+?)\]\s*(.*)$', dotAll: true).firstMatch(text);
        if (match == null) {
          return _ParsedNote(timestamp: '', text: text);
        }
        return _ParsedNote(
          timestamp: match.group(1)?.trim() ?? '',
          text: match.group(2)?.trim() ?? text,
        );
      })
      .where((note) => note.text.isNotEmpty)
      .toList();
}

InputDecoration _sheetInputDecoration(String hint, {String? errorText}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textLightMuted, fontSize: 12),
    errorText: null,
    filled: true,
    fillColor: AppColors.surfaceSoft,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: errorText == null ? AppColors.border : const Color(0xFFDC2626),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
  );
}

String _priorityLabel(String value) => _titleCase(value);

String _visitTypeLabel(String value) {
  switch (value) {
    case 'site_visit':
      return 'Site Visit';
    case 'meeting':
      return 'Meeting';
    case 'call':
      return 'Call';
    case 'audit':
      return 'Audit';
    default:
      return _titleCase(value);
  }
}

String _titleCase(String value) {
  return value
      .split(RegExp(r'[_\s-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _staffName(String? id, List<AppUser> staff) {
  if (id == null || id.trim().isEmpty) return '';
  for (final user in staff) {
    if (user.id == id) return user.name;
  }
  return '';
}

String? _matchingStaffId(String name, List<AppUser> staff) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty || normalized == '-') return null;
  for (final user in staff) {
    if (user.name.trim().toLowerCase() == normalized) return user.id;
  }
  return null;
}

void _putPayload(Map<String, dynamic> payload, String key, String? value) {
  final trimmed = value?.trim();
  if (trimmed != null && trimmed.isNotEmpty && trimmed != '-') {
    payload[key] = trimmed;
  }
}

void _putNumber(Map<String, dynamic> payload, String key, String value) {
  final number = num.tryParse(value.trim());
  if (number != null) payload[key] = number;
}

class _Coordinates {
  final double latitude;
  final double longitude;

  const _Coordinates({required this.latitude, required this.longitude});
}

_Coordinates? _parseCoordinates(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  final match = RegExp(r'(-?\d+(?:\.\d+)?)[,\s]+(-?\d+(?:\.\d+)?)')
      .firstMatch(text);
  if (match == null) return null;
  final lat = double.tryParse(match.group(1) ?? '');
  final lng = double.tryParse(match.group(2) ?? '');
  if (lat == null || lng == null) return null;
  return _Coordinates(latitude: lat, longitude: lng);
}

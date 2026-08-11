import 'package:flutter/material.dart';

import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../customers/sales_manager_customers_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../orders/sales_manager_orders_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _leadIdController = TextEditingController(text: 'LEAD-1008');
  final _customerController = TextEditingController();
  final _leadSourceController = TextEditingController();
  final _assignedSalespersonController = TextEditingController();
  final _leadStatusController = TextEditingController(text: 'New');
  final _contactNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _productController = TextEditingController();
  final _expectedValueController = TextEditingController();
  final _closingDateController = TextEditingController();
  final _notesController = TextEditingController();

  int _currentStep = 0;

  final List<_LeadStep> _steps = const [
    _LeadStep('Lead Information', Icons.info_outline_rounded),
    _LeadStep('Contact Information', Icons.call_outlined),
    _LeadStep('Interest Details', Icons.inventory_2_outlined),
    _LeadStep('Sales Follow-up', Icons.support_agent_rounded),
  ];

  final List<String> _leadSources = const [
    'Website',
    'Referral',
    'Walk-in',
    'Social Media',
    'Advertisement',
  ];

  final List<String> _salespeople = const [
    'Sunil Sales',
    'Neha Sharma',
    'Amit Verma',
  ];

  final List<String> _leadStatuses = const [
    'New',
    'Follow-up',
    'Qualified',
    'Lost',
  ];

  @override
  void dispose() {
    _leadIdController.dispose();
    _customerController.dispose();
    _leadSourceController.dispose();
    _assignedSalespersonController.dispose();
    _leadStatusController.dispose();
    _contactNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _productController.dispose();
    _expectedValueController.dispose();
    _closingDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Leads') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerCustomersScreen()),
      );
      return;
    }
    if (action == 'Create Order' || action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerOrdersScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Leads',
      ),
      body: SafeArea(
        child: Column(
          children: [
            SalesManagerTopBar(title: 'Add Lead'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          border: Border(
                            right: BorderSide(color: const Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            for (var i = 0; i < _steps.length; i++) ...[
                              _StepTile(
                                title: _steps[i].title,
                                icon: _steps[i].icon,
                                selected: _currentStep == i,
                                onTap: () => setState(() => _currentStep = i),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                22,
                                22,
                                16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Lead Information',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Lead identity, source, customer, and ownership.',
                                          style: TextStyle(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF0F172A),
                                      side: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('Back to Leads'),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  20,
                                  22,
                                  22,
                                ),
                                child: _buildCurrentStepForm(),
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                18,
                                22,
                                18,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _currentStep == 0
                                        ? null
                                        : () => setState(() => _currentStep--),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF9CA3AF),
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Back'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_currentStep < _steps.length - 1) {
                                        setState(() => _currentStep++);
                                        return;
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B4A06),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _currentStep < _steps.length - 1
                                          ? 'Next'
                                          : 'Save Lead',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepForm() {
    switch (_currentStep) {
      case 0:
        return _twoColumnForm([
          _FormField(
            label: 'Lead ID *',
            controller: _leadIdController,
            hintText: 'LEAD-1008',
          ),
          _FormDropdown(
            label: 'Lead Source *',
            value: _leadSourceController.text.isEmpty
                ? null
                : _leadSourceController.text,
            hintText: 'Select lead source',
            items: _leadSources,
            onChanged: (value) => setState(() {
              _leadSourceController.text = value ?? '';
            }),
          ),
          _FormSearchField(
            label: 'Customer *',
            hintText: 'Search or create customer',
            controller: _customerController,
          ),
          _FormDropdown(
            label: 'Assigned Salesperson *',
            value: _assignedSalespersonController.text.isEmpty
                ? null
                : _assignedSalespersonController.text,
            hintText: 'Select salesperson',
            items: _salespeople,
            onChanged: (value) => setState(() {
              _assignedSalespersonController.text = value ?? '';
            }),
          ),
          _FormDropdown(
            label: 'Lead Status *',
            value: _leadStatusController.text,
            hintText: 'Select lead status',
            items: _leadStatuses,
            onChanged: (value) => setState(() {
              _leadStatusController.text = value ?? '';
            }),
            fullWidth: true,
          ),
        ]);
      case 1:
        return _twoColumnForm([
          _FormField(
            label: 'Contact Person Name',
            controller: _contactNameController,
            hintText: 'Enter contact name',
          ),
          _FormField(
            label: 'Mobile Number',
            controller: _mobileController,
            hintText: 'Enter mobile number',
            keyboardType: TextInputType.phone,
          ),
          _FormField(
            label: 'Email',
            controller: _emailController,
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
        ]);
      case 2:
        return _twoColumnForm([
          _FormField(
            label: 'Product Interest',
            controller: _productController,
            hintText: 'Enter product interest',
            fullWidth: true,
          ),
          _FormField(
            label: 'Expected Value',
            controller: _expectedValueController,
            hintText: '0',
            keyboardType: TextInputType.number,
          ),
          _FormField(
            label: 'Expected Closing Date',
            controller: _closingDateController,
            hintText: 'Select date',
          ),
        ]);
      case 3:
      default:
        return _twoColumnForm([
          _FormField(
            label: 'Notes',
            controller: _notesController,
            hintText: 'Add follow-up notes',
            fullWidth: true,
            maxLines: 5,
          ),
        ]);
    }
  }

  Widget _twoColumnForm(List<Widget> fields) {
    final fullWidth = fields
        .whereType<_FormField>()
        .where((f) => f.fullWidth)
        .toList();
    final halfWidth = fields
        .whereType<_FormField>()
        .where((f) => !f.fullWidth)
        .toList();
    final dropdowns = fields.whereType<_FormDropdown>().toList();
    final searches = fields.whereType<_FormSearchField>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentStep == 0) const SizedBox.shrink(),
        if (_currentStep == 0)
          Row(
            children: [
              Expanded(child: fields[0]),
              const SizedBox(width: 18),
              Expanded(child: fields[1]),
            ],
          ),
        if (_currentStep == 0) const SizedBox(height: 18),
        if (_currentStep == 0)
          Row(
            children: [
              Expanded(child: fields[2]),
              const SizedBox(width: 18),
              Expanded(child: fields[3]),
            ],
          ),
        if (_currentStep == 0) const SizedBox(height: 18),
        if (_currentStep == 0) fields[4],
        if (_currentStep == 0) const SizedBox(height: 12),
        if (_currentStep == 1) ...[
          Row(
            children: [
              Expanded(child: fields[0]),
              const SizedBox(width: 18),
              Expanded(child: fields[1]),
            ],
          ),
          const SizedBox(height: 18),
          fields[2],
        ],
        if (_currentStep == 2) ...[
          fields[0],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: fields[1]),
              const SizedBox(width: 18),
              Expanded(child: fields[2]),
            ],
          ),
        ],
        if (_currentStep == 3) fields[0],
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StepTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFFD1D5DB) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xFF0B4A06)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF0B4A06)
                      : const Color(0xFF64748B),
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadStep {
  final String title;
  final IconData icon;

  const _LeadStep(this.title, this.icon);
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool fullWidth;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(hintText),
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool fullWidth;

  const _FormDropdown({
    required this.label,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: DropdownButtonFormField<String>(
        key: ValueKey<String?>(value),
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8),
        ),
        decoration: _inputDecoration(hintText),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _FormSearchField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;

  const _FormSearchField({
    required this.label,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(hintText),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0B4A06)),
    ),
  );
}

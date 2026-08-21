import 'package:flutter/material.dart';

import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
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
  final Set<String> _selectedInterestProducts = <String>{};

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

  final List<String> _interestProducts = const [
    'Packaged Drinking Water (250ml)',
    'Packaged Drinking Water (500ml)',
    'Packaged Drinking Water (1L)',
    'Packaged Drinking Water (2L)',
    'Natural Mineral Water (500ml)',
    'Natural Mineral Water (1L)',
    'Sparkling Water (300ml)',
    'Sparkling Water (750ml)',
    'Water Jar Refill (20L)',
    'Water Jar (New, with can) (20L)',
    'Flavored Water - Lemon (500ml)',
    'Flavored Water - Orange (500ml)',
    'Alkaline Water (500ml)',
    'Alkaline Water (1L)',
    'Water Dispenser - Hot & Cold (Standard)',
    'Water Dispenser - Normal (Standard)',
    'Dispenser Tap (Standard)',
    'Bottle Stand (Standard)',
  ];

  Future<void> _pickClosingDate() async {
    final now = DateTime.now();
    final initialDate = _parseDate(_closingDateController.text) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B4A06),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _closingDateController.text =
          '${picked.day.toString().padLeft(2, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.year}';
    });
  }

  DateTime? _parseDate(String text) {
    final parts = text.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 980;

            return Column(
              children: [
                _buildTopBar(),
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
                      child: isCompact
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    18,
                                    18,
                                    14,
                                  ),
                                  child: _buildCompactStepper(),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                                Expanded(child: _buildLeadFormPanel(context)),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: 320,
                                  child: _buildDesktopStepper(),
                                ),
                                const VerticalDivider(
                                  width: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                                Expanded(child: _buildLeadFormPanel(context)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          ),
          const Text(
            'Leads',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _topIconButton(Icons.help_outline_rounded),
          const SizedBox(width: 10),
          _topIconButton(Icons.notifications_none_rounded),
          const SizedBox(width: 10),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4A06),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sunil Sales',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Sales Officer',
                    style: TextStyle(
                      color: Color(0xFF0B4A06),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadFormPanel(BuildContext context) {
    final step = _steps[_currentStep];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _stepSubtitle(_currentStep),
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: _buildCurrentStepForm(),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
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
                    borderRadius: BorderRadius.circular(999),
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
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  _currentStep < _steps.length - 1 ? 'Next' : 'Save Lead',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStepper() {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lead Steps',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < _steps.length; i++) ...[
              _CircleStepTile(
                index: i + 1,
                title: _steps[i].title,
                icon: _steps[i].icon,
                selected: _currentStep == i,
                completed: _currentStep > i,
                onTap: () => setState(() => _currentStep = i),
              ),
              if (i != _steps.length - 1)
                Container(
                  margin: const EdgeInsets.only(left: 22),
                  width: 2,
                  height: 28,
                  color: const Color(0xFFE5E7EB),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lead Steps',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                _CompactCircleStep(
                  index: i + 1,
                  title: _steps[i].title,
                  icon: _steps[i].icon,
                  selected: _currentStep == i,
                  completed: _currentStep > i,
                  onTap: () => setState(() => _currentStep = i),
                ),
                if (i != _steps.length - 1)
                  Container(
                    width: 32,
                    height: 2,
                    color: const Color(0xFFE5E7EB),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _stepSubtitle(int step) {
    switch (step) {
      case 0:
        return 'Lead identity, source, customer, and ownership.';
      case 1:
        return 'Contact details for the primary lead owner.';
      case 2:
        return 'Products, budget, and expected closure timing.';
      case 3:
      default:
        return 'Notes and follow-up details before saving the lead.';
    }
  }

  Widget _topIconButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
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
        return _buildInterestDetailsStep();
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

  Widget _buildInterestDetailsStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;
        final cardWidth = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - 24) / 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interested Products',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 14,
              children: [
                for (final product in _interestProducts)
                  SizedBox(
                    width: cardWidth,
                    child: _InterestProductCard(
                      label: product,
                      selected: _selectedInterestProducts.contains(product),
                      onTap: () {
                        setState(() {
                          if (_selectedInterestProducts.contains(product)) {
                            _selectedInterestProducts.remove(product);
                          } else {
                            _selectedInterestProducts.add(product);
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, innerConstraints) {
                final stacked = innerConstraints.maxWidth < 700;

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormField(
                        label: 'Expected Budget',
                        controller: _expectedValueController,
                        hintText: 'Estimated customer budget',
                        keyboardType: TextInputType.number,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 18),
                      _FormField(
                        label: 'Expected Closing Date',
                        controller: _closingDateController,
                        hintText: 'dd-mm-yyyy',
                        readOnly: true,
                        onTap: _pickClosingDate,
                        suffixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        fullWidth: true,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Expected Budget',
                        controller: _expectedValueController,
                        hintText: 'Estimated customer budget',
                        keyboardType: TextInputType.number,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _FormField(
                        label: 'Expected Closing Date',
                        controller: _closingDateController,
                        hintText: 'dd-mm-yyyy',
                        readOnly: true,
                        onTap: _pickClosingDate,
                        suffixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        fullWidth: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _twoColumnForm(List<Widget> fields) {
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

class _CircleStepTile extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _CircleStepTile({
    required this.index,
    required this.title,
    required this.icon,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = selected || completed
        ? const Color(0xFF0B4A06)
        : const Color(0xFFE5E7EB);
    final iconColor = selected || completed
        ? Colors.white
        : const Color(0xFF6B7280);
    final textColor = selected
        ? const Color(0xFF0B4A06)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFD1D5DB) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $index',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCircleStep extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _CompactCircleStep({
    required this.index,
    required this.title,
    required this.icon,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = selected || completed
        ? const Color(0xFF0B4A06)
        : const Color(0xFFE5E7EB);
    final iconColor = selected || completed
        ? Colors.white
        : const Color(0xFF6B7280);
    final textColor = selected
        ? const Color(0xFF0B4A06)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Step $index',
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 88,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestProductCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _InterestProductCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0B4A06) : const Color(0xFFDDE3EA),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0B4A06) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF0B4A06)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.fullWidth = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: _inputDecoration(hintText, suffixIcon: suffixIcon),
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

InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
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
    suffixIcon: suffixIcon,
  );
}

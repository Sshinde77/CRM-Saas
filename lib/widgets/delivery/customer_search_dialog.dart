import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/customer_model.dart';
import 'voice_input_sheet.dart';

class CustomerSearchDialog extends StatefulWidget {
  const CustomerSearchDialog({
    super.key,
    required this.customers,
    required this.onCreateCustomer,
    this.selectedCustomerId,
  });

  final List<CustomerModel> customers;
  final String? selectedCustomerId;
  final Future<CustomerModel?> Function() onCreateCustomer;

  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  static const _accent = AppColors.deliveryGreen;
  static const _heading = AppColors.primary;
  static const _muted = AppColors.textSecondary;
  static const _border = AppColors.border;
  final _search = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _voiceSearch() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const VoiceInputSheet(),
    );
    if (!mounted || text == null) return;
    setState(() => _search.text = text.trim());
  }

  Future<void> _createCustomer() async {
    setState(() => _creating = true);
    try {
      final customer = await widget.onCreateCustomer();
      if (mounted && customer != null) Navigator.of(context).pop(customer);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  bool _matches(CustomerModel customer) {
    final query = _search.text.trim().toLowerCase();
    final fields = [
      customer.name,
      customer.businessName,
      customer.contactPerson,
      customer.customerId,
      customer.id,
      customer.phone,
      customer.alternatePhone,
    ];
    if (fields.any((value) => value?.toLowerCase().contains(query) ?? false)) {
      return true;
    }
    final digits = query.replaceAll(RegExp(r'\D'), '');
    return digits.isNotEmpty &&
        RegExp(r'^[+\d\s()\-]+$').hasMatch(query) &&
        [customer.phone, customer.alternatePhone].any(
          (phone) =>
              phone?.replaceAll(RegExp(r'\D'), '').contains(digits) ?? false,
        );
  }

  @override
  Widget build(BuildContext context) {
    final customers = widget.customers.where(_matches).toList();
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: (MediaQuery.sizeOf(context).height * 0.85)
              .clamp(0.0, 780.0)
              .toDouble(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: _heading, size: 26),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search Customer',
                      style: TextStyle(
                        color: _heading,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: _heading, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText:
                      'Search by customer name, business name, ID or phone number...',
                  hintStyle: const TextStyle(color: _muted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _muted),
                  suffixIcon: IconButton(
                    tooltip: 'Search by voice',
                    onPressed: _voiceSearch,
                    icon: const Icon(Icons.mic_none, color: _accent),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _accent),
                  ),
                ),
              ),
            ),
            Flexible(
              child: customers.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        widget.customers.isEmpty
                            ? 'No customers yet. Create a customer to get started.'
                            : 'No customers found. Try another search.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      itemCount: customers.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, index) =>
                          _customerCard(customers[index]),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _creating ? null : _createCustomer,
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    'Create Customer',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerCard(CustomerModel customer) {
    final business = customer.businessName?.trim();
    final title = business?.isNotEmpty == true ? business! : customer.name;
    final contact = customer.contactPerson?.trim();
    final person = contact?.isNotEmpty == true ? contact! : customer.name;
    final address =
        [customer.deliveryAddress, customer.address, customer.billingAddress]
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .firstOrNull ??
        'No address available';
    final selected = customer.id == widget.selectedCustomerId;
    return Material(
      color: selected ? AppColors.deliveryGreenSoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? _accent : _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(customer),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            final phone = _detail(
              Icons.phone,
              customer.phone?.trim().isNotEmpty == true
                  ? customer.phone!
                  : 'No phone available',
              color: _accent,
            );
            return Padding(
              padding: EdgeInsets.all(wide ? 18 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: wide ? 80 : 46,
                    height: wide ? 80 : 46,
                    decoration: BoxDecoration(
                      color: AppColors.deliveryGreenSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      color: _accent,
                      size: wide ? 34 : 25,
                    ),
                  ),
                  SizedBox(width: wide ? 18 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: _heading,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _detail(Icons.person_outline, person),
                        _detail(
                          Icons.badge_outlined,
                          customer.customerId?.trim().isNotEmpty == true
                              ? customer.customerId!
                              : customer.id,
                        ),
                        _detail(Icons.location_on_outlined, address),
                        if (!wide) phone,
                      ],
                    ),
                  ),
                  if (wide)
                    Container(
                      width: 220,
                      constraints: const BoxConstraints(minHeight: 80),
                      margin: const EdgeInsets.only(left: 20),
                      padding: const EdgeInsets.only(left: 20),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: _border)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: phone,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String value, {Color color = _muted}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _openingBalanceController = TextEditingController(
    text: '0',
  );
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedCategory = 'Select category';

  static const List<String> _categories = [
    'Select category',
    'Manufacturer',
    'Packaging',
    'Raw Materials',
    'Logistics',
    'Other',
  ];

  @override
  void dispose() {
    _supplierNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _openingBalanceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _saveSupplier() {
    _showSnack('Supplier saved');
    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Suppliers'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Suppliers',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add a new supplier',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Track contact details, category and GST information for every vendor.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 18),
                        _sectionHeader('1', 'Basic information'),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 780;
                            final left = Column(
                              children: [
                                _field(
                                  label: 'Supplier Name *',
                                  controller: _supplierNameController,
                                  hintText: 'Enter supplier name',
                                ),
                                const SizedBox(height: 18),
                                _dropdownField(
                                  label: 'Category',
                                  value: _selectedCategory,
                                  items: _categories,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _selectedCategory = value);
                                  },
                                ),
                                const SizedBox(height: 18),
                                _field(
                                  label: 'Email',
                                  controller: _emailController,
                                  hintText: 'Enter email',
                                ),
                                const SizedBox(height: 18),
                                _field(
                                  label: 'Opening Balance',
                                  controller: _openingBalanceController,
                                  hintText: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            );

                            final right = Column(
                              children: [
                                _field(
                                  label: 'Contact Person',
                                  controller: _contactPersonController,
                                  hintText: 'Enter contact person',
                                ),
                                const SizedBox(height: 18),
                                _field(
                                  label: 'Phone *',
                                  controller: _phoneController,
                                  hintText: 'Enter phone number',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 18),
                                _field(
                                  label: 'GST Number',
                                  controller: _gstController,
                                  hintText: 'Enter GST number',
                                ),
                              ],
                            );

                            if (stacked) {
                              return Column(
                                children: [
                                  left,
                                  const SizedBox(height: 18),
                                  right,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: left),
                                const SizedBox(width: 14),
                                Expanded(child: right),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        _sectionHeader('2', 'Location'),
                        const SizedBox(height: 14),
                        _field(
                          label: 'City *',
                          controller: _cityController,
                          hintText: 'Enter city',
                        ),
                        const SizedBox(height: 18),
                        _field(
                          label: 'Address',
                          controller: _addressController,
                          hintText: 'Enter address',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF3F4F6),
                                foregroundColor: const Color(0xFF111827),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _saveSupplier,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B4A06),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Save Supplier'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF0B4A06),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
          ),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

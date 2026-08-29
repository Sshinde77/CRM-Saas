import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/app_drawer.dart';

class NewSalesReturnScreen extends StatefulWidget {
  const NewSalesReturnScreen({super.key});

  @override
  State<NewSalesReturnScreen> createState() => _NewSalesReturnScreenState();
}

class _NewSalesReturnScreenState extends State<NewSalesReturnScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _returnNumberController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const List<String> _returnTypeOptions = [
    'Credit Note',
    'Replacement',
    'Refund',
  ];

  static const List<String> _warehouseOptions = [
    'Main Warehouse',
    'North Warehouse',
    'South Warehouse',
  ];

  String _selectedReturnType = 'Credit Note';
  String _selectedWarehouse = 'Main Warehouse';
  DateTime _selectedDate = DateTime(2026, 8, 21);

  @override
  void dispose() {
    _invoiceController.dispose();
    _reasonController.dispose();
    _returnNumberController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B4A06),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Colors.white,
              headerForegroundColor: AppColors.textPrimary,
              dayBackgroundColor: WidgetStatePropertyAll<Color>(
                Colors.transparent,
              ),
              todayBackgroundColor: WidgetStatePropertyAll<Color>(
                Color(0xFF0B4A06),
              ),
              todayForegroundColor: WidgetStatePropertyAll<Color>(Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _fetchInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice lookup is not connected yet.')),
    );
  }

  void _raiseReturn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Return submitted locally for now.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Sales Returns'),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _backButton(),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Sales Return',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Raise a return request against an existing invoice.',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Invoice',
                      subtitle: 'Look up the invoice this return is against',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invoice Number or ID',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _invoiceController,
                                  decoration: _fieldDecoration(
                                    hintText: 'e.g. INV-2026-000123',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _outlinedActionButton(
                                label: 'Fetch Invoice',
                                icon: Icons.search_rounded,
                                onTap: _fetchInvoice,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionCard(
                      title: 'Return Details',
                      child: Column(
                        children: [
                          if (narrow)
                            Column(
                              children: [
                                _centeredField(
                                  label: 'Return Reason *',
                                  child: TextField(
                                    controller: _reasonController,
                                    decoration: _fieldDecoration(
                                      hintText: 'Why is this being returned?',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Return Type',
                                  child: _dropdownField(
                                    value: _selectedReturnType,
                                    items: _returnTypeOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(
                                        () => _selectedReturnType = value,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Return Date',
                                  child: GestureDetector(
                                    onTap: _pickDate,
                                    child: _dateField(
                                      _formatDate(_selectedDate),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Return Number',
                                  child: TextField(
                                    controller: _returnNumberController,
                                    decoration: _fieldDecoration(
                                      hintText: 'Auto-generated if left blank',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Warehouse',
                                  child: _dropdownField(
                                    value: _selectedWarehouse,
                                    items: _warehouseOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(
                                        () => _selectedWarehouse = value,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _centeredField(
                                  label: 'Return Reason *',
                                  child: TextField(
                                    controller: _reasonController,
                                    decoration: _fieldDecoration(
                                      hintText: 'Why is this being returned?',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Return Type',
                                  child: _dropdownField(
                                    value: _selectedReturnType,
                                    items: _returnTypeOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(
                                        () => _selectedReturnType = value,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Return Date',
                                  child: GestureDetector(
                                    onTap: _pickDate,
                                    child: _dateField(
                                      _formatDate(_selectedDate),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Return Number',
                                  child: TextField(
                                    controller: _returnNumberController,
                                    decoration: _fieldDecoration(
                                      hintText: 'Auto-generated if left blank',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _centeredField(
                                  label: 'Warehouse',
                                  child: _dropdownField(
                                    value: _selectedWarehouse,
                                    items: _warehouseOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(
                                        () => _selectedWarehouse = value,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            backgroundColor: const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _raiseReturn,
                          icon: const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                          ),
                          label: const Text('Raise Return'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4A06),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0x330B4A06),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _roundIconButton(Icons.help_outline_rounded, onTap: () {}),
          const SizedBox(width: 10),
          _roundIconButton(Icons.notifications_none_rounded, onTap: () {}),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4A06),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'RS',
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
                      'Rahul Sharma',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Color(0xFF0B4A06),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return TextButton.icon(
      onPressed: () => Navigator.of(context).pop(),
      label: const Text('Back'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: const Color(0xFFF3F4F6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: textSecondary, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _inputLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        required ? '$label *' : label,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _centeredField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _dateField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DFE8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.calendar_month_outlined,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF94A3B8),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8DFE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8DFE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0B4A06)),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _outlinedActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: Color(0xFFD8DFE8)),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8DFE8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8DFE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0B4A06)),
      ),
    );
  }

  Widget _roundIconButton(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20),
        ),
      ),
    );
  }
}

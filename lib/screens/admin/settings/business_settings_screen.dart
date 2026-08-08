// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';

const Color kBusinessTitleColor = Color(0xFF0F172A);
const Color kBusinessMutedColor = Color(0xFF64748B);
const Color kBusinessAccentColor = Color(0xFF0B4D08);
const Color kBusinessBorderColor = Color(0xFFD8DFD8);
const Color kBusinessFieldBg = Colors.white;

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final TextEditingController _invoicePrefixController = TextEditingController(
    text: 'INV',
  );
  final TextEditingController _invoiceNotesController = TextEditingController();

  bool _isEditing = false;
  final ApiService _apiService = ApiService();
  String _selectedFinancialYear = '2025-2026';
  String? _selectedCurrency;
  String? _selectedTimeZone;
  String? _selectedLanguage;
  String? _selectedTaxConfiguration;

  final List<String> _financialYears = const [
    '2024-2025',
    '2025-2026',
    '2026-2027',
  ];
  final List<String> _currencies = const ['INR', 'USD', 'EUR', 'GBP', 'AED'];
  final List<String> _timeZones = const [
    'Asia/Calcutta',
    'Asia/Dubai',
    'Europe/London',
    'America/New_York',
  ];
  final List<String> _languages = const [
    'English',
    'Hindi',
    'Gujarati',
    'Marathi',
  ];
  final List<String> _taxConfigs = const [
    'GST Registered',
    'GST Unregistered',
    'Composite Scheme',
  ];

  @override
  void dispose() {
    _invoicePrefixController.dispose();
    _invoiceNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Business Settings',
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final contentWidth = constraints.maxWidth > 1200
                      ? 1200.0
                      : constraints.maxWidth;

                  return Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          _ResponsiveFields(
                            isWide: isWide,
                            children: [
                              _fieldBlock(
                                label: 'Financial Year',
                                child: _dropdownField<String>(
                                  value: _selectedFinancialYear,
                                  items: _financialYears,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(
                                      () => _selectedFinancialYear = value,
                                    );
                                  },
                                ),
                              ),
                              _fieldBlock(
                                label: 'Currency',
                                child: _dropdownField<String>(
                                  value: _selectedCurrency,
                                  hintText: 'Select currency',
                                  items: _currencies,
                                  onChanged: (value) {
                                    setState(() => _selectedCurrency = value);
                                  },
                                ),
                              ),
                              _fieldBlock(
                                label: 'Time Zone',
                                child: _dropdownField<String>(
                                  value: _selectedTimeZone,
                                  hintText: 'Select time zone',
                                  items: _timeZones,
                                  onChanged: (value) {
                                    setState(() => _selectedTimeZone = value);
                                  },
                                ),
                              ),
                              _fieldBlock(
                                label: 'Language',
                                child: _dropdownField<String>(
                                  value: _selectedLanguage,
                                  hintText: 'Select language',
                                  items: _languages,
                                  onChanged: (value) {
                                    setState(() => _selectedLanguage = value);
                                  },
                                ),
                              ),
                              _fieldBlock(
                                label: 'Tax Configuration',
                                child: _dropdownField<String>(
                                  value: _selectedTaxConfiguration,
                                  hintText: 'Select tax configuration',
                                  items: _taxConfigs,
                                  onChanged: (value) {
                                    setState(
                                      () => _selectedTaxConfiguration = value,
                                    );
                                  },
                                ),
                              ),
                              _fieldBlock(
                                label: 'Invoice Prefix',
                                child: _textField(
                                  controller: _invoicePrefixController,
                                  hintText: 'e.g. INV',
                                ),
                              ),
                              _fieldBlock(
                                label: 'Invoice Settings',
                                fullWidth: true,
                                child: _textField(
                                  controller: _invoiceNotesController,
                                  maxLines: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldBlock({
    required String label,
    required Widget child,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: kBusinessTitleColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child,
        ],
      ),
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
        backgroundColor: editing
            ? kBusinessAccentColor
            : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : kBusinessTitleColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      final payload = <String, dynamic>{};
      _putIfNotBlank(payload, 'financial_year', _selectedFinancialYear);
      _putIfNotBlank(payload, 'currency', _selectedCurrency);
      _putIfNotBlank(payload, 'timezone', _selectedTimeZone);
      _putIfNotBlank(payload, 'language', _selectedLanguage);
      final taxConfiguration = <String, dynamic>{};
      _putIfNotBlank(taxConfiguration, 'value', _selectedTaxConfiguration);
      if (taxConfiguration.isNotEmpty) {
        payload['tax_configuration'] = taxConfiguration;
      }
      final invoiceSettings = <String, dynamic>{};
      _putIfNotBlank(
        invoiceSettings,
        'invoice_prefix',
        _invoicePrefixController.text,
      );
      _putIfNotBlank(invoiceSettings, 'notes', _invoiceNotesController.text);
      if (invoiceSettings.isNotEmpty) {
        payload['invoice_settings'] = invoiceSettings;
      }

      await _apiService.updateOrganizationSettings(
        request: OrganizationSettingsRequest(fields: payload),
      );

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

  void _putIfNotBlank(Map<String, dynamic> payload, String key, dynamic value) {
    if (value == null) return;
    if (value is String && value.trim().isEmpty) return;
    payload[key] = value;
  }

  Widget _textField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      style: const TextStyle(fontSize: 15, color: kBusinessTitleColor),
      decoration: _fieldDecoration(hintText: hintText),
    );
  }

  Widget _dropdownField<T>({
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: _isEditing ? onChanged : null,
      isExpanded: true,
      menuMaxHeight: 260,
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF98A2B3)),
      hint: hintText == null
          ? null
          : Text(hintText, style: const TextStyle(color: Color(0xFFB5BCC6))),
      style: const TextStyle(fontSize: 15, color: kBusinessTitleColor),
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
                  color: kBusinessTitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: kBusinessFieldBg,
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFB5BCC6), fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kBusinessBorderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kBusinessBorderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kBusinessAccentColor, width: 2),
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsiveFields({required this.isWide, required this.children});

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    final width = MediaQuery.of(context).size.width;
    final itemWidth = (width > 1200 ? 1200 : width) / 2 - 22;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map((child) => SizedBox(width: itemWidth, child: child))
          .toList(),
    );
  }
}

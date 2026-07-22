import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  bool _saving = false;
  String _gstRate = '18%';
  bool _roundOffInvoices = true;
  final List<String> _gstOptions = const ['0%', '5%', '12%', '18%', '28%'];

  final Map<String, bool> _paymentMethods = {
    'Cash': true,
    'UPI': true,
    'Card': true,
    'Credit': true,
    'Bank Transfer': false,
    'Cheque': false,
  };

  final List<String> _categories = [
    'Packaged Water',
    'Mineral Water',
    'Sparkling Water',
  ];
  final List<String> _units = ['unit', 'jar', 'case (12)', 'litre'];
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  final Map<String, bool> _notificationPrefs = {
    'Low stock alerts': true,
    'Overdue customer payments': true,
    'Pending deliveries': true,
  };

  @override
  void dispose() {
    _categoryController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Settings'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Settings',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Operational Settings',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Configure invoicing, payments, products, and alerts',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Text('Save Settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GST & Tax Defaults',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Default GST Rate',
                            style: TextStyle(color: textPrimary),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _gstRate,
                            decoration: _inputDecoration(),
                            items: _gstOptions
                                .map(
                                  (rate) => DropdownMenuItem<String>(
                                    value: rate,
                                    child: Text(rate),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _gstRate = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            value: _roundOffInvoices,
                            onChanged: (value) =>
                                setState(() => _roundOffInvoices = value),
                            activeThumbColor: AppColors.purple,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Round off invoice totals to nearest rupee',
                              style: TextStyle(color: textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: _buildChipSection(
                        'Product Categories',
                        _categories,
                        _categoryController,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: _buildChipSection(
                        'Units of Measurement',
                        _units,
                        _unitController,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Methods',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _paymentMethods.entries.map((entry) {
                              final active = entry.value;
                              return FilterChip(
                                label: Text(entry.key),
                                selected: active,
                                onSelected: (value) {
                                  setState(
                                    () => _paymentMethods[entry.key] = value,
                                  );
                                },
                                selectedColor: AppColors.purple.withValues(
                                  alpha: 0.12,
                                ),
                                checkmarkColor: AppColors.purple,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notification Preferences',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._notificationPrefs.entries.map(
                            (entry) => SwitchListTile(
                              value: entry.value,
                              onChanged: (value) {
                                setState(
                                  () => _notificationPrefs[entry.key] = value,
                                );
                              },
                              activeThumbColor: AppColors.purple,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                entry.key,
                                style: const TextStyle(color: textPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildChipSection(
    String title,
    List<String> items,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item),
                  onDeleted: () => setState(() => items.remove(item)),
                  backgroundColor: AppColors.purple.withValues(alpha: 0.08),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: _inputDecoration(hint: 'Add new item'),
                onSubmitted: (_) => _addItem(items, controller),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _addItem(items, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceSoft,
                foregroundColor: textPrimary,
                elevation: 0,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  void _addItem(List<String> items, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      items.add(value);
      controller.clear();
    });
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.purple),
      ),
    );
  }
}

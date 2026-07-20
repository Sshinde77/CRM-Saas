import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

/// Admin Settings screen — glassmorphism redesign on a white background.
/// Section order (as requested):
/// 1. Financial Year & Invoice Numbering
/// 2. GST & Tax Defaults
/// 3. Payment Methods
/// 4. Product Categories
/// 5. Units of Measurement
/// 6. Notification Preferences
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ---- Theme colours (kept consistent with the rest of the app) ----
  static const Color bg = Color(0xFFFFFFFF);
  static const Color teal = Color(0xFF1FA2B0);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color amber = Color(0xFFF6A609);
  static const Color orange = Color(0xFFFB923C);

  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

  bool _saving = false;

  // ---- GST & Tax Defaults ----
  String _gstRate = '18%';
  final List<String> _gstOptions = const ['0%', '5%', '12%', '18%', '28%'];
  bool _roundOffInvoices = true;

  // ---- Payment Methods (toggleable) ----
  final Map<String, bool> _paymentMethods = {
    'Cash': true,
    'UPI': true,
    'Card': true,
    'Credit': true,
    'Bank Transfer': false,
    'Cheque': false,
  };

  // ---- Product Categories ----
  final List<String> _categories = [
    'Packaged Water',
    'Mineral Water',
    'Sparkling Water',
    'Water Jar',
    'Flavored Water',
    'Alkaline Water',
    'Dispenser',
    'Accessories',
  ];
  final TextEditingController _categoryController = TextEditingController();

  // ---- Units of Measurement ----
  final List<String> _units = [
    'unit',
    'jar',
    'case (9)',
    'case (12)',
    'case (24)',
    'kg',
    'litre',
    'box',
    'roll',
  ];
  final TextEditingController _unitController = TextEditingController();

  // ---- Notification Preferences ----
  final Map<String, bool> _notificationPrefs = {
    'Low stock alerts': true,
    'Overdue customer payments': true,
    'Pending deliveries': true,
    'Pending cash handovers': true,
    'New order assignments': true,
  };

  @override
  void dispose() {
    _categoryController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    // TODO: persist these settings via your API / provider.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved'),
        backgroundColor: textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const AppDrawer(activeItem: 'Settings'),
      body: Stack(
        children: [
          Positioned(top: -60, left: -70, child: _glowBlob(purple, 220)),
          Positioned(top: 220, right: -90, child: _glowBlob(teal, 240)),
          Positioned(bottom: -80, left: 20, child: _glowBlob(green, 200)),
          Positioned(top: 560, right: 10, child: _glowBlob(orange, 180)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  _buildTitleRow(),
                  const SizedBox(height: 20),
                  _buildFinancialYearSection(),
                  const SizedBox(height: 16),
                  _buildGstSection(),
                  const SizedBox(height: 16),
                  _buildPaymentMethodsSection(),
                  const SizedBox(height: 16),
                  _buildChipSection(
                    title: 'Product Categories',
                    items: _categories,
                    controller: _categoryController,
                    hint: 'New category',
                    onAdd: () => _addChip(_categories, _categoryController),
                    onRemove: (item) => setState(() => _categories.remove(item)),
                  ),
                  const SizedBox(height: 16),
                  _buildChipSection(
                    title: 'Units of Measurement',
                    items: _units,
                    controller: _unitController,
                    hint: 'New unit',
                    onAdd: () => _addChip(_units, _unitController),
                    onRemove: (item) => setState(() => _units.remove(item)),
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationPrefsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addChip(List<String> list, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      list.add(value);
      controller.clear();
    });
  }

  // ---------------- Top bar ----------------
  Widget _buildTopBar(BuildContext context) {
    return _GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: _iconBadge(Icons.menu, textPrimary.withOpacity(0.06), textPrimary),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _iconBadge(Icons.notifications_none_rounded, textPrimary.withOpacity(0.06), textPrimary),
              const Positioned(
                right: 6,
                top: 6,
                child: _NotificationDot(),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [purple, blue]),
            ),
            alignment: Alignment.center,
            child: const Text('AS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color bg, Color fg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 19),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.20), blurRadius: 100, spreadRadius: 30),
        ],
      ),
    );
  }

  // ---------------- Title row + Save button ----------------
  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Operational configuration for invoicing, payments, and products',
                  style: TextStyle(color: textSecondary, fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _saveButton(),
      ],
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: _saving ? null : _handleSave,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [purple, blue]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: purple.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : const Text('Save Settings',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ---------------- 1. Financial Year & Invoice Numbering ----------------
  Widget _buildFinancialYearSection() {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Financial Year & Invoice Numbering'),
          const SizedBox(height: 2),
          Text('Owned by Company Settings — shown here for reference',
              style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          _readOnlyField('Financial Year'),
          const SizedBox(height: 14),
          _readOnlyField('Invoice Prefix'),
          const SizedBox(height: 14),
          _readOnlyField('Invoice Starting Number'),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              // TODO: navigate to your Company Settings screen.
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit in Company Settings',
                    style: TextStyle(color: purple, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15, color: purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: textPrimary.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textPrimary.withOpacity(0.07)),
          ),
          child: Text('—', style: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 14)),
        ),
      ],
    );
  }

  // ---------------- 2. GST & Tax Defaults ----------------
  Widget _buildGstSection() {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('GST & Tax Defaults'),
          const SizedBox(height: 16),
          _fieldLabel('Default GST Rate'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: textPrimary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: textPrimary.withOpacity(0.08)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gstRate,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
                style: const TextStyle(color: textPrimary, fontSize: 14),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                items: _gstOptions
                    .map((rate) => DropdownMenuItem(value: rate, child: Text(rate)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _gstRate = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _checkboxRow(
            label: 'Round off invoice totals to nearest rupee',
            value: _roundOffInvoices,
            onChanged: (v) => setState(() => _roundOffInvoices = v),
          ),
        ],
      ),
    );
  }

  // ---------------- 3. Payment Methods ----------------
  Widget _buildPaymentMethodsSection() {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Payment Methods'),
          const SizedBox(height: 2),
          Text('Methods available when recording payments or delivery collections',
              style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _paymentMethods.entries.map((entry) {
              final active = entry.value;
              return GestureDetector(
                onTap: () => setState(() => _paymentMethods[entry.key] = !active),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? green.withOpacity(0.12) : textPrimary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? green.withOpacity(0.4) : textPrimary.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? green : textSecondary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(entry.key,
                          style: TextStyle(
                              color: active ? green : textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------- 4 & 5. Chip sections (Product Categories / Units of Measurement) ----------------
  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
    required ValueChanged<String> onRemove,
  }) {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: teal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: teal.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item,
                              style: const TextStyle(
                                  color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => onRemove(item),
                            child: Icon(Icons.close_rounded, size: 15, color: textSecondary),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: textPrimary.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: textPrimary.withOpacity(0.08)),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => onAdd(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    color: textPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Add',
                      style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- 6. Notification Preferences ----------------
  Widget _buildNotificationPrefsSection() {
    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Notification Preferences'),
          const SizedBox(height: 14),
          ..._notificationPrefs.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _checkboxRow(
                label: entry.key,
                value: entry.value,
                onChanged: (v) => setState(() => _notificationPrefs[entry.key] = v),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------- Shared helpers ----------------
  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700));
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _checkboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: value ? blue : Colors.transparent,
              border: Border.all(color: value ? blue : textPrimary.withOpacity(0.25), width: 1.5),
            ),
            child: value ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
    );
  }
}

// ---------------- Reusable Glass Container (matches dashboard/profile styling) ----------------
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _GlassContainer({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withOpacity(0.55),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2A2E).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
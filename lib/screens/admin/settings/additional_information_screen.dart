import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

const Color kAdditionalTitleColor = Color(0xFF0F172A);
const Color kAdditionalMutedColor = Color(0xFF64748B);
const Color kAdditionalAccentColor = Color(0xFF0B4D08);
const Color kAdditionalBorderColor = Color(0xFFD8DFD8);
const Color kAdditionalFieldBg = Colors.white;

class AdditionalInformationScreen extends StatefulWidget {
  const AdditionalInformationScreen({super.key});

  @override
  State<AdditionalInformationScreen> createState() =>
      _AdditionalInformationScreenState();
}

class _AdditionalInformationScreenState extends State<AdditionalInformationScreen> {
  final TextEditingController _employeesController = TextEditingController();
  final TextEditingController _businessHoursController = TextEditingController();
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isEditing = false;
  bool _saving = false;

  final List<String> _statusOptions = const ['Active', 'Inactive'];
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _employeesController.dispose();
    _businessHoursController.dispose();
    _missionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Additional information saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 18),
                    _ResponsiveFields(
                      isWide: isWide,
                      children: [
                        _fieldBlock(
                          label: 'Number of Employees',
                          child: _textField(controller: _employeesController),
                        ),
                        _fieldBlock(
                          label: 'Business Hours',
                          child: _textField(controller: _businessHoursController),
                        ),
                        _fieldBlock(
                          label: 'Company Mission/Vision',
                          fullWidth: true,
                          child: _textField(
                            controller: _missionController,
                            maxLines: 3,
                          ),
                        ),
                        _fieldBlock(
                          label: 'Notes',
                          fullWidth: true,
                          child: _textField(
                            controller: _notesController,
                            maxLines: 3,
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
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Information',
                style: TextStyle(
                  color: kAdditionalTitleColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage operational details and internal notes.',
                style: TextStyle(
                  color: kAdditionalMutedColor,
                  fontSize: 14.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (_isEditing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: _saving ? null : () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAdditionalAccentColor,
                  side: const BorderSide(color: kAdditionalAccentColor, width: 1.5),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(13),
                ),
                child: const Icon(Icons.close_rounded, size: 18),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _saving ? null : _handleSave,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(_saving ? 'Saving' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAdditionalAccentColor,
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: kAdditionalAccentColor.withValues(alpha: 0.24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: _saving ? null : () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAdditionalAccentColor,
              foregroundColor: Colors.white,
              elevation: 10,
              shadowColor: kAdditionalAccentColor.withValues(alpha: 0.24),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
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
                color: kAdditionalTitleColor,
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

  Widget _textField({
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      style: const TextStyle(fontSize: 15, color: kAdditionalTitleColor),
      decoration: _fieldDecoration(),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: kAdditionalFieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kAdditionalBorderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kAdditionalBorderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kAdditionalAccentColor, width: 2),
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsiveFields({
    required this.isWide,
    required this.children,
  });

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

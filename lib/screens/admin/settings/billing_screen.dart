import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  static const Color _titleColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _accent = Color(0xFF0B4D08);
  static const Color _borderColor = Color(0xFFD8DFD8);
  static const Color _fieldBg = Colors.white;

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  Uint8List? _qrBytes;
  String? _qrName;
  String? _selectedBank;
  bool _isEditing = false;
  bool _saving = false;

  final List<String> _bankOptions = const [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Bank of Baroda',
    'Punjab National Bank',
  ];

  @override
  void dispose() {
    _upiController.dispose();
    _bankAccountController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickQrCode() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _qrBytes = bytes;
        _qrName = picked.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload QR code')),
      );
    }
  }

  void _removeQrCode() {
    setState(() {
      _qrBytes = null;
      _qrName = null;
    });
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
      const SnackBar(content: Text('Billing details saved')),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Billings',
                                style: TextStyle(
                                  color: _titleColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Manage digital payment and bank details.',
                                style: TextStyle(
                                  color: _mutedColor,
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
                                onPressed: _saving
                                    ? null
                                    : () => setState(() => _isEditing = false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _accent,
                                  side: const BorderSide(
                                    color: _accent,
                                    width: 1.5,
                                  ),
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
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor:
                                      _accent.withValues(alpha: 0.24),
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
                            onPressed: _saving
                                ? null
                                : () => setState(() => _isEditing = true),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              elevation: 10,
                              shadowColor: _accent.withValues(alpha: 0.24),
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
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 22),
                    _SectionShell(
                      title: 'Payment QR',
                      subtitle: 'Upload a QR code for receiving payments.',
                      child: _QrUploadCard(
                        qrBytes: _qrBytes,
                        qrName: _qrName,
                        enabled: _isEditing,
                        onUpload: _pickQrCode,
                        onRemove: _removeQrCode,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionShell(
                      title: 'UPI Details',
                      subtitle: 'Unified Payments Interface information.',
                      child: _ResponsiveFields(
                        isWide: isWide,
                        children: [
                          _fieldBlock(
                            label: 'UPI ID',
                            child: _textField(
                              controller: _upiController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 18),
                    _SectionShell(
                      title: 'Bank Account',
                      subtitle: 'Account holder, bank, and IFSC information.',
                      child: _ResponsiveFields(
                        isWide: isWide,
                        children: [
                          _fieldBlock(
                            label: 'Bank Account Details',
                            child: _textField(
                              controller: _bankAccountController,
                            ),
                          ),
                          _fieldBlock(
                            label: 'Account Holder Name',
                            child: _textField(
                              controller: _accountHolderController,
                            ),
                          ),
                          _fieldBlock(
                            label: 'IFSC Code',
                            child: _textField(
                              controller: _ifscController,
                            ),
                          ),
                          _fieldBlock(
                            label: 'Bank Name',
                            child: _dropdownField<String>(
                              value: _selectedBank,
                              hintText: 'Select bank',
                              items: _bankOptions,
                              onChanged: (value) {
                                setState(() => _selectedBank = value);
                              },
                            ),
                          ),
                          _fieldBlock(
                            label: 'Account Number',
                            child: _textField(
                              controller: _accountNumberController,
                            ),
                          ),
                        ],
                      ),
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

  Widget _fieldBlock({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: const TextStyle(fontSize: 15, color: _titleColor),
      decoration: _fieldDecoration(),
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
      icon: const Icon(
        Icons.expand_more_rounded,
        color: Color(0xFF98A2B3),
      ),
      hint: hintText == null
          ? null
          : Text(
              hintText,
              style: const TextStyle(color: Color(0xFFB5BCC6)),
            ),
      style: const TextStyle(fontSize: 15, color: _titleColor),
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
                  color: _titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accent, width: 2),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _BillingScreenState._titleColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _BillingScreenState._mutedColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _QrUploadCard extends StatelessWidget {
  final Uint8List? qrBytes;
  final String? qrName;
  final bool enabled;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _QrUploadCard({
    required this.qrBytes,
    required this.qrName,
    required this.enabled,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3EA)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;

          final preview = Container(
            width: isCompact ? double.infinity : 190,
            height: isCompact ? 110 : 96,
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E4E8)),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: qrBytes == null
                ? const Text(
                    'Preview',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  )
                : Image.memory(qrBytes!, fit: BoxFit.cover),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Google Pay / PhonePe / Paytm QR\nCode *',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _BillingScreenState._titleColor,
                  fontSize: 15,
                  height: 1.28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'image/png,image/jpeg',
                style: TextStyle(
                  color: _BillingScreenState._mutedColor,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: enabled ? onUpload : null,
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8CAD84),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: qrBytes == null ? null : onRemove,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9CA3AF),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                preview,
                const SizedBox(height: 14),
                details,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              const SizedBox(width: 16),
              Expanded(child: details),
            ],
          );
        },
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
    final cardWidth = (width > 1200 ? 1200 : width) / 2 - 22;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map((child) => SizedBox(width: cardWidth, child: child))
          .toList(),
    );
  }
}

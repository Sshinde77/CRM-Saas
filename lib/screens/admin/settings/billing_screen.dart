// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';

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
  final ApiService _apiService = ApiService();

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  Uint8List? _qrBytes;
  String? _qrName;
  String? _paymentQrUrl;
  bool _paymentQrRemoved = false;
  String? _selectedBank;
  bool _isEditing = false;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizationSettings();
    });
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
      final uploadedUrl = await _apiService.uploadOrganizationSettingsFile(
        fileBytes: bytes,
        fileName: picked.name,
      );
      setState(() {
        _qrBytes = bytes;
        _qrName = picked.name;
        _paymentQrRemoved = false;
        if (uploadedUrl != null && uploadedUrl.trim().isNotEmpty) {
          _paymentQrUrl = uploadedUrl.trim();
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to upload QR code')));
    }
  }

  void _removeQrCode() {
    setState(() {
      _qrBytes = null;
      _qrName = null;
      _paymentQrUrl = null;
      _paymentQrRemoved = true;
    });
  }

  Future<void> _loadOrganizationSettings() async {
    try {
      final data = await _apiService.fetchOrganizationSettingsView();
      if (!mounted) return;
      setState(() {
        _applyOrganizationData(data);
      });
    } catch (_) {
      // Keep defaults if settings are unavailable.
    }
  }

  void _applyOrganizationData(Map<String, dynamic> data) {
    final upiId = _readString(data, 'upi_id');
    final bankAccountDetails = _readString(data, 'bank_account_details');
    final bankAccountHolder = _readString(data, 'bank_account_holder');
    final bankIfsc = _readString(data, 'bank_ifsc');
    final bankName = _readString(data, 'bank_name');
    final paymentQrUrl = _readString(data, 'payment_qr_url');

    if (upiId != null) {
      _upiController.text = upiId;
    }
    if (bankAccountDetails != null) {
      _bankAccountController.text = bankAccountDetails;
      final accountNumber = _extractAccountNumber(bankAccountDetails);
      if (accountNumber != null) {
        _accountNumberController.text = accountNumber;
      }
    }
    if (bankAccountHolder != null) {
      _accountHolderController.text = bankAccountHolder;
    }
    if (bankIfsc != null) {
      _ifscController.text = bankIfsc;
    }
    if (bankName != null) {
      _selectedBank = _matchOption(_bankOptions, bankName);
    }
    if (paymentQrUrl != null) {
      _paymentQrUrl = paymentQrUrl;
      _paymentQrRemoved = false;
      _qrName = Uri.tryParse(paymentQrUrl)?.pathSegments.isNotEmpty == true
          ? Uri.parse(paymentQrUrl).pathSegments.last
          : 'payment_qr';
      _loadRemoteBytes(paymentQrUrl).then((bytes) {
        if (!mounted || bytes == null) return;
        setState(() {
          _qrBytes = bytes;
        });
      });
    }
  }

  String? _readString(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _matchOption(List<String> options, String value) {
    for (final option in options) {
      if (option.trim().toLowerCase() == value.trim().toLowerCase()) {
        return option;
      }
    }
    return null;
  }

  String? _extractAccountNumber(String bankAccountDetails) {
    final match = RegExp(
      r'Account Number:\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(bankAccountDetails);
    if (match == null) return null;
    final value = match.group(1)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<Uint8List?> _loadRemoteBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
    } catch (_) {
      // Ignore preview loading failures.
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Billing',
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
                          _SectionShell(
                            title: 'Payment QR',
                            subtitle:
                                'Upload a QR code for receiving payments.',
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
                                  child: _textField(controller: _upiController),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 18),
                          _SectionShell(
                            title: 'Bank Account',
                            subtitle:
                                'Account holder, bank, and IFSC information.',
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
          ],
        ),
      ),
    );
  }

  Widget _fieldBlock({required String label, required Widget child}) {
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
        backgroundColor: editing ? _accent : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : _titleColor,
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
      _putIfNotBlank(payload, 'upi_id', _upiController.text);
      final bankDetails = <String>[
        _bankAccountController.text.trim(),
        if (_accountNumberController.text.trim().isNotEmpty)
          'Account Number: ${_accountNumberController.text.trim()}',
      ].where((part) => part.isNotEmpty).join(' | ');
      _putIfNotBlank(payload, 'bank_account_details', bankDetails);
      _putIfNotBlank(
        payload,
        'bank_account_holder',
        _accountHolderController.text,
      );
      _putIfNotBlank(payload, 'bank_ifsc', _ifscController.text);
      _putIfNotBlank(payload, 'bank_name', _selectedBank);
      if (_paymentQrRemoved) {
        payload['payment_qr_url'] = null;
      } else {
        _putIfNotBlank(payload, 'payment_qr_url', _paymentQrUrl);
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

  void _putIfNotBlank(Map<String, dynamic> payload, String key, String? value) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      payload[key] = trimmed;
    }
  }

  Widget _textField({required TextEditingController controller}) {
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
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF98A2B3)),
      hint: hintText == null
          ? null
          : Text(hintText, style: const TextStyle(color: Color(0xFFB5BCC6))),
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
                    onPressed: enabled && (qrBytes != null || qrName != null)
                        ? onRemove
                        : null,
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
              children: [preview, const SizedBox(height: 14), details],
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

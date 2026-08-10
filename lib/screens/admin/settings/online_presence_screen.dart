// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';

const Color kOnlinePresenceTitleColor = Color(0xFF0F172A);
const Color kOnlinePresenceMutedColor = Color(0xFF64748B);
const Color kOnlinePresenceAccentColor = Color(0xFF0B4D08);
const Color kOnlinePresenceBorderColor = Color(0xFFD8DFD8);
const Color kOnlinePresenceFieldBg = Colors.white;

class OnlinePresenceScreen extends StatefulWidget {
  const OnlinePresenceScreen({super.key});

  @override
  State<OnlinePresenceScreen> createState() => _OnlinePresenceScreenState();
}

class _OnlinePresenceScreenState extends State<OnlinePresenceScreen> {
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  bool _isEditing = false;
  final ApiService _apiService = ApiService();
  @override
  void dispose() {
    _facebookController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _xController.dispose();
    _youtubeController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Online Presence',
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
                                label: 'Facebook',
                                child: _textField(
                                  controller: _facebookController,
                                ),
                              ),
                              _fieldBlock(
                                label: 'Instagram',
                                child: _textField(
                                  controller: _instagramController,
                                ),
                              ),
                              _fieldBlock(
                                label: 'LinkedIn',
                                child: _textField(
                                  controller: _linkedinController,
                                ),
                              ),
                              _fieldBlock(
                                label: 'X (Twitter)',
                                child: _textField(controller: _xController),
                              ),
                              _fieldBlock(
                                label: 'YouTube',
                                child: _textField(
                                  controller: _youtubeController,
                                ),
                              ),
                              _fieldBlock(
                                label: 'WhatsApp Business Number',
                                child: _textField(
                                  controller: _whatsappController,
                                  keyboardType: TextInputType.phone,
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
            ? kOnlinePresenceAccentColor
            : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : kOnlinePresenceTitleColor,
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
      _putIfNotBlank(payload, 'facebook_url', _facebookController.text);
      _putIfNotBlank(payload, 'instagram_url', _instagramController.text);
      _putIfNotBlank(payload, 'linkedin_url', _linkedinController.text);
      _putIfNotBlank(payload, 'twitter_url', _xController.text);
      _putIfNotBlank(payload, 'youtube_url', _youtubeController.text);
      _putIfNotBlank(payload, 'whatsapp_number', _whatsappController.text);

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

  Future<void> _loadOrganizationSettings() async {
    try {
      final data = await _apiService.fetchOrganizationSettingsView();
      if (!mounted) return;
      setState(() {
        _facebookController.text = _readString(data, 'facebook_url') ?? '';
        _instagramController.text = _readString(data, 'instagram_url') ?? '';
        _linkedinController.text = _readString(data, 'linkedin_url') ?? '';
        _xController.text = _readString(data, 'twitter_url') ?? '';
        _youtubeController.text = _readString(data, 'youtube_url') ?? '';
        _whatsappController.text = _readString(data, 'whatsapp_number') ?? '';
      });
    } catch (_) {
      // Keep defaults if organization data cannot be loaded.
    }
  }

  String? _readString(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  void _putIfNotBlank(Map<String, dynamic> payload, String key, String? value) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      payload[key] = trimmed;
    }
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
              color: kOnlinePresenceTitleColor,
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
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: _isEditing,
      style: const TextStyle(fontSize: 15, color: kOnlinePresenceTitleColor),
      decoration: _fieldDecoration(),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: kOnlinePresenceFieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kOnlinePresenceBorderColor,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kOnlinePresenceBorderColor,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kOnlinePresenceAccentColor,
          width: 2,
        ),
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

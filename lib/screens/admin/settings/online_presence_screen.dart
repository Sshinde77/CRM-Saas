import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
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
  bool _saving = false;

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

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Online presence saved')),
    );
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
        borderSide: const BorderSide(color: kOnlinePresenceBorderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kOnlinePresenceBorderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kOnlinePresenceAccentColor, width: 2),
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

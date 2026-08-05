import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';

const Color kBrandingTitleColor = Color(0xFF0F172A);
const Color kBrandingMutedColor = Color(0xFF64748B);
const Color kBrandingAccentColor = Color(0xFF0B4D08);
const Color kBrandingBorderColor = Color(0xFFD8DFD8);

class BrandingIdentityScreen extends StatefulWidget {
  const BrandingIdentityScreen({super.key});

  @override
  State<BrandingIdentityScreen> createState() => _BrandingIdentityScreenState();
}

class _BrandingIdentityScreenState extends State<BrandingIdentityScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final Map<_BrandAssetType, Uint8List?> _bytes = {
    for (final type in _BrandAssetType.values) type: null,
  };
  final Map<_BrandAssetType, String?> _names = {
    for (final type in _BrandAssetType.values) type: null,
  };

  bool _isEditing = false;
  bool _saving = false;

  static const List<_BrandAsset> _assets = [
    _BrandAsset(
      type: _BrandAssetType.logo,
      title: 'Company Logo',
      mimeHint: 'data:image/png;base64,image/*',
      required: true,
    ),
    _BrandAsset(
      type: _BrandAssetType.signature,
      title: 'Authorized Signature',
      mimeHint: 'image/*',
      required: true,
    ),
    _BrandAsset(
      type: _BrandAssetType.banner,
      title: 'Company Banner',
      mimeHint: 'image/*',
      required: false,
    ),
    _BrandAsset(
      type: _BrandAssetType.seal,
      title: 'Company Stamp/Seal',
      mimeHint: 'image/*',
      required: false,
    ),
    _BrandAsset(
      type: _BrandAssetType.letterhead,
      title: 'Company Letterhead',
      mimeHint: 'application/pdf, .doc, .docx, image/*',
      required: false,
    ),
  ];

  Future<void> _pickAsset(_BrandAssetType type) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes[type] = bytes;
        _names[type] = picked.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload file')),
      );
    }
  }

  void _removeAsset(_BrandAssetType type) {
    setState(() {
      _bytes[type] = null;
      _names[type] = null;
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
      const SnackBar(content: Text('Branding details saved')),
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
              title: 'Branding & Identity',
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
                          _SectionShell(
                            title: 'Brand Assets',
                            subtitle:
                                'Upload company logo, signature, banner, stamp, and letterhead.',
                            child: _ResponsiveGrid(
                              isWide: isWide,
                              children: [
                                for (final asset in _assets)
                                  _BrandUploadCard(
                                    asset: asset,
                                    bytes: _bytes[asset.type],
                                    name: _names[asset.type],
                                    enabled: _isEditing,
                                    onUpload: () => _pickAsset(asset.type),
                                    onRemove: () => _removeAsset(asset.type),
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
}

enum _BrandAssetType { logo, signature, banner, seal, letterhead }

class _BrandAsset {
  final _BrandAssetType type;
  final String title;
  final String mimeHint;
  final bool required;

  const _BrandAsset({
    required this.type,
    required this.title,
    required this.mimeHint,
    required this.required,
  });
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
            color: kBrandingTitleColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: kBrandingMutedColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsiveGrid({
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
            if (i != children.length - 1) const SizedBox(height: 12),
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

class _BrandUploadCard extends StatelessWidget {
  final _BrandAsset asset;
  final Uint8List? bytes;
  final String? name;
  final bool enabled;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _BrandUploadCard({
    required this.asset,
    required this.bytes,
    required this.name,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E4E8)),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: bytes == null
                ? const Text(
                    'Preview',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Image.memory(bytes!, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.title + (asset.required ? ' *' : ''),
                  style: const TextStyle(
                    color: kBrandingTitleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.mimeHint,
                  style: const TextStyle(
                    color: kBrandingMutedColor,
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
                      onPressed: bytes == null ? null : onRemove,
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
                if (name != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kBrandingTitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

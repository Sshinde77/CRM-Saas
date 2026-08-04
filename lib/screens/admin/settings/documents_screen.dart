import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';

const Color kDocumentsTitleColor = Color(0xFF0F172A);
const Color kDocumentsMutedColor = Color(0xFF64748B);
const Color kDocumentsAccentColor = Color(0xFF0B4D08);

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _isEditing = false;
  bool _saving = false;

  final Map<_DocumentType, Uint8List?> _bytes = {
    for (final type in _DocumentType.values) type: null,
  };
  final Map<_DocumentType, String?> _names = {
    for (final type in _DocumentType.values) type: null,
  };

  static const List<_DocumentAsset> _assets = [
    _DocumentAsset(
      type: _DocumentType.gstCertificate,
      title: 'GST Certificate',
      mimeHint: 'application/pdf,image/*',
    ),
    _DocumentAsset(
      type: _DocumentType.panCard,
      title: 'PAN Card',
      mimeHint: 'application/pdf,image/*',
    ),
    _DocumentAsset(
      type: _DocumentType.incorporation,
      title: 'Certificate of Incorporation',
      mimeHint: 'application/pdf',
    ),
    _DocumentAsset(
      type: _DocumentType.tradeLicense,
      title: 'Trade License',
      mimeHint: 'application/pdf,image/*',
    ),
    _DocumentAsset(
      type: _DocumentType.msme,
      title: 'MSME Certificate',
      mimeHint: 'application/pdf',
    ),
    _DocumentAsset(
      type: _DocumentType.fssai,
      title: 'FSSAI License',
      mimeHint: 'application/pdf,image/*',
    ),
    _DocumentAsset(
      type: _DocumentType.other,
      title: 'Other Business Documents',
      mimeHint: 'application/pdf,.doc,.docx,image/*',
    ),
  ];

  Future<void> _pickDocument(_DocumentType type) async {
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
        const SnackBar(content: Text('Unable to upload document')),
      );
    }
  }

  void _removeDocument(_DocumentType type) {
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
      const SnackBar(content: Text('Documents saved')),
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
                    const SizedBox(height: 22),
                    _ResponsiveGrid(
                      isWide: isWide,
                      children: [
                        for (final asset in _assets)
                          _DocumentUploadCard(
                            asset: asset,
                            bytes: _bytes[asset.type],
                            name: _names[asset.type],
                            enabled: _isEditing,
                            onUpload: () => _pickDocument(asset.type),
                            onRemove: () => _removeDocument(asset.type),
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
                'Documents',
                style: TextStyle(
                  color: kDocumentsTitleColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage compliance and registration documents.',
                style: TextStyle(
                  color: kDocumentsMutedColor,
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
                  foregroundColor: kDocumentsAccentColor,
                  side: const BorderSide(color: kDocumentsAccentColor, width: 1.5),
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
                  backgroundColor: kDocumentsAccentColor,
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: kDocumentsAccentColor.withValues(alpha: 0.24),
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
              backgroundColor: kDocumentsAccentColor,
              foregroundColor: Colors.white,
              elevation: 10,
              shadowColor: kDocumentsAccentColor.withValues(alpha: 0.24),
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
}

enum _DocumentType { gstCertificate, panCard, incorporation, tradeLicense, msme, fssai, other }

class _DocumentAsset {
  final _DocumentType type;
  final String title;
  final String mimeHint;

  const _DocumentAsset({
    required this.type,
    required this.title,
    required this.mimeHint,
  });
}

class _DocumentUploadCard extends StatelessWidget {
  final _DocumentAsset asset;
  final Uint8List? bytes;
  final String? name;
  final bool enabled;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _DocumentUploadCard({
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
            width: 120,
            height: 82,
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
                  asset.title,
                  style: const TextStyle(
                    color: kDocumentsTitleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.mimeHint,
                  style: const TextStyle(
                    color: kDocumentsMutedColor,
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
                      color: kDocumentsTitleColor,
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

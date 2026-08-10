// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';

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
  final ApiService _apiService = ApiService();
  final Map<_DocumentType, Uint8List?> _bytes = {
    for (final type in _DocumentType.values) type: null,
  };
  final Map<_DocumentType, String?> _names = {
    for (final type in _DocumentType.values) type: null,
  };
  final Map<_DocumentType, String?> _urls = {
    for (final type in _DocumentType.values) type: null,
  };
  final Map<_DocumentType, bool> _removed = {
    for (final type in _DocumentType.values) type: false,
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
      final uploadedUrl = await _apiService.uploadOrganizationSettingsFile(
        fileBytes: bytes,
        fileName: picked.name,
      );
      setState(() {
        _bytes[type] = bytes;
        _names[type] = picked.name;
        _removed[type] = false;
        if (uploadedUrl != null && uploadedUrl.trim().isNotEmpty) {
          _urls[type] = uploadedUrl.trim();
        }
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
      _urls[type] = null;
      _removed[type] = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizationSettings();
    });
  }

  Future<void> _loadOrganizationSettings() async {
    try {
      final data = await _apiService.fetchOrganizationSettingsView();
      if (!mounted) return;
      setState(() {
        _applyDocumentFromUrl(
          _DocumentType.gstCertificate,
          _readString(data, 'doc_gst_url'),
        );
        _applyDocumentFromUrl(
          _DocumentType.panCard,
          _readString(data, 'doc_pan_url'),
        );
        _applyDocumentFromUrl(
          _DocumentType.incorporation,
          _readString(data, 'doc_coi_url'),
        );
        _applyDocumentFromUrl(
          _DocumentType.tradeLicense,
          _readString(data, 'doc_trade_license_url'),
        );
        _applyDocumentFromUrl(
          _DocumentType.msme,
          _readString(data, 'doc_msme_url'),
        );
        _applyDocumentFromUrl(
          _DocumentType.fssai,
          _readString(data, 'doc_fssai_url'),
        );
        _applyDocumentFromUrl(
          _DocumentType.other,
          _readString(data, 'doc_other_url'),
        );
      });
    } catch (_) {
      // Keep defaults if documents cannot be loaded.
    }
  }

  void _applyDocumentFromUrl(_DocumentType type, String? url) {
    if (url == null) return;
    _urls[type] = url;
    _removed[type] = false;
    _names[type] = _extractFileName(url);
    if (!_looksLikeImage(url)) {
      return;
    }
    _loadRemoteBytes(url).then((bytes) {
      if (!mounted || bytes == null) return;
      setState(() {
        _bytes[type] = bytes;
      });
    });
  }

  bool _looksLikeImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  String _extractFileName(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return url;
    return uri.pathSegments.last;
  }

  String? _readString(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
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
              title: 'Documents',
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
            ? kDocumentsAccentColor
            : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : kDocumentsTitleColor,
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
      _putDocumentUrl(payload, 'doc_gst_url', _DocumentType.gstCertificate);
      _putDocumentUrl(payload, 'doc_pan_url', _DocumentType.panCard);
      _putDocumentUrl(payload, 'doc_coi_url', _DocumentType.incorporation);
      _putDocumentUrl(
        payload,
        'doc_trade_license_url',
        _DocumentType.tradeLicense,
      );
      _putDocumentUrl(payload, 'doc_msme_url', _DocumentType.msme);
      _putDocumentUrl(payload, 'doc_fssai_url', _DocumentType.fssai);
      _putDocumentUrl(payload, 'doc_other_url', _DocumentType.other);

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

  void _putDocumentUrl(
    Map<String, dynamic> payload,
    String key,
    _DocumentType type,
  ) {
    if (_removed[type] == true) {
      payload[key] = null;
      return;
    }
    _putIfNotBlank(payload, key, _urls[type]);
  }
}

enum _DocumentType {
  gstCertificate,
  panCard,
  incorporation,
  tradeLicense,
  msme,
  fssai,
  other,
}

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
                      onPressed: enabled && (bytes != null || name != null)
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

  const _ResponsiveGrid({required this.isWide, required this.children});

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

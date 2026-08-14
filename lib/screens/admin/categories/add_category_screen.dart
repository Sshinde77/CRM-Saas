import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'category_image_picker.dart';
import 'category_models.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subcategoryController = TextEditingController();

  final List<String> _subcategories = [];
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  String _status = 'Draft';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _imageUrlController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _imageUrlController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _pickImage() {
    _pickImageFromGallery();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await pickCategoryImage();
      if (picked == null || !mounted) return;
      setState(() {
        _selectedImageBytes = picked.bytes;
        _selectedImageName = picked.name;
        _imageUrlController.clear();
      });
    } catch (error) {
      if (mounted) {
        _showSnack('Unable to upload image: $error');
      }
    }
  }

  void _addSubcategory() {
    final text = _subcategoryController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subcategories.add(text);
      _subcategoryController.clear();
    });
  }

  void _removeSubcategory(int index) {
    setState(() => _subcategories.removeAt(index));
  }

  void _saveCategory() {
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Category name is required');
      return;
    }
    final name = _nameController.text.trim();
    final imageLabel = name.isEmpty ? 'C' : name[0].toUpperCase();
    Navigator.of(context).pop(
      CategoryRecord(
        name: name,
        description: _descriptionController.text.trim().isEmpty
            ? '-'
            : _descriptionController.text.trim(),
        imageLabel: imageLabel,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : (_selectedImageName == null ? null : 'uploaded://${_selectedImageName!}'),
        subcategories: List<String>.unmodifiable(_subcategories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImageBytes != null || _imageUrlController.text.trim().isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Categories'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Categories',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 1000;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBreadcrumb(),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Create Category',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Add a new category and organize products with optional subcategories.',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        isCompact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMainForm(compact: true),
                                  const SizedBox(height: 16),
                                  _buildSidePanels(hasImage: hasImage),
                                  const SizedBox(height: 16),
                                  _buildActions(compact: true),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildMainForm(compact: false)),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 280,
                                    child: Column(
                                      children: [
                                        _buildSidePanels(hasImage: hasImage),
                                        const SizedBox(height: 16),
                                        _buildActions(compact: false),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ],
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

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Catalog / Categories / Create Category',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainForm({required bool compact}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Details',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _field(
              label: 'Category Name *',
              controller: _nameController,
              hintText: 'e.g. Mineral Water',
            ),
            const SizedBox(height: 18),
            compact
                ? Column(
                    children: [
                      _field(
                        label: 'Image URL',
                        controller: _imageUrlController,
                        hintText: 'Paste image URL',
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_outlined, size: 18),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4A06),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _field(
                          label: 'Image URL',
                          controller: _imageUrlController,
                          hintText: 'Paste image URL',
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_outlined, size: 18),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4A06),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 18),
            _field(
              label: 'Category Description',
              controller: _descriptionController,
              hintText: 'Write a short description about this category...',
              maxLines: 4,
            ),
            const SizedBox(height: 18),
            const Text(
              'Subcategories',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Press Enter or click Add to include a subcategory.',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 10),
            compact
                ? Column(
                    children: [
                      _field(
                        controller: _subcategoryController,
                        hintText: 'Type a subcategory name',
                        onSubmitted: (_) => _addSubcategory(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: _addSubcategory,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _subcategoryController,
                          hintText: 'Type a subcategory name',
                          onSubmitted: (_) => _addSubcategory(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 84,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: _addSubcategory,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
            if (_subcategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _subcategories.length; i++)
                    Chip(
                      label: Text(_subcategories[i]),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeSubcategory(i),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 18),
            compact
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            foregroundColor: const Color(0xFF111827),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF111827),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanels({required bool hasImage}) {
    return Column(
      children: [
        _panel(
          title: 'Image Preview',
          child: SizedBox(
            height: 150,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: _selectedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasImage ? Icons.image_outlined : Icons.image_not_supported_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 44,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hasImage ? 'Image selected' : 'No image yet',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add an image URL or upload a file',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_selectedImageName != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _selectedImageName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _panel(
          title: 'Preview Summary',
          child: Column(
            children: [
              _summaryRow('Status', _status),
              _divider(),
              _summaryRow('Subcategories', '${_subcategories.length}'),
              _divider(),
              _summaryRow('Products', '0'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions({required bool compact}) {
    final cancelButton = TextButton(
      onPressed: () => Navigator.of(context).maybePop(),
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF3F4F6),
        foregroundColor: const Color(0xFF111827),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: const Text('Cancel'),
    );

    final addButton = SizedBox(
      height: 34,
      child: ElevatedButton.icon(
        onPressed: _saveCategory,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Category'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B4A06),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(0, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (compact) {
      return Row(
        children: [
          Expanded(child: cancelButton),
          const SizedBox(width: 10),
          Expanded(child: addButton),
        ],
      );
    }

    return Row(
      children: [
        const Spacer(),
        cancelButton,
        const SizedBox(width: 10),
        addButton,
      ],
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 13.5,
            ),
          ),
          const Spacer(),
          if (label == 'Status')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 12.5,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFE5E7EB));

  Widget _field({
    TextEditingController? controller,
    required String hintText,
    String? label,
    int maxLines = 1,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0B4A06)),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'add_category_screen.dart';
import 'category_models.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const double _checkboxWidth = 40;
  static const double _categoryWidth = 300;
  static const double _imageWidth = 150;
  static const double _descriptionWidth = 400;
  static const double _actionWidth = 72;
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  List<CategoryRecord> _categories = [
    const CategoryRecord(
      name: 'Beverages',
      description: '-',
      imageLabel: 'B',
      imageUrl: null,
      subcategories: [],
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _apiProvider.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = items.map(_categoryFromJson).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<CategoryRecord> _filteredCategories() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _categories;
    return _categories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          category.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openAddCategoryScreen() async {
    final result = await Navigator.of(context).push<CategoryRecord>(
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    );

    if (result != null && mounted) {
      setState(() => _categories.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filteredCategories();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Categories'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Categories',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 1000;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                            child: isCompact
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Categories',
                                              style: TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Create and manage product categories used across catalog items.',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      _buildAddCategoryButton(compact: true),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Categories',
                                              style: TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Create and manage product categories used across catalog items.',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildAddCategoryButton(compact: false),
                                    ],
                                  ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                            child: isCompact
                                ? _buildSearchField()
                                : Row(
                                    children: [
                                      const Spacer(),
                                      SizedBox(width: 360, child: _buildSearchField()),
                                    ],
                                  ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: isCompact
                                ? _isLoading
                                    ? _loadingState()
                                    : _errorMessage != null
                                        ? _errorState(_errorMessage!, _loadCategories)
                                        : _buildCompactList(categories)
                                : _isLoading
                                    ? _loadingState()
                                    : _errorMessage != null
                                        ? _errorState(_errorMessage!, _loadCategories)
                                        : _buildTable(categories),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                            child: Row(
                              children: [
                                Text(
                                  '${categories.length} to ${categories.isEmpty ? 0 : categories.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Categories',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
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

  Widget _buildAddCategoryButton({required bool compact}) {
    return SizedBox(
      height: compact ? 34 : 36,
      child: ElevatedButton.icon(
        onPressed: _openAddCategoryScreen,
        icon: Icon(Icons.add, size: compact ? 16 : 17),
        label: const Text('Add Category'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B4A06),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: TextStyle(
            fontSize: compact ? 12.5 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _loadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF0B4A06))),
    );
  }

  Widget _errorState(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search categories',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0B4A06)),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactList(List<CategoryRecord> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 56),
        child: Center(
          child: Text(
            'No categories found.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < categories.length; i++) ...[
          _CategoryCompactCard(category: categories[i]),
          if (i != categories.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTable(List<CategoryRecord> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 980),
            child: const Padding(
              padding: EdgeInsets.only(left: 2, right: 2, bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: _checkboxWidth),
                  SizedBox(width: _categoryWidth, child: _TableHead('CATEGORY')),
                  SizedBox(width: _imageWidth, child: _TableHead('IMAGE')),
                  SizedBox(width: _descriptionWidth, child: _TableHead('DESCRIPTION')),
                  SizedBox(width: _actionWidth, child: _TableHead('ACTION')),
                ],
              ),
            ),
          ),
        ),
        if (categories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 56),
            child: Center(
              child: Text(
                'No categories found.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ...categories.map(_buildRow),
      ],
    );
  }

  Widget _buildRow(CategoryRecord category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          const SizedBox(width: _checkboxWidth, child: Checkbox(value: false, onChanged: null)),
          SizedBox(
            width: _categoryWidth,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF8FAFC),
                  child: Text(
                    category.imageLabel,
                    style: const TextStyle(
                      color: Color(0xFF0B4A06),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _imageWidth,
            child: _ImageCell(hasImage: category.imageUrl != null),
          ),
          SizedBox(
            width: _descriptionWidth,
            child: Text(
              category.description.trim().isEmpty ? '-' : category.description,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: _actionWidth,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
              onSelected: (_) {},
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCompactCard extends StatelessWidget {
  final CategoryRecord category;

  const _CategoryCompactCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 32, child: Checkbox(value: false, onChanged: null)),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF8FAFC),
            child: Text(
              category.imageLabel,
              style: const TextStyle(
                color: Color(0xFF0B4A06),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ImageCell(hasImage: category.imageUrl != null),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.description.trim().isEmpty ? '-' : category.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
                      onSelected: (_) {},
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  final String text;

  const _TableHead(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _ImageCell extends StatelessWidget {
  final bool hasImage;

  const _ImageCell({required this.hasImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(
        hasImage ? Icons.image_outlined : Icons.image_not_supported_outlined,
        size: 20,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}

CategoryRecord _categoryFromJson(Map<String, dynamic> json) {
  final name = _readText(json, const ['name', 'category_name'], fallback: '-');
  final imageUrl = _readNullableText(json, const ['image', 'category_image']);
  return CategoryRecord(
    name: name,
    description: _readText(json, const ['description'], fallback: '-'),
    imageLabel: name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase(),
    imageUrl: imageUrl,
    subcategories: const [],
  );
}

String _readText(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  return _readNullableText(json, keys) ?? fallback;
}

String? _readNullableText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

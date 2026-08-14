import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import 'add_supplier_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedTab = 'All';
  String _selectedCategory = 'All categories';

  static const List<String> _tabs = ['All', 'Active', 'Inactive'];
  static const List<String> _categories = [
    'All categories',
    'Manufacturer',
    'Packaging',
    'Raw Materials',
    'Logistics',
    'Others',
  ];

  final List<_SupplierRecord> _suppliers = const [
    _SupplierRecord(
      name: 'information',
      category: 'Manufacturer',
      contact: '517364644',
      city: 'Location',
      totalPurchases: 'Rs 0',
      outstandingPayable: 'Rs 0',
      status: 'active',
      statusColor: Color(0xFF15803D),
      statusBg: Color(0xFFF0FDF4),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SupplierRecord> _filteredSuppliers() {
    final query = _searchController.text.trim().toLowerCase();
    return _suppliers.where((supplier) {
      final tabMatch = switch (_selectedTab) {
        'Active' => supplier.status.toLowerCase() == 'active',
        'Inactive' => supplier.status.toLowerCase() == 'inactive',
        _ => true,
      };
      if (!tabMatch) return false;

      final categoryMatch =
          _selectedCategory == 'All categories' ||
          supplier.category == _selectedCategory;
      if (!categoryMatch) return false;

      if (query.isEmpty) return true;
      return supplier.name.toLowerCase().contains(query) ||
          supplier.category.toLowerCase().contains(query) ||
          supplier.contact.toLowerCase().contains(query) ||
          supplier.city.toLowerCase().contains(query) ||
          supplier.totalPurchases.toLowerCase().contains(query) ||
          supplier.outstandingPayable.toLowerCase().contains(query) ||
          supplier.status.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openAddSupplierScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddSupplierScreen()),
    );

    if (result != null && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = _filteredSuppliers();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Suppliers'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 900;

            return Column(
              children: [
                AdminTopBar(
                  title: 'Suppliers',
                  leadingIcon: Icons.menu_rounded,
                  onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 14 : 18,
                      14,
                      isCompact ? 14 : 18,
                      18,
                    ),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: isCompact ? 14 : 22,
                                    runSpacing: 10,
                                    children: _tabs
                                        .map(
                                          (tab) => _TabChip(
                                            label: tab,
                                            selected: _selectedTab == tab,
                                            onTap: () => setState(() => _selectedTab = tab),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _addSupplierButton(compact: true),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                            child: isCompact
                                ? Column(
                                    children: [
                                      _searchField(),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: _categoryDropdown(),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(child: _searchField()),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 210,
                                        child: _categoryDropdown(),
                                      ),
                                    ],
                                  ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: isCompact
                                ? _buildCompactList(suppliers)
                                : _buildTable(suppliers),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                            child: Row(
                              children: [
                                Text(
                                  '${suppliers.length} to ${suppliers.isEmpty ? 0 : suppliers.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Suppliers',
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search suppliers, contact, phone',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  Widget _addSupplierButton({bool compact = false}) {
    return ElevatedButton.icon(
      onPressed: _openAddSupplierScreen,
      icon: Icon(Icons.add, size: compact ? 16 : 18),
      label: const Text('Add Supplier'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B4A06),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size(compact ? 0 : 44, compact ? 34 : 44),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: compact ? 8 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: TextStyle(
          fontSize: compact ? 12.5 : 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      items: _categories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedCategory = value);
      },
    );
  }

  Widget _buildTable(List<_SupplierRecord> suppliers) {
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
                  Expanded(flex: 3, child: _TableHead('SUPPLIER')),
                  Expanded(flex: 2, child: _TableHead('CONTACT')),
                  Expanded(flex: 2, child: _TableHead('CITY')),
                  Expanded(flex: 2, child: _TableHead('TOTAL PURCHASES')),
                  Expanded(flex: 2, child: _TableHead('OUTSTANDING PAYABLE')),
                  Expanded(flex: 1, child: _TableHead('STATUS')),
                  SizedBox(width: 60, child: _TableHead('ACTION')),
                ],
              ),
            ),
          ),
        ),
        if (suppliers.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 56),
            child: Center(
              child: Text(
                'No suppliers found.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ...suppliers.map(_supplierRow),
      ],
    );
  }

  Widget _buildCompactList(List<_SupplierRecord> suppliers) {
    if (suppliers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 56),
        child: Center(
          child: Text(
            'No suppliers found.',
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
        for (var i = 0; i < suppliers.length; i++) ...[
          _supplierCard(suppliers[i]),
          if (i != suppliers.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _supplierRow(_SupplierRecord supplier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        supplier.category,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              supplier.contact,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              supplier.city,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              supplier.totalPurchases,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              supplier.outstandingPayable,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: supplier.statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  supplier.status,
                  style: TextStyle(
                    color: supplier.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 60,
            child: Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _supplierCard(_SupplierRecord supplier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                alignment: Alignment.center,
                child: Text(
                  supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.category,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _mobileInfoRow('Contact', supplier.contact),
          const SizedBox(height: 8),
          _mobileInfoRow('City', supplier.city),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _mobileInfoRow('Purchases', supplier.totalPurchases)),
              const SizedBox(width: 10),
              Expanded(child: _mobileInfoRow('Payable', supplier.outstandingPayable)),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: supplier.statusBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                supplier.status,
                style: TextStyle(
                  color: supplier.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF0B4A06) : const Color(0xFF64748B),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 18,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0B4A06) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  final String label;

  const _TableHead(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SupplierRecord {
  final String name;
  final String category;
  final String contact;
  final String city;
  final String totalPurchases;
  final String outstandingPayable;
  final String status;
  final Color statusColor;
  final Color statusBg;

  const _SupplierRecord({
    required this.name,
    required this.category,
    required this.contact,
    required this.city,
    required this.totalPurchases,
    required this.outstandingPayable,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });
}

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_bottom_navigation.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import 'create_delivery_customer_screen.dart';

class DeliveryCustomersScreen extends StatefulWidget {
  const DeliveryCustomersScreen({super.key});

  @override
  State<DeliveryCustomersScreen> createState() =>
      _DeliveryCustomersScreenState();
}

class _DeliveryCustomersScreenState extends State<DeliveryCustomersScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();
  List<CustomerModel> _customers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCustomers();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customers = await ApiProviderScope.of(context).fetchCustomers();
      if (!mounted) return;
      setState(() => _customers = customers);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load customers. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCustomer() async {
    final customer = await Navigator.of(context).push<CustomerModel>(
      MaterialPageRoute(builder: (_) => const CreateDeliveryCustomerScreen()),
    );
    if (customer != null && mounted) {
      _search.clear();
      await _loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final customers = _customers.where((customer) {
      return [
        customer.name,
        customer.businessName,
        customer.phone,
        customer.customerId,
      ].whereType<String>().any((value) => value.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.deliveryBackground,
      drawer: const DeliveryPartnerSidebar(
        currentRoute: AppRoutes.deliveryCustomers,
      ),
      bottomNavigationBar: const DeliveryBottomNavigation(currentIndex: -1),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'delivery-create-customer',
        onPressed: _createCustomer,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Create Customer'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Customers',
              subtitle: 'View and search your customers',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search by name, phone or customer ID',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setState(_search.clear),
                                  ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_error!, textAlign: TextAlign.center),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: _loadCustomers,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadCustomers,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    96,
                                  ),
                                  itemCount: customers.isEmpty
                                      ? 1
                                      : customers.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, index) => customers.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 48,
                                          ),
                                          child: Text(
                                            query.isEmpty
                                                ? 'No customers yet. Create your first customer.'
                                                : 'No customers match your search.',
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : _customerCard(customers[index]),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerCard(CustomerModel customer) {
    final address =
        customer.deliveryAddress ?? customer.address ?? customer.billingAddress;
    final details = [
      customer.customerId,
      customer.phone,
      address,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.surfaceSoft,
            child: Icon(Icons.storefront_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                for (final detail in details)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      detail,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

/// Vehicle Stock screen — shows stock levels currently loaded in each
/// delivery vehicle, grouped by vehicle/driver, with a per-vehicle total.
class VehicleStockScreen extends StatefulWidget {
  const VehicleStockScreen({super.key});

  @override
  State<VehicleStockScreen> createState() => _VehicleStockScreenState();
}

class _VehicleStockScreenState extends State<VehicleStockScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _selectedPartner = 'All Delivery Partners';
  final Set<String> _expandedVehicles = {};

  // Mock data — replace with your providers / API calls.
  final List<_VehicleStock> _vehicles = const [
    _VehicleStock(
      vehicleNo: 'KA-05-1000',
      driver: 'Suresh Kumar',
      phone: '+91 98450 11223',
      email: 'delivery@demo.com',
      vehicleModel: 'Tata Ace (Mini Truck)',
      licenseNumber: 'KA05 20230011223',
      joinedOn: '12 Jan 2024',
      status: 'Active',
      totalDeliveries: 482,
      pendingDeliveries: 6,
      lines: [
        _StockLine('Packaged Drinking Water (250ml)', 200, 24),
        _StockLine('Packaged Drinking Water (500ml)', 160, 24),
        _StockLine('Packaged Drinking Water (1L)', 120, 12),
        _StockLine('Packaged Drinking Water (2L)', 80, 9),
      ],
    ),
    _VehicleStock(
      vehicleNo: 'KA-05-1002',
      driver: 'Ramesh Yadav',
      phone: '+91 98450 33445',
      email: 'ramesh.yadav@demo.com',
      vehicleModel: 'Mahindra Bolero Pickup',
      licenseNumber: 'KA05 20220045678',
      joinedOn: '03 Jun 2024',
      status: 'Active',
      totalDeliveries: 310,
      pendingDeliveries: 3,
      lines: [
        _StockLine('Water Jar Refill (20L)', 40, 1),
        _StockLine('Mineral Water Bottle (1L)', 96, 12),
        _StockLine('Sparkling Water Can (330ml)', 144, 24),
      ],
    ),
  ];

  List<String> get _partners => [
    'All Delivery Partners',
    ..._vehicles.map((v) => v.driver).toSet(),
  ];

  List<_VehicleStock> get _filteredVehicles {
    if (_selectedPartner == 'All Delivery Partners') return _vehicles;
    return _vehicles.where((v) => v.driver == _selectedPartner).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = _filteredVehicles;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Vehicle Stock'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Vehicle Stock',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicle Stock',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Track stock levels in delivery vehicles',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _partnerDropdown(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (vehicles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No vehicles for this delivery partner.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...vehicles.map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _vehicleCard(v),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partnerDropdown() {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.24)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPartner,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textSecondary,
          ),
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          items: _partners
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedPartner = v);
          },
        ),
      ),
    );
  }

  Widget _driverDetails(_VehicleStock vehicle) {
    final active = vehicle.status == 'Active';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Driver Details',
                  style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (active ? AppColors.green : textSecondary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (active ? AppColors.green : textSecondary).withValues(alpha: 0.35)),
                ),
                child: Text(vehicle.status,
                    style: TextStyle(
                        color: active ? AppColors.green : textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _driverDetailItem('Phone', vehicle.phone)),
              Expanded(child: _driverDetailItem('Email', vehicle.email)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _driverDetailItem('Vehicle Model', vehicle.vehicleModel)),
              Expanded(child: _driverDetailItem('License No.', vehicle.licenseNumber)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _driverDetailItem('Joined On', vehicle.joinedOn)),
              Expanded(child: _driverDetailItem('Total Deliveries', '${vehicle.totalDeliveries}')),
            ],
          ),
          const SizedBox(height: 12),
          _driverDetailItem('Pending Deliveries', '${vehicle.pendingDeliveries}'),
        ],
      ),
    );
  }

  Widget _driverDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _vehicleCard(_VehicleStock vehicle) {
    final total = vehicle.lines.fold<int>(0, (sum, l) => sum + l.count);
    final isExpanded = _expandedVehicles.contains(vehicle.vehicleNo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle ${vehicle.vehicleNo}',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Driver: ${vehicle.driver}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  if (_expandedVehicles.contains(vehicle.vehicleNo)) {
                    _expandedVehicles.remove(vehicle.vehicleNo);
                  } else {
                    _expandedVehicles.add(vehicle.vehicleNo);
                  }
                }),
                icon: Icon(
                  isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: textSecondary,
                  size: 24,
                ),
                splashRadius: 20,
                tooltip: isExpanded ? 'Hide details' : 'Show details',
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _driverDetails(vehicle),
                  const SizedBox(height: 12),
                  ...vehicle.lines.map((line) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 18, color: textSecondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(line.product,
                                    style:
                                        const TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${line.count} case',
                                      style: const TextStyle(
                                          color: AppColors.purple, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                  Text('(${line.caseSize})',
                                      style: const TextStyle(
                                          color: AppColors.purple, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const Divider(color: AppColors.secondary, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Stock', style: TextStyle(color: textSecondary, fontSize: 14)),
                      Text('$total units',
                          style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StockLine {
  final String product;
  final int count;
  final int caseSize;
  const _StockLine(this.product, this.count, this.caseSize);
}

class _VehicleStock {
  final String vehicleNo;
  final String driver;
  final String phone;
  final String email;
  final String vehicleModel;
  final String licenseNumber;
  final String joinedOn;
  final String status;
  final int totalDeliveries;
  final int pendingDeliveries;
  final List<_StockLine> lines;
  const _VehicleStock({
    required this.vehicleNo,
    required this.driver,
    required this.phone,
    required this.email,
    required this.vehicleModel,
    required this.licenseNumber,
    required this.joinedOn,
    required this.status,
    required this.totalDeliveries,
    required this.pendingDeliveries,
    required this.lines,
  });
}

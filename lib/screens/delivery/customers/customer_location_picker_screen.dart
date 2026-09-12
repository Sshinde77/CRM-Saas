import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';

class CustomerLocationPickerScreen extends StatefulWidget {
  const CustomerLocationPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<CustomerLocationPickerScreen> createState() =>
      _CustomerLocationPickerScreenState();
}

class _CustomerLocationPickerScreenState
    extends State<CustomerLocationPickerScreen> {
  static const _green = AppColors.deliveryGreen;
  final _mapController = MapController();
  late LatLng? _selected = widget.initialLocation;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoom(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + delta).clamp(2, 19));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin customer location'),
        backgroundColor: AppColors.deliveryDashboardHeaderEnd,
        foregroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Move and zoom the map, then tap to place your pin.'),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        widget.initialLocation ??
                        const LatLng(12.9352, 77.6245),
                    initialZoom: 15,
                    minZoom: 2,
                    maxZoom: 19,
                    onTap: (_, point) => setState(() => _selected = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.crm_saas.app',
                    ),
                    if (selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selected,
                            width: 48,
                            height: 48,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_pin,
                              size: 48,
                              color: _green,
                              semanticLabel: 'Selected customer location',
                            ),
                          ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      IconButton.filled(
                        tooltip: 'Zoom in',
                        style: IconButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                          iconSize: 28,
                        ),
                        onPressed: () => _zoom(1),
                        icon: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      IconButton.filled(
                        tooltip: 'Zoom out',
                        style: IconButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                          iconSize: 28,
                        ),
                        onPressed: () => _zoom(-1),
                        icon: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    selected == null
                        ? 'Tap the map to select a location'
                        : '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _green),
                    onPressed: selected == null
                        ? null
                        : () => Navigator.of(context).pop(selected),
                    child: const Text('Confirm location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

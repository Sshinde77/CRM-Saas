import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';

class MapLocationViewScreen extends StatelessWidget {
  const MapLocationViewScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title = 'Map location',
    this.subtitle,
  });

  final double latitude;
  final double longitude;
  final String title;
  final String? subtitle;

  google_maps.LatLng get _position => google_maps.LatLng(latitude, longitude);

  Future<void> _openExternally(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Google Maps.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Open in Google Maps',
              onPressed: () => _openExternally(context),
              icon: const Icon(Icons.open_in_new_rounded, size: 22),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              google_maps.GoogleMap(
                initialCameraPosition: google_maps.CameraPosition(
                  target: _position,
                  zoom: 16,
                ),
                markers: {
                  google_maps.Marker(
                    markerId: const google_maps.MarkerId('location'),
                    position: _position,
                    infoWindow: google_maps.InfoWindow(
                      title: subtitle ?? title,
                    ),
                  ),
                },
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (subtitle != null &&
                                  subtitle!.trim().isNotEmpty)
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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
          ),
        ),
      ),
    );
  }
}

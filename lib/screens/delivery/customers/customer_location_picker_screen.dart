import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart' as latlong;

import '../../../constants/app_colors.dart';
import '../../../services/location_search_service.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class PickedMapLocation {
  const PickedMapLocation({required this.location, required this.placeName});

  final latlong.LatLng location;
  final String placeName;
}

class CustomerLocationPickerScreen extends StatefulWidget {
  const CustomerLocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialPlaceName,
  });

  final latlong.LatLng? initialLocation;
  final String? initialPlaceName;

  @override
  State<CustomerLocationPickerScreen> createState() =>
      _CustomerLocationPickerScreenState();
}

class _CustomerLocationPickerScreenState
    extends State<CustomerLocationPickerScreen> {
  static const _green = AppColors.deliveryGreen;
  static const _fallbackLocation = google_maps.LatLng(12.9352, 77.6245);

  final _searchController = TextEditingController();
  final _searchService = const LocationSearchService();

  google_maps.GoogleMapController? _mapController;
  Timer? _searchDebounce;
  int _lookupToken = 0;
  late google_maps.LatLng? _selected = _toGoogleLatLng(
    widget.initialLocation,
  );
  late String? _selectedPlaceName = _cleanPlaceName(widget.initialPlaceName);
  List<LocationSearchResult> _results = const [];
  bool _searching = false;
  bool _locating = false;
  bool _resolvingPlace = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    if (_selected != null && _selectedPlaceName == null) {
      unawaited(_resolvePlaceName(_selected!));
    } else if (_selected == null) {
      unawaited(_useCurrentLocation(silent: true));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  static google_maps.LatLng? _toGoogleLatLng(latlong.LatLng? location) {
    if (location == null) return null;
    return google_maps.LatLng(location.latitude, location.longitude);
  }

  static String? _cleanPlaceName(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    if (RegExp(r'^-?\d+(?:\.\d+)?\s*,\s*-?\d+(?:\.\d+)?$').hasMatch(text)) {
      return null;
    }
    return text;
  }

  latlong.LatLng _toResultLatLng(google_maps.LatLng location) {
    return latlong.LatLng(location.latitude, location.longitude);
  }

  Future<void> _zoom(double amount) async {
    await _mapController?.animateCamera(
      google_maps.CameraUpdate.zoomBy(amount),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _results = const [];
        _searching = false;
        _searchError = null;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await _searchService.search(query);
      if (!mounted || _searchController.text.trim() != query) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _searching = false;
        _searchError = 'Could not search locations';
      });
    }
  }

  Future<void> _selectSearchResult(LocationSearchResult result) async {
    FocusScope.of(context).unfocus();
    _searchController.text = result.displayName;
    setState(() => _results = const []);
    await _selectLocation(
      google_maps.LatLng(result.location.latitude, result.location.longitude),
      placeName: result.displayName,
    );
  }

  Future<void> _selectLocation(
    google_maps.LatLng point, {
    String? placeName,
  }) async {
    setState(() {
      _selected = point;
      _selectedPlaceName = _cleanPlaceName(placeName);
      _resolvingPlace = _selectedPlaceName == null;
    });
    await _mapController?.animateCamera(
      google_maps.CameraUpdate.newLatLngZoom(point, 16),
    );
    if (_selectedPlaceName == null) {
      await _resolvePlaceName(point);
    }
  }

  Future<void> _resolvePlaceName(google_maps.LatLng point) async {
    final token = ++_lookupToken;
    setState(() => _resolvingPlace = true);
    try {
      final result = await _searchService.reverseLookup(
        latlong.LatLng(point.latitude, point.longitude),
      );
      if (!mounted || token != _lookupToken) return;
      setState(() {
        _selectedPlaceName = result?.displayName ?? 'Pinned location';
        _resolvingPlace = false;
      });
    } catch (_) {
      if (!mounted || token != _lookupToken) return;
      setState(() {
        _selectedPlaceName = 'Pinned location';
        _resolvingPlace = false;
      });
    }
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!silent) _showSnack('Please turn on location services.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (!silent) {
          _showSnack('Location permission is needed to use current location.');
        }
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (!silent) {
          _showSnack('Enable location permission from app settings.');
          await Geolocator.openAppSettings();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _selectLocation(
        google_maps.LatLng(position.latitude, position.longitude),
        placeName: 'Current location',
      );
    } catch (_) {
      if (!silent) _showSnack('Could not get current location.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _selectedLabel(google_maps.LatLng? selected) {
    if (selected == null) return 'Tap the map or search to select a location';
    if (_resolvingPlace) return 'Finding place name...';
    return _selectedPlaceName ?? 'Pinned location';
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: DeliveryTopBar(
              title: 'Pin customer location',
              subtitle: 'Search, use current location, or tap the map',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                google_maps.GoogleMap(
                  initialCameraPosition: google_maps.CameraPosition(
                    target: selected ?? _fallbackLocation,
                    zoom: 15,
                  ),
                  minMaxZoomPreference: const google_maps.MinMaxZoomPreference(
                    2,
                    19,
                  ),
                  markers: selected == null
                      ? const <google_maps.Marker>{}
                      : {
                          google_maps.Marker(
                            markerId: const google_maps.MarkerId(
                              'selected-customer-location',
                            ),
                            position: selected,
                            infoWindow: google_maps.InfoWindow(
                              title: _selectedPlaceName ?? 'Pinned location',
                            ),
                          ),
                        },
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    final selected = _selected;
                    if (selected != null) {
                      controller.animateCamera(
                        google_maps.CameraUpdate.newLatLngZoom(selected, 16),
                      );
                    }
                  },
                  onTap: _selectLocation,
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: _SearchPanel(
                    controller: _searchController,
                    searching: _searching,
                    error: _searchError,
                    results: _results,
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    onSelect: _selectSearchResult,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      IconButton.filled(
                        tooltip: 'Use current location',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _green,
                          minimumSize: const Size(48, 48),
                          iconSize: 22,
                        ),
                        onPressed: _locating ? null : _useCurrentLocation,
                        icon: _locating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                      ),
                      const SizedBox(height: 8),
                      IconButton.filled(
                        tooltip: 'Zoom in',
                        style: IconButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                          iconSize: 24,
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
                          iconSize: 24,
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
                    _selectedLabel(selected),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _green),
                    onPressed: selected == null
                        ? null
                        : () => Navigator.of(context).pop(
                            PickedMapLocation(
                              location: _toResultLatLng(selected),
                              placeName:
                                  _selectedPlaceName ?? 'Pinned location',
                            ),
                          ),
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

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.searching,
    required this.error,
    required this.results,
    required this.onChanged,
    required this.onClear,
    required this.onSelect,
  });

  final TextEditingController controller;
  final bool searching;
  final String? error;
  final List<LocationSearchResult> results;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<LocationSearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: onClear,
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (searching)
            const LinearProgressIndicator(minHeight: 2)
          else if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                error!,
                style: const TextStyle(
                  color: AppColors.deliveryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = results[index];
                  return ListTile(
                    dense: true,
                    minLeadingWidth: 20,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.deliveryGreen,
                      size: 20,
                    ),
                    title: Text(
                      result.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      result.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => onSelect(result),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

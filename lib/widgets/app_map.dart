import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/map_service.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class AppMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool interactive; // false = mini map, true = full screen
  final bool showPin;

  // Optional second point (e.g. a worker's live location) — when set, a
  // second marker is drawn along with a line connecting the two points.
  final double? secondaryLatitude;
  final double? secondaryLongitude;
  final IconData secondaryIcon;
  final Color secondaryColor;

  const AppMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15.0,
    this.interactive = false,
    this.showPin = true,
    this.secondaryLatitude,
    this.secondaryLongitude,
    this.secondaryIcon = Icons.directions_car,
    this.secondaryColor = Colors.blue,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  CacheStore? _cacheStore;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  Future<void> _initCache() async {
    final store = await MapService.getCacheStore();
    setState(() {
      _cacheStore = store;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final location = LatLng(widget.latitude, widget.longitude);
    final hasSecondary =
        widget.secondaryLatitude != null && widget.secondaryLongitude != null;
    final secondaryLocation = hasSecondary
        ? LatLng(widget.secondaryLatitude!, widget.secondaryLongitude!)
        : null;

    // Center between both points when tracking a second location, so
    // neither pin starts off-screen.
    final center = secondaryLocation == null
        ? location
        : LatLng(
            (location.latitude + secondaryLocation.latitude) / 2,
            (location.longitude + secondaryLocation.longitude) / 2,
          );

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: widget.zoom,
        // Disable interactions for mini map
        interactionOptions: InteractionOptions(
          flags: widget.interactive
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
      ),
      children: [
        // OpenStreetMap tile layer with caching
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.lsf.app',
          tileProvider: CachedTileProvider(
            // Cache tiles so map works offline
            store: _cacheStore!,
            maxStale: const Duration(days: 30), // cache for 30 days
            cachePolicy:
                CachePolicy.forceCache, // always use cache if available
          ),
        ),

        // Line joining the destination and the secondary (e.g. worker) point
        if (secondaryLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [location, secondaryLocation],
                strokeWidth: 4,
                color: widget.secondaryColor,
              ),
            ],
          ),

        // Destination marker
        if (widget.showPin)
          MarkerLayer(
            markers: [
              Marker(
                point: location,
                width: 50,
                height: 50,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    // Pin tail
                    Container(
                      width: 2,
                      height: 8,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

        // Secondary (e.g. worker) marker
        if (secondaryLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: secondaryLocation,
                width: 44,
                height: 44,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.secondaryColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.secondaryIcon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

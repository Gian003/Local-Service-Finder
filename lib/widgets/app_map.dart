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

  const AppMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15.0,
    this.interactive = false,
    this.showPin = true,
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

    return FlutterMap(
      options: MapOptions(
        initialCenter: location,
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
      ],
    );
  }
}

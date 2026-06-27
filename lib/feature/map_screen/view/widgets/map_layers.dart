import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/core/const/app_secret.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


class MapLayers extends StatelessWidget {
  final MapConnectionController controller;

  const MapLayers({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final route = controller.route.value;
      final origin = controller.originLatLng.value;
      final destination = controller.destinationLatLng.value;

      return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialZoom: AppSecret.defaultZoom,
          initialCenter: AppSecret.initialCenterLatLng,
          onTap: controller.onMapTap,
        ),
        children: [
          // ── Tile Layer ────────────────────────────────────────────────────
          TileLayer(
            urlTemplate: controller.isSatelliteView.value
                ? AppSecret.satelliteTileUrl
                : AppSecret.osmTileUrl,
            userAgentPackageName: AppSecret.userAgentPackageName,
            maxZoom: 19,
          ),

          // ── Route Polyline ─────────────────────────────────────────────────
          if (route.polylinePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route.polylinePoints,
                  color: const Color(0xFF1A73E8),
                  strokeWidth: 5,
                  borderColor: Colors.white,
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),

          // ── Markers ────────────────────────────────────────────────────────
          MarkerLayer(
            markers: [
              if (origin != null)
                Marker(
                  point: origin,
                  width: 36,
                  height: 36,
                  child: _OriginMarker(),
                ),
              if (destination != null)
                Marker(
                  point: destination,
                  width: 44,
                  height: 44,
                  child: _DestinationMarker(),
                ),
            ],
          ),
        ],
      );
    });
  }
}

// ── Origin Marker (blue pulsing dot) ──────────────────────────────────────────
class _OriginMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A73E8),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// ── Destination Marker (red pin) ──────────────────────────────────────────────
class _DestinationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.location_on,
      color: Color(0xFFE53935),
      size: 44,
      shadows: [
        Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }
}
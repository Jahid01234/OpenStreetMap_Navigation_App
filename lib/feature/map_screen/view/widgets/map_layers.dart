import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';

class MapLayersWidget extends StatelessWidget {
  final MapConnectionController controller;

  const MapLayersWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPos = controller.currentPosition.value;
      final destPos = controller.destinationPoint.value;
      final route = controller.routeResult.value;

      return Stack(
        children: [
          // Route Polyline
          if (route != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route.points,
                  strokeWidth: 6,
                  color: const Color(0xFF4A9EFF),
                  borderColor: const Color(0xFF1A6FDB),
                  borderStrokeWidth: 2,
                ),
              ],
            ),

          // Markers
          MarkerLayer(
            markers: [
              // Current Location Marker
              if (currentPos != null &&
                  currentPos.latitude.isFinite &&
                  currentPos.longitude.isFinite)
                Marker(
                  point: currentPos,
                  width: 60,
                  height: 60,
                  child: _CurrentLocationMarker(
                    heading: controller.userHeading.value,
                  ),
                ),

              // Destination Marker
              if (destPos != null &&
                  destPos.latitude.isFinite &&
                  destPos.longitude.isFinite)
                Marker(
                  point: destPos,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_pin,
                    color: Color(0xFFFF4757),
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  final double heading;
  const _CurrentLocationMarker({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing outer ring
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A9EFF).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF4A9EFF).withOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),
          // Direction arrow
          Transform.rotate(
            angle: heading * (3.14159 / 180),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4A9EFF),
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


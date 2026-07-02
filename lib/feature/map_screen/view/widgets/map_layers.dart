import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/current_location_marker.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/navigation_marker.dart';

class MapLayersWidget extends StatelessWidget {
  final MapConnectionController controller;

  const MapLayersWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPos = controller.currentPosition.value;
      final destPos = controller.destinationPoint.value;
      final navPos = controller.navigationPosition.value;
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
                  child: CurrentLocationMarker(
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

               // Moving Navigation Marker
                if (navPos != null &&
                    navPos.latitude.isFinite &&
                    navPos.longitude.isFinite)
                  Marker(
                    point: navPos,
                    width: 60,
                    height: 60,
                    child: NavigationMarker(
                      heading: controller.userHeading.value,
                    ),
                  ),
            ],
          ),
        ],
      );
    });
  }
}






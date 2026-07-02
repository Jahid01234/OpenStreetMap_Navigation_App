import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/core/global_widget/map_fab.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';

class MapControlButtons extends StatelessWidget {
  final MapConnectionController controller;

  const MapControlButtons({
    super.key,
    required this.controller,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Recenter / Follow
        Obx(() => MapFAB(
          icon: controller.isSatelliteView.value
              ? Icons.map_outlined
              : Icons.satellite_alt_outlined,
          color: controller.isMapFollowing.value
              ? const Color(0xFF4A9EFF)
              : Colors.white,
          onTap: controller.toggleMapStyle,
        )),
        const SizedBox(height: 10),
        Obx(() => MapFAB(
          icon: controller.isMapFollowing.value
              ? Icons.gps_fixed
              : Icons.gps_not_fixed,
          color: controller.isMapFollowing.value
              ? const Color(0xFF4A9EFF)
              : Colors.white,
          onTap: controller.recenterMap,
        )),
        const SizedBox(height: 10),
        // Zoom In
        MapFAB(
          icon: Icons.add,
          onTap: () => controller.mapController.move(
            controller.mapController.camera.center,
            controller.mapController.camera.zoom + 1,
          ),
        ),
        const SizedBox(height: 10),
        // Zoom Out
        MapFAB(
          icon: Icons.remove,
          onTap: () => controller.mapController.move(
            controller.mapController.camera.center,
            controller.mapController.camera.zoom - 1,
          ),
        ),
      ],
    );
  }
}



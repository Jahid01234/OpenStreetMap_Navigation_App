import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';

class MapControlButtons extends StatelessWidget {
  final MapConnectionController controller;

  const MapControlButtons({super.key, required this.controller});


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Recenter / Follow
        Obx(() => _MapFAB(
          icon: controller.isSatelliteView.value
              ? Icons.map_outlined
              : Icons.satellite_alt_outlined,
          color: controller.isMapFollowing.value
              ? const Color(0xFF4A9EFF)
              : Colors.white,
          onTap: controller.toggleMapStyle,
        )),
        const SizedBox(height: 10),
        Obx(() => _MapFAB(
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
        _MapFAB(
          icon: Icons.add,
          onTap: () => controller.mapController.move(
            controller.mapController.camera.center,
            controller.mapController.camera.zoom + 1,
          ),
        ),
        const SizedBox(height: 10),
        // Zoom Out
        _MapFAB(
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


class _MapFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MapFAB({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
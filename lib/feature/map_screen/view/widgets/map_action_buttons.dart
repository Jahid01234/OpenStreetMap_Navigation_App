import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


class MapActionButtons extends StatelessWidget {
  final MapConnectionController controller;

  const MapActionButtons({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 200,
      child: Column(
        children: [
          // ── Satellite toggle ──────────────────────────────────────────────
          Obx(() => _ActionButton(
            icon: controller.isSatelliteView.value
                ? Icons.map_outlined
                : Icons.satellite_alt_outlined,
            tooltip: controller.isSatelliteView.value
                ? 'Street View'
                : 'Satellite',
            onTap: controller.toggleMapStyle,
          )),
          const SizedBox(height: 10),

          // ── Current location ──────────────────────────────────────────────
          _ActionButton(
            icon: Icons.my_location,
            tooltip: 'My Location',
            onTap: () {
              // GPS integration can be wired here
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF444444)),
        ),
      ),
    );
  }
}
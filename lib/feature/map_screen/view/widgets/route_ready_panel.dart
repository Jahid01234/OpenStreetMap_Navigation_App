import 'package:flutter/material.dart';
import 'package:open_streetmap_app/core/global_widget/info_chip.dart';
import 'package:open_streetmap_app/core/style/global_text_style.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';

class RouteReadyPanel extends StatelessWidget {
  final MapConnectionController controller;

  const RouteReadyPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Destination
        Row(
          children: [
            const Icon(Icons.location_pin, color: Color(0xFFFF4757), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.destinationAddress.value.isNotEmpty
                    ? controller.destinationAddress.value
                    : 'Selected Destination',
                style: globalTextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Distance & Time chips
        Row(
          children: [
            InfoChip(
              title: "Distance",
              icon: Icons.straighten,
              label: controller.remainingDistance.value,
              color: const Color(0xFF4A9EFF),
            ),
            const SizedBox(width: 12),
            InfoChip(
              title: "ETA",
              icon: Icons.timer,
              label: controller.remainingDuration.value,
              color: const Color(0xFFFF6B35),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.startNavigation,
                icon: const Icon(Icons.navigation, size: 18),
                label: Text(
                  'Start',
                  style: globalTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A9EFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: controller.clearRoute,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

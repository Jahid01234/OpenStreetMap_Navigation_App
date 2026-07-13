import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/core/global_widget/info_chip.dart';
import 'package:open_streetmap_app/core/style/global_text_style.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';

class NavigatingPanel extends StatelessWidget {
  final MapConnectionController controller;

  const NavigatingPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current Step Instruction
        Obx(() {
          final step = controller.currentStep;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9EFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _maneuverIcon(step?.maneuverType ?? ''),
                  color: const Color(0xFF4A9EFF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  step?.instruction ?? 'Follow the route',
                  style: globalTextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        // Distance & ETA
        Obx(() => Row(
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
            const Spacer(),
            GestureDetector(
              onTap: controller.stopNavigation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stop, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Stop',
                      style: globalTextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  IconData _maneuverIcon(String type) {
    switch (type) {
      case 'turn':
        return Icons.turn_right;
      case 'arrive':
        return Icons.flag;
      case 'depart':
        return Icons.navigation;
      case 'roundabout':
        return Icons.roundabout_right;
      case 'merge':
        return Icons.merge;
      default:
        return Icons.straight;
    }
  }
}



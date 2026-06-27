import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


class RouteInfoSheet extends StatelessWidget {
  final MapConnectionController controller;

  const RouteInfoSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isRouteReady.value) return const SizedBox.shrink();

      final route = controller.route.value;
      final dist = route.distanceKm.toStringAsFixed(1);
      final dur = route.durationMinutes;

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ───────────────────────────────────────────────
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Route Ready Label ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.alt_route,
                            color: Color(0xFF1A73E8), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Route ready',
                          style: TextStyle(
                            color: Color(0xFF1A73E8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // ── Close ────────────────────────────────────────────────
                  GestureDetector(
                    onTap: controller.clearRoute,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Distance & Duration ───────────────────────────────────────
              Row(
                children: [
                  // Distance
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.straighten,
                      iconColor: const Color(0xFF1A73E8),
                      bgColor: const Color(0xFFE8F0FE),
                      label: 'Distance',
                      value: '$dist km',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Duration
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFFE53935),
                      bgColor: const Color(0xFFFFEBEE),
                      label: 'Duration',
                      value: '$dur min',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Start Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigation start logic here
                    Get.snackbar(
                      'Navigation',
                      'Starting turn-by-turn navigation...',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF1A73E8),
                      colorText: Colors.white,
                      icon: const Icon(Icons.navigation,
                          color: Colors.white),
                    );
                  },
                  icon: const Icon(Icons.navigation_outlined, size: 20),
                  label: const Text(
                    'Start',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Info Chip Widget ──────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: iconColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
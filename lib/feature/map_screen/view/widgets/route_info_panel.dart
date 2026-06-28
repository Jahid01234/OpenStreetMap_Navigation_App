import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';

class RouteInfoPanel extends StatelessWidget {
  final MapConnectionController controller;
  const RouteInfoPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.navState.value;
      if (state == NavState.idle) return const SizedBox.shrink();

      final isLoading = controller.isLoadingRoute.value;
      final isNavigation = controller.isNavigating;

      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        offset: Offset.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2332),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: isLoading
              ? const _LoadingPanel()
              : isNavigation
              ?  _NavigatingPanel(controller: controller)
              :  _RouteReadyPanel(controller: controller),
        ),
      );
    });
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        CircularProgressIndicator(color: Color(0xFF4A9EFF)),
        SizedBox(height: 12),
        Text(
          'Finding best route...',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class _RouteReadyPanel extends StatelessWidget {
  final MapConnectionController controller;
  const _RouteReadyPanel({super.key, required this.controller});

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
                style: const TextStyle(
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
            _InfoChip(
              icon: Icons.straighten,
              label: controller.remainingDistance.value,
              color: const Color(0xFF4A9EFF),
            ),
            const SizedBox(width: 12),
            _InfoChip(
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
                label: const Text(
                  'Start',
                  style: TextStyle(
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

class _NavigatingPanel extends StatelessWidget {
  final MapConnectionController controller;
  const _NavigatingPanel({super.key,required this.controller});

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
                  color: const Color(0xFF4A9EFF).withOpacity(0.2),
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
                  style: const TextStyle(
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
            _InfoChip(
              icon: Icons.straighten,
              label: controller.remainingDistance.value,
              color: const Color(0xFF4A9EFF),
            ),
            const SizedBox(width: 12),
            _InfoChip(
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
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Stop',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
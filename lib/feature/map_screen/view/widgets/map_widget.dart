// lib/widgets/map_widgets.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


// ── Search Bar ────────────────────────────────────────────────────────────────

class SearchBarWidget extends GetWidget<MapConnectionController> {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isNav = controller.isNavigating;
      if (isNav) return const SizedBox.shrink();

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.onSearchChanged,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
              decoration: InputDecoration(
                hintText: 'Search destination...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A9EFF)),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey,
                  onPressed: () {
                    controller.onSearchChanged('');
                    controller.searchResults.clear();
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              ),
            ),
          ),
          // Search Results Dropdown
          if (controller.searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: controller.searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final result = controller.searchResults[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFF4A9EFF),
                      size: 20,
                    ),
                    title: Text(
                      result.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    onTap: () => controller.selectFromSearch(result),
                  );
                },
              ),
            ),
          if (controller.isLoadingSearch.value)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(color: Color(0xFF4A9EFF)),
            ),
        ],
      );
    });
  }
}

// ── Route Info Bottom Sheet ───────────────────────────────────────────────────

class RouteInfoPanel extends GetWidget<MapConnectionController> {
  const RouteInfoPanel({super.key});

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
              ? const _NavigatingPanel()
              : const _RouteReadyPanel(),
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

class _RouteReadyPanel extends GetWidget<MapConnectionController> {
  const _RouteReadyPanel();

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

class _NavigatingPanel extends GetWidget<MapConnectionController> {
  const _NavigatingPanel();

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

// ── Map Layers (Markers & Polyline) ──────────────────────────────────────────

class MapLayersWidget extends GetWidget<MapConnectionController> {
  const MapLayersWidget({super.key});

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
              if (currentPos != null)
                Marker(
                  point: currentPos,
                  width: 60,
                  height: 60,
                  child: _CurrentLocationMarker(
                    heading: controller.userHeading.value,
                  ),
                ),

              // Destination Marker
              if (destPos != null)
                Marker(
                  point: destPos,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_pin,
                    color: Color(0xFFFF4757),
                    size: 40,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
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

// ── FAB Controls ──────────────────────────────────────────────────────────────

class MapControlButtons extends GetWidget<MapConnectionController> {
  const MapControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Recenter / Follow
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

// ── Route Ready Banner ────────────────────────────────────────────────────────

class RouteReadyBanner extends GetWidget<MapConnectionController> {
  const RouteReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.navState.value != NavState.routeReady) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route, color: Color(0xFF4A9EFF), size: 18),
            const SizedBox(width: 8),
            Text(
              'Route ready  •  ${controller.remainingDistance.value}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    });
  }
}
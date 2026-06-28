import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/core/const/app_secret.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_control_buttons.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_layers.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_search_bar.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/route_info_panel.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/route_ready_banner.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final MapConnectionController controller = Get.put(MapConnectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────
          Obx(() {
            final pos = controller.currentPosition.value;
            final defaultCenter = pos ?? AppSecret.initialCenterLatLng;

            return FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: defaultCenter,
                initialZoom: 15.0,
                minZoom: 4,
                maxZoom: 20,
                onTap: (_, point) => controller.onMapTap(point),
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture && controller.isMapFollowing.value) {
                    controller.isMapFollowing.value = false;
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: controller.isSatelliteView.value
                      ? AppSecret.satelliteTileUrl
                      : AppSecret.osmTileUrl,
                  userAgentPackageName: AppSecret.userAgentPackageName,
                  maxZoom: 19,
                ),
                 MapLayersWidget(controller: controller),
              ],
            );
          }),

          // ── Top Bar ────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child:  SearchBarWidget(controller: controller),
                  ),
                  const SizedBox(height: 8),
                   Center(child: RouteReadyBanner(controller: controller)),
                ],
              ),
            ),
          ),

          // ── Right Side Controls ────────────────────────────────────────
          Positioned(
            right: 14,
            bottom: 220,
            child:  MapControlButtons(controller: controller),
          ),

          // ── Bottom Panel ───────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RouteInfoPanel(controller: controller),
          ),

          // ── Loading Overlay ────────────────────────────────────────────
          Obx(() {
            if (!controller.isLoadingRoute.value) return const SizedBox();
            return Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A9EFF)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
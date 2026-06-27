import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_action_buttons.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_layers.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_loading_overlay.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_search_bar.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/route_info_sheet.dart';


class MapScreen extends StatelessWidget {
   MapScreen({super.key});

  final MapConnectionController controller = Get.put(MapConnectionController());

   @override
   Widget build(BuildContext context) {
     return Stack(
       children: [
         // ── Layer 1: Map (base) ─────────────────────────────────────────────
         MapLayers(controller: controller),

         // ── Layer 2: Search bar + dropdown ─────────────────────────────────
         //MapSearchBar(controller: controller),
         // Search Bar
         Positioned(
           top: 0,
           left: 0,
           right: 0,
           child: MapSearchBar(controller: controller),
         ),

         // ── Layer 3: Loading indicator ──────────────────────────────────────
         MapLoadingOverlay(controller: controller),

         // ── Layer 4: Action buttons (satellite/locate) ──────────────────────
         MapActionButtons(controller: controller),

         // ── Layer 5: Route info bottom sheet ───────────────────────────────
         RouteInfoSheet(controller: controller),
       ],
     );
   }
}


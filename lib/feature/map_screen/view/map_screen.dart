import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/map_widget.dart';

class MapScreen extends StatelessWidget {
   MapScreen({super.key});

  final MapConnectionController controller = MapConnectionController();

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: const Color(0xFF1A2332),
       body: Stack(
         children: [
           // ── Map ────────────────────────────────────────────────────────
           Obx(() {
             final pos = controller.currentPosition.value;
             final defaultCenter = pos ?? const LatLng(23.8103, 90.4125);

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
                   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                   userAgentPackageName: 'com.example.open_streetmap_app',
                   maxZoom: 20,
                 ),
                 const MapLayersWidget(),
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
                     child: const SearchBarWidget(),
                   ),
                   const SizedBox(height: 8),
                   const Center(child: RouteReadyBanner()),
                 ],
               ),
             ),
           ),

           // ── Right Side Controls ────────────────────────────────────────
           Positioned(
             right: 14,
             bottom: 220,
             child: const MapControlButtons(),
           ),

           // ── Bottom Panel ───────────────────────────────────────────────
           Positioned(
             bottom: 0,
             left: 0,
             right: 0,
             child: const RouteInfoPanel(),
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


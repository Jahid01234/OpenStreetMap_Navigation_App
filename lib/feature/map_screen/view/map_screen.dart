import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/core/const/app_secret.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


class MapScreen extends StatelessWidget {
   MapScreen({super.key});

  final MapConnectionController controller = Get.put(MapConnectionController());

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Stack(
         children: [
           FlutterMap(
             mapController: controller.mapController,
               options: MapOptions(
                 initialZoom: AppSecret.defaultZoom,
                 initialCenter: AppSecret.initialCenterLatLng
               ),
               children: [
                 TileLayer(
                   maxZoom: 15,
                   urlTemplate: AppSecret.osmTileUrl,
                   userAgentPackageName: AppSecret.userAgentPackageName
                 ),
               ],
           )
         ],
       ),
     );
   }
}


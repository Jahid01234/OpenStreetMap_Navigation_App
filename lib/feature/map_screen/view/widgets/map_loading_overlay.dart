import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


class MapLoadingOverlay extends StatelessWidget {
  final MapConnectionController controller;

  const MapLoadingOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      return Positioned(
        top: 110,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Finding route...',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/loading_panel.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/navigating_panel.dart';
import 'package:open_streetmap_app/feature/map_screen/view/widgets/route_ready_panel.dart';

class RouteInfoPanel extends StatelessWidget {
  final MapConnectionController controller;

  const RouteInfoPanel({
    super.key,
    required this.controller,
  });

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
              ? const LoadingPanel()
              : isNavigation
              ?   NavigatingPanel(controller: controller)
              :   RouteReadyPanel(controller: controller),
        ),
      );
    });
  }
}








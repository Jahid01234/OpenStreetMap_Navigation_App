import 'package:flutter/material.dart';
import 'package:open_streetmap_app/core/global_widget/triangle_painter.dart';

class NavigationMarker extends StatelessWidget {
  final double heading;

  const NavigationMarker({
    super.key,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: heading * (3.1415926535 / 180),
      child: SizedBox(
        width: 46,
        height: 54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main Marker
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            // Triangle
            CustomPaint(
              size: const Size(14, 10),
              painter: TrianglePainter(),
            ),
          ],
        ),
      ),
    );
  }
}


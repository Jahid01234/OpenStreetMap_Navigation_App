import 'package:flutter/material.dart';

class CurrentLocationMarker extends StatelessWidget {
  final double heading;

  const CurrentLocationMarker({
    super.key,
    required this.heading,
  });

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
              color: const Color(0xFF4A9EFF).withValues(alpha: 0.2),
              border: Border.all(
                color: const Color(0xFF4A9EFF).withValues(alpha: 0.5),
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
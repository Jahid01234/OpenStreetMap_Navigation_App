import 'package:flutter/material.dart';
import 'package:open_streetmap_app/core/style/global_text_style.dart';

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const CircularProgressIndicator(color: Color(0xFF4A9EFF)),
        const SizedBox(height: 12),
        Text(
          'Finding best route...',
          style: globalTextStyle(
              color: Colors.white70,
              fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
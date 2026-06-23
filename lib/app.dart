import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/view/map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OSM Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A9EFF),
          secondary: Color(0xFFFF6B35),
          surface: Color(0xFF1A2332),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A2332),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2332),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: MapScreen(),
    );
  }
}
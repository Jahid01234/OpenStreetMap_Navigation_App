import 'package:flutter/material.dart';
import 'package:open_streetmap_app/app.dart';
import 'package:open_streetmap_app/core/const/app_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFonts.loadGoogleFonts();
  runApp(const MyApp());
}




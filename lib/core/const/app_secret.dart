import 'package:latlong2/latlong.dart';

class AppSecret{
  // OSRM routing api.........
  static const String osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving/';

  // Nominatim search api.........
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  // Default map tile URL(OpenStreetMap).........
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Satellite tile.........
  static const String satelliteTileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  // Animation durations................
  static const Duration markerAnimDuration = Duration(microseconds: 50);
  static const Duration cameraAnimDuration = Duration(microseconds: 600);
  static const Duration routerDrawDuration = Duration(microseconds: 1200);

  // Marker animation total steps................
  static const int markerAnimSteps = 200;

  // OpenStreetMap zoom................
  static const double defaultZoom = 15.0;
  static const double routeZoom = 13.0;

  // Initial center LatLong................
  static const LatLng initialCenterLatLng = LatLng(20.0000, 30.9999);

  // My package name ................
  static const String userAgentPackageName = "com.example.open_streetmap_app";


}
import 'package:latlong2/latlong.dart';

class RouteModel {
  final List<LatLng> polylinePoints;
  final double distanceKm;
  final int durationMinutes;
  final LatLng origin;
  final LatLng destination;

  RouteModel({
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
    required this.origin,
    required this.destination,
  });

  factory RouteModel.empty() => RouteModel(
    polylinePoints: [],
    distanceKm: 0,
    durationMinutes: 0,
    origin: const LatLng(0, 0),
    destination: const LatLng(0, 0),
  );
}
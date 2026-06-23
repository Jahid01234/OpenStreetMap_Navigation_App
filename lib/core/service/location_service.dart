// lib/services/location_service.dart
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationService {
  // ── Location Permission & Stream ──────────────────────────────────────────

  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Stream<Position> getLiveLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    );
  }

  // ── OSRM Routing API ──────────────────────────────────────────────────────

  static Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&steps=true&annotations=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          return RouteResult.fromJson(data['routes'][0]);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Route fetch error: $e');
    }
    return null;
  }

  // ── Geocoding (Nominatim) ─────────────────────────────────────────────────

  static Future<String> reverseGeocode(LatLng point) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${point.latitude}&lon=${point.longitude}&format=json';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterOSMNav/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown Location';
      }
    } catch (_) {}
    return 'Unknown Location';
  }

  static Future<List<SearchResult>> searchPlace(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterOSMNav/1.0'},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => SearchResult.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<RouteStep> steps;

  RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
  });

  String get distanceText {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toInt()} m';
  }

  String get durationText {
    final mins = (durationSeconds / 60).ceil();
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '$h hr $m min' : '$h hr';
    }
    return '$mins min';
  }

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    // Parse geometry coordinates
    final coords =
    (json['geometry']['coordinates'] as List)
        .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
        .toList();

    // Parse steps
    final legs = json['legs'] as List;
    final steps = <RouteStep>[];
    for (final leg in legs) {
      for (final step in (leg['steps'] as List)) {
        steps.add(RouteStep.fromJson(step));
      }
    }

    return RouteResult(
      points: coords,
      distanceMeters: (json['distance'] as num).toDouble(),
      durationSeconds: (json['duration'] as num).toDouble(),
      steps: steps,
    );
  }
}

class RouteStep {
  final String instruction;
  final double distanceMeters;
  final String maneuverType;

  RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.maneuverType,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>;
    final name = json['name'] as String? ?? '';
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';

    String instruction = _buildInstruction(type, modifier, name);

    return RouteStep(
      instruction: instruction,
      distanceMeters: (json['distance'] as num).toDouble(),
      maneuverType: type,
    );
  }

  static String _buildInstruction(
      String type,
      String modifier,
      String name,
      ) {
    final dest = name.isEmpty ? '' : ' onto $name';
    switch (type) {
      case 'depart':
        return 'Start${dest.isEmpty ? '' : dest}';
      case 'arrive':
        return 'Arrive at destination';
      case 'turn':
        return 'Turn ${modifier.isNotEmpty ? modifier : 'right'}$dest';
      case 'merge':
        return 'Merge$dest';
      case 'roundabout':
        return 'Enter roundabout$dest';
      case 'exit roundabout':
        return 'Exit roundabout$dest';
      case 'fork':
        return 'Keep ${modifier.isNotEmpty ? modifier : 'straight'}$dest';
      case 'continue':
        return 'Continue$dest';
      default:
        return name.isNotEmpty ? 'Head towards $name' : 'Continue';
    }
  }
}

class SearchResult {
  final String displayName;
  final LatLng location;

  SearchResult({required this.displayName, required this.location});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'] as String,
      location: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
    );
  }
}
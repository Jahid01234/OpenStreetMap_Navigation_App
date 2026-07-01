import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:open_streetmap_app/core/const/app_secret.dart';
import 'package:open_streetmap_app/feature/map_screen/model/route_model.dart';
import 'package:open_streetmap_app/feature/map_screen/model/search_result_model.dart';

class LocationService {

  //Location Permission & Stream................................................
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // static Future<Position?> getCurrentPosition() async {
  //   final hasPermission = await requestPermission();
  //   if (!hasPermission) return null;
  //   return await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  // }
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      // Location service (GPS) on ache kina check
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('getCurrentPosition error: $e');
      return null;
    }
  }

  static Stream<Position> getLiveLocationStream(){
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  // OSRM Routing API...........................................................
  static Future<RouteResultModel?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        '${AppSecret.osrmBaseUrl}'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&steps=true&annotations=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          return RouteResultModel.fromJson(data['routes'][0]);
        }
      }
    } catch (e) {
      debugPrint('Route fetch error: $e');
    }
    return null;
  }

  // Geocoding (Nominatim)......................................................
  static Future<String> reverseGeocode(LatLng point) async {
    final url =
        '${AppSecret.nominatimBaseUrl}/reverse'
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
    } catch (e) {
      debugPrint('Reverse Geocode fetch error: $e');
    }
    return 'Unknown Location';
  }

  // search nominatim api.......................................................
  static Future<List<SearchResultModel>> searchPlace(String query) async {
    final url =
        '${AppSecret.nominatimBaseUrl}/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterOSMNav/1.0'},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => SearchResultModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Search fetch error: $e');
    }
    return [];
  }
}




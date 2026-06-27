import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:open_streetmap_app/core/const/app_secret.dart';
import 'package:open_streetmap_app/feature/map_screen/model/route_model.dart';
import 'package:open_streetmap_app/feature/map_screen/model/search_result_model.dart';

class MapConnectionController extends GetxController{
  final MapController mapController = MapController();
  final searchController = TextEditingController();

  // ── Observables ─────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isRouteReady = false.obs;
  final isSatelliteView = false.obs;

  final searchResults = <SearchResultModel>[].obs;
  final Rx<RouteModel> route = RouteModel.empty().obs;

  final Rxn<LatLng> originLatLng = Rxn<LatLng>();
  final Rxn<LatLng> destinationLatLng = Rxn<LatLng>();

  // ── Search ──────────────────────────────────────────────────────────────────
  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      isLoading(true);
      final uri = Uri.parse(
        '${AppSecret.nominatimBaseUrl}/search'
            '?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      ).replace();
      final response = await http.get(uri, headers: {
        'User-Agent': AppSecret.userAgentPackageName,
      });
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        searchResults.value =
            data.map((e) => SearchResultModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Select destination from search ─────────────────────────────────────────
  Future<void> selectDestination(SearchResultModel result) async {
    searchController.text = result.displayName;
    searchResults.clear();

    // Use current map center as origin if not set
    originLatLng.value ??= AppSecret.initialCenterLatLng;
    destinationLatLng.value = result.latLng;

    await fetchRoute(
      origin: originLatLng.value!,
      destination: destinationLatLng.value!,
    );
  }

  // ── Tap on map to set destination ──────────────────────────────────────────
  Future<void> onMapTap(TapPosition _, LatLng tapped) async {
    if (originLatLng.value == null) {
      originLatLng.value = tapped;
    } else {
      destinationLatLng.value = tapped;
      await fetchRoute(
        origin: originLatLng.value!,
        destination: tapped,
      );
    }
  }

  // ── OSRM Route Fetch ────────────────────────────────────────────────────────
  Future<void> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      isLoading(true);
      isRouteReady(false);

      final url =
          '${AppSecret.osrmBaseUrl}${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final distanceM = data['routes'][0]['distance'] as num;
        final durationS = data['routes'][0]['duration'] as num;

        final points =
        coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();

        route.value = RouteModel(
          polylinePoints: points,
          distanceKm: distanceM / 1000,
          durationMinutes: (durationS / 60).ceil(),
          origin: origin,
          destination: destination,
        );

        isRouteReady(true);
        _fitMapToBounds(points);
      }
    } catch (e) {
      debugPrint('Route fetch error: $e');
      Get.snackbar('Error', 'Could not fetch route. Try again.',
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }

  // ── Fit map to show full route ──────────────────────────────────────────────
  void _fitMapToBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  // ── Toggle satellite/street view ───────────────────────────────────────────
  void toggleMapStyle() => isSatelliteView.toggle();

  // ── Clear route ────────────────────────────────────────────────────────────
  void clearRoute() {
    originLatLng.value = null;
    destinationLatLng.value = null;
    route.value = RouteModel.empty();
    isRouteReady(false);
    searchController.clear();
    searchResults.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

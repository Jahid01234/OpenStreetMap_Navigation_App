import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_streetmap_app/core/service/location_service.dart';
import 'package:open_streetmap_app/feature/map_screen/model/route_model.dart';
import 'package:open_streetmap_app/feature/map_screen/model/route_step_model.dart';
import 'package:open_streetmap_app/feature/map_screen/model/search_result_model.dart';


enum NavState { idle, searching, routeReady, navigating }

class MapConnectionController extends GetxController {
  final MapController mapController = MapController();
  final navState = NavState.idle.obs;
  final currentPosition = Rxn<LatLng>();
  final destinationPoint = Rxn<LatLng>();
  final routeResult = Rxn<RouteResultModel>();
  final currentAddress = ''.obs;
  final destinationAddress = ''.obs;
  final searchQuery = ''.obs;
  final searchResults = <SearchResultModel>[].obs;
  final isLoadingRoute = false.obs;
  final isLoadingSearch = false.obs;
  final currentStepIndex = 0.obs;
  final remainingDistance = ''.obs;
  final remainingDuration = ''.obs;
  final userHeading = 0.0.obs;
  final isMapFollowing = true.obs;
  final isSatelliteView = false.obs;
  StreamSubscription<Position>? _locationSub;
  Timer? _searchDebounce;
  Timer? _navSimulationTimer;
  int _routePointIndex = 0;
  final Distance _distCalc = const Distance();



  @override
  void onInit() {
    super.onInit();
    _initLocation();
  }

  @override
  void onClose() {
    _locationSub?.cancel();
    _searchDebounce?.cancel();
    _navSimulationTimer?.cancel();
    super.onClose();
  }

  // ── Location Init ─────────────────────────────────────────────────────────
  Future<void> _initLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      _updatePosition(LatLng(pos.latitude, pos.longitude));
    }
    _startLiveTracking();
  }

  void _startLiveTracking() {
    _locationSub = LocationService.getLiveLocationStream().listen((pos) {
      final newPos = LatLng(pos.latitude, pos.longitude);
      userHeading.value = pos.heading;
      _updatePosition(newPos);

      if (navState.value == NavState.navigating) {
        _updateNavigationProgress(newPos);
      }
    });
  }

  void _updatePosition(LatLng pos) {
    currentPosition.value = pos;

    if (isMapFollowing.value && navState.value != NavState.idle) {
      mapController.move(pos, mapController.camera.zoom);
    }

    // Fetch address in background
    LocationService.reverseGeocode(pos).then((addr) {
      currentAddress.value = addr;
    });
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    if (query.trim().length < 3) {
      searchResults.clear();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 600), () async {
      isLoadingSearch.value = true;
      final results = await LocationService.searchPlace(query);
      searchResults.assignAll(results);
      isLoadingSearch.value = false;
    });
  }

  // ── Destination Selection ─────────────────────────────────────────────────
  Future<void> selectDestination(LatLng point, {String? address}) async {
    destinationPoint.value = point;
    searchResults.clear();
    navState.value = NavState.searching;

    // Reverse geocode if no address provided
    if (address != null) {
      destinationAddress.value = address;
    } else {
      LocationService.reverseGeocode(point).then((addr) {
        destinationAddress.value = addr;
      });
    }

    await _fetchRoute();
  }

  Future<void> selectFromSearch(SearchResultModel result) async {
    await selectDestination(
      result.location,
      address: result.displayName,
    );
  }

  Future<void> onMapTap(LatLng point) async {
    if (navState.value == NavState.navigating) return;
    await selectDestination(point);
  }

  // ── Route Fetch ───────────────────────────────────────────────────────────
  Future<void> _fetchRoute() async {
    final origin = currentPosition.value;
    final dest = destinationPoint.value;
    if (origin == null || dest == null) return;

    isLoadingRoute.value = true;
    final result = await LocationService.getRoute(
      origin: origin,
      destination: dest,
    );
    isLoadingRoute.value = false;

    if (result != null) {
      routeResult.value = result;
      remainingDistance.value = result.distanceText;
      remainingDuration.value = result.durationText;
      navState.value = NavState.routeReady;
      _fitRouteOnMap(result.points);
    } else {
      Get.snackbar(
        'Error',
        'Could not find a route. Check your connection.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      navState.value = NavState.idle;
    }
  }

  void _fitRouteOnMap(List<LatLng> points) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(40, 80, 40, 200),
      ),
    );
  }

  //── Navigation ────────────────────────────────────────────────────────────
  void startNavigation() {
    navState.value = NavState.navigating;

    currentStepIndex.value = 0;

    isMapFollowing.value = true;

    if (currentPosition.value != null) {
      mapController.move(currentPosition.value!, 17.0);
    }

    _startSimulation();
  }

  void _startSimulation() {
    final route = routeResult.value;

    if (route == null || route.points.isEmpty) return;

    _routePointIndex = 0;

    _navSimulationTimer?.cancel();

    _navSimulationTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {

          if (_routePointIndex >= route.points.length) {
            timer.cancel();
            _onArrived();
            return;
          }

          final point = route.points[_routePointIndex];

          currentPosition.value = point;

          if (isMapFollowing.value) {
            mapController.move(point, 17);
          }

          _updateNavigationProgress(point);

          _routePointIndex++;
        });
  }

  void _updateNavigationProgress(LatLng pos) {
    final route = routeResult.value;

    if (route == null) return;

    final dest = destinationPoint.value;

    if (dest == null) return;

    final distToDest = _distCalc(pos, dest);

    // Remaining Distance
    if (distToDest < 1000) {
      remainingDistance.value =
      '${distToDest.toInt()} m';
    } else {
      remainingDistance.value =
      '${(distToDest / 1000).toStringAsFixed(1)} km';
    }

    // Remaining ETA
    const speedKmH = 40.0;

    final remainingMinutes =
        ((distToDest / 1000) / speedKmH) * 60;

    remainingDuration.value =
    '${remainingMinutes.ceil()} min';

    // Step Progress
    if (route.steps.isNotEmpty) {
      final progress =
          _routePointIndex / route.points.length;

      final step =
      (progress * route.steps.length).floor();

      currentStepIndex.value =
          step.clamp(0, route.steps.length - 1);
    }

    // Arrived
    if (distToDest < 30) {
      _onArrived();
    }
  }


  void _onArrived() {
    navState.value = NavState.idle;
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🎉 Arrived!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have reached ${destinationAddress.value}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              clearRoute();
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFF4A9EFF)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Controls ──────────────────────────────────────────────────────────────
  void stopNavigation() {
    _navSimulationTimer?.cancel();

    navState.value = NavState.routeReady;

    isMapFollowing.value = false;
  }

  void clearRoute() {
    navState.value = NavState.idle;
    destinationPoint.value = null;
    routeResult.value = null;
    destinationAddress.value = '';
    searchQuery.value = '';
    currentStepIndex.value = 0;
    isMapFollowing.value = true;
    _navSimulationTimer?.cancel();

    if (currentPosition.value != null) {
      mapController.move(currentPosition.value!, 15.0);
    }
  }

  void toggleMapFollow() {
    isMapFollowing.value = !isMapFollowing.value;
    if (isMapFollowing.value && currentPosition.value != null) {
      mapController.move(currentPosition.value!, mapController.camera.zoom);
    }
  }

  // ── Toggle satellite/street view ───────────────────────────────────────────
  void toggleMapStyle() => isSatelliteView.toggle();

  void recenterMap() {
    if (currentPosition.value != null) {
      isMapFollowing.value = true;
      mapController.move(currentPosition.value!, 16.0);
    }
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  RouteStepModel? get currentStep {
    final route = routeResult.value;
    if (route == null) return null;
    final idx = currentStepIndex.value;
    if (idx < route.steps.length) return route.steps[idx];
    return null;
  }

  bool get isNavigating => navState.value == NavState.navigating;
  bool get hasRoute => routeResult.value != null;
}

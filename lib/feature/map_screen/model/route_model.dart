import 'package:latlong2/latlong.dart';
import 'package:open_streetmap_app/feature/map_screen/model/route_step_model.dart';

class RouteResultModel {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<RouteStepModel> steps;

  RouteResultModel({
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

  factory RouteResultModel.fromJson(Map<String, dynamic> json) {
    // Parse geometry coordinates
    final coords =
    (json['geometry']['coordinates'] as List)
        .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
        .toList();

    // Parse steps
    final legs = json['legs'] as List;
    final steps = <RouteStepModel>[];
    for (final leg in legs) {
      for (final step in (leg['steps'] as List)) {
        steps.add(RouteStepModel.fromJson(step));
      }
    }

    return RouteResultModel(
      points: coords,
      distanceMeters: (json['distance'] as num).toDouble(),
      durationSeconds: (json['duration'] as num).toDouble(),
      steps: steps,
    );
  }
}


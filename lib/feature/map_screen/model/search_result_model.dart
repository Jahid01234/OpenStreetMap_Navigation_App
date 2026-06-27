import 'package:latlong2/latlong.dart';

class SearchResultModel {
  final String displayName;
  final LatLng latLng;

  SearchResultModel({
    required this.displayName,
    required this.latLng,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      displayName: json['display_name'] ?? '',
      latLng: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
    );
  }
}
import 'package:latlong2/latlong.dart';

class SearchResultModel {
  final String displayName;
  final LatLng location;

  SearchResultModel({required this.displayName, required this.location});

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      displayName: json['display_name'] as String,
      location: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
    );
  }
}
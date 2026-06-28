class RouteStepModel {
  final String instruction;
  final double distanceMeters;
  final String maneuverType;

  RouteStepModel({
    required this.instruction,
    required this.distanceMeters,
    required this.maneuverType,
  });

  factory RouteStepModel.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>;
    final name = json['name'] as String? ?? '';
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';

    String instruction = _buildInstruction(type, modifier, name);

    return RouteStepModel(
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


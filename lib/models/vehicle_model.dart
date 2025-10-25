/// Represents a vehicle in the system
class VehicleModel {
  final String make; // e.g., "Toyota", "Audi"
  final String model; // e.g., "Land Cruiser", "A8"
  final int? year;
  final String? plateNumber;

  VehicleModel({
    required this.make,
    required this.model,
    this.year,
    this.plateNumber,
  });

  // Convert map to VehicleModel
  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'],
      plateNumber: map['plateNumber'],
    );
  }

  // Convert VehicleModel to map
  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'plateNumber': plateNumber,
    };
  }

  // Display name for the vehicle
  String get displayName {
    final yearStr = year != null ? ' $year' : '';
    return '$make $model$yearStr';
  }
}


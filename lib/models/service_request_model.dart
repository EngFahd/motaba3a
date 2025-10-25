import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle_model.dart';

/// Status of a service request
enum ServiceStatus {
  pending, // Waiting to start
  inProgress, // Being worked on
  completed, // Finished
  cancelled, // Cancelled
}

/// Represents a service/repair request for a vehicle
class ServiceRequestModel {
  final String id;
  final String workshopId; // Workshop owner's UID
  final String clientId; // Client's UID
  final String clientName;
  final String clientPhone;
  final VehicleModel vehicle;
  final List<String> serviceTypes; // e.g., ["Oil Change", "Tire Replacement"]
  final double price;
  final DateTime entryDate; // When vehicle arrived
  final DateTime? exitDate; // Expected or actual exit date
  final ServiceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRequestModel({
    required this.id,
    required this.workshopId,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.vehicle,
    required this.serviceTypes,
    required this.price,
    required this.entryDate,
    this.exitDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Firestore document to ServiceRequestModel
  factory ServiceRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceRequestModel(
      id: id,
      workshopId: map['workshopId'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      vehicle: VehicleModel.fromMap(map['vehicle'] ?? {}),
      serviceTypes: List<String>.from(map['serviceTypes'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      entryDate: (map['entryDate'] as Timestamp).toDate(),
      exitDate: map['exitDate'] != null
          ? (map['exitDate'] as Timestamp).toDate()
          : null,
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString() == 'ServiceStatus.${map['status']}',
        orElse: () => ServiceStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert ServiceRequestModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'workshopId': workshopId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'vehicle': vehicle.toMap(),
      'serviceTypes': serviceTypes,
      'price': price,
      'entryDate': Timestamp.fromDate(entryDate),
      'exitDate': exitDate != null ? Timestamp.fromDate(exitDate!) : null,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate days remaining until exit
  int? get daysRemaining {
    if (exitDate == null) return null;
    final now = DateTime.now();
    return exitDate!.difference(now).inDays;
  }

  // Create a copy with updated fields
  ServiceRequestModel copyWith({
    String? clientName,
    String? clientPhone,
    VehicleModel? vehicle,
    List<String>? serviceTypes,
    double? price,
    DateTime? entryDate,
    DateTime? exitDate,
    ServiceStatus? status,
    DateTime? updatedAt,
  }) {
    return ServiceRequestModel(
      id: id,
      workshopId: workshopId,
      clientId: clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      vehicle: vehicle ?? this.vehicle,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      price: price ?? this.price,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


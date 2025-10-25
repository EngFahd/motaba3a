import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_request_model.dart';

/// Repository for service request operations
/// Handles all Firestore operations related to service requests
class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'service_requests';

  /// Create a new service request
  Future<String> createServiceRequest(ServiceRequestModel request) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(request.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service request: $e');
    }
  }

  /// Get all service requests for a workshop
  Stream<List<ServiceRequestModel>> getWorkshopRequests(String workshopId) {
    return _firestore
        .collection(_collection)
        .where('workshopId', isEqualTo: workshopId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get service requests by status for a workshop
  Stream<List<ServiceRequestModel>> getWorkshopRequestsByStatus(
    String workshopId,
    ServiceStatus status,
  ) {
    return _firestore
        .collection(_collection)
        .where('workshopId', isEqualTo: workshopId)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get requests for last N days for a workshop
  Stream<List<ServiceRequestModel>> getRecentWorkshopRequests(
    String workshopId,
    int days,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return _firestore
        .collection(_collection)
        .where('workshopId', isEqualTo: workshopId)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Update service request
  Future<void> updateServiceRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Always update the updatedAt timestamp
      updates['updatedAt'] = Timestamp.now();

      await _firestore.collection(_collection).doc(requestId).update(updates);
    } catch (e) {
      throw Exception('Failed to update service request: $e');
    }
  }

  /// Delete service request
  Future<void> deleteServiceRequest(String requestId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete service request: $e');
    }
  }

  /// Search clients by phone number
  Future<List<ServiceRequestModel>> searchClientsByPhone(
    String workshopId,
    String phoneNumber,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('workshopId', isEqualTo: workshopId)
          .where('clientPhone', isEqualTo: phoneNumber)
          .get();

      return snapshot.docs
          .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search clients: $e');
    }
  }

  /// Get single service request by ID
  Future<ServiceRequestModel?> getServiceRequest(String requestId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(requestId).get();
      if (doc.exists) {
        return ServiceRequestModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service request: $e');
    }
  }
}


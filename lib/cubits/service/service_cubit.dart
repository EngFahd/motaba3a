import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/service_request_model.dart';
import '../../repositories/service_repository.dart';
import 'service_state.dart';

/// Cubit for managing service request state and operations
/// Replaces ServiceViewModel with BLoC pattern
class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository _serviceRepository;
  StreamSubscription<List<ServiceRequestModel>>? _requestsSubscription;

  ServiceCubit(this._serviceRepository) : super(const ServiceInitial());

  /// Load service requests for a workshop
  void loadWorkshopRequests(
    String workshopId, [
    ServiceFilter filter = ServiceFilter.all,
  ]) {
    // Cancel previous subscription to avoid memory leaks
    _requestsSubscription?.cancel();

    emit(const ServiceLoading());

    // Get appropriate stream based on filter
    Stream<List<ServiceRequestModel>> stream;

    switch (filter) {
      case ServiceFilter.recent90Days:
        stream = _serviceRepository.getRecentWorkshopRequests(workshopId, 90);
        break;
      case ServiceFilter.current:
        stream = _serviceRepository.getWorkshopRequestsByStatus(
          workshopId,
          ServiceStatus.inProgress,
        );
        break;
      case ServiceFilter.all:
        stream = _serviceRepository.getWorkshopRequests(workshopId);
        break;
    }

    // Subscribe to real-time updates
    _requestsSubscription = stream.listen(
      (requests) {
        emit(ServiceLoaded(requests: requests, currentFilter: filter));
      },
      onError: (error) {
        emit(ServiceError('فشل تحميل الطلبات: $error'));
      },
    );
  }

  /// Change filter and reload data
  void setFilter(ServiceFilter filter, String workshopId) {
    loadWorkshopRequests(workshopId, filter);
  }

  /// Create new service request
  Future<void> createServiceRequest(ServiceRequestModel request) async {
    try {
      await _serviceRepository.createServiceRequest(request);
      emit(const ServiceOperationSuccess('تم إنشاء الطلب بنجاح'));
    } catch (e) {
      emit(ServiceError('فشل إنشاء الطلب: $e'));
    }
  }

  /// Update service request status
  Future<void> updateRequestStatus(
    String requestId,
    ServiceStatus status,
  ) async {
    try {
      await _serviceRepository.updateServiceRequest(requestId, {
        'status': status.toString().split('.').last,
      });
      emit(const ServiceOperationSuccess('تم تحديث الحالة'));
    } catch (e) {
      emit(ServiceError('فشل تحديث الحالة: $e'));
    }
  }

  /// Update service request details
  Future<void> updateRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _serviceRepository.updateServiceRequest(requestId, updates);
      emit(const ServiceOperationSuccess('تم التحديث بنجاح'));
    } catch (e) {
      emit(ServiceError('فشل التحديث: $e'));
    }
  }

  /// Delete service request
  Future<void> deleteRequest(String requestId) async {
    try {
      await _serviceRepository.deleteServiceRequest(requestId);
      emit(const ServiceOperationSuccess('تم الحذف بنجاح'));
    } catch (e) {
      emit(ServiceError('فشل الحذف: $e'));
    }
  }

  /// Search clients by phone number
  Future<List<ServiceRequestModel>> searchClients(
    String workshopId,
    String phoneNumber,
  ) async {
    try {
      return await _serviceRepository.searchClientsByPhone(
        workshopId,
        phoneNumber,
      );
    } catch (e) {
      emit(ServiceError('فشل البحث: $e'));
      return [];
    }
  }

  /// Clear error state
  void clearError() {
    if (state is ServiceLoaded) {
      // Keep current data
      return;
    }
    emit(const ServiceInitial());
  }

  @override
  Future<void> close() {
    // Cancel subscription when cubit is closed
    _requestsSubscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import '../../models/service_request_model.dart';

/// Filter options for service requests
enum ServiceFilter { all, recent90Days, current }

/// Base class for service states
abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

/// Loading state
class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

/// Loaded state with service requests
class ServiceLoaded extends ServiceState {
  final List<ServiceRequestModel> requests;
  final ServiceFilter currentFilter;

  const ServiceLoaded({
    required this.requests,
    this.currentFilter = ServiceFilter.all,
  });

  @override
  List<Object?> get props => [requests, currentFilter];

  /// Create a copy with updated values
  ServiceLoaded copyWith({
    List<ServiceRequestModel>? requests,
    ServiceFilter? currentFilter,
  }) {
    return ServiceLoaded(
      requests: requests ?? this.requests,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

/// Error state
class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Operation success state (create, update, delete)
class ServiceOperationSuccess extends ServiceState {
  final String message;

  const ServiceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


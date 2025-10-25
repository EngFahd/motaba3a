import 'package:flutter/material.dart';
import '../models/service_request_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

/// Card widget to display a service request
/// Used in the home screen list
class ServiceCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        request.vehicle.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.serviceTypes.join('، '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (request.daysRemaining != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${request.daysRemaining} أيام متبقي للتسليم',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildVehicleIcon(),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM').format(request.entryDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (request.vehicle.year != null)
                  Text(
                    '${request.vehicle.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build vehicle icon based on make
  Widget _buildVehicleIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _getVehicleColor(),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Icon(
        Icons.directions_car,
        size: 40,
        color: _getVehicleIconColor(),
      ),
    );
  }

  /// Get color based on vehicle type or status
  Color _getVehicleColor() {
    switch (request.status) {
      case ServiceStatus.inProgress:
        return Colors.blue.shade100;
      case ServiceStatus.completed:
        return Colors.green.shade100;
      case ServiceStatus.cancelled:
        return Colors.grey.shade200;
      default:
        return Colors.red.shade100;
    }
  }

  Color _getVehicleIconColor() {
    switch (request.status) {
      case ServiceStatus.inProgress:
        return Colors.blue;
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  /// Build status badge
  Widget _buildStatusBadge() {
    String statusText;
    Color statusColor;

    switch (request.status) {
      case ServiceStatus.inProgress:
        statusText = 'قيد العمل';
        statusColor = Colors.blue;
        break;
      case ServiceStatus.completed:
        statusText = 'مكتمل';
        statusColor = Colors.green;
        break;
      case ServiceStatus.cancelled:
        statusText = 'ملغي';
        statusColor = Colors.grey;
        break;
      default:
        statusText = 'غير متكمل';
        statusColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.info_outline, size: 16, color: statusColor),
        ],
      ),
    );
  }
}

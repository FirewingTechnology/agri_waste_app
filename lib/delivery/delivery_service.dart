import '../core/constants/app_constants.dart';

// Create function to calculate delivery charges based on distance
// Charge per km configurable

class DeliveryService {
  /// Calculate delivery charge based on distance in kilometers
  /// Returns delivery charge in rupees
  static double calculateDeliveryCharge(double distanceInKm) {
    if (distanceInKm <= 0) {
      return 0;
    }

    // Check if distance exceeds maximum allowed
    if (distanceInKm > AppConstants.maxDeliveryDistance) {
      throw Exception(
        'Delivery not available for distances over ${AppConstants.maxDeliveryDistance} km',
      );
    }

    // Calculate charge based on distance
    double charge = distanceInKm * AppConstants.deliveryChargePerKm;

    // Apply minimum delivery charge
    if (charge < AppConstants.minDeliveryCharge) {
      charge = AppConstants.minDeliveryCharge;
    }

    return double.parse(charge.toStringAsFixed(2));
  }

  /// Estimate delivery time based on distance
  /// Returns estimated time in hours
  static double estimateDeliveryTime(double distanceInKm) {
    // Average speed: 40 km/hr
    const avgSpeed = 40.0;
    return double.parse((distanceInKm / avgSpeed).toStringAsFixed(1));
  }

  /// Calculate total order amount including delivery
  static Map<String, double> calculateOrderTotal({
    required double quantity,
    required double pricePerKg,
    required double distanceInKm,
  }) {
    final itemTotal = quantity * pricePerKg;
    final deliveryCharge = calculateDeliveryCharge(distanceInKm);
    final grandTotal = itemTotal + deliveryCharge;

    return {
      'itemTotal': double.parse(itemTotal.toStringAsFixed(2)),
      'deliveryCharge': deliveryCharge,
      'grandTotal': double.parse(grandTotal.toStringAsFixed(2)),
    };
  }

  /// Check if delivery is available for given distance
  static bool isDeliveryAvailable(double distanceInKm) {
    return distanceInKm > 0 && distanceInKm <= AppConstants.maxDeliveryDistance;
  }

  /// Get delivery charge breakdown as formatted string
  static String getDeliveryChargeBreakdown(double distanceInKm) {
    if (!isDeliveryAvailable(distanceInKm)) {
      return 'Delivery not available';
    }

    final charge = calculateDeliveryCharge(distanceInKm);
    final time = estimateDeliveryTime(distanceInKm);

    return '''
Distance: ${distanceInKm.toStringAsFixed(1)} km
Charge: ₹$charge
Estimated Time: ${time.toStringAsFixed(1)} hours
Rate: ₹${AppConstants.deliveryChargePerKm}/km
''';
  }
}

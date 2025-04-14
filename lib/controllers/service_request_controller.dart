import '../services/service_request_service.dart';
import '../models/service_request_commodities_model.dart';

class ServiceRequestController {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();

  Future<void> confirmOrder({
    required String userId,
    required String driverId, // String received from UI or other source
    required List<ServiceRequestCommodityModel> commodities,
    required double distance,
  }) async {
    // 🛠 Convert driverId to int
    int? driverIdInt = int.tryParse(driverId);

    if (driverIdInt == null) {
      print("❌ Error: Invalid driver ID format. It should be an integer.");
      return;
    }

    // 🔍 Debugging: Print all values before making the request
    print("🛒 Confirming Order with:");
    print("👤 User ID: $userId");
    print("🚖 Driver ID: $driverIdInt"); // Updated to use int
    print("📏 Distance: $distance km");
    print("📦 Commodities (${commodities.length} items):");

    for (var commodity in commodities) {
      print("  - Commodity ID: ${commodity.commodityId}");
      print("    Quantity: ${commodity.quantity}");
      print("    Weight: ${commodity.weight ?? 'N/A'}");
    }

    // 🚨 Ensure all required data is available
    if (userId.isEmpty || commodities.isEmpty || distance <= 0) {
      print("❌ Error: Invalid input data. Order cannot be confirmed.");
      return;
    }

    // 🔥 Call the service to create order
    bool isSuccess = await _serviceRequestService.createServiceRequest(
      userId: userId,
      driverId: driverIdInt, // Pass as int ✅ FIXED
      status: 'pending',
      commodities: commodities,
      distance: distance,
    );

    // ✅ Success or ❌ Failure
    if (isSuccess) {
      print("✅ Order confirmed and data stored successfully.");
    } else {
      print("❌ Failed to confirm order.");
    }
  }
}

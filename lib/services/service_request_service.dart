import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_request_commodities_model.dart';

class ServiceRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> createServiceRequest({
    required String userId,
    required int driverId,
    required String status,
    required List<ServiceRequestCommodityModel> commodities,
    required double distance,
  }) async {
    try {
      // 1️⃣ Debugging: Log data before inserting `service_requests`
      Map<String, dynamic> serviceRequestData = {
        'user_id': userId,
        'driver_id': driverId,
        'status': status,
        'price': 0,
      };
      print("\n🔍 Inserting into `service_requests`:");
      serviceRequestData.forEach(
          (key, value) => print("  🔹 $key (${value.runtimeType}): $value"));

      // Insert into `service_requests`
      final serviceRequestResponse = await _supabase
          .from('service_requests')
          .insert(serviceRequestData)
          .select()
          .maybeSingle();

      if (serviceRequestResponse == null ||
          serviceRequestResponse['id'] == null) {
        print("❌ Failed to insert service request.");
        return false;
      }

      final int? serviceRequestId = serviceRequestResponse['id'] as int?;
      if (serviceRequestId == null) {
        print("❌ Service request ID is null.");
        return false;
      }

      // 2️⃣ Debugging: Insert commodities into `service_request_commodities`
      int totalPrice = 0;
      List<Map<String, dynamic>> commodityData = [];

      for (var commodity in commodities) {
        final commodityDataResponse = await _supabase
            .from('commodity')
            .select('price_per_kg')
            .eq('id', commodity.commodityId)
            .maybeSingle();

        if (commodityDataResponse == null ||
            commodityDataResponse['price_per_kg'] == null) {
          print(
              "❌ Commodity ${commodity.commodityId} not found or missing price_per_kg.");
          return false;
        }

        double pricePerKg =
            (commodityDataResponse['price_per_kg'] as num?)?.toDouble() ?? 0.0;
        int commodityPrice = ((commodity.weight ?? 0.0) * pricePerKg).round();
        totalPrice += commodityPrice;

        print(
            "📦 Commodity ID: ${commodity.commodityId}, 💰 Price Per Kg: $pricePerKg, 🏋️‍♂️ Weight: ${commodity.weight}, 💵 Total: $commodityPrice");

        Map<String, dynamic> commodityEntry = {
          'service_request_id': serviceRequestId,
          'commodity_id': commodity.commodityId,
          'quantity': commodity.quantity,
          'weight': commodity.weight,
          'created_at': DateTime.now().toIso8601String(),
        };

        commodityData.add(commodityEntry);
      }

      if (commodityData.isNotEmpty) {
        await _supabase
            .from('service_request_commodities')
            .insert(commodityData);
      }

      // 3️⃣ Debugging: Calculate price based on distance
      int deliveryPrice = (distance.round() * 5000);
      print("$distance");
      print("$deliveryPrice");
      // 4️⃣ Debugging: Calculate final price
      int finalPrice = totalPrice + deliveryPrice;
      await _supabase
          .from('service_requests')
          .update({'price': finalPrice}).eq('id', serviceRequestId);

      print(
          "✅ Service request created successfully with total price: $finalPrice");
      return true;
    } catch (e) {
      print("❌ Error creating service request: $e");
      return false;
    }
  }
}

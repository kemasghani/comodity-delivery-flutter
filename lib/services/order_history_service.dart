import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_request_model.dart';
import '../models/service_request_commodities_model.dart';

class OrderHistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch order history for a user
  Future<List<ServiceRequest>> fetchOrderHistory(String userId) async {
    try {
      print('[OrderHistoryService] Fetching orders for userId: $userId');

      final response = await _supabase
          .from('service_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('[OrderHistoryService] Orders response: $response');

      return response
              ?.map<ServiceRequest>((json) => ServiceRequest.fromJson(json))
              .toList() ??
          [];
    } catch (e, stackTrace) {
      print('[OrderHistoryService] Error fetching order history: $e');
      print(stackTrace);
      return [];
    }
  }

  /// Fetch order details including commodity names
  Future<List<Map<String, dynamic>>> fetchOrderDetails(int orderId) async {
    try {
      print(
          '[OrderHistoryService] Fetching order details for orderId: $orderId');

      // Fetch raw commodities
      final commoditiesResponse = await _supabase
          .from('service_request_commodities')
          .select(
              'id, service_request_id, commodity_id, quantity, weight, created_at, commodity:commodity_id(name)')
          .eq('service_request_id', orderId);

      // ✅ Transform response before returning
      final transformedCommodities = commoditiesResponse.map((json) {
        return {
          'id': json['id'],
          'service_request_id': json['service_request_id'],
          'commodity_id': json['commodity_id'],
          'quantity': json['quantity'],
          'weight': json['weight'],
          'created_at': json['created_at'],
          'commodity_name': json['commodity']?['name'] ??
              'Unknown', // ✅ Flatten commodity name
        };
      }).toList();

      print(
          '[OrderHistoryService] Raw Commodities Response: $transformedCommodities'); // ✅ Now correctly formatted

      return transformedCommodities; // ✅ Return only transformed data
    } catch (e) {
      print('[OrderHistoryService] Error fetching order details: $e');
      return [];
    }
  }
}

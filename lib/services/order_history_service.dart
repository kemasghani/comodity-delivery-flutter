import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_request_model.dart';
import '../models/service_request_commodities_model.dart';

class OrderHistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceRequest>> fetchOrderHistory(String userId) async {
    final response = await _supabase
        .from('service_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response
        .map<ServiceRequest>((json) => ServiceRequest.fromJson(json))
        .toList();
  }

  Future<ServiceRequest> fetchOrderDetails(int orderId) async {
    final response = await _supabase
        .from('service_requests')
        .select()
        .eq('id', orderId)
        .single();

    return ServiceRequest.fromJson(response);
  }

  Future<List<ServiceRequestCommodityModel>> fetchOrderCommodities(
      int orderId) async {
    final response = await _supabase
        .from('service_request_commodities')
        .select()
        .eq('service_request_id', orderId);

    return response
        .map<ServiceRequestCommodityModel>(
            (json) => ServiceRequestCommodityModel.fromJson(json))
        .toList();
  }
}

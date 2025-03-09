import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/commodity_model.dart';

class CommodityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Fetch all commodities
  Future<List<Commodity>> getCommodities() async {
    try {
      final response = await _supabase.from('commodity').select();

      if (response.isEmpty) {
        print("⚠️ No commodities found.");
        return [];
      }

      return response.map((json) => Commodity.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching commodities: $e");
      return [];
    }
  }

  // ✅ Fetch a commodity by ID
  Future<Commodity?> getCommodityById(int id) async {
    try {
      final response =
          await _supabase.from('commodity').select().eq('id', id).single();

      return Commodity.fromJson(response);
    } catch (e) {
      print("❌ Error fetching commodity with ID $id: $e");
      return null;
    }
  }

  // ✅ Insert a new commodity
  Future<bool> addCommodity(Commodity commodity) async {
    try {
      await _supabase.from('commodity').insert({
        'name': commodity.name,
        'description': commodity.description,
        'price_per_kg': commodity.pricePerKg,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ Commodity added successfully.");
      return true;
    } catch (e) {
      print("❌ Error adding commodity: $e");
      return false;
    }
  }
}

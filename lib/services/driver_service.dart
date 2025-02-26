import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver_model.dart';

class DriverService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ✅ Fetch Available Drivers from Supabase
  Future<List<Driver>> getAvailableDrivers() async {
    try {
      final List<dynamic> response =
          await _supabase.from('drivers').select().eq('availability', true);

      print("🟢 Raw response from Supabase: $response");

      for (var json in response) {
        print("📍 Checking field types:");
        json.forEach((key, value) {
          print("   🔹 $key: ${value.runtimeType} ($value)");
        });
      }

      return response.map((json) => Driver.fromJson(json)).toList();
    } catch (e) {
      print("⚠️ Error fetching available drivers: $e");
      return [];
    }
  }
}

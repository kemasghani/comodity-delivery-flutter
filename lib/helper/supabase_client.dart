import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'SUPABASE_URL';
  static const String anonKey = 'SUPABASE_ANON_KEY';

  static void initialize() {
    Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}

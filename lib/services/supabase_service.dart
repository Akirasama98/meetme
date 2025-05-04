import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meetme/config/supabase_config.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: true, // Set false untuk production
    );
  }

  // Getter untuk mengakses instance Supabase client
  static SupabaseClient get client => Supabase.instance.client;
  
  // Getter untuk mengakses Auth
  static GoTrueClient get auth => client.auth;
  
  // Getter untuk mengakses Database - perbaikan tipe pengembalian
  static SupabaseQueryBuilder get db => client.from('your_table_name');
  
  // Getter untuk mengakses Storage
  static SupabaseStorageClient get storage => client.storage;
  
  // Getter untuk mengakses Functions
  static FunctionsClient get functions => client.functions;
  
  // Metode untuk mengakses tabel tertentu
  static PostgrestFilterBuilder<List<Map<String, dynamic>>> table(String tableName) {
    return client.from(tableName).select();
  }
}


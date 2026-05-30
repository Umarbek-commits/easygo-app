import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    await client.from('users').insert({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': 'passenger',
    });
  }

  static Future<bool> userExists(String phone) async {
    final response = await client
        .from('users')
        .select()
        .eq('phone', phone);

    return response.isNotEmpty;
  }
}
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

  static Future<Map<String, dynamic>?> getUserByPhone(
    String phone,
  ) async {
    final response = await client
        .from('users')
        .select()
        .eq('phone', phone)
        .maybeSingle();

    return response;
  }

  static Future<void> sendSupportMessage({
    required String phone,
    required String message,
  }) async {
    await client.from('support_messages').insert({
      'phone': phone,
      'message': message,
      'is_support': false,
    });
  }

  static Future<List<Map<String, dynamic>>> getReplies(
    String userId,
  ) async {
    final response = await client
        .from('support_replies')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getSupportMessages(
    String phone,
  ) async {
    final response = await client
        .from('support_messages')
        .select()
        .eq('phone', phone)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // — Регистрация пользователя
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

  // — Проверка существования пользователя
  static Future<bool> userExists(String phone) async {
    final response = await client
        .from('users')
        .select()
        .eq('phone', phone);
    return response.isNotEmpty;
  }

  // — Получить пользователя по телефону
  static Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final response = await client
        .from('users')
        .select()
        .eq('phone', phone)
        .maybeSingle();
    return response;
  }

  // — Отправить сообщение в поддержку (с session_id)
  static Future<void> sendSupportMessage({
    required String phone,
    required String message,
    required String sessionId,
  }) async {
    await client.from('support_messages').insert({
      'phone': phone,
      'message': message,
      'session_id': sessionId,
      'is_support': false,
    });
  }

  // — Получить все сообщения пользователя (старый метод)
  static Future<List<Map<String, dynamic>>> getSupportMessages(String phone) async {
    final response = await client
        .from('support_messages')
        .select()
        .eq('phone', phone)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  // — Получить все ответы оператора (старый метод)
  static Future<List<Map<String, dynamic>>> getReplies(String userId) async {
    final response = await client
        .from('support_replies')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  // ————————————————————————————————————————
  // СЕССИИ ПОДДЕРЖКИ
  // ————————————————————————————————————————

  // — Получить все сессии пользователя (новые сверху)
  static Future<List<Map<String, dynamic>>> getSupportSessions(String userId) async {
    final response = await client
        .from('support_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // — Создать новую сессию
  static Future<Map<String, dynamic>?> createSupportSession(String userId) async {
    final response = await client
        .from('support_sessions')
        .insert({
          'user_id': userId,
          'status': 'active',
        })
        .select()
        .single();
    return response;
  }

  // — Получить сессию по ID
  static Future<Map<String, dynamic>?> getSessionById(String sessionId) async {
    final response = await client
        .from('support_sessions')
        .select()
        .eq('id', sessionId)
        .single();
    return response;
  }

  // — Получить сообщения клиента по session_id
  static Future<List<Map<String, dynamic>>> getSessionMessages(String sessionId) async {
    final response = await client
        .from('support_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // — Получить ответы оператора по session_id
  static Future<List<Map<String, dynamic>>> getSessionReplies(String sessionId) async {
    final response = await client
        .from('support_replies')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // — Автоответ при первом сообщении
  static Future<void> sendAutoReply({
    required String sessionId,
    required String userId,
  }) async {
    await client.from('support_replies').insert({
      'user_id': userId,
      'session_id': sessionId,
      'message': 'Ваше сообщение получено. Оператор ответит в ближайшее время.',
    });
  }
} 
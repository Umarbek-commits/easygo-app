import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramService {
  static const String botToken =
      '8041502924:AAFcvwBXHTlApR__Y3EdhfsMjN8g-_L5Xmk';

  static const String chatId =
      '6170555228';

  static Future<void> sendMessage(String text) async {
    final url = Uri.parse(
      'https://api.telegram.org/bot$botToken/sendMessage',
    );

    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'chat_id': chatId,
        'text': text,
      }),
    );
  }
}
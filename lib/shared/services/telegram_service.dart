import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/secrets.dart';

class TelegramService {
  static const String botToken = AppSecrets.telegramBotToken;

  static const String chatId = AppSecrets.telegramChatId;

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
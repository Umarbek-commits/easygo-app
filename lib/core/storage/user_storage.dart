import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String phoneKey = 'user_phone';
  static const String supportChatClearedKey = 'support_chat_cleared';

  static Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(phoneKey, phone);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(phoneKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(phoneKey);
  }

  static Future<void> clearSupportChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(supportChatClearedKey, true);
  }

  static Future<bool> isSupportChatCleared() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(supportChatClearedKey) ?? false;
  }

  static Future<void> resetSupportChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(supportChatClearedKey);
  }
}
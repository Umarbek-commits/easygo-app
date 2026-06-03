import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/widgets/mobile_shell.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../../../../shared/services/telegram_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController messageController = TextEditingController();
  bool firstMessageSent = false;

  final List<Map<String, dynamic>> messages = [];

  // Ключ для SharedPreferences — хранит timestamp последней очистки
  static const String _clearKey = 'support_chat_cleared_at';

  Future<void> clearChat() async {
    // Сохраняем время очистки — всё что было ДО этого момента скрываем
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clearKey, DateTime.now().toIso8601String());

    setState(() {
      messages.clear();
      messages.add({
        "isSupport": true,
        "text": "Здравствуйте, чем могу помочь?",
        "time": "",
      });
    });
  }

  Future<void> loadChatHistory() async {
    final phone = await UserStorage.getPhone();
    if (phone == null) return;

    final user = await SupabaseService.getUserByPhone(phone);
    if (user == null) return;

    // Читаем время последней очистки
    final prefs = await SharedPreferences.getInstance();
    final clearedAtStr = prefs.getString(_clearKey);
    final clearedAt = clearedAtStr != null ? DateTime.parse(clearedAtStr) : null;

    final userMessages = await SupabaseService.getSupportMessages(phone);
    final replies = await SupabaseService.getReplies(user['id']);

    List<Map<String, dynamic>> allMessages = [];

    for (final msg in userMessages) {
      final createdAt = DateTime.parse(msg["created_at"]);
      // Пропускаем сообщения до момента очистки
      if (clearedAt != null && createdAt.isBefore(clearedAt)) continue;

      allMessages.add({
        "isSupport": false,
        "text": msg["message"],
        "time": DateFormat('HH:mm').format(createdAt),
        "created_at": msg["created_at"],
      });
    }

    for (final reply in replies) {
      final createdAt = DateTime.parse(reply["created_at"]);
      // Пропускаем ответы до момента очистки
      if (clearedAt != null && createdAt.isBefore(clearedAt)) continue;

      allMessages.add({
        "isSupport": true,
        "text": reply["message"],
        "time": DateFormat('HH:mm').format(createdAt),
        "created_at": reply["created_at"],
      });
    }

    allMessages.sort(
      (a, b) => DateTime.parse(a["created_at"]).compareTo(
        DateTime.parse(b["created_at"]),
      ),
    );

    allMessages.insert(0, {
      "isSupport": true,
      "text": "Здравствуйте, чем могу помочь?",
      "time": "",
      "created_at": "",
    });

    setState(() {
      messages.clear();
      messages.addAll(allMessages);
    });
  }

  @override
  void initState() {
    super.initState();
    loadChatHistory();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      await loadChatHistory();
      return true;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final text = messageController.text.trim();

    setState(() {
      messages.add({
        "isSupport": false,
        "text": text,
        "time": DateFormat('HH:mm').format(DateTime.now()),
      });
    });

    messageController.clear();

    final phone = await UserStorage.getPhone();

    if (phone != null) {
      await SupabaseService.sendSupportMessage(
        phone: phone,
        message: text,
      );

      final user = await SupabaseService.getUserByPhone(phone);

      await TelegramService.sendMessage(
        '📩 Новый запрос EasyGO\n\n'
        'ID: ${user?['support_id']}\n'
        'Телефон: $phone\n'
        'Имя: ${user?['first_name']} ${user?['last_name']}\n\n'
        'Сообщение:\n'
        '$text\n\n'
        'Ответь командой:\n'
        '/reply ${user?['support_id']} ваш ответ',
      );
    }

    if (!firstMessageSent) {
      firstMessageSent = true;

      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (!mounted) return;


          setState(() {
            messages.add({
              "isSupport": true,
              "text": "Ваше сообщение получено. Оператор ответит в ближайшее время.",
              "time": DateFormat('HH:mm').format(DateTime.now()),
            });
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF3F3F3),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter, 
                    colors: [
                      Color(0xFFAE00FF),
                      Color(0xFFD8A8E8),
                      Color(0xFFF3F3F3),
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Поддержка",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: clearChat,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Очистить",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];

                        if (msg["isSupport"] == true) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D2B36),
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  child: const Icon(
                                    Icons.headset_mic_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "EasyGO! Поддержка",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2D2B36),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg["text"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (msg["time"].toString().isNotEmpty)
                                              Text(
                                                msg["time"] ?? "",
                                                style: TextStyle(
                                                  color:
                                                      Colors.white.withOpacity(0.6),
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 6,
                              bottom: 6,
                              left: 60,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFAE00FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  msg["text"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg["time"] ?? "",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      child: Row(
                        children: [
                          _chip("Проблема с водителем", () {
                            messageController.text = "Проблема с водителем";
                          }),
                          _chip("Как работает рейтинг?", () {
                            messageController.text = "Как работает рейтинг?";
                          }),
                          _chip("Как вернуть вещь?", () {
                            messageController.text = "Как вернуть вещь?";
                          }),
                        ],
                      ),
                    ),
                  ),

                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 105,
                    ),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                filled: false,
                                hintText: "Сообщение",
                                hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2B36),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
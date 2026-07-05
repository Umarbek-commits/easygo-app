import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/telegram_service.dart';

class SupportChatScreen extends StatefulWidget {
  final String sessionId;
  final int sessionNumber;
  final bool isActive;

  const SupportChatScreen({
    super.key,
    required this.sessionId,
    required this.sessionNumber,
    required this.isActive,
  });

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isActive = true;
  bool firstMessageSent = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    isActive = widget.isActive;
    _loadFirstMessageSent();
    loadMessages();

    // Поллинг каждые 3 секунды (только для активного диалога)
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      if (!isActive) return false;
      await loadMessages();
      return true;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstMessageSent() async {
    final prefs = await SharedPreferences.getInstance();
    firstMessageSent = prefs.getBool('first_msg_${widget.sessionId}') ?? false;
  }

  Future<void> _setFirstMessageSent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_msg_${widget.sessionId}', true);
    firstMessageSent = true;
  }

  // Время в часовом поясе Кыргызстана (UTC+6), независимо от настроек телефона
  String _kgTime(DateTime dt) {
    final kg = dt.toUtc().add(const Duration(hours: 6));
    return DateFormat('HH:mm').format(kg);
  }

  Future<void> loadMessages() async {
    final phone = await UserStorage.getPhone();
    if (phone == null) return;

    final user = await SupabaseService.getUserByPhone(phone);
    if (user == null) return;

    // Загружаем сообщения и ответы по session_id
    final userMessages = await SupabaseService.getSessionMessages(widget.sessionId);
    final replies = await SupabaseService.getSessionReplies(widget.sessionId);

    // Проверяем статус сессии (оператор мог закрыть)
    final session = await SupabaseService.getSessionById(widget.sessionId);
    final sessionStatus = session?['status'] ?? 'active';

    List<Map<String, dynamic>> allMessages = [];

    for (final msg in userMessages) {
      final createdAt = DateTime.parse(msg["created_at"]);
      allMessages.add({
        "isSupport": false,
        "text": msg["message"],
        "time": _kgTime(createdAt),
        "created_at": msg["created_at"],
      });
    }

    for (final reply in replies) {
      final createdAt = DateTime.parse(reply["created_at"]);
      allMessages.add({
        "isSupport": true,
        "text": reply["message"],
        "time": _kgTime(createdAt),
        "created_at": reply["created_at"],
      });
    }

    allMessages.sort((a, b) {
  final aTime = DateTime.tryParse(a["created_at"] ?? '') ?? DateTime(2000);
  final bTime = DateTime.tryParse(b["created_at"] ?? '') ?? DateTime(2000);
  return aTime.compareTo(bTime);
   });
    // Первое приветствие всегда сверху
    allMessages.insert(0, {
      "isSupport": true,
      "text": "Здравствуйте, чем могу помочь?",
      "time": "",
      "created_at": "",
    });

    // Если диалог закрыт — добавляем системное сообщение о закрытии
    if (sessionStatus == 'closed') {
      allMessages.add({
        "isSupport": true,
        "text": "Диалог завершён оператором. Для нового обращения создайте новый диалог.",
        "time": "",
        "created_at": "z",
        "isSystem": true,
      });
    }

    // Список рисуется в обратном порядке (reverse: true) — новые снизу.
    // Поэтому храним новые сообщения первыми. Благодаря reverse при загрузке
    // новых сообщений экран НЕ сбрасывается вниз, когда листаешь историю вверх.
    setState(() {
      messages = allMessages.reversed.toList();
      isActive = sessionStatus == 'active';
    });
  }

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (!isActive) return;
    if (_isSending) return; // Защита от двойной отправки

    _isSending = true;
    final text = messageController.text.trim();
    messageController.clear();

    // Временно добавляем сообщение в UI для мгновенного отображения
    final tempMessage = {
      "isSupport": false,
      "text": text,
      "time": _kgTime(DateTime.now()),
      "created_at": DateTime.now().toIso8601String(),
    };
    
    setState(() {
      // Новые — в начало (reverse: true рисует их снизу)
      messages.insert(0, tempMessage);
    });

    // При отправке всегда показываем низ (в reverse это offset 0)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final phone = await UserStorage.getPhone();
    if (phone != null) {
      // Отправляем сообщение в БД
      await SupabaseService.sendSupportMessage(
        phone: phone,
        message: text,
        sessionId: widget.sessionId,
      );

      final user = await SupabaseService.getUserByPhone(phone);
      if (user != null) {
        // Отправляем уведомление в Telegram
        await TelegramService.sendMessage(
          '📩 Новый запрос EasyGO\n\n'
          'ID: ${user['support_id']}\n'
          'Телефон: $phone\n'
          'Имя: ${user['first_name']} ${user['last_name']}\n'
          'Сессия: ${widget.sessionId}\n\n'
          'Сообщение:\n'
          '$text\n\n'
          'Ответить: /reply ${user['support_id']} ваш ответ\n'
          'Закрыть диалог: /close ${user['support_id']}',
        );

        // Автоответ только на первое сообщение в диалоге
        if (!firstMessageSent) {
          await _setFirstMessageSent();
          await SupabaseService.sendAutoReply(
            sessionId: widget.sessionId,
            userId: user['id'],
          );
        }
      }
    }

    // Сразу перезагружаем сообщения из БД
    await loadMessages();
    _isSending = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.scaffold(context),
      body: Stack(
        children: [
            // Градиент сверху — до самого верха, под статус-бар
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFAE00FF),
                    const Color(0xFFD8A8E8),
                    AppColors.scaffold(context),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 24, 0),
                  child: Row(
                    children: [
                      // Кнопка назад
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Диалог #${widget.sessionNumber}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              isActive ? "● Активен" : "Завершён",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Список сообщений
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.fromLTRB(12, 8, 12, isActive ? 128 : 90),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      // Системное сообщение о закрытии
                      if (msg["isSystem"] == true) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.isDark(context)
                                    ? Colors.white.withOpacity(0.07)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg["text"],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // Сообщение от поддержки
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
                                  color: AppColors.card(context),
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
                                    Text(
                                      "EasyGO! Поддержка",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface(context),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.card(context),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg["text"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (msg["time"].toString().isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              msg["time"] ?? "",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
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

                      // Сообщение от клиента
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

                      // Поле ввода как в Telegram: блюр-панель поверх списка,
                      // сообщения проглядывают под ней
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                            child: Container(
                              color:
                                  AppColors.scaffold(context).withOpacity(0.55),
                              padding: const EdgeInsets.only(top: 6, bottom: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Быстрые чипы (только для активного)
                                  if (isActive)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 2, 16, 8),
                                      child: Row(
                                        children: [
                                          _chip("Проблема с водителем", () {
                                            messageController.text =
                                                "Проблема с водителем";
                                          }),
                                          _chip("Как работает рейтинг?", () {
                                            messageController.text =
                                                "Как работает рейтинг?";
                                          }),
                                          _chip("Как вернуть вещь?", () {
                                            messageController.text =
                                                "Как вернуть вещь?";
                                          }),
                                        ],
                                      ),
                                    ),

                                  // Поле ввода / заглушка
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: isActive
                                        ? Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.inputBg(context),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        messageController,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .onSurface(context)),
                                                    decoration:
                                                        const InputDecoration(
                                                      filled: false,
                                                      hintText: "Сообщение",
                                                      hintStyle: TextStyle(
                                                          color: Color(
                                                              0xFF9E9E9E)),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                    ),
                                                    onSubmitted: (_) =>
                                                        _sendMessage(),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: _sendMessage,
                                                  child: Container(
                                                    width: 44,
                                                    height: 44,
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: _isSending
                                                        ? const SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          )
                                                        : const Icon(
                                                            Icons.send_rounded,
                                                            size: 20,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.isDark(context)
                                                  ? Colors.white
                                                      .withOpacity(0.06)
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Диалог завершён",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textSecondary(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget _chip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.card(context),
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
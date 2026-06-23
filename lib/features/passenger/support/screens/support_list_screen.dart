import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/mobile_shell.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/storage/user_storage.dart';
import 'support_chat_screen.dart';

class SupportListScreen extends StatefulWidget {
  const SupportListScreen({super.key});

  @override
  State<SupportListScreen> createState() => _SupportListScreenState();
}

class _SupportListScreenState extends State<SupportListScreen> {
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final phone = await UserStorage.getPhone();
    if (phone == null) return;

    final user = await SupabaseService.getUserByPhone(phone);
    if (user == null) return;

    // Получаем все сессии пользователя, отсортированные по дате (новые сверху)
    final data = await SupabaseService.getSupportSessions(user['id']);

    setState(() {
      sessions = data;
      isLoading = false;
    });
  }

  Future<void> _startNewSession() async {
    final phone = await UserStorage.getPhone();
    if (phone == null) return;

    final user = await SupabaseService.getUserByPhone(phone);
    if (user == null) return;

    // Создаём новую сессию в Supabase
    final session = await SupabaseService.createSupportSession(user['id']);
    if (session == null) return;

    if (!mounted) return;

    // Открываем чат новой сессии
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupportChatScreen(
          sessionId: session['id'],
          sessionNumber: sessions.length + 1,
          isActive: true,
        ),
      ),
    );

    // После возврата обновляем список
    loadSessions();
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
        backgroundColor: const Color(0xFFF3F3F3),
        body: SafeArea(
          child: Stack(
            children: [
              // Градиент сверху
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
                  // Заголовок
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
                        // Кнопка нового диалога
                        GestureDetector(
                          onTap: _startNewSession,
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
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Новый",
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

                  // Список сессий
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFAE00FF)))
                        : sessions.isEmpty
                            ? _buildEmpty()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                itemCount: sessions.length,
                                itemBuilder: (context, index) {
                                  final session = sessions[index];
                                  final isActive = session['status'] == 'active';
                                  final createdAt = DateTime.parse(session['created_at']);
                                  final sessionNumber = sessions.length - index;

                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SupportChatScreen(
                                            sessionId: session['id'],
                                            sessionNumber: sessionNumber,
                                            isActive: isActive,
                                          ),
                                        ),
                                      );
                                      loadSessions();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Иконка
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? const Color(0xFFAE00FF)
                                                  : const Color(0xFF2D2B36),
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            child: Icon(
                                              isActive
                                                  ? Icons.headset_mic_rounded
                                                  : Icons.check_circle_outline,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Текст
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Диалог #$sessionNumber",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat('dd.MM.yyyy, HH:mm').format(createdAt),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Статус
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? const Color(0xFFAE00FF).withOpacity(0.1)
                                                  : Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isActive ? "Активен" : "Закрыт",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isActive
                                                    ? const Color(0xFFAE00FF)
                                                    : Colors.grey[500],
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2B36),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Нет обращений",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Нажмите «Новый», чтобы начать диалог",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startNewSession,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFAE00FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Написать в поддержку",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
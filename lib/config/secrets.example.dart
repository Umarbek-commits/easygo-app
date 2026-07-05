// Шаблон секретов. Скопируй этот файл в secrets.dart (тот в .gitignore)
// и вставь свои реальные ключи.
class AppSecrets {
  // Публичный (publishable) токен Mapbox — начинается на pk.
  static const String mapboxToken = 'YOUR_MAPBOX_PUBLIC_TOKEN';

  // Telegram-бот поддержки
  static const String telegramBotToken = 'YOUR_TELEGRAM_BOT_TOKEN';
  static const String telegramChatId = 'YOUR_TELEGRAM_CHAT_ID';

  // Supabase
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}

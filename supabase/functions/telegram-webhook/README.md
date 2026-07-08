# Telegram-бот поддержки EasyGO

Оператор отвечает клиенту прямо из Telegram. Клиент пишет в приложении →
уведомление приходит оператору в бот → оператор **отвечает (reply)** на это
сообщение → ответ появляется в приложении.

## Как это работает

```
Приложение → Supabase (support_messages) → уведомление в Telegram (боту)
Оператор reply в Telegram → этот webhook → support_replies → приложение
```

- Ответ: свайп-**reply** на уведомление, или команда `/reply <session_id> текст`.
- Закрыть диалог: `/close <session_id>`.

## Деплой (вариант А — через дашборд, без CLI)

1. Supabase Dashboard → **Edge Functions** → **Create a new function**.
2. Имя: `telegram-webhook`. Вставить код из `index.ts`. **Verify JWT: OFF**. Deploy.
3. Edge Functions → **Secrets** → добавить:
   - `TELEGRAM_BOT_TOKEN` = токен бота от @BotFather
   - (`SUPABASE_URL` и `SUPABASE_SERVICE_ROLE_KEY` уже есть автоматически)
4. Прописать webhook в Telegram (заменить `<ТОКЕН>`):
   ```
   curl "https://api.telegram.org/bot<ТОКЕН>/setWebhook?url=https://ppfyjiengpulysyvgawn.supabase.co/functions/v1/telegram-webhook"
   ```

## Деплой (вариант Б — через CLI)

```
npm i -g supabase
export SUPABASE_ACCESS_TOKEN=<личный токен из дашборда>
supabase functions deploy telegram-webhook --no-verify-jwt --project-ref ppfyjiengpulysyvgawn
supabase secrets set TELEGRAM_BOT_TOKEN=<токен> --project-ref ppfyjiengpulysyvgawn
```
Затем тот же `setWebhook`, что и выше.

## Проверка

- `getWebhookInfo`: `curl "https://api.telegram.org/bot<ТОКЕН>/getWebhookInfo"`
- Написать в поддержку из приложения → оператор получит уведомление → reply → ответ виден в приложении.

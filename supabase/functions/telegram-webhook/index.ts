// EasyGO — Telegram webhook (поддержка).
//
// Оператор отвечает в Telegram-боте (свайп-reply на уведомление или
// командой /reply <session_id> текст), а этот webhook пишет ответ в
// support_replies. Приложение опрашивает support_replies и показывает ответ.
//
// Деплой:
//   supabase functions deploy telegram-webhook --no-verify-jwt \
//     --project-ref ppfyjiengpulysyvgawn
//   supabase secrets set TELEGRAM_BOT_TOKEN=<токен> --project-ref ppfyjiengpulysyvgawn
//   (SUPABASE_URL и SUPABASE_SERVICE_ROLE_KEY подставляются автоматически)
//
// Затем прописать webhook в Telegram:
//   curl "https://api.telegram.org/bot<ТОКЕН>/setWebhook?url=\
//   https://ppfyjiengpulysyvgawn.supabase.co/functions/v1/telegram-webhook"

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BOT_TOKEN = Deno.env.get("TELEGRAM_BOT_TOKEN")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const TG = `https://api.telegram.org/bot${BOT_TOKEN}`;
const supabase = createClient(SUPABASE_URL, SERVICE_ROLE);

const UUID_RE =
  /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/;

async function tgSend(chatId: number | string, text: string, replyTo?: number) {
  await fetch(`${TG}/sendMessage`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      reply_to_message_id: replyTo,
    }),
  });
}

function extractSessionId(text: string | undefined): string | null {
  if (!text) return null;
  // В уведомлении единственный UUID — это id сессии
  const m = text.match(UUID_RE);
  return m ? m[0] : null;
}

Deno.serve(async (req) => {
  try {
    const update = await req.json();
    const msg = update.message ?? update.edited_message;
    if (!msg || typeof msg.text !== "string") {
      return new Response("ok");
    }

    const chatId = msg.chat.id;
    const text: string = msg.text.trim();

    // ── Закрыть диалог: /close <session_id> (или reply + /close)
    if (text.startsWith("/close")) {
      const sid =
        extractSessionId(text) ?? extractSessionId(msg.reply_to_message?.text);
      if (!sid) {
        await tgSend(chatId, "Укажите ID: /close <session_id>", msg.message_id);
        return new Response("ok");
      }
      await supabase
        .from("support_sessions")
        .update({ status: "closed" })
        .eq("id", sid);
      await tgSend(chatId, `✅ Диалог закрыт (${sid})`, msg.message_id);
      return new Response("ok");
    }

    // ── Ответ оператора
    let sessionId: string | null = null;
    let replyText = text;

    if (text.startsWith("/reply")) {
      // /reply <session_id> <текст>
      const parts = text.split(/\s+/);
      sessionId = extractSessionId(parts[1]) ?? parts[1] ?? null;
      replyText = parts.slice(2).join(" ").trim();
    } else if (msg.reply_to_message) {
      // Свайп-ответ на уведомление — берём session из того сообщения
      sessionId = extractSessionId(msg.reply_to_message.text);
      replyText = text;
    }

    // Не относится к поддержке — тихо игнорируем
    if (!sessionId || !replyText) {
      return new Response("ok");
    }

    // Находим сессию → user_id
    const { data: session, error } = await supabase
      .from("support_sessions")
      .select("id, user_id, status")
      .eq("id", sessionId)
      .maybeSingle();

    if (error || !session) {
      await tgSend(chatId, `❌ Сессия не найдена (${sessionId})`, msg.message_id);
      return new Response("ok");
    }

    const { error: insErr } = await supabase.from("support_replies").insert({
      session_id: session.id,
      user_id: session.user_id,
      message: replyText,
    });

    if (insErr) {
      await tgSend(chatId, `❌ Ошибка: ${insErr.message}`, msg.message_id);
      return new Response("ok");
    }

    await tgSend(chatId, "✅ Отправлено пользователю", msg.message_id);
    return new Response("ok");
  } catch (e) {
    console.error("webhook error", e);
    // Всегда 200, чтобы Telegram не забивал повторами
    return new Response("ok");
  }
});

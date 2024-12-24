// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { user, session, chat, message } from "../_shared/schema.ts";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { eq, sql } from "drizzle-orm";
import { createClient } from "jsr:@supabase/supabase-js@2";

const connectionString = Deno.env.get("SUPABASE_DB_URL")!;
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",
};

function createErrorResponse(message: string, status = 400) {
  return new Response(
    JSON.stringify({ error: message }),
    { status, headers: corsHeaders },
  );
}

async function sendPrompt(messages: Array<any>) {
  const url = "http://host.docker.internal:11434/api/chat";
  const data = {
    model: "llama3.2",
    messages,
    stream: false,
  };

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error("AI service returned an error");
    }
    return await response.json();
  } catch (error) {
    console.error("Error sending prompt:", error);
    throw new Error("Failed to communicate with AI service");
  }
}

async function validateSession(db, supabaseClient, token: string) {
  const { data } = await supabaseClient.auth.getUser(token);
  const supabaseUser = data?.user;

  if (!supabaseUser) throw new Error("Invalid or missing user");

  const [existingSession] = await db
    .select()
    .from(session)
    .where(eq(session.userId, supabaseUser.id));

  if (!existingSession) throw new Error("Session not found. Update your session.");

  return { supabaseUser, existingSession };
}

async function validateUser(db, accountId: string) {
  const [existingUser] = await db
    .select()
    .from(user)
    .where(eq(user.id, accountId));

  if (!existingUser) throw new Error("User not found in the system.");
  if (existingUser.isBanned) throw new Error("User is banned.");

  return existingUser;
}

async function validateChat(db, chatId: string) {
  const [existingChat] = await db
    .select()
    .from(chat)
    .where(eq(chat.id, chatId));

  if (!existingChat) throw new Error("Chat does not exist.");
  return existingChat;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        ...corsHeaders,
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Authorization, Content-Type",
      },
    });
  }

  try {
    const client = postgres(connectionString, { prepare: false });
    const db = drizzle(client);
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    );

    const authHeader = req.headers.get("Authorization")!;
    const token = authHeader.replace("Bearer ", "");

    const { supabaseUser, existingSession } = await validateSession(db, supabaseClient, token);
    const existingUser = await validateUser(db, existingSession.accountId);

    const jsonBody = await req.json();
    const { chatId, authorId, message: userMessage } = jsonBody;

    if (authorId !== existingSession.accountId) {
      throw new Error("Invalid author ID.");
    }

    const existingChat = await validateChat(db, chatId);

    jsonBody.message = sql`${userMessage}::jsonb`;

    const [insertedMessage] = await db
      .insert(message)
      .values(jsonBody)
      .returning();

    const chatHistory = await db
      .select()
      .from(message)
      .where(eq(message.chatId, chatId));

    const promptForAI = chatHistory.map((msg) => ({
      role: msg.authorId === "ai" ? "assistant" : "user",
      content: msg.message.text,
    }));

    const aiResponse = await sendPrompt(promptForAI);

    const aiBodyRequest = {
      messageType: "text",
      message: { text: aiResponse.message.content },
      chatId,
      authorId: "ai",
    };

    aiBodyRequest.message = sql`${aiBodyRequest.message}::jsonb`;

    const [insertedAIMessage] = await db
      .insert(message)
      .values(aiBodyRequest)
      .returning();

    return new Response(
      JSON.stringify({ message_data: insertedAIMessage }),
      { headers: corsHeaders },
    );
  } catch (error) {
    console.error("Error handling request:", error);
    return createErrorResponse(error.message || "Unexpected error");
  }
});

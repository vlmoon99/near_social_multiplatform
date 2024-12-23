// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { user, session, chat, message } from "../_shared/schema.ts";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { eq, sql } from 'drizzle-orm';
import { createClient } from 'jsr:@supabase/supabase-js@2';

// let db;

const connectionString = Deno.env.get("SUPABASE_DB_URL")!;

async function sendPromt(message: Array<any>) {
  const url = 'http://host.docker.internal:11434/api/chat';

  const data = {
    model: "llama3.2",
    messages: message,
    stream: false
  };

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (response.ok) {
      const responseBody = await response.json();
      return responseBody;
    } else {
      throw new Response(
        JSON.stringify({ error: "Invalid JSON input" }),
        { status: 400, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*", } },
      );
    }
  } catch (e) {
    throw new Response(
        JSON.stringify({ error: "Invalid JSON input" }),
        { status: 400, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*", } },
      );
  }
}

// async function sendMassageToDB(jsonBody: any) {
//   jsonBody.message = sql`${jsonBody.message}::jsonb`;

//   console.log(" json to send {}", jsonBody);

//   const [insertedMessage] = await db
//     .insert(message)
//     .values(jsonBody).returning();
//   return insertedMessage;
// }

function roundDateToNearestTenSeconds(input) {
  const date = new Date(input); // Преобразуем строку в объект Date
  const seconds = date.getSeconds(); 
  
  // Округляем секунды вниз до ближайшего кратного 10
  const roundedSeconds = Math.floor(seconds / 10) * 10; 
  
  // Устанавливаем округленные секунды и обнуляем миллисекунды
  date.setSeconds(roundedSeconds, 0); 
  
  return date; // Возвращаем объект Date
}

function convertDate(input) {
  const date = new Date(input);

  // Установить секунды на ближайшее кратное 10
  const seconds = Math.floor(date.getSeconds() / 10) * 10;
  date.setSeconds(seconds, 0);

  // Преобразовать в строку ISO 8601
  return date.toISOString();
}

Deno.serve(async (req) => {

  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Authorization, Content-Type",
      },
    });
  }

   const client = postgres(connectionString, { prepare: false });
   const db = drizzle(client);


   const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  )
  
   const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')
    const { data } = await supabaseClient.auth.getUser(token)
    const supabaseUser = data.user
  
    const [existingUserSession] = await db
      .select()
      .from(session)
      .where(eq(session.userId, supabaseUser.id));
  
    if (!existingUserSession) {
      return new Response(
        JSON.stringify({
          'result': 'error',
          'operation_message': 'Update your session',
        }),
        { ...corsHeaders, headers: { "Content-Type": "application/json" } },
      )
    }

    const [existingUser] = await db
        .select()
        .from(user)
        .where(eq(user.id, existingUserSession.accountId));
    
    
      if (existingUser) {
        if (existingUser.isBanned) {
          return new Response(
            JSON.stringify({ success: false, reason: "User is banned." }),
            { ...corsHeaders, headers: { "Content-Type": "application/json" } },
          );
        }
      } else {
        return new Response(
          JSON.stringify({
            'result': 'error',
            'operation_message': 'No User inside the system.',
          }),
          { ...corsHeaders, headers: { "Content-Type": "application/json" } },
        )
      }


  try {
    const jsonBody = await req.json(); 

    const massage = jsonBody.message;

    const [existingChat] = await db
    .select()
    .from(chat)
    .where(eq(chat.id, jsonBody.chatId));

  if (!existingChat) {
    return new Response(
      JSON.stringify({
        'result': 'error',
        'operation_message': 'User try to insert message in un-existing chat.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    )
  }

  console.log("existingChat {}", existingChat);

  console.log("jsonBody {}", jsonBody);

  if (jsonBody.authorId != existingUserSession.accountId) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'Invalid author id.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );
  }


  jsonBody.message = sql`${jsonBody.message}::jsonb`;

  console.log("new jsonBody", jsonBody);



  const [insertedUserMessage] = await db
    .insert(message)
    .values(jsonBody).returning();

  console.log("Message was successfully created {}", insertedUserMessage);



    const chatHistory = await db
    .select()
    .from(message)
    .where(eq(message.chatId, jsonBody.chatId));

    const promptForAI = chatHistory.map((msg) => ({
      role: msg.authorId == "ai" ? "assistant" : "user",
      content: msg.message.text,
    }))

    const request = await sendPromt(promptForAI);


    const aiBodyRequest = {
      messageType: "text",
      message: { text: request.message.content },
      chatId: insertedUserMessage.chatId,
      authorId: "ai"};


      aiBodyRequest.message = sql`${aiBodyRequest.message}::jsonb`;

      console.log("new aiBodyRequest", aiBodyRequest);

      const [insertedAIMessage] = await db
        .insert(message)
        .values(aiBodyRequest).returning();
    
      console.log("Message was successfully created {}", insertedAIMessage);



    return new Response(JSON.stringify({'message_data': insertedMessage,}), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*", 
      },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Invalid JSON input" }),
      { status: 400, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*", } },
    );
  }
});


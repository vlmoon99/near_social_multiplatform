import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { user, session, chat } from "../_shared/schema.ts";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { eq , sql } from 'drizzle-orm';
import { createClient } from 'jsr:@supabase/supabase-js@2'


const connectionString = Deno.env.get("SUPABASE_DB_URL")!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

async function generateChatHash(userId1, userId2, type) {
  const crypto = await import('crypto');

  const sortedIds = [userId1, userId2, type].sort();

  const hash = crypto.createHash('sha256');
  hash.update(sortedIds.join('_'));

  const chatId = hash.digest('hex');
  return chatId;
}

Deno.serve(async (req) => {

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

  if(!existingUserSession){
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
    if (existingUser.is_banned) {
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

  const reqJsonBody = await req.json()

  console.log("reqJsonBody {}",reqJsonBody);

  const { id, metadata } = reqJsonBody

  const participants = metadata['participants']

  if (!participants.includes(existingUserSession.accountId)) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'The current user is not included in the participants.',
      }),
      { 
        ...corsHeaders, 
        headers: { "Content-Type": "application/json" },
      }
    );
  }

  const chatType = metadata['chat_type']

  let chatHash;

  if (chatType == "public" || chatType == "private") {
    chatHash = await generateChatHash(participants[0], participants[1], chatType);
  }
  else {
    console.log("Not implemented");
  }


  if (!chatHash || id != chatHash) {
    console.log("Error while creating chathash");
    return new Response(
      JSON.stringify({
        'result': 'error',
        'operation_message': 'Error creating private chat: Incorrect chat hash',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    )
  }


  const [existingChat] = await db
    .select()
    .from(chat)
    .where(eq(chat.id, chatHash));


  if (!existingChat) {


    console.log("reqJsonBody {}",reqJsonBody);

    reqJsonBody.metadata = sql`${reqJsonBody.metadata}::jsonb`;
  
    const [insertedChat] = await db
      .insert(chat)
      .values(reqJsonBody).returning();

    console.log("Chat was successfully created {}",insertedChat);
    return new Response(
      JSON.stringify({
        'result': 'ok',
        'operation_message': 'Chat created successfully.',
        'chat_data': insertedChat,
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    )
  }
  else {
    console.log("Chat is alredy exist");
    return new Response(
      JSON.stringify({
        'result': 'error',
        'operation_message': 'Error creating private chat: Chat is alredy exist',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    )
  }

})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/chat_managing' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

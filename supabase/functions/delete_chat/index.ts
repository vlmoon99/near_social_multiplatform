import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { user, session, chat, message } from "../_shared/schema.ts";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { eq, sql, and } from "drizzle-orm";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const connectionString = Deno.env.get("SUPABASE_DB_URL")!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}



Deno.serve(async (req) => {
  const client = postgres(connectionString, { prepare: false });
  const db = drizzle(client);

  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  );

  const authHeader = req.headers.get('Authorization')!;
  const token = authHeader.replace('Bearer ', '');
  const { data } = await supabaseClient.auth.getUser(token);
  const supabaseUser = data.user;

  if (!supabaseUser) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'Invalid user.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );
  }

  const [existingUserSession] = await db
    .select()
    .from(session)
    .where(eq(session.userId, supabaseUser.id));

  if (!existingUserSession) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'No active session found.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );
  }

  const reqJsonBody = await req.json();
  const { chatId } = reqJsonBody;

  if (!chatId) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'Chat ID is required.',
      }),
      {
        ...corsHeaders,
        headers: { "Content-Type": "application/json" },
      }
    );
  }

  const [existingChat] = await db
    .select()
    .from(chat)
    .where(eq(chat.id, chatId));

  if (!existingChat) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'Chat does not exist.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );
  }

  const accountId = existingUserSession.accountId;
  const participants = existingChat.metadata['participants']

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
  console.log("Pass all cheks");

  if (!existingChat.metadata.delete) {
    existingChat.metadata.delete = {
      [participants[0]]: false,
      [participants[1]]: false,
    };
  }

  existingChat.metadata.delete[accountId] = true;


  if (existingChat.metadata['chat_type'] == 'private') {
    console.log("existingChat.metadata['chat_type'] == 'private'");
  }

  console.log("existingChat.metadata {}", existingChat.metadata);

  
  existingChat.metadata = sql`${existingChat.metadata}::jsonb`;

  const [updatedChat] = await db
    .update(chat)
    .set({ metadata: existingChat.metadata })
    .where(eq(chat.id, chatId))
    .returning();

  if (!updatedChat) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'Failed to mark chat as deleted.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );
  }


  const updatedDelete = {
    [participants[0]]: true,
    [participants[1]]: true,
  };

  // updatedDelete[existingUserSession.accountId] = true
  
  await db
    .update(message)
    .set({
      delete: sql`${updatedDelete}::jsonb`,
    })
    // .where(and(eq(message.authorId, existingUserSession.accountId),eq(message.chatId, updatedChat.id)))
    .where(eq(message.chatId, updatedChat.id))
    .returning();

  return new Response(
    JSON.stringify({
      result: 'ok',
      operation_message: 'Chat marked as deleted for the user.',
      chat_data: updatedChat,
    }),
    { ...corsHeaders, headers: { "Content-Type": "application/json" } },
  );

})



/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/delete_chat' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

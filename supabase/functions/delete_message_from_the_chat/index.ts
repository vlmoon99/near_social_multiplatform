import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { user, session, chat, message } from "../_shared/schema.ts";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { eq, sql } from 'drizzle-orm';
import { createClient } from 'jsr:@supabase/supabase-js@2'

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


  const jsonBody = await req.json()


  const [existingMessage] = await db
    .select()
    .from(message)
    .where(eq(message.id, jsonBody.messageId));

  if (existingMessage.authorId != existingUserSession.accountId) {
    return new Response(
      JSON.stringify({
        'result': 'error',
        'operation_message': 'Incorrect author id.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    )
  }


  existingMessage.message.delete[existingUserSession.accountId] = true

  existingMessage.message = sql`${existingMessage.message}::jsonb`;

  console.log("existingMessage {}", existingMessage);

  const [updatedMessage] = await db
    .update(message)
    .set({ message: existingMessage.message })
    .where(eq(message.id, existingMessage.id))
    .returning();

  if (!updatedMessage) {
    return new Response(
      JSON.stringify({
        result: 'error',
        operation_message: 'Failed to delete message.',
      }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );
  }


  return new Response(
    JSON.stringify({
      result: 'ok',
      operation_message: 'Message marked as deleted for the user.',
      updated_message: updatedMessage,
    }),
    { ...corsHeaders, headers: { "Content-Type": "application/json" } },
  );
})



/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/delete_message_from_the_chat' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import bs58 from "bs58";
import nearApi from "near-api-js";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { user, session } from "../_shared/schema.ts";
import { eq } from 'drizzle-orm';
import { createClient } from 'jsr:@supabase/supabase-js@2'

const connectionString = Deno.env.get("SUPABASE_DB_URL")!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}


async function verifySignature(signature, publicKeyStr) {
  try {
    const signatureBytes = bs58.decode(signature);
    console.log('signatureBytes :', signatureBytes);

    const publicKey = nearApi.utils.PublicKey.from(publicKeyStr);

    console.log('publicKey :', publicKey);

    const isVerified = publicKey.verify(new Uint8Array([]), signatureBytes);

    console.log('isVerified :', isVerified);

    return isVerified;
  } catch (error) {
    console.error('Verification failed:', error);
    return false;
  }
}


Deno.serve(async (req) => {

  try {

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')
    const { data } = await supabaseClient.auth.getUser(token)
    const supabaseUser = data.user

    const body = await req.json();
    const { signature, publicKeyStr, uuid, accountId } = body;

    console.log("supabaseUser.id {}",supabaseUser.id)
    console.log("uuid {}",uuid)
    console.log("supabaseUser.id != uuid {}",supabaseUser.id != uuid)

    if(supabaseUser.id != uuid){
      return new Response(
        JSON.stringify({ success: false, reason: "Fake user uid, pls re-install this app" }),
        { ...corsHeaders, headers: { "Content-Type": "application/json" } },
      );
    }

    const isVerified = await verifySignature(signature, publicKeyStr);

    if (!isVerified) {
      return new Response(
        JSON.stringify({ success: false, reason: "Signature verification failed." }),
        { ...corsHeaders, headers: { "Content-Type": "application/json" } },
      );
    }

    const client = postgres(connectionString, { prepare: false });
    const db = drizzle(client);

    const [existingUser] = await db
      .select()
      .from(user)
      .where(eq(user.id, accountId));


    if (existingUser) {
      if (existingUser.is_banned) {
        return new Response(
          JSON.stringify({ success: false, reason: "User is banned." }),
          { ...corsHeaders, headers: { "Content-Type": "application/json" } },
        );
      }
    } else {
      await db
        .insert(user)
        .values({
          id: accountId,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
    }


    let newSession;

    const existingSessions = await db
      .select()
      .from(session)
      .where(eq(session.userId, uuid));

    if (existingSessions.length > 0) {
      await db
        .update(session)
        .set({
          updatedAt: new Date(),
          isActive: true,
          accountId: accountId
        })
        .where(eq(session.userId, uuid));

      const [updatedSession] = await db
        .select()
        .from(session)
        .where(eq(session.userId, uuid));

      newSession = updatedSession;
    } else {
      const [insertedSession] = await db
        .insert(session)
        .values({
          userId: uuid,
          accountId: accountId,
          isActive: true,
          createdAt: new Date(),
        })
        .returning();

      newSession = insertedSession;
    }

    return new Response(
      JSON.stringify({ success: true, session: newSession }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
    );

  } catch (e) {
    console.error('Error processing request:', e);
    return new Response(
      JSON.stringify({ success: false, reason: "Internal server error." }),
      { ...corsHeaders, headers: { "Content-Type": "application/json" } },
      { status: 500 },
    );
  }

});


/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'https://82e3-178-54-185-162.ngrok-free.app/functions/v1/verifyAccount' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

  curl -i --location --request POST 'http://localhost:54321/functions/v1/verifyAccount' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

  flutter run -d chrome --web-browser-flag "--disable-web-security"
*/


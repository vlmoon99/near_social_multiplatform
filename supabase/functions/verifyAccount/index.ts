// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import bs58 from "bs58";
import nearApi from "near-api-js";

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { session } from "../_shared/schema.ts";

const connectionString = Deno.env.get("SUPABASE_DB_URL")!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}


async function verifySignature(signature, publicKeyStr) {
  try {
    const signatureBytes = bs58.decode(signature);

    const publicKey = nearApi.utils.PublicKey.from(publicKeyStr);

    const isVerified = publicKey.verify(new Uint8Array([]), signatureBytes);

    return isVerified;
  } catch (error) {
    console.error('Verification failed:', error);
    return false;
  }
}


async function connectToTheDBTest() {
  try {

    console.log('Sucsess  : {} ', data);

  } catch (err) {

    console.log('Error  : {} ', err);

  }

}


Deno.serve(async (req) => {

  // Connect to the database
  const client = postgres(connectionString, { prepare: false });
  const db = drizzle(client);

  // Generate random data for the session
  const randomId = crypto.randomUUID();
  const randomAccountId = crypto.randomUUID();
  const isActive = Math.random() < 0.5; // Random boolean

    // Insert the session into the database
  const [newSession] = await db
    .insert(session)
    .values({
      id: randomId,
      accountId: randomAccountId,
      isActive,
    })
  .returning();

  // Return the inserted session as the response
  return new Response(
    JSON.stringify(newSession),
    { headers: { "Content-Type": "application/json" } },
  );

  // const body = (await req.json());

  // const { signature, publicKeyStr, uuid, accountId } = body;


  // try {
  //   const isVerified = await verifySignature(signature, publicKeyStr);

  //   if (isVerified) {
  //     console.log('isVerified:', isVerified);

  //     return new Response(
  //       JSON.stringify({ success: true }),
  //       { ...corsHeaders, headers: { "Content-Type": "application/json" } },
  //     )
  //   } else {
  //     console.log('isVerified:', isVerified);
  //     return new Response(
  //       JSON.stringify({ success: false }),
  //       { ...corsHeaders, headers: { "Content-Type": "application/json" } },
  //     )

  //   }

  // } catch (e) {
  //   console.error('Error verifying transaction:', e);
  // }

  // return new Response(
  //   JSON.stringify("Hello world"),
  //   { ...corsHeaders, headers: { "Content-Type": "application/json" } },
  // )
})

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


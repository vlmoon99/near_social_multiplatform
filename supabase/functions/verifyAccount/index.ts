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
  const body = (await req.json());

  const { signature, publicKeyStr, uuid, accountId } = body;

  try {
    const isVerified = await verifySignature(signature, publicKeyStr);

    if (isVerified) {
      console.log('isVerified:', isVerified);
      const client = postgres(connectionString, { prepare: false });
      const db = drizzle(client);
      const [newSession] = await db
        .insert(session)
        .values({
          userId: uuid,
          accountId: accountId,
          isActive : isVerified,
        })
        .returning();

      return new Response(
        JSON.stringify({ success: true }),
        { ...corsHeaders, headers: { "Content-Type": "application/json" } },
      )
    } else {
      console.log('isVerified:', isVerified);
      return new Response(
        JSON.stringify({ success: false }),
        { ...corsHeaders, headers: { "Content-Type": "application/json" } },
      )
    }
  } catch (e) {
    console.error('Error verifying transaction:', e);
  }
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


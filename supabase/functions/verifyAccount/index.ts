// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import bs58 from "bs58";
import nearApi from "near-api-js";


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

Deno.serve(async (req) => {

  const { signature, publicKeyStr, uuid, accountId } = await req.json();

  console.log('await req.json():', (await req.json()));

  console.log('signature:', signature);
  console.log('Received publicKeyStr:', publicKeyStr);
  console.log('Received uuid:', uuid);
  console.log('Received accountId:', accountId);

  try {
  const isVerified = await verifySignature(signature, publicKeyStr);

  if (isVerified) {
      console.log('isVerified:', isVerified);
      console.log(`Session created for uuid: ${uuid}, accountId: ${accountId}`);

      return new Response(
        JSON.stringify({ success: true }),
        { headers: { "Content-Type": "application/json" } },
      )
  } else {
      console.log('isVerified:', isVerified);
      return new Response(
        JSON.stringify({ success: false }),
        { headers: { "Content-Type": "application/json" } },
      )
    
  }

  } catch (e) {
    console.error('Error verifying transaction:', e);
  }

  return new Response(
    JSON.stringify("Hello world"),
    { headers: { "Content-Type": "application/json" } },
  )
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/verifyAccount' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

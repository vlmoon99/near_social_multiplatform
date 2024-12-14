// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

import bs58 from "bs58";
import nearApi from "near-api-js";

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
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: "admin_key" } } }
    )

    const { data, error } = await supabase.from('Session').select('*')

    if (error) {
      throw error
    }
    
    console.log('Sucsess  : {} ', data);

  } catch (err) {

    console.log('Error  : {} ', err);

  }

}


Deno.serve(async (req) => {

  const body = (await req.json());

  const { signature, publicKeyStr, uuid, accountId } = body;


  try {
  const isVerified = await verifySignature(signature, publicKeyStr);

  if (isVerified) {
      console.log('isVerified:', isVerified);
      console.log(`Session created for uuid: ${uuid}, accountId: ${accountId}`);

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

  return new Response(
    JSON.stringify("Hello world"),
    { ...corsHeaders, headers: { "Content-Type": "application/json" } },
  )
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


// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient, SupabaseClient } from 'jsr:@supabase/supabase-js@2'

async function sendPostRequest(message: Array<any>) {
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
    console.log(response);

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

console.log("Hello from Functions!")

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


  try {
    const { message } = await req.json(); 
   
    const test  = await sendPostRequest(message);

    return new Response(JSON.stringify(test), {
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


// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { user, session, chat, message , embedding} from "../_shared/schema.ts";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { eq, sql } from "drizzle-orm";
import { createClient } from "jsr:@supabase/supabase-js@2";

const connectionString = Deno.env.get("SUPABASE_DB_URL")!;
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",
};

function createErrorResponse(message: string, status = 400) {
  return new Response(
    JSON.stringify({ error: message }),
    { status, headers: corsHeaders },
  );
}

async function sendPrompt(messages: Array<any>) {
  const url = "http://host.docker.internal:11434/api/chat";
  const data = {
    model: "llama3.2",
    messages,
    stream: false,
  };

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error("AI service returned an error");
    }
    return await response.json();
  } catch (error) {
    console.error("Error sending prompt:", error);
    throw new Error("Failed to communicate with AI service");
  }
}

async function validateSession(db, supabaseClient, token: string) {
  try{
    const { data } = await supabaseClient.auth.getUser(token);
    const supabaseUser = data?.user;
  
    if (!supabaseUser) throw new Error("Invalid or missing user");
  
    const [existingSession] = await db
      .select()
      .from(session)
      .where(eq(session.userId, supabaseUser.id));
  
    if (!existingSession) throw new Error("Session not found. Update your session.");
  
    return { supabaseUser, existingSession };
  
  } catch(error){
    console.error("Error validate session:", error);
    throw new Error("Failed to validate session");
  }
}

async function validateUser(db, accountId: string) {
  try {
    const [existingUser] = await db
    .select()
    .from(user)
    .where(eq(user.id, accountId));

    if (!existingUser) throw new Error("User not found in the system.");
    if (existingUser.isBanned) throw new Error("User is banned.");

    return existingUser;
  } catch (error) {
    console.error("Error validate user:", error);
    throw new Error("Failed to validate user");
  }
}

async function validateChat(db, chatId: string) {
  try{
    const [existingChat] = await db
    .select()
    .from(chat)
    .where(eq(chat.id, chatId));

    if (!existingChat) throw new Error("Chat does not exist.");
    return existingChat;
  } catch (error) {
    console.error("Error validate chat:", error);
    throw new Error("Failed to validate chat");
  }
}

async function textToEmbedding(user_query:string) {
  const url = "http://host.docker.internal:8000/createembeddings";
  const data = {
   "user_query": user_query
  };

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error("Convert service returned an error");
    }
    return await response.json();
  } catch (error) {
    console.error("Error converting prompt:", error);
    throw new Error("Failed to communicate with convert service");
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        ...corsHeaders,
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Authorization, Content-Type",
      },
    });
  }

  try {
    const client = postgres(connectionString, { prepare: false });
    const db = drizzle(client);
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    );

    const authHeader = req.headers.get("Authorization")!;
    const token = authHeader.replace("Bearer ", "");

    const { supabaseUser, existingSession } = await validateSession(db, supabaseClient, token);
    const existingUser = await validateUser(db, existingSession.accountId);

    var jsonBody = await req.json();
    const { chatId, authorId, message: userMessage } = jsonBody;

    if (authorId !== existingSession.accountId) {
      throw new Error("Invalid author ID.");
    }

    const existingChat = await validateChat(db, chatId);

    jsonBody.message.isActive = true;

    const inputQuery = jsonBody.message.text;
    
    jsonBody.message = sql`${userMessage}::jsonb`;

    const [insertedMessage] = await db
      .insert(message)
      .values(jsonBody)
      .returning();

      console.log("inserted user message {}", insertedMessage);

    // convert and store user massage embedding
    const inputEmbedding = await textToEmbedding(inputQuery);

    const userVectorString = JSON.stringify(inputEmbedding.successful);

    const convertUserEmbedding = sql`${userVectorString}::vector`;

    const valueForUserEmbedding = {
      text: inputQuery,
      embedding: convertUserEmbedding
    }

    const [insertedUserEmbedding] = await db
    .insert(embedding)
    .values(valueForUserEmbedding)
    .returning();

    console.log("inserted user embedding {}", insertedUserEmbedding);



    const chatHistory = await db
      .select()
      .from(message)
      .where(eq(message.chatId, chatId));
    let aiResponse;


    // send promt to ai
    if(chatHistory.length > 1) {
      const embeddingIdList = chatHistory.map((msg) => (msg.message.embedding_id));



      const { data, error } = await supabaseClient.rpc('match_embedding', {
        query_embedding: inputEmbedding.successful,
        match_threshold: 0.5,
        match_count: 10,
        ids: embeddingIdList,
      });
    

      if (error) {
        console.error('Error calling match_embedding:', error);
        throw error;
      }

      const contextChatHistory = chatHistory
      .map(item => {
        const matchingEmbedding = data.find(embedding => embedding.id.toString() === item.message.embedding_id);
        if (!matchingEmbedding) return null;

        return {
          role: item.authorId === "ai" ? "assistant" : "user",
          content: matchingEmbedding.text,
        };
      })
      .filter(Boolean);


      const userPromt = [{
        role: "user",
        content: inputQuery}];
      
      const promtToAI = [...contextChatHistory, ...userPromt];

      console.log("promt to Ai {}", promtToAi);

      aiResponse = await sendPrompt(promtToAI);
      } else {
      const promtToAi = [{
        role: "user",
        content: inputQuery}];

      console.log("promt to Ai {}", promtToAi);


      aiResponse = await sendPrompt(promtToAi);

    }

    console.log("AI response {}", aiResponse);

    // convert and store ai massage embedding


    const aiEmbedding = await textToEmbedding(aiResponse.message.content);

    const aiVectorString = JSON.stringify(aiEmbedding.successful);


    const convertAIEmbedding = sql`${aiVectorString}::vector`;

    const valueForAIEmbedding = {
      text: aiResponse.message.content,
      embedding: convertAIEmbedding
    }

    const [insertedAIEmbedding] = await db
    .insert(embedding)
    .values(valueForAIEmbedding)
    .returning();



    const aiBodyRequest = {
      messageType: "text",
      message: { text: aiResponse.message.content, embedding_id: insertedAIEmbedding.id },
      chatId,
      authorId: "ai",
    };

    aiBodyRequest.message = sql`${aiBodyRequest.message}::jsonb`;

    const [insertedAIMessage] = await db
      .insert(message)
      .values(aiBodyRequest)
      .returning();

      console.log("final AI Massage {}", insertedAIMessage);

      const updateMeesegeJSON = {
        text: inputQuery,
        embedding_id: insertedUserEmbedding.id,
        isActive: false,
      }

      const updateUserMassage =  await db
      .update(message)
      .set({
        message: sql`${updateMeesegeJSON}::jsonb`
      })
      .where(eq(message.id, insertedMessage.id))
      .returning();

      console.log("final User Massage {}", updateUserMassage);

    return new Response(
      JSON.stringify({ message_data: insertedAIMessage }),
      { headers: corsHeaders },
    );
  } catch (error) {
    console.error("Error handling request:", error);
    return createErrorResponse(error.message || "Unexpected error");
  }
});

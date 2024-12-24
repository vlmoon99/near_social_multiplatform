CREATE TABLE "User" (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_banned BOOLEAN NOT NULL           
);

CREATE TABLE "Session" (
    user_id UUID PRIMARY KEY,
    account_id TEXT NOT NULL,             
    FOREIGN KEY (account_id) REFERENCES "User"(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),  
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL           
);

CREATE TABLE "Chat" (
    id TEXT PRIMARY KEY,
    metadata JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE "Message" (
    id UUID not null default uuid_generate_v4() primary key,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(), 
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(), 
    message_type TEXT NOT NULL,          
    message JSONB NOT NULL,      
    chat_id TEXT NOT NULL,             
    FOREIGN KEY (chat_id) REFERENCES "Chat"(id) ON DELETE CASCADE,
    author_id TEXT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES "User"(id) ON DELETE CASCADE
);

create table "Embedding" (
  id INT8 serial primary key,
  text TEXT NOT NULL,
  embedding vector(384)
);

-- Indexes

CREATE INDEX idx_chat_metadata_delete ON "Chat" USING GIN ((metadata->'delete'));

CREATE INDEX idx_chat_metadata_participants ON "Chat" USING GIN ((metadata->'participants'));

CREATE INDEX idx_chat_pub_keys ON "Chat" USING GIN ((metadata->'pub_keys'));


CREATE INDEX idx_message_content ON "Message" USING GIN (message);

CREATE INDEX idx_message_author ON "Message" (author_id);

CREATE INDEX idx_message_chat ON "Message" (chat_id);

CREATE INDEX idx_session_account ON "Session" (account_id);



-- Enable RLS

alter table "User" enable row level security;
alter table "Chat" enable row level security;
alter table "Message" enable row level security;
alter table "Session" enable row level security;



-- Functions Start


-- Check if the user has active session

CREATE OR REPLACE FUNCTION private.has_active_session()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM "Session"
        WHERE user_id = (SELECT auth.uid())
        AND is_active = true
    );
END;
$$;

-- Check if the user has active session and he inside the chat which he want to create


CREATE OR REPLACE FUNCTION public.is_user_participant_in_chat(metadata JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  accountId TEXT; 
  isActiveSession BOOLEAN; 
  deleteStatus JSONB;
BEGIN
  SELECT account_id, is_active
  INTO accountId, isActiveSession
  FROM "Session"
  WHERE user_id = (SELECT auth.uid())
  LIMIT 1;

  IF NOT FOUND OR NOT isActiveSession THEN
    RAISE NOTICE 'No active session found or session inactive.';
    RETURN FALSE;
  END IF;


  deleteStatus := metadata->'delete';

  IF deleteStatus ? accountId AND deleteStatus->>accountId = 'true' THEN
    RETURN FALSE;
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(metadata->'participants') AS participant
    WHERE participant = accountId
  );
END;
$$;


CREATE OR REPLACE FUNCTION public.is_user_can_see_the_message(message JSONB, chat_id TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  accountId TEXT;
  authorId TEXT;
  isActiveSession BOOLEAN; 
  isParticipant BOOLEAN;
  deleteStatus JSONB;
  chatMetadata JSONB;
BEGIN
  SELECT account_id, is_active
  INTO accountId, isActiveSession
  FROM "Session"
  WHERE user_id = (SELECT auth.uid())
  LIMIT 1;

  IF NOT FOUND OR NOT isActiveSession THEN
    RAISE NOTICE 'No active session found or session inactive.';
    RETURN FALSE;
  END IF;

  SELECT metadata
  INTO chatMetadata
  FROM "Chat"
  WHERE id = chat_id
  LIMIT 1;

  IF chatMetadata IS NULL THEN
    RAISE NOTICE 'No chat by provided chat_id.';
    RETURN FALSE;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(chatMetadata->'participants') AS participant
    WHERE participant = accountId
  ) INTO isParticipant;


  deleteStatus := message->'delete';

  authorId := message->'author_id';

  IF (
    (deleteStatus ? accountId AND deleteStatus->>accountId = 'true')
    OR authorId != accountId
    OR isParticipant = false
  ) THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

END;
$$;

-- Functions END


-- Policies Start

create policy "Enable users to view their own data only."
on "public"."Session" 
for SELECT
to authenticated
using (
  (select auth.uid()) = user_id
);

create policy "Enable users to view their own data only."
on "public"."Session" 
for select using ( (select auth.uid()) = user_id );


create policy "Enable read for authenticated users only"
on "public"."User" for select
to authenticated
using ( true );


CREATE POLICY "Users can view chats they participate in" 
ON "Chat"
FOR SELECT
USING (
  public.is_user_participant_in_chat(metadata)
);


CREATE POLICY "Users can view chats message they participate in" 
ON "Message"
FOR SELECT
USING (
  public.is_user_can_see_the_message(message,chat_id)
);



create policy "Allow listening for broadcasts for authenticated users only"
on "realtime"."messages"
as PERMISSIVE
for SELECT
to authenticated
using (
  realtime.messages.extension = 'broadcast'
);


create policy "Allow listening for broadcasts for authenticated users only"
on "realtime"."messages"
as PERMISSIVE
for SELECT
to authenticated
using (
  realtime.messages.extension = 'broadcast'
);



-- Policies End

--Postgres Func 

create or replace function match_documents (
  query_embedding vector(384),
  match_threshold float,
  match_count int
)
returns table (
  id bigint,
  title text,
  body text,
  similarity float
)
language sql stable
as $$
  select
    Embedding.id,
    Embedding.title,
    Embedding.body,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where 1 - (documents.embedding <=> query_embedding) > match_threshold
  order by (documents.embedding <=> query_embedding) asc
  limit match_count;
$$;

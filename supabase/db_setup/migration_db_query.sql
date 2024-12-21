-- Tables

CREATE TABLE "User" (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_banned BOOLEAN NOT NULL           
);

CREATE TABLE "Session" (
    user_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,            
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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(), 
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(), 
    message_type TEXT NOT NULL,          
    message JSONB NOT NULL,
    chat_id TEXT NOT NULL,             
    FOREIGN KEY (chat_id) REFERENCES "Chat"(id) ON DELETE CASCADE,
    author_id TEXT NOT NULL,             
    FOREIGN KEY (author_id) REFERENCES "User"(id) ON DELETE CASCADE
);

-- Indexes

CREATE INDEX idx_chat_metadata_delete ON "Chat" USING GIN ((metadata->'delete'));

CREATE INDEX idx_chat_metadata_participants ON "Chat" USING GIN ((metadata->'participants'));

CREATE INDEX idx_chat_pub_keys ON "Chat" USING GIN ((metadata->'pub_keys'));

CREATE INDEX idx_chat_metadata ON "Chat" USING (metadata);


CREATE INDEX idx_message_content ON "Message" USING GIN (message);

CREATE INDEX idx_message_author ON "Message" (author_id);

CREATE INDEX idx_message_author ON "Message" (chat_id);

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
BEGIN
  SELECT account_id, is_active
  INTO accountId, isActiveSession
  FROM "Session"
  WHERE user_id = (SELECT auth.uid())
  LIMIT 1;

  RAISE NOTICE 'Account ID: %', accountId;
  RAISE NOTICE 'Is Active Session: %', isActiveSession;

  IF NOT FOUND OR NOT isActiveSession THEN
    RAISE NOTICE 'No active session found or session inactive.';
    RETURN FALSE;
  END IF;

  RAISE NOTICE 'Participants Array: %', metadata->'participants';

  RETURN EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(metadata->'participants') AS participant
    WHERE participant = accountId
  );
END;
$$;



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


-- Functions END


-- Policies Start

create policy "Enable users to view their own data only."
on "public"."Session" 
as RESTRICTIVE
for SELECT
to authenticated
using (
  (select auth.uid()) = user_id
);


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


create policy "Allow listening for broadcasts for authenticated users only"
on "realtime"."messages"
as PERMISSIVE
for SELECT
to authenticated
using (
  realtime.messages.extension = 'broadcast'
);

-- Policies End


-- CREATE POLICY "Users can create chats if they are participants" 
-- ON "Chat"
-- FOR INSERT
-- WITH CHECK (
--   public.is_user_participant_in_chat(metadata)
-- );

-- Test for this policies

-- INSERT INTO "Chat" (id, metadata) 
-- VALUES (
--     '3',
--     '{
--       "chat_type": "public",
--       "participants": ["nearsocialmobile.near", "vlmoon.near"]
--     }'::jsonb
-- );

-- SELECT *
-- FROM "Chat"
-- WHERE EXISTS (
--     SELECT 1
--     FROM jsonb_array_elements_text("Chat".metadata->'participants') AS participant
--     WHERE participant = 'bosmobile.near'
-- );

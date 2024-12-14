-- Tables

CREATE TABLE "User" (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE "Chat" (
    id TEXT PRIMARY KEY,
    metadata JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE "Message" (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(), 
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(), 
    message_type TEXT NOT NULL,          
    message JSONB NOT NULL,              
    author_id TEXT NOT NULL,             
    FOREIGN KEY (author_id) REFERENCES "User"(id) ON DELETE CASCADE
);

CREATE TABLE "Session" (
    id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,            
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),  
    is_active BOOLEAN NOT NULL           
);

-- Indexes

CREATE INDEX idx_chat_metadata ON "Chat" USING GIN (metadata);

CREATE INDEX idx_message_content ON "Message" USING GIN (message);

CREATE INDEX idx_message_author ON "Message" (author_id);

CREATE INDEX idx_session_account ON "Session" (account_id);

CREATE INDEX idx_chat_pub_keys ON "Chat" ((metadata->'pub_keys'));


-- Enable RLS

alter table "User" enable row level security;
alter table "Chat" enable row level security;
alter table "Message" enable row level security;
alter table "Session" enable row level security;


-- Policies

create policy "Users can create a profile."
on "User" for insert
to authenticated
with check ( (select auth.uid()) = user_id );




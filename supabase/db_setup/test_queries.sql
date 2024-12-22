
-- Test for this policies

INSERT INTO "Chat" (id, metadata) 
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
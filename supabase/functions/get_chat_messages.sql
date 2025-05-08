-- Function to get all chat messages between two users
CREATE OR REPLACE FUNCTION get_chat_messages(user_id_1 UUID, user_id_2 UUID)
RETURNS TABLE (
  id UUID,
  sender_id UUID,
  receiver_id UUID,
  message TEXT,
  created_at TIMESTAMPTZ,
  is_read BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    cm.id,
    cm.sender_id,
    cm.receiver_id,
    cm.message,
    cm.created_at,
    cm.is_read
  FROM
    chat_messages cm
  WHERE
    (cm.sender_id = user_id_1 AND cm.receiver_id = user_id_2) OR
    (cm.sender_id = user_id_2 AND cm.receiver_id = user_id_1)
  ORDER BY
    cm.created_at ASC;
END;
$$;

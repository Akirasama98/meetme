-- Function to count unread messages
CREATE OR REPLACE FUNCTION count_unread_messages(user_id_param UUID)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  unread_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO unread_count
  FROM chat_messages
  WHERE receiver_id = user_id_param AND is_read = false;
  
  RETURN unread_count;
END;
$$;

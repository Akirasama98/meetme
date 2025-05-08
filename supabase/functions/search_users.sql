-- Function to search for users with optional filtering
CREATE OR REPLACE FUNCTION search_users(
  search_query TEXT DEFAULT NULL,
  role_filter TEXT DEFAULT NULL,
  exclude_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  role TEXT,
  profile_image_url TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.name,
    u.role,
    CASE
      WHEN u.role = 'dosen' THEN d.profile_image_url
      WHEN u.role = 'mahasiswa' THEN m.profile_image_url
      ELSE NULL
    END as profile_image_url
  FROM 
    users u
  LEFT JOIN 
    dosen d ON u.id = d.user_id
  LEFT JOIN 
    mahasiswa m ON u.id = m.user_id
  WHERE 
    (search_query IS NULL OR u.name ILIKE '%' || search_query || '%')
    AND (role_filter IS NULL OR u.role = role_filter)
    AND (exclude_user_id IS NULL OR u.id != exclude_user_id)
  ORDER BY 
    u.name ASC;
END;
$$;

-- Function to get chat contacts for a user
CREATE OR REPLACE FUNCTION get_chat_contacts(user_id_param UUID)
RETURNS TABLE (
  id UUID,
  name TEXT,
  role TEXT,
  avatar TEXT,
  last_message TEXT,
  last_message_time TIMESTAMPTZ,
  has_unread_messages BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  WITH last_messages AS (
    SELECT DISTINCT ON (
      CASE
        WHEN cm.sender_id = user_id_param THEN cm.receiver_id
        ELSE cm.sender_id
      END
    )
      CASE
        WHEN cm.sender_id = user_id_param THEN cm.receiver_id
        ELSE cm.sender_id
      END as contact_id,
      cm.message as last_message,
      cm.created_at as last_message_time,
      CASE
        WHEN cm.receiver_id = user_id_param AND cm.is_read = false THEN true
        ELSE false
      END as has_unread_messages
    FROM
      chat_messages cm
    WHERE
      cm.sender_id = user_id_param OR cm.receiver_id = user_id_param
    ORDER BY
      contact_id,
      cm.created_at DESC
  )
  SELECT
    u.id,
    u.name,
    u.role,
    CASE
      WHEN u.role = 'dosen' THEN d.profile_image_url
      WHEN u.role = 'mahasiswa' THEN m.profile_image_url
      ELSE NULL
    END as avatar,
    lm.last_message,
    lm.last_message_time,
    lm.has_unread_messages
  FROM
    last_messages lm
  JOIN
    users u ON lm.contact_id = u.id
  LEFT JOIN
    dosen d ON u.id = d.user_id
  LEFT JOIN
    mahasiswa m ON u.id = m.user_id
  ORDER BY
    lm.last_message_time DESC;
END;
$$;

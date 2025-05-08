-- Trigger function to automatically update sender information
CREATE OR REPLACE FUNCTION update_sender_info()
RETURNS TRIGGER AS $$
DECLARE
  sender_info RECORD;
BEGIN
  -- Get sender information
  SELECT 
    u.role,
    CASE
      WHEN u.role = 'dosen' THEN d.nama
      WHEN u.role = 'mahasiswa' THEN m.nama
      ELSE u.email
    END as name,
    CASE
      WHEN u.role = 'dosen' THEN d.profile_image_url
      WHEN u.role = 'mahasiswa' THEN m.profile_image_url
      ELSE NULL
    END as avatar
  INTO sender_info
  FROM 
    users u
  LEFT JOIN 
    dosen d ON u.id = d.user_id
  LEFT JOIN 
    mahasiswa m ON u.id = m.user_id
  WHERE 
    u.id = NEW.sender_id;
  
  -- Update sender information
  NEW.sender_name := sender_info.name;
  NEW.sender_role := sender_info.role;
  NEW.sender_avatar := sender_info.avatar;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS before_insert_chat_message ON chat_messages;
CREATE TRIGGER before_insert_chat_message
BEFORE INSERT ON chat_messages
FOR EACH ROW
EXECUTE FUNCTION update_sender_info();

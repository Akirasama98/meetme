-- Function to search for users with optional filtering (improved version)
CREATE OR REPLACE FUNCTION search_users(
  search_query TEXT DEFAULT NULL,
  role_filter TEXT DEFAULT NULL,
  exclude_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  role TEXT,
  avatar TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    CASE
      WHEN u.role = 'dosen' THEN COALESCE(d.nama, u.email)
      WHEN u.role = 'mahasiswa' THEN COALESCE(m.nama, u.email)
      ELSE u.email
    END as name,
    u.role,
    CASE
      WHEN u.role = 'dosen' THEN d.profile_image_url
      WHEN u.role = 'mahasiswa' THEN m.profile_image_url
      ELSE NULL
    END as avatar
  FROM 
    users u
  LEFT JOIN 
    dosen d ON u.id = d.user_id
  LEFT JOIN 
    mahasiswa m ON u.id = m.user_id
  WHERE 
    (search_query IS NULL OR 
     (u.role = 'dosen' AND d.nama ILIKE '%' || search_query || '%') OR
     (u.role = 'mahasiswa' AND m.nama ILIKE '%' || search_query || '%') OR
     u.email ILIKE '%' || search_query || '%')
    AND (role_filter IS NULL OR u.role = role_filter)
    AND (exclude_user_id IS NULL OR u.id != exclude_user_id)
  ORDER BY 
    name ASC;
END;
$$;

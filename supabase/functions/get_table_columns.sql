-- Function to get column information for a table
CREATE OR REPLACE FUNCTION get_table_columns(table_name TEXT)
RETURNS TABLE (
  column_name TEXT,
  data_type TEXT,
  is_nullable BOOLEAN
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.column_name::TEXT,
    c.data_type::TEXT,
    (c.is_nullable = 'YES')::BOOLEAN
  FROM 
    information_schema.columns c
  WHERE 
    c.table_name = table_name
  ORDER BY 
    c.ordinal_position;
END;
$$;

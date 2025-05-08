-- Buat tabel chat_messages untuk menyimpan pesan chat
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  receiver_id UUID NOT NULL REFERENCES auth.users(id),
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  sender_name TEXT,
  sender_role TEXT,
  sender_avatar TEXT
);

-- Buat indeks untuk meningkatkan performa query
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_receiver_id ON chat_messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);

-- Aktifkan Row Level Security (RLS)
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Buat kebijakan untuk membaca pesan (hanya pengirim dan penerima yang bisa membaca)
CREATE POLICY "Users can read their own messages" ON chat_messages
  FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

-- Buat kebijakan untuk menulis pesan (hanya pengirim yang bisa menulis)
CREATE POLICY "Users can insert their own messages" ON chat_messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id
  );

-- Buat kebijakan untuk mengupdate pesan (hanya penerima yang bisa mengupdate status baca)
CREATE POLICY "Users can update read status of messages sent to them" ON chat_messages
  FOR UPDATE USING (
    auth.uid() = receiver_id
  );

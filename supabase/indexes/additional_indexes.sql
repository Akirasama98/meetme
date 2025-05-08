-- Add additional indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_dosen_user_id ON dosen(user_id);
CREATE INDEX IF NOT EXISTS idx_mahasiswa_user_id ON mahasiswa(user_id);
CREATE INDEX IF NOT EXISTS idx_dosen_nama ON dosen(nama);
CREATE INDEX IF NOT EXISTS idx_mahasiswa_nama ON mahasiswa(nama);

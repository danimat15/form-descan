-- ==========================================
-- SQL Query to Insert a Test User
-- ==========================================
-- Email: test@bps.go.id
-- Password: password123
-- (The password below is already hashed using bcrypt so the backend can verify it correctly)

-- OPTION A: If you are using the custom schema "form-descan"
INSERT INTO "form-descan"."users" (id, email, password, desa, kecamatan, kabupaten)
VALUES (
  'test-user-uuid-12345', 
  'test@bps.go.id', 
  '$2a$10$U8X.omhr1fpHUYvrxynXgu3iYvOT67ccZYdgl/.MsGgEeF6ab3l8G', 
  'Desa Contoh', 
  'Kecamatan Contoh', 
  'Kabupaten Contoh'
)
ON CONFLICT (email) DO UPDATE SET 
  password = EXCLUDED.password,
  desa = EXCLUDED.desa,
  kecamatan = EXCLUDED.kecamatan,
  kabupaten = EXCLUDED.kabupaten;


-- OPTION B: If you are using the standard public schema (matches default backend code)
INSERT INTO public."form-descan-users" (id, email, password, desa, kecamatan, kabupaten)
VALUES (
  'test-user-uuid-12345', 
  'test@bps.go.id', 
  '$2a$10$U8X.omhr1fpHUYvrxynXgu3iYvOT67ccZYdgl/.MsGgEeF6ab3l8G', 
  'Desa Contoh', 
  'Kecamatan Contoh', 
  'Kabupaten Contoh'
)
ON CONFLICT (email) DO UPDATE SET 
  password = EXCLUDED.password,
  desa = EXCLUDED.desa,
  kecamatan = EXCLUDED.kecamatan,
  kabupaten = EXCLUDED.kabupaten;

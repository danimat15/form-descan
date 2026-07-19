# 🛠️ Panduan Development & Menjalankan Aplikasi (Lokal & Android Emulator)

Dokumen ini berisi panduan lengkap langkah-demi-langkah untuk menyiapkan **Database PostgreSQL**, sinkronisasi menggunakan **Drizzle ORM**, menjalankan **Backend API**, dan menguji aplikasi **Flutter** menggunakan **Android Emulator**.

---

## 🏗️ 1. Menjalankan Database PostgreSQL

Untuk menjalankan PostgreSQL secara lokal di Windows, Anda bisa memilih salah satu dari dua metode di bawah ini:

### Pilihan A: Menggunakan Docker (Direkomendasikan & Paling Praktis)
Jika Anda sudah menginstal Docker Desktop di laptop Anda:
1. Buka Terminal/PowerShell.
2. Jalankan perintah berikut untuk mengunduh dan menjalankan container PostgreSQL dengan konfigurasi yang sesuai dengan berkas `.env` Anda:
   ```bash
   docker run --name pg-descan -e POSTGRES_PASSWORD=descan2026 -e POSTGRES_DB=form_descan -p 5432:5432 -d postgres
   ```
3. Database PostgreSQL Anda sudah aktif dan siap digunakan.

### Pilihan B: Menggunakan PostgreSQL Installer (Windows Service)
Jika Anda menginstal PostgreSQL menggunakan installer resmi ([EnterpriseDB](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)):
1. Pastikan Service PostgreSQL sudah berjalan. Buka **Services** (`Services.msc` di Windows Run) -> cari `postgresql-x64-xx` -> pastikan statusnya **Running**. 
   *Atau jalankan via Command Prompt (Administrator):*
   ```cmd
   net start postgresql-x64-16
   ```
2. Hubungkan ke PostgreSQL melalui terminal atau pgAdmin dan buat database dengan nama `form_descan`.
   *Contoh via command-line (psql):*
   ```bash
   psql -U postgres -h localhost -c "CREATE DATABASE form_descan;"
   ```
   *(Gunakan password admin PostgreSQL yang Anda tentukan saat instalasi, misal `descan2026`)*

---

## ⚡ 2. Konfigurasi Backend & Drizzle Service

Setelah PostgreSQL berjalan, saatnya mengonfigurasi backend dan menyinkronkan skema tabel database menggunakan **Drizzle Kit**.

### Langkah A: Konfigurasi Berkas `.env`
Pastikan berkas `.env` di dalam folder [backend](file:///d:/Hamdani/form-descan/backend/.env) sudah sesuai:
```env
DATABASE_URL=postgresql://postgres:descan2026@localhost:5432/form_descan
JWT_SECRET=b393264a4e07304763b0e8b43e820f5647f4780b61a529fada633d45e071ddb1
PORT=3000
```

### Langkah B: Jalankan Drizzle Service
Buka terminal baru, arahkan ke direktori backend, dan instal dependensi jika belum:
```bash
cd d:\Hamdani\form-descan\backend
npm install
```

Jalankan perintah berikut secara berurutan:
1. **Generate Migrasi**: Membuat berkas migrasi SQL dari berkas skema [schema.ts](file:///d:/Hamdani/form-descan/backend/src/db/schema.ts):
   ```bash
   npm run db:generate
   ```
2. **Push Skema ke Database**: Mengirim skema tabel langsung ke database PostgreSQL lokal Anda:
   ```bash
   npm run db:push
   ```
3. **Buka Drizzle Studio (Drizzle Web)**: Untuk melihat, menambah, atau mengedit data database melalui antarmuka web (GUI):
   ```bash
   npm run db:studio
   ```
   *Atau jika ingin menjalankan langsung:*
   ```bash
   npx drizzle-kit studio
   ```
   *Drizzle Studio akan berjalan di [http://localhost:4983](http://localhost:4983) atau port yang ditampilkan di terminal.*

### Langkah C: Menambahkan User Uji Coba (Test User)
Untuk masuk ke aplikasi, Anda memerlukan akun petugas di database. Anda bisa menambahkannya dengan tiga cara berikut:
- **Cara 1 (Rekomendasi - Script Seed)**: Jalankan perintah berikut di direktori backend untuk membuat user `test@bps.go.id` secara otomatis:
  ```bash
  npm run db:seed
  ```
- **Cara 2 (Drizzle Studio)**: Buka Drizzle Studio di browser, pilih tabel `form-descan-users`, lalu tambahkan baris baru dengan email `test@bps.go.id` dan password terenkripsi bcrypt berikut: `$2a$10$U8X.omhr1fpHUYvrxynXgu3iYvOT67ccZYdgl/.MsGgEeF6ab3l8G` (itu adalah enkripsi dari teks `password123`).
- **Cara 3 (SQL Query)**: Jalankan query dari berkas [insert_test_user.sql](file:///d:/Hamdani/form-descan/insert_test_user.sql) ke database Anda menggunakan pgAdmin atau tool database lainnya.

---

## 🚀 3. Menjalankan Backend API

Jalankan backend server agar aplikasi Flutter dapat melakukan request data:

1. Pastikan Anda berada di direktori `backend`:
   ```bash
   cd d:\Hamdani\form-descan\backend
   ```
2. Jalankan server dalam mode development:
   ```bash
   npm run dev
   ```
   *Server akan berjalan di port `3000` (`http://localhost:3000`).*
3. **Uji Server**: Buka browser Anda dan akses [http://localhost:3000/health](http://localhost:3000/health). Jika muncul respons `{"status":"ok",...}`, backend Anda sudah aktif dan terhubung ke PostgreSQL dengan sukses!

---

## 📱 4. Menjalankan Aplikasi Flutter di Android Emulator

Agar Android Emulator dapat berkomunikasi dengan backend yang berjalan di komputer host (laptop Anda):

### Langkah A: Pemahaman IP Android Emulator
- Di dalam Android Emulator, kata kunci `localhost` merujuk ke emulator itu sendiri, bukan ke laptop Anda.
- Untuk mengakses localhost laptop Anda dari dalam emulator, gunakan IP khusus: **`http://10.0.2.2:3000`**.
- Kami telah memperbarui kode di [auth_service.dart](file:///d:/Hamdani/form-descan/lib/services/auth_service.dart#L12-L24) agar secara otomatis mendeteksi perangkat Android dan mengarahkannya ke `http://10.0.2.2:3000` secara default.

### Langkah B: Jalankan Emulator Android
1. Buka **Android Studio** -> **Device Manager** -> Jalankan salah satu Virtual Device (Emulator) Anda.
2. Atau jalankan emulator melalui VS Code (klik status bar bagian bawah kanan, pilih emulator yang tersedia).

### Langkah C: Jalankan Aplikasi Flutter
1. Buka terminal baru dan masuk to root folder proyek:
   ```bash
   cd d:\Hamdani\form-descan
   ```
2. Pastikan emulator Anda terdeteksi dengan perintah:
   ```bash
   flutter devices
   ```
3. Jalankan aplikasi Flutter:
   ```bash
   flutter run --no-enable-impeller
   ```
   *Catatan: Menggunakan parameter `--no-enable-impeller` sangat penting pada Android Emulator untuk menghindari crash rendering grafis (Impeller OpenGLES crash) saat aplikasi baru dibuka.*
   
   *(Jika ada beberapa perangkat yang aktif, gunakan target spesifik emulator Anda, misalnya: `flutter run -d emulator-5554 --no-enable-impeller`)*
4. Aplikasi akan terinstal dan terbuka di Emulator Android Anda tanpa mengalami crash.
5. **Login Uji Coba**:
   - **Email**: `test@bps.go.id`
   - **Password**: `password123`

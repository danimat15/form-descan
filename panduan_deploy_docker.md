# 🐳 Panduan Deploy Docker untuk Pemula (Form Descan)

Panduan ini dibuat khusus untuk programmer pemula agar dapat mendeploy **Backend API (Node.js)** dan **Database (PostgreSQL)** menggunakan **Docker Compose** dengan mudah di Drive `F:\`.

---

## 💡 Konsep Dasar Docker (Wajib Dibaca Pemula!)

### ❓ *"Apakah saya harus menginstall Node.js & PostgreSQL dulu di laptop/server saya?"*
👉 **TIDAK PERLU!** Anda **hanya perlu menginstall Docker Desktop**. 
Docker bekerja seperti "kontainer terisolasi" (seperti miniatur komputer di dalam komputer Anda). Ketika Anda menjalankan perintah Docker Compose, Docker akan **otomatis mengunduh (pull)** image Node.js dan PostgreSQL dari internet, lalu memasangnya di dalam kontainer terisolasi tersebut tanpa mengotori sistem Windows Anda.

### ❓ *"Apakah kodingannya harus di-clone dulu?"*
👉 **YA, BENAR!** Kode proyek harus berada di laptop/server Anda terlebih dahulu (bisa lewat `git clone` atau copy folder manual) agar Docker dapat membaca file konfigurasi `Dockerfile` dan `docker-compose.yml` yang ada di dalam folder `backend`.

---

## 📁 Struktur Folder yang Disarankan di Drive `F:\`

Berikut susunan folder yang direkomendasikan di drive `F:\` untuk proyek Anda kedepannya:

```text
F:\ (Drive F Anda)
└── projects\                      <-- Folder utama untuk menampung semua project Anda
    └── form-descan\               <-- Folder project hasil git clone / copy
        ├── backend\               <-- [FOKUS DEPLOY DOCKER DI SINI]
        │   ├── Dockerfile         <-- Resep untuk build Node.js backend
        │   ├── docker-compose.yml <-- Konfigurasi Node.js + PostgreSQL + Migrasi DB
        │   ├── package.json
        │   ├── src/
        │   └── ...
        ├── lib/                   <-- Kode Frontend Flutter (HP)
        ├── pubspec.yaml
        └── panduan_deploy_docker.md
```

---

## 📋 Prasyarat Komputer/Server
Sebelum memulai deploy, pastikan hal berikut sudah siap di komputer Anda:
1. **Docker Desktop** sudah terinstall dan **sedang berjalan** (pastikan ikon paus 🐳 di pojok kanan bawah taskbar Windows Anda sudah aktif).
   - [Download Docker Desktop untuk Windows](https://www.docker.com/products/docker-desktop/)
2. **Git for Windows** (opsional, jika ingin meng-clone dari GitHub/GitLab).

---

## 🚀 Langkah demi Langkah Deployment

### Langkah 1: Pindah ke Drive `F:\` dan Clone Project

1. Buka **Command Prompt (CMD)** atau **PowerShell** atau **Terminal di VS Code**.
2. Ketik perintah berikut untuk pindah ke drive `F:\` dan membuat folder `projects`:
   ```powershell
   cd F:\
   mkdir projects
   cd F:\projects
   ```
3. Clone repository project Anda (atau copy folder project Anda ke `F:\projects\form-descan`):
   ```powershell
   git clone <URL_REPOSITORY_ANDA> form-descan
   ```
4. Masuk ke folder `backend`:
   ```powershell
   cd F:\projects\form-descan\backend
   ```
   *(Pastikan terminal Anda sekarang berada di jalur `F:\projects\form-descan\backend`)*

---

### Langkah 2: Jalankan Docker Compose (Deploy Backend & Postgres)

Di dalam folder `F:\projects\form-descan\backend`, jalankan perintah berikut:

```bash
docker compose up -d --build
```

#### 🔄 Apa yang terjadi secara otomatis saat perintah ini dijalankan?
1. 📥 **Download Postgres**: Docker mengunduh image PostgreSQL 16 Alpine resmi dari internet.
2. 🏗️ **Build Backend Node.js**: Docker membaca `Dockerfile` dan memasang dependensi backend Node.js.
3. ⏳ **Healthcheck DB**: Docker menunggu sampai PostgreSQL benar-benar siap menerima koneksi.
4. 🗄️ **Migrasi Skema DB**: Perintah `npm run db:push` otomatis berjalan di container untuk membuat tabel-tabel di Postgres.
5. 🌱 **Seeding Data Awal**: Perintah `npm run db:seed` otomatis berjalan untuk memasukkan akun petugas uji coba (`test@bps.go.id`).
6. 🚀 **Server Backend Aktif**: Server API Express berjalan di port `3000`.

---

### Langkah 3: Verifikasi Deployment

1. **Cek Status Container:**
   ```bash
   docker compose ps
   ```
   *Pastikan status `descan-postgres-db` adalah **(healthy)** dan `descan-backend-api` berstatus **Up / running**.*

2. **Cek Log Backend (jika ingin melihat aktivitas server):**
   ```bash
   docker compose logs -f web
   ```
   *(Tekan `Ctrl + C` untuk keluar dari log).*

3. **Uji Server dari Browser:**
   Buka browser di laptop Anda dan akses: `http://localhost:3000/health`
   Jika berhasil, akan muncul balasan:
   ```json
   {"status":"ok","timestamp":"..."}
   ```

---

### Langkah 4: Seeding Data Wilayah Sangihe (Opsional tapi Disarankan)

Untuk memasukkan data wilayah dari CSV ke dalam database PostgreSQL yang ada di dalam Docker:

Jalankan perintah ini dari folder `F:\projects\form-descan\backend`:
```bash
docker compose exec web npm run db:seed-wilayah
```

---

### Langkah 5: Konfigurasi Subdomain & Tunneling (`descan.mentorku.online`)

Agar proyek **Form Descan** rapi dan tidak mengganggu halaman utama domain `mentorku.online`, kita akan membuat subdomain khusus: **`descan.mentorku.online`**.

---

#### 🌐 Panduan Membuat Subdomain di Cloudflare Tunnel (Langkah demi Langkah)

1. **Buka Cloudflare Dashboard:**
   - Login ke [dash.cloudflare.com](https://dash.cloudflare.com)
   - Pilih menu **Zero Trust** di menu sebelah kiri.

2. **Masuk ke Pengaturan Tunnel:**
   - Pilih **Networks** ➡️ **Tunnels**.
   - Pilih nama Tunnel yang sedang aktif di komputer/server Anda (misal `my-server-tunnel`).
   - Klik tombol **Edit** di sebelah kanan.

3. **Tambah Hostname Subdomain Baru:**
   - Pilih tab **Public Hostname**.
   - Klik tombol **Add a public hostname**.

4. **Isi Formulir Konfigurasi Subdomain:**
   - **Subdomain:** Ketik `descan`
   - **Domain:** Pilih `mentorku.online`
   - **Path:** Biarkan kosong
   - **Service Type:** Pilih `HTTP`
   - **URL:** Ketik `localhost:3000` *(atau `localhost:5000` jika Anda mengubah port lokal)*
   - Klik **Save Hostname**.

   *(Cloudflare akan secara otomatis menambahkan CNAME record `descan.mentorku.online` ke DNS domain Anda!)*

---

#### 🔄 Bisakah Port Backend Diubah?
**Bisa!** Jika port `3000` di komputer Anda terpakai oleh aplikasi lain:

1. Buka file [`docker-compose.yml`](file:///d:/Hamdani/form-descan/backend/docker-compose.yml) di folder `backend`.
2. Ubah pemetaan port pada bagian `web`:
   ```yaml
       ports:
         - "5000:3000"  # Format: "PORT_LAPTOP:PORT_CONTAINER"
   ```
3. Restart Docker Compose: `docker compose up -d`
4. Di Cloudflare Dashboard (pada langkah 4 di atas), ubah **URL Service** menjadi `localhost:5000`.

---

### Langkah 6: Pengujian & Hubungkan ke Aplikasi Flutter

#### 1. Uji Subdomain di Browser:
Buka browser di laptop atau HP Anda dan akses:
👉 **`https://descan.mentorku.online/health`**  
Jika berhasil, akan muncul respon JSON: `{"status":"ok","timestamp":"..."}`

#### 2. Masukkan URL Subdomain di Aplikasi Flutter:
1. Buka aplikasi **Form Descan** di HP / Emulator Android.
2. Di halaman **Login**, klik **Ikon Gerigi ⚙️ (Settings)** di pojok kanan atas.
3. Masukkan URL Subdomain Anda:
   👉 **`https://descan.mentorku.online`**
4. Klik **Simpan**.
5. Coba login dengan akun petugas uji coba:
   - **Email**: `test@bps.go.id`
   - **Password**: `password123`
6. Selamat! Aplikasi Flutter Anda telah sukses terhubung ke Backend & PostgreSQL melalui subdomain publik **`https://descan.mentorku.online`**!

---

## 🛠️ Perintah-Perintah Penting Docker (Cheatsheet Pemula)

| Kebutuhan | Perintah (Jalankan di `F:\projects\form-descan\backend`) |
|---|---|
| **Menyalakan Backend & DB** | `docker compose up -d` |
| **Rebuild jika ada perubahan kode Node.js** | `docker compose up -d --build` |
| **Mematikan Backend & DB** | `docker compose down` |
| **Mematikan & Reset Ulang Semua Data Database** | `docker compose down -v` |
| **Melihat Log Backend** | `docker compose logs -f web` |
| **Melihat Log Database** | `docker compose logs -f db` |
| **Masuk ke CLI Postgres DB** | `docker compose exec db psql -U postgres -d form_descan` |


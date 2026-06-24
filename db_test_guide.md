# Panduan Menjalankan Backend & Menguji Koneksi Database (MySQL)

Dokumen ini berisi panduan langkah-demi-langkah bagi **Hamdani** untuk menjalankan aplikasi backend secara lokal dan menguji koneksi ke database cPanel MySQL langsung melalui terminal Anda.

---

## 💻 1. Persiapan Awal di Terminal
Buka terminal Anda (CMD / PowerShell / Git Bash) lalu arahkan ke direktori backend:
```bash
cd d:\Hamdani\form-descan\backend
```

---

## ⚡ 2. Menguji Koneksi Database (MySQL)
Kami telah menyediakan script pengujian koneksi database otomatis. Script ini akan membaca konfigurasi `DATABASE_URL` dari file `.env` Anda dan mencoba mengeksekusi perintah tes ke server MySQL cPanel Anda.

> [!IMPORTANT]
> **Catatan untuk Server cPanel (Bypass LVE Limits)**:
> cPanel membatasi virtual address space WebAssembly (yang digunakan oleh tool `tsx` untuk memproses TypeScript langsung). 
> Oleh karena itu, di cPanel Anda harus selalu **melakukan build terlebih dahulu** kemudian menjalankan hasil JavaScript-nya:
> 1. Kompilasi TypeScript: `npm run build`
> 2. Jalankan Uji Koneksi: `npm run db:test` (ini akan menjalankan `node dist/test-db.js` yang ringan tanpa WebAssembly).

Jalankan perintah berikut di terminal Anda:
```bash
npm run db:test
```

### Hasil yang Diharapkan:
*   **Jika Sukses**:
    ```text
    =============================================
    Testing connection to MySQL Database...
    DATABASE_URL: mysql://nlabsang_hamdani:Hamdani_7103@localhost:3306/nlabsan_descan
    =============================================
    ✓ Database connection successful!
    Result: [ { connection_test: 1 } ]
    =============================================
    ```
*   **Jika Gagal**: Terminal akan menampilkan pesan error koneksi secara rinci (misalnya `ECONNREFUSED` atau `ER_ACCESS_DENIED_ERROR`). Anda dapat menggunakannya sebagai acuan untuk mencocokkan kredensial database di berkas `.env` Anda.

---

## 🚀 3. Menjalankan Backend API Secara Lokal
Untuk menjalankan server API backend secara lokal di komputer Anda demi keperluan testing aplikasi atau debugging:

1.  **Jalankan Server Development**:
    ```bash
    npm run dev
    ```
    Server akan berjalan di port `3000` (atau port yang didefinisikan di `.env` Anda).
2.  **Cek Status Server**:
    Buka peramban (browser) Anda dan akses alamat:
    [http://localhost:3000/health](http://localhost:3000/health)
    Jika berhasil, Anda akan melihat respons JSON seperti:
    ```json
    { "status": "ok", "timestamp": "2026-05-31T..." }
    ```

---

## 🗳️ 4. Menjalankan Sinkronisasi Skema Database (Drizzle Kit Push)
Jika Anda melakukan perubahan pada file [schema.ts](file:///d:/Hamdani/form-descan/backend/src/db/schema.ts) dan ingin langsung menerapkannya ke tabel database MySQL, jalankan perintah berikut:
```bash
npm run db:push
```
*Catatan: Perintah ini memerlukan koneksi internet aktif karena akan langsung menghubungi server database MySQL yang terdaftar di berkas `.env` Anda.*

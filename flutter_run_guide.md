# Panduan Menjalankan & Memasang Aplikasi Flutter (Sensus Ekonomi 2026)

Dokumen ini berisi panduan langkah-demi-langkah bagi **Hamdani** untuk menjalankan, menguji, dan memasang aplikasi Flutter **Form Descan** pada perangkat tablet Android Anda (`HEY3 W00`) atau simulator/perangkat lainnya.

---

## 📋 1. Persiapan Awal di Terminal
Buka terminal Anda (CMD / PowerShell / Git Bash) lalu arahkan ke direktori root proyek Flutter Anda:
```bash
cd d:\Hamdani\form-descan
```

---

## 📱 2. Memeriksa Perangkat yang Terhubung
Pastikan tablet Anda telah terhubung ke komputer menggunakan kabel data dan fitur **USB Debugging** pada opsi pengembang (Developer Options) tablet sudah aktif.

Untuk memverifikasi perangkat yang terdeteksi oleh Flutter, jalankan perintah:
```bash
flutter devices
```
### Hasil yang Diharapkan:
Anda akan melihat daftar perangkat, salah satunya adalah tablet Anda:
```text
Found 4 connected devices:
  HEY3 W00 (mobile) • ARMVUN5A23H08599 • android-arm64  • Android 16 (API 36)
```

---

## ⚡ 3. Menjalankan Aplikasi Secara Langsung (Debug Mode)
Untuk menjalankan aplikasi secara langsung dengan fitur **Hot Reload** (perubahan kode langsung terlihat di tablet tanpa install ulang):

1.  Jalankan perintah berikut:
    ```bash
    flutter run -d ARMVUN5A23H08599
    ```
    *(Ganti `ARMVUN5A23H08599` dengan Device ID tablet Anda jika berubah).*
2.  Tunggu proses kompilasi hingga aplikasi terbuka secara otomatis di layar tablet Anda.
3.  Tekan **`r`** pada terminal untuk melakukan Hot Reload cepat setelah Anda mengubah kode.

---

## 📦 4. Membangun Berkas Aplikasi (Build APK)
Jika Anda ingin menghasilkan berkas instalasi mentah (APK) yang siap dibagikan atau dipasang manual:

```bash
flutter build apk --debug
```
*   **Lokasi File Hasil Build**: `build\app\outputs\flutter-apk\app-debug.apk`

---

## 📲 5. Memasang (Install) APK Langsung ke Tablet
Jika Anda sudah mem-build APK di atas dan ingin memasangnya langsung ke tablet tanpa menjalankan server debugging:

Jalankan perintah install berikut:
```bash
flutter install -d ARMVUN5A23H08599 --debug
```
Perintah ini akan secara otomatis menghapus (uninstall) versi lama aplikasi di tablet Anda dan memasang versi terbaru dengan logo yang diperbarui.

---

## 🛠️ 6. Troubleshooting (Pemecahan Masalah)
*   **Perangkat Tidak Terdeteksi**: 
    Cabut dan colokkan kembali kabel USB tablet Anda. Pastikan mode koneksi USB diatur sebagai **Transfer File (MTP)**, bukan sekadar mengisi daya (Charging Only).
*   **Masalah Gradle / Build Error**:
    Jika proses build macet atau terjadi error cache Gradle, bersihkan proyek Anda terlebih dahulu lalu jalankan kembali:
    ```bash
    flutter clean
    flutter pub get
    ```

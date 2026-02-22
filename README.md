# Jejak Faa 🗺️

**Jurnal Pendakian *Offline-First* dengan Sinkronisasi Cloud.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-blueviolet?logo=riverpod)](https://riverpod.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green?logo=supabase)](https://supabase.io)
[![Drift](https://img.shields.io/badge/Drift-Offline_Database-orange)](https://drift.simonbinder.eu)

---

### Daftar Isi
* [Tentang Proyek](#-tentang-proyek)
* [Tangkapan Layar](#-tangkapan-layar)
* [Fitur Utama](#-fitur-utama)
* [Tumpukan Teknologi](#-tumpukan-teknologi)
* [Arsitektur](#-arsitektur)
* [Memulai (Instalasi)](#-memulai)
* [Rencana Pengembangan](#-rencana-pengembangan)

---

## 🌎 Tentang Proyek

**Jejak Faa** adalah aplikasi *mobile* jurnal pendakian yang dibuat dengan Flutter. Aplikasi ini dirancang sebagai alat bantu pendaki yang **andal di area tanpa sinyal**.

Fokus utama proyek ini adalah fungsionalitas **offline-first** yang kuat. Pelacakan GPS, penambahan *waypoint* (POI), dan pencatatan data disimpan dengan aman di database lokal (Drift). Saat perangkat kembali mendapatkan koneksi internet, semua data akan secara otomatis tersinkronisasi ke *backend* (Supabase).

---

## 📸 Tangkapan Layar

| Beranda | Halaman Peta (Tracking) |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/7b4e5a7d-2d98-417e-a04e-55985412b086" width="250"> | <img src="https://github.com/user-attachments/assets/108b688a-7d75-422b-9c55-f8ce8bbe65a8" width="250"> |
| **Halaman Detail Jejak** | **Halaman Prediksi Cuaca** |
| <img src="https://github.com/user-attachments/assets/7a302198-8bc0-4e20-9ac3-8638685af910" width="250"> | <img src="https://github.com/user-attachments/assets/9e86b719-f9ff-4882-9a61-66e1bf3e184c" width="250"> |

---

## ✨ Fitur Utama

Aplikasi ini menggabungkan fungsionalitas pelacakan standar dengan fitur *geo-journaling* yang canggih.

### Pelacakan & Sinkronisasi
* **Pelacakan GPS Live:** Menggunakan `geolocator` dengan *Foreground Service* untuk pelacakan akurat (meskipun saat ini *service* masih terikat pada UI).
* **100% Offline-First:** Semua data (`Hikes`, `RoutePoints`, `Waypoints`, `Photos`) disimpan dengan aman di database lokal **Drift**.
* **Sinkronisasi Cloud 4-Tabel:** Sinkronisasi dua arah yang *robust* ke **Supabase** untuk *backup* data dan sinkronisasi antar perangkat.
* **Manajemen Sesi Cerdas:** Dialog "Lanjutkan atau Buang Sesi" secara proaktif menangani *tracking* yang belum selesai akibat *crash* atau ditutup paksa.

### *Advanced Waypoints* (POI)
* **Input Ganda:** Pengguna dapat menambahkan *waypoint* (POI) melalui dua cara:
    1.  **Lokasi Saat Ini:** Menandai lokasi GPS pengguna saat itu juga.
    2.  **Pilih dari Peta:** Menggunakan *reticle* (pin di tengah layar) untuk memilih lokasi presisi dari peta yang bisa digeser.
* **Metadata Lengkap:** Setiap *waypoint* mendukung:
    * **Kategori** (Pos, Puncak, Sumber Air, Camp, dll.).
    * **Foto Opsional** (diambil dari kamera/galeri, tertaut ke *waypoint*).
    * **Altitude** (mdpl) (jika ditandai dari GPS).
* **Statistik Per-Waypoint:** Aplikasi secara otomatis menghitung total **Elevation Gain** dan **Elevation Loss** dari titik awal *hingga* ke setiap *waypoint* saat pendakian selesai.

### UI/UX
* **Manajemen State:** Dikelola secara reaktif menggunakan **Riverpod**.
* **Navigasi:** Menggunakan **Go_Router** dengan *nested routes* untuk navigasi yang bersih.
* **Galeri Cerdas:** Halaman Galeri Utama secara otomatis **menyembunyikan** foto-foto teknis yang terikat pada *waypoint* (seperti foto plang pos), sehingga galeri tetap bersih untuk foto pemandangan.

---

## 🛠️ Tumpukan Teknologi

* **Framework:** Flutter 3.x
* **State Management:** Riverpod 2.x
* **Database (Lokal):** [Drift](https://drift.simonbinder.eu) (Reactive persistence library untuk SQLite)
* **Backend (BaaS):** [Supabase](https://supabase.io)
    * **Auth:** Supabase Auth
    * **Database (Cloud):** Supabase Postgres
    * **Storage:** Supabase Storage (untuk foto)
* **Navigasi:** Go_Router
* **GPS:** Geolocator
* **Peta:** flutter_map
* **Lainnya:** `permission_handler`, `image_picker`

---

## 🏛️ Arsitektur

Proyek ini dibangun menggunakan prinsip **Clean Architecture** yang dimodifikasi untuk Flutter, dengan pemisahan yang jelas antara tiga lapisan utama:

1.  **`lib/features` (Lapisan Presentasi & Fitur):** Berisi semua UI (Pages/Screens) dan *State Management* (Provider Riverpod).
2.  **`lib/domain` (Lapisan Domain):** (Saat ini di-skip untuk *rapid development*, namun disiapkan).
3.  **`lib/data` (Lapisan Data):** Berisi `Repositories` (logika bisnis sinkronisasi) dan `DataSources` (Lokal/Drift dan Remote/Supabase).

Pemisahan ini membuat *state* terisolasi dan logika sinkronisasi data dapat diuji secara independen.

---

## 🏁 Memulai

1.  **Clone repositori:**
    ```bash
    git clone [https://github.com/USERNAME_ANDA/jejakFaa.git](https://github.com/USERNAME_ANDA/jejakFaa.git)
    cd jejakFaa
    ```

2.  **Install dependensi:**
    ```bash
    flutter pub get
    ```

3.  **Setup Supabase:**
    * Buat proyek baru di [Supabase](https://supabase.io).
    * Gunakan [skrip SQL](https://github.com/USERNAME_ANDA/jejakFaa/issues/1) *(Anda bisa buatkan Issue untuk menaruh SQL skema)* untuk membuat tabel `hikes`, `hike_photos`, `hike_waypoints`, dan `route_points`.
    * Nyalakan RLS (Row Level Security) untuk semua tabel.
    * Siapkan file `.env` Anda (atau `app_config.dart`) dengan **URL** dan **Anon Key** Supabase Anda.

4.  **Jalankan Build Runner (Drift):**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

## 🚀 Rencana Pengembangan

Proyek ini terus berkembang. Rencana besar selanjutnya adalah:

* **[Dalam Rencana] Refaktor "Pro" Background Service:**
    Memindahkan `geolocator` ke *isolate* terpisah menggunakan `flutter_background_service` agar *tracking* GPS tetap berjalan 100% aman (gaya Strava), bahkan jika aplikasi di-*swipe-to-kill* oleh OS.

* **[Dalam Rencana] Snapshot Cuaca:**
    Memanggil API cuaca (seperti OpenWeatherMap) saat `startTracking()` untuk menyimpan kondisi cuaca awal.

* **[Dalam Rencana] Kompas (Bearing):**
    Menggunakan sensor kompas perangkat untuk memutar *marker* lokasi pengguna di peta sesuai arah hadap.

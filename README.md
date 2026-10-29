# SINI-GAN

> **Aplikasi Manajemen Peminjaman Ruangan Kampus Berbasis Mobile dengan Computer Vision**  
> Proyek Akhir Mata Kuliah Pemrograman Perangkat Bergerak (PPB)  
> Program Studi S1 Rekayasa Perangkat Lunak — Fakultas Informatika, Telkom University  

---

## 1. Deskripsi Project

**SINI-GAN** (*Sistem Informasi Peminjaman Ruangan Kampus*) merupakan aplikasi mobile berbasis Flutter yang dirancang untuk mengintegrasikan seluruh tahapan peminjaman fasilitas ruangan di lingkungan kampus secara transparan dan efisien.

Aplikasi ini menghubungkan dua peran utama:
1. **Mahasiswa:** Mencari ruangan kampus, memeriksa jadwal ketersediaan jam kosong, mengajukan peminjaman, memantau status secara transparan, serta mengunggah foto kondisi ruangan sesaat sebelum dan sesudah kegiatan.
2. **Admin / Pengelola Ruangan:** Memantau dasbor operasional, mengelola master data ruangan dan jadwal kuliah reguler, memblokir tanggal tertentu untuk pemeliharaan gedung, memproses persetujuan/penolakan dengan alasan wajib, serta meninjau dokumentasi foto kondisi ruangan dengan dukungan analisis tata letak **Computer Vision (CV)**.

Fitur Computer Vision pada SINI-GAN berperan sebagai **alat bantu pendukung keputusan (*advisory triage / human-in-the-loop*)** untuk mendeteksi kesesuaian konfigurasi tata letak ruangan (Standar, Ujian, Diskusi) dan tidak mengambil keputusan sanksi secara otomatis.

---

## 2. Fitur Utama Aplikasi

Fitur SINI-GAN dikembangkan untuk memenuhi **9 Persyaratan Minimal Fitur Wajib** sesuai Pedoman Resmi Project Akhir PPB:

### A. Fitur Mahasiswa (Student Experience)
* **Katalog & Pencarian Ruangan:** Pencarian instan nama ruangan, filter lantai dan kapasitas, serta indikator status ketersediaan.
* **Detail Ruangan & Denah:** Informasi kapasitas, daftar fasilitas lengkap (AC, proyektor, Wi-Fi), dan denah lokasi visual.
* **Kalender & Cek Jam Kosong:** Tampilan pita tanggal mingguan dan grid slot jam harian yang secara visual membedakan jam terpakai (kuliah reguler) dan jam kosong yang dapat dipinjam.
* **Formulir Pengajuan Peminjaman:** Pemilihan tanggal, jam mulai/selesai, dan tujuan kegiatan dengan validasi waktu instan (*jam selesai > jam mulai*).
* **Riwayat Peminjaman & Alasan Penolakan:** Pelacakan status permohonan (*Menunggu, Disetujui, Ditolak*). Jika pengajuan ditolak admin, alasan penolakan ditampilkan secara jelas.
* **Dokumentasi Foto Before & After:** Pengambilan foto ruangan sebelum digunakan (*before*) dan sesudah dirapikan (*after*) via kamera sebagai bukti serah terima privat.
* **Profil Mahasiswa:** Informasi akun demo mahasiswa dan tombol keluar (*logout*).

### B. Fitur Pengelola Ruangan (Admin Experience)
* **Dasbor Metrik Operasional:** Pemantauan jumlah permohonan pending, peminjaman disetujui hari ini, dan total ruangan aktif.
* **Manajemen Master Ruangan:** Melihat daftar ruangan, mengubah status aktif/nonaktif melalui switch toggle, dan simulasi penambahan ruangan baru.
* **Manajemen Jadwal & Blokir Tanggal:** Melihat jadwal perkuliahan reguler mingguan dan formulir pemblokiran tanggal/rentang waktu untuk pemeliharaan fasilitas atau acara kampus.
* **Antrean Permohonan Masuk & Review:** Peninjauan rincian pemohon dengan tombol persetujuan (*Approve*) atau penolakan (*Reject*) yang **mewajibkan input alasan penolakan**.
* **Tinjauan Kondisi Ruangan (Computer Vision Triage):** Menampilkan perbandingan foto *before* dan *after* secara berdampingan (*side-by-side*), disertai lencana hasil analisis layout AI/CV (Standar/Ujian/Diskusi, confidence score) untuk verifikasi admin.

### C. Pemetaan 9 Persyaratan Fitur Wajib Perkuliahan
| No | Kategori Fitur Wajib Pedoman | Implementasi pada SINI-GAN | Status Target |
|:--:|---|---|:---:|
| 1 | **Navigation dan Routing** | Multi-page mobile application dengan shell navigasi berbasis peran (`NavigationBar` Material 3). | On Progress (UTS) |
| 2 | **Database** | Database berbasis server menggunakan **PostgreSQL** (bukan BaaS) yang diakses via REST API. | Fase UAS |
| 3 | **API Integration** | Pertukaran data asinkron berbasis JSON antara aplikasi mobile Flutter dan REST API FastAPI. | Fase UAS |
| 4 | **File Storage** | Pengelolaan berkas lokal (*image picker*, penyimpanan berkas lokal sementara/caching, pratinjau foto). | Fase UAS |
| 5 | **Camera** | Pemanfaatan perangkat keras kamera sebagai sumber input langsung foto kondisi ruangan. | Fase UAS |
| 6 | **State Management** | Pengelolaan state terstruktur memisahkan UI dan data (`MockDataStore` / `ChangeNotifier`). | On Progress (UTS) |
| 7 | **Error Handling** | Penanganan komprehensif atas jaringan terputus, data kosong (*empty state*), dan validasi input. | On Progress (UTS) |
| 8 | **Google Maps** | Menampilkan peta Google Maps, menyimpan koordinat lokasi ruangan, dan menampilkan kembali pin lokasi. | Fase UAS |
| 9 | **Notification** | Menampilkan notifikasi pembaruan status peminjaman (disetujui/ditolak) kepada pengguna. | Fase UAS |

---

## 3. Demo Aplikasi & Panduan Menjalankan

### A. Prasyarat Sistem
* Flutter SDK (Versi $\ge 3.19.0$)
* Dart SDK (Versi $\ge 3.3.0$)
* Android Studio / VS Code dengan Ekstensi Flutter & Dart
* Emulator Android atau Perangkat Fisik Android (OS $\ge 8.0$ Oreo)

### B. Langkah Menjalankan Aplikasi
1. Clone repositori ini ke komputer lokal Anda:
   ```bash
   git clone https://github.com/RukoPermata/sini_gan.git
   cd sini_gan
   ```
2. Unduh seluruh dependensi paket:
   ```bash
   flutter pub get
   ```
3. Pastikan analisis statis kode bersih tanpa error:
   ```bash
   flutter analyze
   ```
4. Jalankan pengujian otomatis (*smoke test*):
   ```bash
   flutter test
   ```
5. Jalankan aplikasi pada emulator atau perangkat yang terhubung:
   ```bash
   flutter run
   ```

### C. Kredensial Login & Skenario Demonstrasi UTS
Aplikasi menyediakan tombol pintas seleksi role cepat pada halaman Login untuk memudahkan demonstrasi tanpa mengetik:

* **Skenario Uji Mahasiswa:**
  1. Pada halaman Login, tekan tombol pintas **"Masuk sebagai Mahasiswa"**.
  2. Buka menu **Katalog**, cari ruangan `"TULT-0701"`, pilih slot jam kosong yang berwarna hijau pada pita tanggal, lalu buka detail ruangan.
  3. Tekan **"Ajukan Peminjaman"**, isi tujuan kegiatan, lalu kirimkan formulir.
  4. Buka menu **Profil** dan tekan **Logout**.
* **Skenario Uji Admin:**
  1. Pada halaman Login, tekan tombol pintas **"Masuk sebagai Admin"**.
  2. Buka menu **Pengajuan**. Permohonan mahasiswa tadi akan muncul di antrean teratas berstatus *Menunggu*.
  3. Buka permohonan tersebut, tunjukkan dialog tolak dengan alasan wajib atau tekan **Setujui**.
  4. Buka menu **Ruangan** & **Jadwal** untuk melihat simulasi toggle aktif/nonaktif dan pemblokiran tanggal.
  5. Buka menu **Kondisi** untuk melihat komparasi foto *before-after* dan simulasi lencana deteksi Computer Vision.
  6. Login kembali sebagai Mahasiswa dan periksa bahwa status di menu **Riwayat** telah terbarui menjadi *Disetujui* secara dinamis.

---

## 4. Arsitektur Sistem & Teknologi

```text
┌────────────────────────────────────────────────────────┐
│             Flutter Mobile Application                 │
│      (Presentation Layer: Screens & Widgets)           │
└───────────────────────────┬────────────────────────────┘
                            │ HTTPS / REST API (JSON)
                            ▼
┌────────────────────────────────────────────────────────┐
│             Backend API Service (FastAPI)              │
│    (Business Rules, Authentication JWT, & RBAC)        │
└─────────────┬────────────────────────────┬─────────────┘
              │                            │
              ▼                            ▼
┌───────────────────────────┐┌───────────────────────────┐
│   PostgreSQL Database     ││   CV Module (PyTorch)     │
│ (Users, Rooms, Bookings,  ││ (MobileNetV3 Classifier:  │
│  Schedules, ActivityLogs) ││  Standar, Ujian, Diskusi) │
└───────────────────────────┘└───────────────────────────┘
```

Aplikasi menerapkan pola **Clean Architecture** pada sisi mobile:
* **Presentation Layer (`lib/features/`, `lib/core/widgets/`):** Mengelola antarmuka pengguna, widget bersama, dan penanganan interaksi.
* **Domain Layer (`lib/models/`):** Berisi entitas model bisnis independen (`Room`, `Booking`).
* **Data Layer (`lib/data/`):** Menyediakan sumber data (`mock_data_store.dart` saat UTS dan REST API Client saat UAS).

---

## 5. Tim Pengembang

Proyek ini dikembangkan oleh lima mahasiswa Program Studi S1 Rekayasa Perangkat Lunak, Fakultas Informatika, Telkom University:

| No | Nama Lengkap | NIM | Peran Utama | Tanggung Jawab Utama |
|:--:|---|:---:|---|---|
| 1 | **Kaisar Rayfa Al Baihaqqi** | 103022400110 | Product Manager & Computer Vision Lead | Fondasi sistem, model data, data mock, riset lapangan, dan antarmuka inspeksi foto AI/CV. |
| 2 | **Fauzan Zulfa Muhammad** | 103022400032 | Flutter Developer (Student Flow) | Katalog ruangan, filter ketersediaan, detail ruangan, formulir peminjaman, dan riwayat peminjaman mahasiswa. |
| 3 | **Fityah Bayoediansyah Harahap** | 103022400085 | Flutter Developer & Backend Lead | Layar manajemen ruangan (toggle aktif) & jadwal reguler/blokir tanggal di UTS; Database PostgreSQL & REST API di UAS. |
| 4 | **Rayazka Aris Fadhillah Nugraha** | 103022400096 | Flutter Developer (Admin Requests Flow) | Dasbor metrik admin, antrean permohonan masuk, dan layar persetujuan/penolakan dengan alasan wajib. |
| 5 | **Farrel Irham Adzkaar Susanto** | 103022400105 | UI/UX Designer & Frontend | Desain sistem visual (Figma), layar autentikasi (login/register), beranda mahasiswa, dan profil mahasiswa. |

---

*Dikembangkan untuk memenuhi evaluasi Project Akhir Mata Kuliah Pemrograman Perangkat Bergerak (PPB) Semester Ganjil 2026/2027.*

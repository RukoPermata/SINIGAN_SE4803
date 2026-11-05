# SINI-GAN

> **Aplikasi Manajemen Peminjaman Ruangan Kampus Berbasis Mobile dengan Computer Vision**  
> Proyek Akhir Mata Kuliah Pemrograman Perangkat Bergerak (PPB)  
> Program Studi S1 Rekayasa Perangkat Lunak, Fakultas Informatika, Telkom University  

---

## 1. Deskripsi Project

SINI-GAN (Sistem Informasi Peminjaman Ruangan Kampus) merupakan aplikasi mobile berbasis Flutter yang dirancang untuk mengintegrasikan proses peminjaman fasilitas ruangan di lingkungan kampus secara transparan dan terstruktur.

Aplikasi ini melayani dua peran utama:
1. **Mahasiswa:** Menelusuri katalog ruangan kampus, memeriksa jadwal ketersediaan jam kosong, mengajukan permohonan peminjaman, memantau status persetujuan, serta mendokumentasikan kondisi ruangan sesaat sebelum dan sesudah kegiatan melalui foto.
2. **Admin / Pengelola Ruangan:** Memantau ringkasan operasional melalui dasbor, mengelola data ruangan dan jadwal perkuliahan reguler, memblokir tanggal tertentu untuk pemeliharaan gedung, memproses persetujuan atau penolakan pengajuan dengan alasan tertulis, serta meninjau dokumentasi foto kondisi ruangan dengan bantuan analisis tata letak Computer Vision (CV).

Fitur Computer Vision pada SINI-GAN berfungsi sebagai instrumen pendukung keputusan (advisory triage dengan pendekatan human-in-the-loop) untuk mengklasifikasikan kesesuaian konfigurasi tata letak ruangan (Standar, Ujian, Diskusi). Sistem tidak mengambil keputusan sanksi atau denda secara otomatis.

---

## 2. Fitur Utama Aplikasi

Implementasi fitur SINI-GAN mencakup pemenuhan 9 Persyaratan Minimal Fitur Wajib sesuai Pedoman Resmi Project Akhir PPB:

### A. Fitur Mahasiswa (Student Experience)
* **Katalog dan Pencarian Ruangan:** Pencarian nama ruangan secara langsung, filter lantai dan kapasitas, serta indikator status ketersediaan.
* **Detail Ruangan dan Lokasi:** Informasi kapasitas maksimal, daftar fasilitas penunjang, dan pratinjau lokasi denah ruangan.
* **Kalender dan Pengecekan Slot Waktu:** Tampilan pita tanggal mingguan dan slot jam harian yang membedakan jadwal perkuliahan terpakai dan jam kosong yang dapat dipinjam.
* **Formulir Pengajuan Peminjaman:** Pemilihan tanggal kegiatan, jam mulai dan jam selesai, serta deskripsi tujuan dengan validasi waktu (jam selesai harus lebih besar dari jam mulai).
* **Riwayat Peminjaman:** Pelacakan status permohonan (Menunggu, Disetujui, Ditolak). Apabila permohonan ditolak, alasan penolakan ditampilkan secara transparan.
* **Dokumentasi Foto Before dan After:** Pengambilan foto ruangan sebelum digunakan (before) dan sesudah kegiatan selesai dirapikan (after) sebagai bukti serah terima.
* **Profil Pengguna:** Tampilan data identitas mahasiswa dan tombol keluar akun (logout).

### B. Fitur Pengelola Ruangan (Admin Experience)
* **Dasbor Operasional:** Pemantauan metrik permohonan yang menunggu persetujuan, peminjaman aktif hari ini, dan total ruangan terdaftar.
* **Manajemen Data Ruangan:** Menampilkan daftar ruangan, mengubah status aktif atau nonaktif melalui switch toggle, dan dialog penambahan ruangan baru.
* **Manajemen Jadwal dan Pemblokiran Tanggal:** Menampilkan jadwal perkuliahan reguler mingguan dan formulir penonaktifan tanggal tertentu untuk agenda institusi atau pemeliharaan gedung.
* **Antrean Pengajuan dan Keputusan:** Pemeriksaan rincian pemohon dengan opsi persetujuan (Approve) atau penolakan (Reject) yang mewajibkan pengisian catatan alasan penolakan.
* **Tinjauan Kondisi Ruangan (Computer Vision Triage):** Antrean pemeriksaan permohonan selesai yang menampilkan perbandingan foto before dan after secara berdampingan, disertai lencana hasil prediksi model klasifikasi tata letak (MobileNetV3) dan confidence score untuk verifikasi admin.

### C. Pemetaan 9 Persyaratan Fitur Wajib Perkuliahan
| No | Kategori Fitur Wajib Pedoman | Implementasi pada SINI-GAN | Status Target |
|:--:|---|---|:---:|
| 1 | **Navigation dan Routing** | Multi-page mobile application dengan navigasi berbasis peran (NavigationBar Material 3 dan GetPage routing). | Selesai (UTS) |
| 2 | **Database** | Database relasional berbasis server menggunakan PostgreSQL (bukan BaaS) yang diakses melalui REST API backend. | Fase UAS |
| 3 | **API Integration** | Pertukaran data asinkron berbasis JSON antara aplikasi mobile Flutter dan backend FastAPI. | Fase UAS |
| 4 | **File Storage** | Pengelolaan berkas lokal (image picker, local caching, dan persistensi lokal SharedPreferences). | Selesai (UTS) |
| 5 | **Camera** | Pemanfaatan perangkat keras kamera sebagai sumber input langsung foto kondisi ruangan. | Fase UAS |
| 6 | **State Management** | Pengelolaan state terstruktur memisahkan UI dan data menggunakan GetX (GetxController dan GetBuilder). | Selesai (UTS) |
| 7 | **Error Handling** | Penanganan komprehensif atas data kosong (empty state), validasi input form, dan kegagalan proses. | Selesai (UTS) |
| 8 | **Google Maps** | Menampilkan peta Google Maps, menyimpan data koordinat lokasi ruangan, dan menampilkan pin lokasi. | Fase UAS |
| 9 | **Notification** | Menampilkan notifikasi pembaruan status peminjaman kepada pengguna. | Fase UAS |

---

## 3. Panduan Menjalankan Aplikasi dan Skenario Demonstrasi

### A. Prasyarat Sistem
* Flutter SDK versi 3.19.0 atau yang lebih baru
* Dart SDK versi 3.3.0 atau yang lebih baru
* Android Studio atau VS Code dengan ekstensi Flutter dan Dart
* Perangkat fisik Android dengan OS Android 8.0 (Oreo) ke atas dan USB Debugging aktif

### B. Langkah Menjalankan Aplikasi
1. Salin repositori ke direktori lokal:
   ```bash
   git clone https://github.com/RukoPermata/SINIGAN_SE4803.git
   cd SINIGAN_SE4803
   ```
2. Pasang dependensi proyek:
   ```bash
   flutter pub get
   ```
3. Jalankan pengujian analisis statis kode:
   ```bash
   flutter analyze
   ```
4. Jalankan seluruh pengujian otomatis:
   ```bash
   flutter test
   ```
5. Hubungkan smartphone Android fisik via kabel USB data transfer, lalu jalankan aplikasi:
   ```bash
   flutter run
   ```

### C. Skenario Demonstrasi Aplikasi (Alur Pengujian UTS)
Halaman Login menyediakan tombol pintas peran untuk mempermudah demonstrasi langsung di hadapan dosen:

* **Skenario Peran Mahasiswa:**
  1. Pada halaman Login, pilih tombol "Masuk sebagai Mahasiswa".
  2. Buka menu Katalog, cari ruangan "TULT-0701", lalu periksa ketersediaan jadwal pada pita tanggal mingguan.
  3. Buka halaman Detail Ruangan, pilih tombol "Ajukan Peminjaman", isi formulir tujuan kegiatan, lalu kirimkan permohonan.
  4. Buka menu Riwayat untuk melihat permohonan baru yang berstatus Menunggu.
  5. Buka menu Profil, lalu lakukan Logout.

* **Skenario Peran Admin:**
  1. Pada halaman Login, pilih tombol "Masuk sebagai Admin".
  2. Pada Dasbor, amati pembaruan angka metrik permohonan masuk.
  3. Buka menu Pengajuan, buka rincian permohonan mahasiswa tadi, lalu lakukan persetujuan (Approve) atau penolakan dengan catatan alasan.
  4. Buka menu Ruangan dan Jadwal untuk mendemonstrasikan status toggle ruangan aktif/nonaktif serta jadwal perkuliahan.
  5. Buka menu Kondisi untuk melihat antrean pemeriksaan foto before-after dan hasil klasifikasi tata letak Computer Vision.
  6. Masuk kembali sebagai Mahasiswa dan buktikan bahwa status permohonan pada menu Riwayat telah terbarui secara dinamis.

---

## 4. Arsitektur Sistem dan Teknologi

```text
+--------------------------------------------------------+
|             Flutter Mobile Application                 |
|      (Presentation Layer: Screens & Widgets)           |
+---------------------------+----------------------------+
                            | HTTPS / REST API (JSON)
                            v
+--------------------------------------------------------+
|             Backend API Service (FastAPI)              |
|    (Business Rules, Authentication JWT, & RBAC)        |
+-------------+----------------------------+-------------+
              |                            |
              v                            v
+---------------------------++---------------------------+
|   PostgreSQL Database     ||   CV Module (PyTorch)     |
| (Users, Rooms, Bookings,  || (MobileNetV3 Classifier:  |
|  Schedules, ActivityLogs) ||  Standar, Ujian, Diskusi) |
+---------------------------++---------------------------+
```

Aplikasi menerapkan prinsip Clean Architecture pada sisi mobile:
* **Presentation Layer (lib/features/, lib/core/widgets/):** Mengelola antarmuka pengguna, widget bersama, dan penanganan interaksi reaktif (GetBuilder).
* **Domain Layer (lib/models/):** Berisi entitas model bisnis independen (Room, Booking, RegularSchedule, BlackoutPeriod).
* **Data Layer (lib/data/):** Mengelola sumber data (MockDataStore berbasis GetxController dan persistensi SharedPreferences pada fase UTS, yang akan terhubung ke REST API Client pada fase UAS).

---

## 5. Tim Pengembang

Proyek ini dikembangkan oleh lima mahasiswa Program Studi S1 Rekayasa Perangkat Lunak, Fakultas Informatika, Telkom University:

| No | Nama Lengkap | NIM | Peran Utama | Tanggung Jawab Utama |
|:--:|---|:---:|---|---|
| 1 | **Kaisar Rayfa Al Baihaqqi** | 103022400110 | Product Manager & Computer Vision Lead | Arsitektur sistem, model data, data tiruan, riset kebutuhan, dan modul inspeksi kondisi ruangan AI/CV. |
| 2 | **Fauzan Zulfa Muhammad** | 103022400032 | Flutter Developer (Student Flow) | Katalog ruangan, filter ketersediaan, detail ruangan, formulir peminjaman, riwayat peminjaman, GetX, dan SharedPreferences. |
| 3 | **Fityah Bayoediansyah Harahap** | 103022400085 | Flutter Developer & Backend Lead | Manajemen ruangan aktif/nonaktif dan jadwal reguler/blokir tanggal di UTS; Database PostgreSQL dan REST API di UAS. |
| 4 | **Rayazka Aris Fadhillah Nugraha** | 103022400096 | Flutter Developer (Admin Requests Flow) | Dasbor metrik admin, antrean permohonan masuk, dan layar persetujuan/penolakan dengan catatan alasan wajib. |
| 5 | **Farrel Irham Adzkaar Susanto** | 103022400105 | UI/UX Designer & Frontend | Layar autentikasi (login dan register), layar beranda mahasiswa, dan layar profil mahasiswa. |

---

*Disusun untuk memenuhi evaluasi Project Akhir Mata Kuliah Pemrograman Perangkat Bergerak (PPB) Semester Ganjil 2026/2027.*

# SINI-GAN

### Aplikasi Manajemen Peminjaman Ruangan Kampus Berbasis Mobile dengan Computer Vision

SINI-GAN merupakan proyek aplikasi mobile untuk membantu pengelolaan peminjaman ruangan kampus. Aplikasi ini dirancang untuk mengintegrasikan informasi ruangan, jadwal perkuliahan reguler, pengajuan peminjaman, persetujuan admin, serta dokumentasi kondisi ruangan melalui foto sebelum dan sesudah penggunaan.

SINI-GAN juga mengembangkan fitur **Computer Vision (CV)** untuk mengklasifikasikan tata letak ruangan sebagai informasi pendukung bagi admin dalam memeriksa kondisi ruangan.

> **Status proyek:** Dalam tahap pengembangan bertahap.

## Fitur Utama

### 1. Autentikasi dan Manajemen Pengguna

- Login dan autentikasi pengguna.
- Pembagian peran mahasiswa dan admin.
- Pembatasan akses fitur berdasarkan peran pengguna.

### 2. Manajemen Ruangan

- Menambah, melihat, mengubah, dan menonaktifkan data ruangan.
- Menampilkan fasilitas dan informasi lokasi ruangan.
- Menampilkan lokasi ruangan melalui Google Maps.

### 3. Sistem Peminjaman Ruangan

- Melihat katalog dan ketersediaan ruangan.
- Memeriksa jadwal perkuliahan reguler dan peminjaman yang telah disetujui.
- Mengajukan peminjaman berdasarkan ruangan, tanggal, waktu, dan tujuan kegiatan.
- Menyetujui atau menolak pengajuan melalui admin.
- Menonaktifkan tanggal atau rentang tanggal peminjaman.
- Melihat riwayat peminjaman mahasiswa.
- Mencatat log aktivitas peminjaman.

### 4. Dokumentasi Kondisi Ruangan

- Mengambil atau memilih foto sebelum penggunaan ruangan.
- Mengunggah foto setelah penggunaan ruangan.
- Menampilkan dokumentasi foto untuk pemeriksaan admin.

### 5. Computer Vision Layout Checker

- Mengklasifikasikan tata letak ruangan menjadi kategori standar, ujian, atau diskusi.
- Membandingkan hasil klasifikasi dengan tata letak target.
- Menandai laporan yang terindikasi tidak sesuai.
- Menyediakan hasil klasifikasi sebagai bahan tinjauan admin.

Hasil Computer Vision bersifat pendukung keputusan (*human-in-the-loop*). Keputusan akhir pemeriksaan tetap dilakukan oleh admin.

### 6. Notifikasi

- Memberikan informasi mengenai status pengajuan.
- Menyampaikan pembaruan terkait pemeriksaan kondisi ruangan.

*Daftar fitur di atas merupakan ruang lingkup yang direncanakan. Implementasi fitur dilakukan secara bertahap sesuai prioritas dan hasil pengembangan.*

## Tahapan Pengembangan

Pengembangan SINI-GAN dibagi menjadi dua tahap utama, yaitu UTS dan UAS.

### Tahap 1 — UTS: Pengembangan UI

**Target:** Menyelesaikan seluruh rancangan dan implementasi antarmuka aplikasi mobile.

Ruang lingkup pengerjaan:

- Membuat halaman login dan antarmuka berdasarkan peran pengguna.
- Membuat halaman beranda dan katalog ruangan.
- Membuat halaman detail ruangan beserta informasi fasilitas dan lokasi.
- Membuat halaman kalender atau ketersediaan ruangan.
- Membuat formulir pengajuan peminjaman.
- Membuat halaman riwayat dan status peminjaman.
- Membuat dashboard admin dan halaman pengelolaan ruangan.
- Membuat halaman persetujuan atau penolakan pengajuan.
- Membuat antarmuka dokumentasi foto before-after.
- Membuat antarmuka hasil pemeriksaan dan klasifikasi Computer Vision.
- Membuat antarmuka notifikasi dan halaman pendukung lainnya sesuai kebutuhan.

Pada tahap ini, UI dapat menggunakan data dummy atau mock data untuk mendemonstrasikan alur penggunaan aplikasi. Fokus utamanya adalah kelengkapan halaman, navigasi, konsistensi desain, dan alur interaksi pengguna.

### Tahap 2 — UAS: Implementasi Backend dan Integrasi

**Target:** Mengimplementasikan backend, menghubungkan UI dengan layanan data, serta memastikan fitur utama dapat berfungsi sesuai kebutuhan.

Ruang lingkup pengerjaan:

- Mengimplementasikan database utama menggunakan PostgreSQL.
- Mengembangkan backend dan REST API.
- Mengimplementasikan autentikasi serta otorisasi pengguna.
- Mengimplementasikan manajemen ruangan dan jadwal reguler.
- Mengimplementasikan pengajuan, persetujuan, penolakan, dan riwayat peminjaman.
- Menerapkan business rules untuk validasi ketersediaan dan bentrokan jadwal.
- Mengimplementasikan penonaktifan tanggal atau rentang tanggal peminjaman.
- Mengimplementasikan log aktivitas peminjaman.
- Mengintegrasikan upload foto dan penyimpanan file.
- Mengintegrasikan peta, notifikasi, serta layanan pendukung.
- Mengembangkan dan mengintegrasikan API Computer Vision sesuai prioritas dan kesiapan dataset.
- Melakukan pengujian fungsional, integrasi, dan penanganan kesalahan.

UI tambahan atau penyempurnaan antarmuka tetap dapat dilakukan selama tahap UAS apabila ditemukan kebutuhan baru, perubahan alur, atau penyesuaian berdasarkan hasil integrasi dan pengujian.

## Teknologi yang Direncanakan

| Komponen              | Teknologi                             |
| --------------------- | ------------------------------------- |
| Mobile application    | Flutter, Dart                         |
| Database utama        | PostgreSQL                            |
| Komunikasi aplikasi   | REST API                              |
| Backend               | Framework backend yang disepakati tim |
| Computer Vision API   | Python, FastAPI                       |
| Model Computer Vision | PyTorch, MobileNetV3                  |
| Peta dan lokasi       | Google Maps Flutter                   |
| Pemilihan foto        | Image Picker                          |
| Penyimpanan foto      | Layanan penyimpanan file              |
| Notifikasi            | Firebase Cloud Messaging (FCM)        |

Teknologi di atas merupakan rancangan awal dan dapat disesuaikan berdasarkan implementasi akhir.

## Arsitektur Sistem

```text
Flutter Mobile Application
          |
          | HTTP / REST API
          v
       Backend API
          |
          v
       PostgreSQL
   (Primary Database)

Flutter Mobile Application
          |
          | Request klasifikasi foto
          v
   Computer Vision API
       (FastAPI)
          |
          v
   PyTorch / MobileNetV3
          |
          v
   Hasil Klasifikasi Layout
```

Penyimpanan foto dan layanan notifikasi dapat diintegrasikan sebagai layanan pendukung.

**Ketentuan arsitektur:** PostgreSQL menjadi database relasional utama. Aplikasi Flutter mengakses data melalui REST API dan tidak mengakses database secara langsung.

## Business Rules

1. Pengajuan tidak boleh disetujui apabila bertabrakan dengan jadwal perkuliahan reguler, peminjaman lain yang telah disetujui, atau periode penonaktifan ruangan.
2. Waktu selesai peminjaman harus lebih besar daripada waktu mulai.
3. Pengajuan harus mendapatkan persetujuan admin sebelum dianggap sebagai peminjaman yang disetujui.
4. Admin dapat menonaktifkan tanggal atau rentang tanggal sesuai cakupan ruangan yang ditentukan.
5. Mahasiswa hanya dapat melihat riwayat peminjamannya sendiri.
6. Akses log aktivitas dibatasi berdasarkan peran dan kewenangan.
7. Hasil Computer Vision merupakan indikator pendukung dan tidak secara otomatis menentukan pelanggaran atau keputusan akhir pemeriksaan.

Validasi business rules dilakukan pada backend untuk menjaga konsistensi data dan mencegah peminjaman yang tidak valid.

## Tujuan Proyek

- Mempermudah mahasiswa dan organisasi kampus dalam mencari serta mengajukan peminjaman ruangan.
- Membantu admin mengelola data ruangan dan jadwal penggunaan.
- Mengurangi risiko bentrokan jadwal.
- Meningkatkan transparansi proses persetujuan dan riwayat peminjaman.
- Mendukung dokumentasi kondisi ruangan melalui foto.
- Mengeksplorasi penerapan Computer Vision untuk membantu pemeriksaan tata letak ruangan.

## Tim Pengembang

Proyek ini dikembangkan oleh lima mahasiswa Program Studi S1 Rekayasa Perangkat Lunak.

| No. | Nama                         | Peran                                            |
| --- | ---------------------------- | ------------------------------------------------ |
| 1   | Kaisar Rayfa Al Baihaqqi      | Product Manager & Data Science / Computer Vision |
| 2   | Fauzan Zulfa Muhammad        | Flutter Developer                                |
| 3   | Fityah Bayoediansyah Harahap | Backend, Firebase & Integrasi API                |
| 4   | Rayazka Aris                 | Flutter Developer                                |
| 5   | Farrel Irham Adzkaar Susanto | UI/UX Designer                                   |

Pembagian peran dapat disesuaikan dengan kebutuhan dan perkembangan proyek.

## Dokumentasi

Dokumentasi proyek mencakup:

- Product Requirements Document (PRD).
- Feature backlog dan prioritas fitur.
- Task board dan progres pengerjaan.
- Wireframe dan desain antarmuka.
- Dokumentasi database dan REST API.
- Dokumentasi dataset dan evaluasi model Computer Vision.
- Hasil pengujian aplikasi.

Tautan dokumentasi akan ditambahkan setelah tersedia.

---

Dikembangkan sebagai proyek akademik untuk menerapkan pengembangan aplikasi mobile, manajemen basis data relasional, REST API, dan Computer Vision dalam konteks pengelolaan ruangan kampus.

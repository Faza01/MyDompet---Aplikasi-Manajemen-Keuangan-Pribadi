# Changelog

Semua perubahan penting pada proyek **MyDompet** akan didokumentasikan di berkas ini.

## [1.0.0] - 2026-07-04

### Ditambahkan
- **Estetika Premium Glassmorphism**:
  - Implementasi *Truly Floating Bottom Navbar* berbentuk kapsul melayang dengan aksen bayangan drop shadow yang realistis.
  - Integrasi paket `progressive_blur` berbasis custom shader GLSL untuk memudarkan keburaman (*feathered progressive blur*) secara kontinu dari atas (tajam) ke bawah (buram penuh) tanpa garis pembatas fisik.
  - Dukungan rendering layar penuh (*edge-to-edge*) yang menembus area navigasi sistem Android bawaan dengan membuat status bar dan system navigation bar transparan.
- **Pencatatan Cepat Cerdas (Quick Input NLP)**:
  - Dukungan asisten suara & teks pintar yang mendeteksi nominal uang, kategori, dan deskripsi pengeluaran secara otomatis berbasis pencocokan pola kata kunci asisten.
  - Pemosisian dan visualisasi masukan transaksi cepat yang intuitif.
- **Manajemen Anggaran (Budgeting)**:
  - Kemampuan menetapkan alokasi anggaran belanja bulanan per kategori.
  - Indikator bar progres interaktif yang melacak pengeluaran secara dinamis.
- **Laporan Statistik Visual**:
  - Penambahan visualisasi diagram pai dan diagram batang interaktif per kurun waktu (Hari, Minggu, Bulan, Tahun).
- **SQLite Backup & Restore**:
  - Fitur ekspor basis data lokal ke penyimpanan internal dan impor data cadangan kapan saja.

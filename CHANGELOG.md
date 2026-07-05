# Changelog

Semua perubahan penting pada proyek **MyDompet** akan didokumentasikan di berkas ini.

## [1.2.0] - 2026-07-05

### Ditambahkan
- **Custom Date Range Picker**: Dialog pemilihan rentang tanggal di Laporan Keuangan kini menggunakan pop-up kalender kecil (bukan layar penuh) dengan visual range selection monokrom dan mode input teks manual (ikon edit).

### Diperbaiki
- **Redesain Palet Warna Kategori**: Mengganti warna ikon kategori yang gelap/kusam (*Teal Family + Orange Family*) dengan palet *Sophisticated Muted* — setiap kategori expense kini memiliki warna unik yang lebih hidup namun tetap elegan:
  - Belanja → Warm Terracotta (`#E8845C`)
  - Makanan → Golden Sand (`#E6A65D`)
  - Tagihan → Soft Crimson (`#E05A5A`)
  - Hiburan → Lavender Mist (`#A78BDA`)
  - Transportasi → Sky Slate (`#5BA4D9`)
  - Income (Gaji/Bonus/Terima Transfer) → Fresh Teal variants yang lebih cerah
  - Transfer/Lain-lain → Steel Gray & Mist Gray yang lebih terang

## [1.1.0] - 2026-07-04

### Ditambahkan
- **Paginasi Riwayat Transaksi**: Navigasi halaman interaktif (`< 1, 2, 3, ... >`) langsung pada dashboard beranda dengan performa scroll konstan 120 FPS.

### Diperbaiki
- **Optimasi Performa Ekstrem**: Menghapus efek shader blur pada navbar untuk memotong beban GPU menjadi 0ms, membatasi daftar transaksi awal hingga 10 transaksi terbaru untuk menghindari bottleneck UI Thread.
- **Revisi & Perbaikan Visual (UI Polish)**:
  - Mengubah warna fokus border input field dan nominal angka preview pemasukan (*income*) menjadi hijau (`0xFF10B981`) di Quick Input.
  - Mengubah warna tombol mic dan centang di sebelah kolom Quick Input menjadi hitam/charcoal.
  - Memperbaiki visibilitas tombol "Simpan Transaksi" (Quick Input) dan "Kirim Transfer" (Kelola Dompet) di mode gelap agar teks terlihat kontras.
  - Menyelaraskan tema Splash Screen Android secara default ke latar belakang putih, melenyapkan efek kedipan kilau saat aplikasi dimuat.

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

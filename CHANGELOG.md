# Changelog

Semua perubahan penting pada proyek **MyDompet** akan didokumentasikan di berkas ini.

## [1.2.0] - 2026-07-05

### Ditambahkan
- **Pencatatan Cepat & Chatbot Cerdas (NLP Quick Input)**:
  - Penambahan antarmuka asisten percakapan (chatbot) untuk memproses input transaksi cepat.
  - Dukungan edit pesan langsung secara inline (pesan pengguna dapat diedit kembali untuk memicu reparsing instan).
  - Redesain dialog edit transaksi beranda dengan aksen garis warna vertikal (hijau/merah) di sisi kiri dan editor tanggal-waktu.
- **Redesain & Fitur Baru Laporan Keuangan (Reports Screen)**:
  - **Diagram Tren Keuangan Komparatif**: Menampilkan perbandingan 2 batang (Pemasukan vs Pengeluaran) secara berdampingan dengan tooltip detail berwarna adaptif (hijau/merah).
  - **Penyaringan Rentang Tanggal Pop-up**: Mengubah dialog pemilihan rentang tanggal dari layar penuh menjadi modal dialog berukuran ringkas (`DateRangePickerDialog`) yang berpusat di layar.
  - **Pemilihan Tanggal Monokrom & Manual**: Mengkustomisasi warna range selection menjadi hitam transparan (Light Mode) / putih transparan (Dark Mode) serta mengintegrasikan tombol edit manual untuk input teks terformat (`HH/BB/TTTT`) dua arah.
  - **Penyaringan Lanjutan**: Selektor tipe alokasi, rentang waktu, dan filter multi-rekening berbasis Bottom Sheet yang didesain dengan bentuk kapsul minimalis dan indikator latar geser (*sliding active indicator*).
  - **Interaktivitas Grafik**: Mendukung filter interaktif pada diagram batang, persentase nilai pada diagram pai, serta toggle interaktif alokasi dana dengan mengetuk kotak ringkasan Tren Keuangan.
- **Redesain Pengaturan & Manajemen Dompet (Settings & Wallet dialog)**:
  - **Unified Settings Container**: Pengelompokan item menu ke dalam satu kontainer terpadu ber-divider tipis dan ber-ikon warna-warni, lengkap dengan kartu header profil ringkas di bagian atas.
  - **Premium Wallet dialog**: Desain ulang dialog Tambah/Edit dompet menggunakan modal pop-up melengkung (`borderRadius: 24.0`), selektor chip ikon lingkaran interaktif, grid palet warna logo, dan tombol aksi blok lebar penuh yang solid.

### Diperbaiki
- **Redesain Palet Warna Kategori (Sophisticated Muted)**:
  - Mengganti warna kategori gelap dan kusam dengan palet warna mid-tone premium yang kontras baik di mode gelap maupun terang:
    - Belanja → Warm Terracotta (`#E8845C`)
    - Makanan → Golden Sand (`#E6A65D`)
    - Tagihan → Soft Crimson (`#E05A5A`)
    - Hiburan → Lavender Mist (`#A78BDA`)
    - Transportasi → Sky Slate (`#5BA4D9`)
    - Pemasukan (Gaji, Bonus, Terima Transfer) → Varian Teal cerah yang segar
    - Transfer & Lain-lain → Steel Gray (`#8B96A3`) & Mist Gray (`#A0AAB4`)
  - Meningkatkan opacity latar belakang ikon kategori dari `12%` ke `15%` untuk visibilitas yang lebih tegas.
- **Monokrom Ikon Dashboard**: Menyinkronkan seluruh ikon kategori di halaman Dashboard beranda menggunakan warna monokrom netral (putih/hitam transparan) demi mempertahankan estetika beranda yang sangat bersih.
- **Duplikasi Database Safe Guard**: Memperbaiki bug duplikasi database ketika tombol "Batal Hapus" (Undo) di snackbar ditekan berkali-kali secara cepat menggunakan teknik debouncing/guarding.
- **Optimasi CI/CD**: Upgrade versi Flutter SDK di CI ke 3.44.4 dan perbaikan penanganan parsing rilis otomatis.

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

# Rencana Implementasi: Fitur Hutang & Piutang (Debts & Receivables)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan modul Hutang & Piutang terintegrasi dengan saldo dompet, pencatatan tenggat waktu, nama orang, catatan, dan fitur pelunasan parsial (cicilan).

**Architecture:** Database SQLite ditingkatkan ke versi 3 dengan menambahkan tabel `debts` dan `debt_repayments`. Logika transaksi otomatis dipicu saat penambahan/pembayaran parsial untuk memperbarui saldo akun. UI diakses dari Dashboard dan dikelola melalui halaman khusus `DebtsScreen` beserta Bottom Sheet detailnya.

**Tech Stack:** Flutter, sqflite (SQLite), Riverpod State Management.

## Global Constraints
- Target SDK/Platform: Flutter Mobile (Android/iOS)
- Versi Database: Migrasi dari versi 2 ke versi 3
- Estetika UI: Premium minimalis, kontras tinggi di mode gelap/terang, sudut melengkung (`borderRadius: 24.0` untuk dialog, `16.0` untuk card/sheet).

---

### Task 1: Migrasi Database SQLite ke Versi 3

**Files:**
- Modify: `lib/core/database/database_helper.dart`

**Interfaces:**
- Produces: SQLite tables `debts` and `debt_repayments`.

- [ ] **Step 1: Naikkan versi database di lib/core/database/database_helper.dart**
  Ubah konstanta versi di baris 28:
  ```dart
  version: 3,
  ```

- [ ] **Step 2: Tambahkan logika pembuatan tabel baru pada _createDB dan update _onUpgrade**
  ```dart
  // Di _onUpgrade
  if (oldVersion < 3) {
    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('debt', 'receivable')),
        due_date TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('pending', 'paid')),
        note TEXT,
        account_id INTEGER NOT NULL,
        transaction_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE debt_repayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        transaction_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (debt_id) REFERENCES debts(id) ON DELETE CASCADE,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      )
    ''');
  }
  ```

- [ ] **Step 3: Jalankan verifikasi kompilasi**
  Run: `flutter analyze`
  Expected: PASS

- [ ] **Step 4: Commit perubahan database**
  ```bash
  git add lib/core/database/database_helper.dart
  git commit -m "feat: upgrade db schema to v3 for debts and repayments tables"
  ```

---

### Task 2: Implementasi Model Data & State Provider (Riverpod)

**Files:**
- Create: `lib/data/models/debt.dart`
- Create: `lib/data/models/debt_repayment.dart`
- Create: `lib/features/debts/debts_provider.dart`
- Modify: `lib/core/database/database_helper.dart`

**Interfaces:**
- Produces: `DebtModel`, `DebtRepaymentModel`, `debtsNotifierProvider`.

- [ ] **Step 1: Buat file model lib/data/models/debt.dart**
  ```dart
  class DebtModel {
    final int? id;
    final String contactName;
    final double amount;
    final String type; // 'debt' | 'receivable'
    final DateTime dueDate;
    final String status; // 'pending' | 'paid'
    final String? note;
    final int accountId;
    final int? transactionId;
    final DateTime createdAt;

    DebtModel({
      this.id,
      required this.contactName,
      required this.amount,
      required this.type,
      required this.dueDate,
      required this.status,
      this.note,
      required this.accountId,
      this.transactionId,
      required this.createdAt,
    });

    Map<String, dynamic> toMap() {
      return {
        if (id != null) 'id': id,
        'contact_name': contactName,
        'amount': amount,
        'type': type,
        'due_date': dueDate.toIso8601String(),
        'status': status,
        'note': note,
        'account_id': accountId,
        'transaction_id': transactionId,
        'created_at': createdAt.toIso8601String(),
      };
    }

    factory DebtModel.fromMap(Map<String, dynamic> map) {
      return DebtModel(
        id: map['id'] as int?,
        contactName: map['contact_name'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        dueDate: DateTime.parse(map['due_date'] as String),
        status: map['status'] as String,
        note: map['note'] as String?,
        accountId: map['account_id'] as int,
        transactionId: map['transaction_id'] as int?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    }
  }
  ```

- [ ] **Step 2: Buat file model lib/data/models/debt_repayment.dart**
  ```dart
  class DebtRepaymentModel {
    final int? id;
    final int debtId;
    final double amount;
    final int transactionId;
    final DateTime createdAt;

    DebtRepaymentModel({
      this.id,
      required this.debtId,
      required this.amount,
      required this.transactionId,
      required this.createdAt,
    });

    Map<String, dynamic> toMap() {
      return {
        if (id != null) 'id': id,
        'debt_id': debtId,
        'amount': amount,
        'transaction_id': transactionId,
        'created_at': createdAt.toIso8601String(),
      };
    }

    factory DebtRepaymentModel.fromMap(Map<String, dynamic> map) {
      return DebtRepaymentModel(
        id: map['id'] as int?,
        debtId: map['debt_id'] as int,
        amount: (map['amount'] as num).toDouble(),
        transactionId: map['transaction_id'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    }
  }
  ```

- [ ] **Step 3: Tambahkan query database di lib/core/database/database_helper.dart**
  Implementasikan fungsi CRUD untuk `debts` dan `debt_repayments`, pastikan menyertakan fungsi untuk menghitung sisa hutang dan mengotomatisasi pembuatan transaksi awal / pembayaran.

- [ ] **Step 4: Buat Riverpod Provider lib/features/debts/debts_provider.dart**
  - Implementasikan notifier `DebtsNotifier` yang melacak daftar hutang/piutang secara dinamis dan memiliki fungsi `addDebt`, `deleteDebt`, serta `repayDebt`.

- [ ] **Step 5: Jalankan flutter analyze**
  Run: `flutter analyze`
  Expected: PASS

- [ ] **Step 6: Commit**
  ```bash
  git add lib/data/models/debt.dart lib/data/models/debt_repayment.dart lib/features/debts/debts_provider.dart
  git commit -m "feat: add debt models and Riverpod provider state management"
  ```

---

### Task 3: Tombol Aksi di Dashboard (Entry Point)

**Files:**
- Modify: `lib/features/transactions/home_screen.dart`

**Interfaces:**
- Consumes: Tap action to navigate to `DebtsScreen`.

- [ ] **Step 1: Cari lokasi penempatan tombol di lib/features/transactions/home_screen.dart**
  Temukan baris di sekitar Kelola Dompet / Akun. Tambahkan tombol kapsul horizontal baru dengan visual:
  ```dart
  ElevatedButton.icon(
    icon: const Icon(Icons.handshake_outlined),
    label: const Text('Hutang & Piutang'),
    // ... styling minimalis
  )
  ```

- [ ] **Step 2: Jalankan verifikasi**
  Run: `flutter analyze`
  Expected: PASS

- [ ] **Step 3: Commit**
  ```bash
  git add lib/features/transactions/home_screen.dart
  git commit -m "style: add Hutang & Piutang entry point button to dashboard"
  ```

---

### Task 4: Halaman Utama `DebtsScreen` & Dialog Tambah Data

**Files:**
- Create: `lib/features/debts/debts_screen.dart`
- Create: `lib/features/debts/add_debt_dialog.dart`

- [ ] **Step 1: Buat layar utama lib/features/debts/debts_screen.dart**
  Implementasikan:
  - Header Summary Card (Piutang, Hutang, Net)
  - Toggle Filter: Belum Lunas vs Lunas
  - Chip Filter: Semua, Hutang, Piutang
  - ListView dengan kartu bar progres sisa pembayaran dan indikator jatuh tempo (warna merah jika overdue).

- [ ] **Step 2: Buat Dialog Tambah data lib/features/debts/add_debt_dialog.dart**
  Rancang dialog minimalis bersudut lengkung 24.0 dengan input:
  - Nama Kontak
  - Nominal
  - Tipe (Hutang / Piutang)
  - Tenggat Waktu (Date Picker)
  - Dompet Asal (Dropdown)
  - Catatan

- [ ] **Step 3: Jalankan verifikasi compile**
  Run: `flutter analyze`
  Expected: PASS

- [ ] **Step 4: Commit**
  ```bash
  git add lib/features/debts/debts_screen.dart lib/features/debts/add_debt_dialog.dart
  git commit -m "feat: add DebtsScreen main layout and AddDebtDialog"
  ```

---

### Task 5: Bottom Sheet Detail & Pembayaran Parsial (Cicilan)

**Files:**
- Create: `lib/features/debts/debt_detail_sheet.dart`
- Modify: `lib/features/debts/debts_screen.dart`

- [ ] **Step 1: Buat Bottom Sheet lib/features/debts/debt_detail_sheet.dart**
  - Tampilkan nama kontak, nominal awal, sisa nominal, dan catatan.
  - Tampilkan list riwayat cicilan (diambil dari `debt_repayments` based on `debt_id`).
  - Tambahkan tombol **"Cicil"** yang menampilkan dialog input nominal cicilan dan pilihan rekening dompet.
  - Tambahkan tombol **"Hapus"** dengan konfirmasi.

- [ ] **Step 2: Sambungkan ketukan list item di DebtsScreen ke Bottom Sheet ini**
  Modifikasi `debts_screen.dart` agar membuka `DebtDetailSheet` saat salah satu item daftar diketuk.

- [ ] **Step 3: Uji seluruh kompilasi akhir**
  Run: `flutter analyze`
  Expected: PASS

- [ ] **Step 4: Commit dan selesaikan**
  ```bash
  git add lib/features/debts/debt_detail_sheet.dart lib/features/debts/debts_screen.dart
  git commit -m "feat: implement DebtDetailSheet with partial repayment tracking history"
  ```

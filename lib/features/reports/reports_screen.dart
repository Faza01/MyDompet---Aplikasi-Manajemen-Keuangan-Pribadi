import 'dart:io';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category.dart';
import '../accounts/accounts_provider.dart';
import '../budgeting/categories_provider.dart';
import '../transactions/transactions_provider.dart';
import 'category_detail_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final Set<int> _selectedAccountIds = {};
  String _timeframe = 'month'; // 'day' | 'week' | 'month' | 'year'
  DateTimeRange? _selectedDateRange; // null means no custom date range
  String _allocationType = 'expense'; // 'income' | 'expense'
  bool _showAllocationChart = false;

  String _formatRp(double val) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  String _getAdaptiveTitle() {
    if (_selectedDateRange != null) {
      final start = _selectedDateRange!.start;
      final end = _selectedDateRange!.end;
      final startStr = DateFormat('dd MMM').format(start);
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return 'Tren Keuangan: $startStr';
      }
      final endStr = DateFormat('dd MMM').format(end);
      return 'Tren Keuangan: $startStr - $endStr';
    }

    switch (_timeframe) {
      case 'day':
        return 'Tren Keuangan Hari Ini';
      case 'week':
        return 'Tren Keuangan Minggu Ini';
      case 'month':
        return 'Tren Keuangan Bulan Ini';
      case 'year':
        return 'Tren Keuangan Tahun Ini';
      default:
        return 'Tren Keuangan';
    }
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work_outline;
      case 'card_giftcard':
        return Icons.card_giftcard_outlined;
      case 'download':
        return Icons.download_outlined;
      case 'add_circle':
        return Icons.add_circle_outline;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'sports_esports':
        return Icons.sports_esports_outlined;
      case 'swap_horiz':
        return Icons.swap_horiz;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getAccountIcon(String? iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'payment':
        return Icons.payment_outlined;
      default:
        return Icons.credit_card_outlined;
    }
  }

  void _showWalletFilterBottomSheet(
      BuildContext context, List<AccountWithBalance> accounts) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        // Define tempSelected here, outside the StatefulBuilder's builder callback to persist state!
        final tempSelected = Set<int>.from(_selectedAccountIds);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: isDarkMode ? AppColors.darkModal : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih rekening',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 6.0),
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  tempSelected.clear();
                                });
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: accounts.map((acc) {
                            final isChecked =
                                tempSelected.contains(acc.account.id);
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (isChecked) {
                                    tempSelected.remove(acc.account.id);
                                  } else {
                                    tempSelected.add(acc.account.id!);
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? (isDarkMode
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black
                                              .withValues(alpha: 0.05))
                                      : (isDarkMode
                                          ? Colors.white.withValues(alpha: 0.03)
                                          : Colors.black
                                              .withValues(alpha: 0.02)),
                                  border: Border.all(
                                    color: isChecked
                                        ? (isDarkMode
                                            ? Colors.white30
                                            : Colors.black38)
                                        : (isDarkMode
                                            ? Colors.white
                                                .withValues(alpha: 0.08)
                                            : Colors.black
                                                .withValues(alpha: 0.08)),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  children: [
                                    // Custom Checkbox
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? (isDarkMode
                                                ? Colors.white30
                                                : Colors.black26)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.white54
                                              : Colors.black38,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: isChecked
                                          ? const Icon(
                                              Icons.check,
                                              size: 14.0,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Icon(
                                      _getAccountIcon(acc.account.icon),
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            acc.account.name,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: isChecked
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            _formatRp(acc.balance),
                                            style: TextStyle(
                                              fontSize: 11.0,
                                              color: isDarkMode
                                                  ? Colors.white38
                                                  : Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.white : const Color(0xFF1E222B),
                        foregroundColor:
                            isDarkMode ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedAccountIds.clear();
                          _selectedAccountIds.addAll(tempSelected);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Tampilkan',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCalendarFilterBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDarkMode ? AppColors.darkModal : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih rentang waktu',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildCalendarOptionItem(
                  context,
                  label: 'Hari Ini',
                  icon: Icons.today_outlined,
                  isActive: _selectedDateRange == null && _timeframe == 'day',
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                      _timeframe = 'day';
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildCalendarOptionItem(
                  context,
                  label: 'Minggu Ini',
                  icon: Icons.view_week_outlined,
                  isActive: _selectedDateRange == null && _timeframe == 'week',
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                      _timeframe = 'week';
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildCalendarOptionItem(
                  context,
                  label: 'Bulan Ini',
                  icon: Icons.calendar_view_month_outlined,
                  isActive: _selectedDateRange == null && _timeframe == 'month',
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                      _timeframe = 'month';
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildCalendarOptionItem(
                  context,
                  label: 'Tahun Ini',
                  icon: Icons.calendar_today_outlined,
                  isActive: _selectedDateRange == null && _timeframe == 'year',
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                      _timeframe = 'year';
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildCalendarOptionItem(
                  context,
                  label: 'Pilih Range Tanggal',
                  icon: Icons.date_range_outlined,
                  isActive: _selectedDateRange != null,
                  onTap: () async {
                    Navigator.pop(context); // Close calendar options dialog

                    final DateTimeRange? pickedRange =
                        await showDialog<DateTimeRange>(
                      context: context,
                      builder: (ctx) {
                        return CustomDateRangePickerDialog(
                          initialDateRange: _selectedDateRange,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                      },
                    );

                    if (pickedRange != null) {
                      setState(() {
                        _selectedDateRange = pickedRange;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportMutasiPdf(
    BuildContext context,
    List<dynamic> txs,
    double totalIncome,
    double totalExpense,
    String accountFilterText,
  ) async {
    if (txs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Tidak ada data transaksi untuk diekspor pada periode ini.'),
          backgroundColor: AppColors.semanticRed,
        ),
      );
      return;
    }

    // Tampilkan Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final pdf = pw.Document();
      final titleText = _getAdaptiveTitle();
      final netBalance = totalIncome - totalExpense;

      // Ambil categories & accounts secara sinkron untuk pencarian di tabel
      final categories = ref.read(categoriesNotifierProvider).value ?? [];
      final accounts = ref.read(accountsNotifierProvider).value ?? [];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'MyDompet',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                    pw.Text(
                      'LAPORAN MUTASI KEUANGAN',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Periode: ${titleText.replaceFirst("Tren Keuangan: ", "").replaceFirst("Tren Keuangan ", "")}',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Rekening: $accountFilterText',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 12),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              // Summary Cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Pemasukan',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                          pw.SizedBox(height: 4),
                          pw.Text(_formatRp(totalIncome),
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.teal)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Pengeluaran',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                          pw.SizedBox(height: 4),
                          pw.Text(_formatRp(totalExpense),
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Selisih',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            (netBalance >= 0 ? '+' : '') +
                                _formatRp(netBalance),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: netBalance >= 0
                                  ? PdfColors.teal800
                                  : PdfColors.red800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Tabel Mutasi
              pw.TableHelper.fromTextArray(
                border: null,
                headerAlignment: pw.Alignment.centerLeft,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                headerHeight: 25,
                cellHeight: 25,
                headerStyle:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 9),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                ),
                headers: <String>[
                  'Tanggal',
                  'Kategori',
                  'Rekening',
                  'Catatan',
                  'Nominal'
                ],
                data: List<List<String>>.generate(txs.length, (index) {
                  final tx = txs[index];
                  final formattedDate =
                      DateFormat('dd MMM yyyy').format(tx.createdAt);

                  final category = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => Category(name: 'Lain-lain', type: tx.type),
                  );
                  final categoryName = category.name;

                  String accountName = '-';
                  if (accounts.isNotEmpty) {
                    final matchingAccount = accounts.firstWhere(
                      (a) => a.account.id == tx.accountId,
                      orElse: () => accounts.first,
                    );
                    accountName = matchingAccount.account.name;
                  }

                  final amountPrefix = tx.type == 'income' ? '+' : '-';
                  return <String>[
                    formattedDate,
                    categoryName,
                    accountName,
                    tx.note.isEmpty ? '-' : tx.note,
                    '$amountPrefix${_formatRp(tx.amount)}',
                  ];
                }),
                cellDecoration: (index, data, rowNum) {
                  if (rowNum == 0) return const pw.BoxDecoration();
                  return pw.BoxDecoration(
                    color: rowNum % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                  );
                },
              ),
            ];
          },
        ),
      );

      // Simpan Berkas
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/Mutasi_Keuangan_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      // Tutup Loading Dialog
      if (context.mounted) Navigator.pop(context);

      // Jalankan native share sheet
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Laporan Mutasi Keuangan - MyDompet',
      );
    } catch (e) {
      // Tutup Loading Dialog jika terjadi error
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppColors.semanticRed,
          ),
        );
      }
    }
  }

  Widget _buildCalendarOptionItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05))
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02)),
          border: Border.all(
            color: isActive
                ? (isDarkMode ? Colors.white30 : Colors.black38)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08)),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              size: 18,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isActive)
              Icon(
                Icons.check,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accounts = accountsAsync.value ?? [];
    final transactions = transactionsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];

    final filteredTxsForExport = transactions.where((tx) {
      final matchesAccount = _selectedAccountIds.isEmpty ||
          _selectedAccountIds.contains(tx.accountId);

      bool matchesDate = false;
      final now = DateTime.now();
      if (_selectedDateRange != null) {
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end;
        final actualEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
        matchesDate =
            tx.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
                tx.createdAt.isBefore(actualEnd);
      } else {
        if (_timeframe == 'day') {
          matchesDate = tx.createdAt.year == now.year &&
              tx.createdAt.month == now.month &&
              tx.createdAt.day == now.day;
        } else if (_timeframe == 'week') {
          final startOfWeek = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          matchesDate = tx.createdAt
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
        } else if (_timeframe == 'month') {
          matchesDate =
              tx.createdAt.year == now.year && tx.createdAt.month == now.month;
        } else if (_timeframe == 'year') {
          matchesDate = tx.createdAt.year == now.year;
        }
      }

      final category = categories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => Category(name: 'Lain-lain', type: tx.type),
      );
      final isNotTransfer = category.name.toLowerCase() != 'transfer';

      return matchesAccount && matchesDate && isNotTransfer;
    }).toList();

    final double totalIncomeForExport = filteredTxsForExport
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final double totalExpenseForExport = filteredTxsForExport
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final selectedAccName = _selectedAccountIds.isEmpty
        ? 'Semua Akun'
        : (_selectedAccountIds.length == 1
            ? accounts
                .firstWhere((a) => a.account.id == _selectedAccountIds.first,
                    orElse: () => accounts.first)
                .account
                .name
            : '${_selectedAccountIds.length} Rekening');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Unduh Mutasi',
            onPressed: () {
              _exportMutasiPdf(
                context,
                filteredTxsForExport,
                totalIncomeForExport,
                totalExpenseForExport,
                selectedAccName,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8.0, bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Filters Row with rounded card selection boxes matching dashboard dialog styles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // Wallet Selector Pill
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showWalletFilterBottomSheet(
                                  context, accounts),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1E222B)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : Colors.black.withValues(alpha: 0.03),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedAccName,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16.0,
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // Calendar Icon Button
                          GestureDetector(
                            onTap: () =>
                                _showCalendarFilterBottomSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF1E222B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : Colors.black.withValues(alpha: 0.03),
                                  width: 1.0,
                                ),
                              ),
                              child: Icon(
                                Icons.calendar_month_outlined,
                                size: 18.0,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDateRange != null) ...[
                        const SizedBox(height: 10.0),
                        Center(
                          child: InputChip(
                            label: Text(
                              'Rentang: ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedDateRange = null;
                              });
                            },
                            deleteIcon: const Icon(Icons.close, size: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 2. Data Rendering
                transactionsAsync.when(
                  data: (transactions) {
                    final categories = categoriesAsync.value ?? [];

                    // Apply filters to transactions
                    final now = DateTime.now();
                    final filteredTxs = transactions.where((tx) {
                      final matchesAccount = _selectedAccountIds.isEmpty ||
                          _selectedAccountIds.contains(tx.accountId);

                      // Filter by Date
                      bool matchesDate = false;
                      if (_selectedDateRange != null) {
                        final start = _selectedDateRange!.start;
                        final end = _selectedDateRange!.end;
                        final actualEnd =
                            DateTime(end.year, end.month, end.day, 23, 59, 59);
                        matchesDate = tx.createdAt.isAfter(
                                start.subtract(const Duration(seconds: 1))) &&
                            tx.createdAt.isBefore(actualEnd);
                      } else {
                        if (_timeframe == 'day') {
                          matchesDate = tx.createdAt.year == now.year &&
                              tx.createdAt.month == now.month &&
                              tx.createdAt.day == now.day;
                        } else if (_timeframe == 'week') {
                          final startOfWeek =
                              DateTime(now.year, now.month, now.day)
                                  .subtract(Duration(days: now.weekday - 1));
                          matchesDate = tx.createdAt.isAfter(
                              startOfWeek.subtract(const Duration(seconds: 1)));
                        } else if (_timeframe == 'month') {
                          matchesDate = tx.createdAt.year == now.year &&
                              tx.createdAt.month == now.month;
                        } else if (_timeframe == 'year') {
                          matchesDate = tx.createdAt.year == now.year;
                        }
                      }

                      // Exclude Transfer transactions from financial reports
                      final category = categories.firstWhere(
                        (c) => c.id == tx.categoryId,
                        orElse: () =>
                            Category(name: 'Lain-lain', type: tx.type),
                      );
                      final isNotTransfer =
                          category.name.toLowerCase() != 'transfer';

                      return matchesAccount && matchesDate && isNotTransfer;
                    }).toList();

                    // Calculate Summary Totals
                    final double totalIncome = filteredTxs
                        .where((tx) => tx.type == 'income')
                        .fold(0.0, (sum, tx) => sum + tx.amount);
                    final double totalExpense = filteredTxs
                        .where((tx) => tx.type == 'expense')
                        .fold(0.0, (sum, tx) => sum + tx.amount);

                    // Check if showing single day comparison
                    final bool isSingleDay =
                        (_selectedDateRange == null && _timeframe == 'day') ||
                            (_selectedDateRange != null &&
                                _selectedDateRange!.start.year ==
                                    _selectedDateRange!.end.year &&
                                _selectedDateRange!.start.month ==
                                    _selectedDateRange!.end.month &&
                                _selectedDateRange!.start.day ==
                                    _selectedDateRange!.end.day);

                    // Trend Line/Bar calculations for multi-day periods
                    List<FlSpot> lineSpotsIncome = [];
                    List<FlSpot> lineSpotsExpense = [];
                    List<String> bottomAxisLabels = [];
                    int totalChartPoints = 0;

                    if (!isSingleDay) {
                      if (_selectedDateRange != null) {
                        final start = _selectedDateRange!.start;
                        final end = _selectedDateRange!.end;
                        final daysInRange = end.difference(start).inDays + 1;

                        final List<DateTime> rangeDays =
                            List.generate(daysInRange, (i) {
                          final d = start.add(Duration(days: i));
                          return DateTime(d.year, d.month, d.day);
                        });

                        final Map<String, double> dailyExpenses = {};
                        final Map<String, double> dailyIncome = {};
                        final df = DateFormat('yyyy-MM-dd');
                        for (final day in rangeDays) {
                          dailyExpenses[df.format(day)] = 0.0;
                          dailyIncome[df.format(day)] = 0.0;
                        }

                        for (final tx in filteredTxs) {
                          final key = df.format(tx.createdAt);
                          if (dailyExpenses.containsKey(key)) {
                            if (tx.type == 'expense') {
                              dailyExpenses[key] =
                                  dailyExpenses[key]! + tx.amount;
                            } else if (tx.type == 'income') {
                              dailyIncome[key] = dailyIncome[key]! + tx.amount;
                            }
                          }
                        }

                        totalChartPoints = daysInRange;
                        lineSpotsExpense = List.generate(daysInRange, (i) {
                          final key = df.format(rangeDays[i]);
                          return FlSpot(
                              i.toDouble(), dailyExpenses[key] ?? 0.0);
                        });
                        lineSpotsIncome = List.generate(daysInRange, (i) {
                          final key = df.format(rangeDays[i]);
                          return FlSpot(i.toDouble(), dailyIncome[key] ?? 0.0);
                        });

                        bottomAxisLabels = List.generate(daysInRange, (i) {
                          final day = rangeDays[i];
                          if (daysInRange <= 7) {
                            return DateFormat('dd MMM').format(day);
                          } else {
                            if (i == 0 ||
                                i == daysInRange - 1 ||
                                i % (daysInRange ~/ 4) == 0) {
                              return DateFormat('dd MMM').format(day);
                            }
                            return '';
                          }
                        });
                      } else if (_timeframe == 'week') {
                        final startOfWeek =
                            DateTime(now.year, now.month, now.day)
                                .subtract(Duration(days: now.weekday - 1));
                        final List<DateTime> weekDays = List.generate(7, (i) {
                          final d = startOfWeek.add(Duration(days: i));
                          return DateTime(d.year, d.month, d.day);
                        });

                        final Map<String, double> dailyExpenses = {};
                        final Map<String, double> dailyIncome = {};
                        final df = DateFormat('yyyy-MM-dd');
                        for (final day in weekDays) {
                          dailyExpenses[df.format(day)] = 0.0;
                          dailyIncome[df.format(day)] = 0.0;
                        }

                        for (final tx in filteredTxs) {
                          final key = df.format(tx.createdAt);
                          if (dailyExpenses.containsKey(key)) {
                            if (tx.type == 'expense') {
                              dailyExpenses[key] =
                                  dailyExpenses[key]! + tx.amount;
                            } else if (tx.type == 'income') {
                              dailyIncome[key] = dailyIncome[key]! + tx.amount;
                            }
                          }
                        }

                        totalChartPoints = 7;
                        lineSpotsExpense = List.generate(7, (i) {
                          final key = df.format(weekDays[i]);
                          return FlSpot(
                              i.toDouble(), dailyExpenses[key] ?? 0.0);
                        });
                        lineSpotsIncome = List.generate(7, (i) {
                          final key = df.format(weekDays[i]);
                          return FlSpot(i.toDouble(), dailyIncome[key] ?? 0.0);
                        });

                        bottomAxisLabels = weekDays.map((day) {
                          return DateFormat('E', 'id_ID').format(day);
                        }).toList();
                      } else if (_timeframe == 'month') {
                        final daysInMonth =
                            DateTime(now.year, now.month + 1, 0).day;
                        final List<DateTime> monthDays =
                            List.generate(daysInMonth, (i) {
                          return DateTime(now.year, now.month, i + 1);
                        });

                        final Map<String, double> dailyExpenses = {};
                        final Map<String, double> dailyIncome = {};
                        final df = DateFormat('yyyy-MM-dd');
                        for (final day in monthDays) {
                          dailyExpenses[df.format(day)] = 0.0;
                          dailyIncome[df.format(day)] = 0.0;
                        }

                        for (final tx in filteredTxs) {
                          final key = df.format(tx.createdAt);
                          if (dailyExpenses.containsKey(key)) {
                            if (tx.type == 'expense') {
                              dailyExpenses[key] =
                                  dailyExpenses[key]! + tx.amount;
                            } else if (tx.type == 'income') {
                              dailyIncome[key] = dailyIncome[key]! + tx.amount;
                            }
                          }
                        }

                        totalChartPoints = daysInMonth;
                        lineSpotsExpense = List.generate(daysInMonth, (i) {
                          final key = df.format(monthDays[i]);
                          return FlSpot(
                              i.toDouble(), dailyExpenses[key] ?? 0.0);
                        });
                        lineSpotsIncome = List.generate(daysInMonth, (i) {
                          final key = df.format(monthDays[i]);
                          return FlSpot(i.toDouble(), dailyIncome[key] ?? 0.0);
                        });

                        bottomAxisLabels = List.generate(daysInMonth, (i) {
                          final dayNum = i + 1;
                          if (dayNum == 1 ||
                              dayNum == 5 ||
                              dayNum == 10 ||
                              dayNum == 15 ||
                              dayNum == 20 ||
                              dayNum == 25 ||
                              dayNum == daysInMonth) {
                            return dayNum.toString();
                          }
                          return '';
                        });
                      } else if (_timeframe == 'year') {
                        final Map<int, double> monthlyExpenses = {};
                        final Map<int, double> monthlyIncome = {};
                        for (int i = 1; i <= 12; i++) {
                          monthlyExpenses[i] = 0.0;
                          monthlyIncome[i] = 0.0;
                        }

                        for (final tx in filteredTxs) {
                          final m = tx.createdAt.month;
                          if (tx.type == 'expense') {
                            monthlyExpenses[m] =
                                monthlyExpenses[m]! + tx.amount;
                          } else if (tx.type == 'income') {
                            monthlyIncome[m] = monthlyIncome[m]! + tx.amount;
                          }
                        }

                        totalChartPoints = 12;
                        lineSpotsExpense = List.generate(12, (i) {
                          final monthNum = i + 1;
                          return FlSpot(
                              i.toDouble(), monthlyExpenses[monthNum] ?? 0.0);
                        });
                        lineSpotsIncome = List.generate(12, (i) {
                          final monthNum = i + 1;
                          return FlSpot(
                              i.toDouble(), monthlyIncome[monthNum] ?? 0.0);
                        });

                        bottomAxisLabels = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'Mei',
                          'Jun',
                          'Jul',
                          'Ags',
                          'Sep',
                          'Okt',
                          'Nov',
                          'Des'
                        ];
                      }
                    }

                    // 2a. Allocation Calculations based on active toggle
                    final Map<int, double> allocationByCategory = {};
                    for (final tx in filteredTxs) {
                      if (tx.type == _allocationType && tx.categoryId != null) {
                        allocationByCategory[tx.categoryId!] =
                            (allocationByCategory[tx.categoryId!] ?? 0.0) +
                                tx.amount;
                      }
                    }

                    final double totalForAllocation =
                        _allocationType == 'income'
                            ? totalIncome
                            : totalExpense;

                    final sortedAllocation = allocationByCategory.entries
                        .toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: Tren Pengeluaran
                        Card(
                          elevation: 0,
                          color: isDarkMode
                              ? const Color(0xFF1E222B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.03),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getAdaptiveTitle(),
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),

                                // Totals side-by-side
                                Builder(
                                  builder: (context) {
                                    final isIncomeActive =
                                        _showAllocationChart &&
                                            _allocationType == 'income';
                                    final isExpenseActive =
                                        _showAllocationChart &&
                                            _allocationType == 'expense';

                                    return Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? AppColors.darkCard
                                            : const Color(0xFFECEEEE),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: AnimatedAlign(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeInOutCubic,
                                              alignment: isIncomeActive
                                                  ? Alignment.centerLeft
                                                  : (isExpenseActive
                                                      ? Alignment.centerRight
                                                      : Alignment.center),
                                              child: FractionallySizedBox(
                                                widthFactor: 0.5,
                                                heightFactor: 1.0,
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 150),
                                                  decoration: BoxDecoration(
                                                    color: (isIncomeActive ||
                                                            isExpenseActive)
                                                        ? const Color(
                                                            0xFF2C2C2C)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (isIncomeActive) {
                                                        _showAllocationChart =
                                                            false;
                                                      } else {
                                                        _showAllocationChart =
                                                            true;
                                                        _allocationType =
                                                            'income';
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10.0),
                                                    color: Colors.transparent,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 8,
                                                              height: 8,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: AppColors
                                                                    .income,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            AnimatedDefaultTextStyle(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          150),
                                                              style: TextStyle(
                                                                fontSize: 11.5,
                                                                fontWeight: isIncomeActive
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                                color: isIncomeActive
                                                                    ? Colors
                                                                        .white
                                                                    : (isDarkMode
                                                                        ? Colors.grey[
                                                                            400]
                                                                        : Colors
                                                                            .grey[600]),
                                                              ),
                                                              child: const Text(
                                                                  'Pemasukan'),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        AnimatedDefaultTextStyle(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      150),
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                isIncomeActive
                                                                    ? Colors
                                                                        .white
                                                                    : AppColors
                                                                        .income,
                                                          ),
                                                          child: Text(_formatRp(
                                                              totalIncome)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (isExpenseActive) {
                                                        _showAllocationChart =
                                                            false;
                                                      } else {
                                                        _showAllocationChart =
                                                            true;
                                                        _allocationType =
                                                            'expense';
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10.0),
                                                    color: Colors.transparent,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 8,
                                                              height: 8,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: AppColors
                                                                    .expense,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            AnimatedDefaultTextStyle(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          150),
                                                              style: TextStyle(
                                                                fontSize: 11.5,
                                                                fontWeight: isExpenseActive
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                                color: isExpenseActive
                                                                    ? Colors
                                                                        .white
                                                                    : (isDarkMode
                                                                        ? Colors.grey[
                                                                            400]
                                                                        : Colors
                                                                            .grey[600]),
                                                              ),
                                                              child: const Text(
                                                                  'Pengeluaran'),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        AnimatedDefaultTextStyle(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      150),
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                isExpenseActive
                                                                    ? Colors
                                                                        .white
                                                                    : AppColors
                                                                        .expense,
                                                          ),
                                                          child: Text(_formatRp(
                                                              totalExpense)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14.0),

                                // Net Difference (Selisih)
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Selisih ',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: (totalIncome - totalExpense >= 0
                                                  ? '+'
                                                  : '') +
                                              _formatRp(
                                                  totalIncome - totalExpense),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                totalIncome - totalExpense >= 0
                                                    ? const Color(0xFF0D9488)
                                                    : const Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24.0),

                                // Bar chart
                                if (isSingleDay)
                                  Builder(
                                    builder: (context) {
                                      final double activeMax =
                                          _showAllocationChart
                                              ? (_allocationType == 'income'
                                                  ? totalIncome
                                                  : totalExpense)
                                              : max(totalIncome, totalExpense);
                                      final double singleDayMaxY =
                                          activeMax == 0
                                              ? 1000.0
                                              : activeMax * 1.15;

                                      return SizedBox(
                                        height:
                                            200, // increased scrollview height to allow vertical tooltip float
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 24.0, left: 8.0, right: 8.0),
                                          child: BarChart(
                                            BarChartData(
                                              alignment:
                                                  BarChartAlignment.spaceEvenly,
                                              maxY: singleDayMaxY,
                                              barTouchData: BarTouchData(
                                                enabled: true,
                                                touchTooltipData:
                                                    BarTouchTooltipData(
                                                  fitInsideHorizontally: true,
                                                  fitInsideVertically: true,
                                                  getTooltipColor: (group) {
                                                    if (_showAllocationChart) {
                                                      return _allocationType ==
                                                              'income'
                                                          ? const Color(
                                                              0xFF0D9488)
                                                          : const Color(
                                                              0xFFDC2626);
                                                    }
                                                    return group.x == 0
                                                        ? const Color(
                                                            0xFF0D9488)
                                                        : const Color(
                                                            0xFFDC2626); // Green for Pemasukan, Red for Pengeluaran
                                                  },
                                                  tooltipBorderRadius:
                                                      BorderRadius.circular(8),
                                                  getTooltipItem: (group,
                                                      groupIndex,
                                                      rod,
                                                      rodIndex) {
                                                    return BarTooltipItem(
                                                      _formatRp(rod.toY),
                                                      const TextStyle(
                                                        color: Colors
                                                            .white, // white text stands out on green/red bg
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              titlesData: FlTitlesData(
                                                rightTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                topTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                leftTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget:
                                                        (val, meta) {
                                                      if (val == 0) {
                                                        return const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 8.0),
                                                          child: Text(
                                                            'Pemasukan',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        );
                                                      } else if (val == 1) {
                                                        return const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 8.0),
                                                          child: Text(
                                                            'Pengeluaran',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      return const SizedBox();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              gridData:
                                                  const FlGridData(show: false),
                                              borderData:
                                                  FlBorderData(show: false),
                                              barGroups: [
                                                if (!_showAllocationChart ||
                                                    _allocationType == 'income')
                                                  BarChartGroupData(
                                                    x: 0,
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: totalIncome,
                                                        width: 48,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            AppColors.income,
                                                            Color(0xFF2DD4BF)
                                                          ],
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                        ),
                                                        backDrawRodData:
                                                            BackgroundBarChartRodData(
                                                          show: true,
                                                          toY: singleDayMaxY,
                                                          color: isDarkMode
                                                              ? Colors.white
                                                                  .withValues(
                                                                      alpha:
                                                                          0.04)
                                                              : Colors.black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.04),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (!_showAllocationChart ||
                                                    _allocationType ==
                                                        'expense')
                                                  BarChartGroupData(
                                                    x: 1,
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: totalExpense,
                                                        width: 48,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color(0xFFDC2626),
                                                            Color(0xFFF87171)
                                                          ],
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                        ),
                                                        backDrawRodData:
                                                            BackgroundBarChartRodData(
                                                          show: true,
                                                          toY: singleDayMaxY,
                                                          color: isDarkMode
                                                              ? Colors.white
                                                                  .withValues(
                                                                      alpha:
                                                                          0.04)
                                                              : Colors.black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.04),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  // Scrollable Trend Bar Chart showing both Income and Expense side-by-side
                                  Builder(
                                    builder: (context) {
                                      final double maxAmount;
                                      if (_showAllocationChart) {
                                        if (_allocationType == 'income') {
                                          maxAmount = lineSpotsIncome.isEmpty
                                              ? 1000.0
                                              : lineSpotsIncome
                                                  .map((s) => s.y)
                                                  .reduce(
                                                      (a, b) => a > b ? a : b);
                                        } else {
                                          maxAmount = lineSpotsExpense.isEmpty
                                              ? 1000.0
                                              : lineSpotsExpense
                                                  .map((s) => s.y)
                                                  .reduce(
                                                      (a, b) => a > b ? a : b);
                                        }
                                      } else {
                                        maxAmount = lineSpotsExpense.isEmpty
                                            ? 1000.0
                                            : max(
                                                lineSpotsExpense
                                                    .map((s) => s.y)
                                                    .reduce((a, b) =>
                                                        a > b ? a : b),
                                                lineSpotsIncome.isEmpty
                                                    ? 0.0
                                                    : lineSpotsIncome
                                                        .map((s) => s.y)
                                                        .reduce((a, b) =>
                                                            a > b ? a : b),
                                              );
                                      }
                                      final double chartMaxY = maxAmount == 0
                                          ? 1000.0
                                          : maxAmount *
                                              1.15; // compact chart headroom

                                      final isMonth = _timeframe == 'month' ||
                                          totalChartPoints > 15;

                                      return SizedBox(
                                        height:
                                            200, // increased scrollview height to allow vertical tooltip float
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          // clipBehavior remains default hardEdge to prevent horizontal bars bleed outside the card
                                          child: Container(
                                            width: max(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    64.0,
                                                totalChartPoints *
                                                    (isMonth ? 36.0 : 52.0)),
                                            padding: const EdgeInsets.only(
                                                top: 24.0,
                                                left: 8.0,
                                                right:
                                                    8.0), // top padding keeps tooltip inside scrollview bounds
                                            child: BarChart(
                                              BarChartData(
                                                alignment: BarChartAlignment
                                                    .spaceAround,
                                                maxY: chartMaxY,
                                                barTouchData: BarTouchData(
                                                  enabled: true,
                                                  touchTooltipData:
                                                      BarTouchTooltipData(
                                                    fitInsideHorizontally: true,
                                                    fitInsideVertically: true,
                                                    getTooltipColor: (group) {
                                                      if (_showAllocationChart) {
                                                        return _allocationType ==
                                                                'income'
                                                            ? const Color(
                                                                0xFF0D9488)
                                                            : const Color(
                                                                0xFFDC2626);
                                                      }
                                                      // Dynamic tooltip color: Green if Pemasukan is higher, Red if Pengeluaran is higher
                                                      final income =
                                                          group.barRods[0].toY;
                                                      final expense =
                                                          group.barRods[1].toY;
                                                      if (income > expense) {
                                                        return const Color(
                                                            0xFF0D9488);
                                                      } else {
                                                        return const Color(
                                                            0xFFDC2626);
                                                      }
                                                    },
                                                    tooltipBorderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    getTooltipItem: (group,
                                                        groupIndex,
                                                        rod,
                                                        rodIndex) {
                                                      return BarTooltipItem(
                                                        _formatRp(rod.toY),
                                                        const TextStyle(
                                                          color: Colors
                                                              .white, // white text stands out on green/red bg
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                titlesData: FlTitlesData(
                                                  rightTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false)),
                                                  topTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false)),
                                                  leftTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false)),
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      getTitlesWidget:
                                                          (val, meta) {
                                                        final index =
                                                            val.toInt();
                                                        if (index >= 0 &&
                                                            index <
                                                                totalChartPoints) {
                                                          final label =
                                                              bottomAxisLabels[
                                                                  index];
                                                          if (label.isEmpty) {
                                                            return const SizedBox();
                                                          }
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 6.0),
                                                            child: Text(
                                                              label,
                                                              style: const TextStyle(
                                                                  fontSize: 9,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                gridData: const FlGridData(
                                                    show: false),
                                                borderData:
                                                    FlBorderData(show: false),
                                                barGroups: List.generate(
                                                    totalChartPoints, (index) {
                                                  final incomeAmt =
                                                      lineSpotsIncome[index].y;
                                                  final expenseAmt =
                                                      lineSpotsExpense[index].y;
                                                  final rodWidth =
                                                      isMonth ? 12.0 : 18.0;
                                                  final rRadius =
                                                      isMonth ? 4.0 : 6.0;

                                                  return BarChartGroupData(
                                                    x: index,
                                                    barRods: [
                                                      if (!_showAllocationChart ||
                                                          _allocationType ==
                                                              'income')
                                                        // Pemasukan Bar (Green Gradient)
                                                        BarChartRodData(
                                                          toY: incomeAmt,
                                                          width: rodWidth,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      rRadius),
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              AppColors.income,
                                                              Color(0xFF2DD4BF)
                                                            ],
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                          ),
                                                          backDrawRodData:
                                                              BackgroundBarChartRodData(
                                                            show: true,
                                                            toY: chartMaxY,
                                                            color: isDarkMode
                                                                ? Colors.white
                                                                    .withValues(
                                                                        alpha:
                                                                            0.04)
                                                                : Colors.black
                                                                    .withValues(
                                                                        alpha:
                                                                            0.04),
                                                          ),
                                                        ),
                                                      if (!_showAllocationChart ||
                                                          _allocationType ==
                                                              'expense')
                                                        // Pengeluaran Bar (Red Gradient)
                                                        BarChartRodData(
                                                          toY: expenseAmt,
                                                          width: rodWidth,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      rRadius),
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              Color(0xFFDC2626),
                                                              Color(0xFFF87171)
                                                            ],
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                          ),
                                                          backDrawRodData:
                                                              BackgroundBarChartRodData(
                                                            show: true,
                                                            toY: chartMaxY,
                                                            color: isDarkMode
                                                                ? Colors.white
                                                                    .withValues(
                                                                        alpha:
                                                                            0.04)
                                                                : Colors.black
                                                                    .withValues(
                                                                        alpha:
                                                                            0.04),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Card 2: Alokasi Dana (Flexible toggling income/expense with Donut/Pie Chart kept)
                        if (_showAllocationChart) ...[
                          Card(
                            elevation: 0,
                            color: isDarkMode
                                ? const Color(0xFF1E222B)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _allocationType == 'income'
                                            ? 'Alokasi Pemasukan'
                                            : 'Alokasi Pengeluaran',
                                        style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded,
                                            size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _showAllocationChart = false;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Donut/Pie Chart Breakdown (Kept as requested)
                                  if (sortedAllocation.isNotEmpty) ...[
                                    SizedBox(
                                      height: 180,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 4,
                                          centerSpaceRadius: 45,
                                          startDegreeOffset: -90,
                                          sections:
                                              sortedAllocation.map((entry) {
                                            final catId = entry.key;
                                            final amt = entry.value;
                                            final cat = categories.firstWhere(
                                                (c) => c.id == catId,
                                                orElse: () => Category(
                                                    name: 'Lain-lain',
                                                    type: _allocationType));
                                            final catColor = cat.color;

                                            return PieChartSectionData(
                                              color: catColor,
                                              value: amt,
                                              title: '',
                                              radius: 40,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                  ],

                                  // List of allocation categories matching layout style
                                  if (sortedAllocation.isEmpty)
                                    SizedBox(
                                      height: 120,
                                      child: Center(
                                        child: Text(
                                          'Tidak ada data ${_allocationType == 'income' ? 'pemasukan' : 'pengeluaran'}.',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    )
                                  else
                                    ...sortedAllocation.map((entry) {
                                      final catId = entry.key;
                                      final amt = entry.value;
                                      final cat = categories.firstWhere(
                                          (c) => c.id == catId,
                                          orElse: () => Category(
                                              name: 'Lain-lain',
                                              type: _allocationType));
                                      final catColor = cat.color;

                                      final pct = totalForAllocation > 0
                                          ? (amt / totalForAllocation) * 100
                                          : 0.0;

                                      // Filter transactions of this category in the range
                                      final catTxs = filteredTxs
                                          .where(
                                              (tx) => tx.categoryId == cat.id)
                                          .toList();

                                      final dateRangeStr = _selectedDateRange !=
                                              null
                                          ? '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                                          : _timeframe == 'day'
                                              ? 'Hari Ini'
                                              : _timeframe == 'week'
                                                  ? 'Minggu Ini'
                                                  : _timeframe == 'month'
                                                      ? 'Bulan Ini'
                                                      : 'Tahun Ini';

                                      return InkWell(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetailScreen(
                                                category: cat,
                                                transactions: catTxs,
                                                accountName: selectedAccName,
                                                dateRangeStr: dateRangeStr,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Row(
                                            children: [
                                              // Circular Icon Lead
                                              Container(
                                                width: 36.0,
                                                height: 36.0,
                                                decoration: BoxDecoration(
                                                  color: catColor.withValues(
                                                      alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _getCategoryIcon(cat.icon),
                                                  color: catColor,
                                                  size: 18.0,
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),

                                              // Category name and Amount subtitle
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      cat.name,
                                                      style: const TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2.0),
                                                    Text(
                                                      _formatRp(amt),
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isDarkMode
                                                            ? Colors.white70
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Percentage and Arrow chevron right
                                              Row(
                                                children: [
                                                  Text(
                                                    '${pct.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Icon(
                                                    Icons.chevron_right,
                                                    size: 18.0,
                                                    color: isDarkMode
                                                        ? Colors.white54
                                                        : Colors.black54,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) =>
                      Center(child: Text('Error loading report: $err')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDateRangePickerDialog({
    super.key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
  late DateTime _currentMonth;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  bool _isInputMode = false;

  late TextEditingController _startInputController;
  late TextEditingController _endInputController;
  String? _startError;
  String? _endError;

  @override
  void initState() {
    super.initState();
    _selectedStart = widget.initialDateRange?.start;
    _selectedEnd = widget.initialDateRange?.end;
    _currentMonth = _selectedStart ?? DateTime.now();
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);

    _startInputController = TextEditingController(
      text: _selectedStart != null
          ? DateFormat('dd/MM/yyyy').format(_selectedStart!)
          : '',
    );
    _endInputController = TextEditingController(
      text: _selectedEnd != null
          ? DateFormat('dd/MM/yyyy').format(_selectedEnd!)
          : '',
    );
  }

  @override
  void dispose() {
    _startInputController.dispose();
    _endInputController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_selectedStart == null ||
          (_selectedStart != null && _selectedEnd != null)) {
        _selectedStart = day;
        _selectedEnd = null;
      } else {
        if (day.isBefore(_selectedStart!)) {
          _selectedStart = day;
        } else {
          _selectedEnd = day;
        }
      }
      _startInputController.text = _selectedStart != null
          ? DateFormat('dd/MM/yyyy').format(_selectedStart!)
          : '';
      _endInputController.text = _selectedEnd != null
          ? DateFormat('dd/MM/yyyy').format(_selectedEnd!)
          : '';
      _startError = null;
      _endError = null;
    });
  }

  void _toggleInputMode() {
    setState(() {
      _isInputMode = !_isInputMode;
      if (!_isInputMode && _selectedStart != null) {
        _currentMonth =
            DateTime(_selectedStart!.year, _selectedStart!.month, 1);
      }
    });
  }

  DateTime? _parseDate(String text) {
    try {
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          final parsed = DateTime(year, month, day);
          if (parsed.year == year &&
              parsed.month == month &&
              parsed.day == day) {
            return parsed;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  void _validateAndSetStartDate(String val) {
    if (val.isEmpty) {
      setState(() {
        _startError = null;
        _selectedStart = null;
      });
      return;
    }
    final parsed = _parseDate(val);
    if (parsed == null) {
      setState(() {
        _startError = 'Format salah';
      });
    } else if (parsed.isBefore(widget.firstDate) ||
        parsed.isAfter(widget.lastDate)) {
      setState(() {
        _startError = 'Di luar rentang';
      });
    } else {
      setState(() {
        _startError = null;
        _selectedStart = parsed;
      });
    }
  }

  void _validateAndSetEndDate(String val) {
    if (val.isEmpty) {
      setState(() {
        _endError = null;
        _selectedEnd = null;
      });
      return;
    }
    final parsed = _parseDate(val);
    if (parsed == null) {
      setState(() {
        _endError = 'Format salah';
      });
    } else if (parsed.isBefore(widget.firstDate) ||
        parsed.isAfter(widget.lastDate)) {
      setState(() {
        _endError = 'Di luar rentang';
      });
    } else if (_selectedStart != null && parsed.isBefore(_selectedStart!)) {
      setState(() {
        _endError = 'Sebelum mulai';
      });
    } else {
      setState(() {
        _endError = null;
        _selectedEnd = parsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : Colors.black;
    final onPrimaryColor = isDarkMode ? Colors.black : Colors.white;
    final surfaceColor = isDarkMode ? AppColors.darkModal : Colors.white;
    final rangeHighlightColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    final days = _generateDays(_currentMonth);
    final weekdayLabels = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];

    final headerText = _selectedStart == null
        ? 'Mulai – Selesai'
        : _selectedEnd == null
            ? '${DateFormat('E, d MMM', 'id_ID').format(_selectedStart!)} – ...'
            : '${DateFormat('E, d MMM', 'id_ID').format(_selectedStart!)} – ${DateFormat('E, d MMM', 'id_ID').format(_selectedEnd!)}';

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 328),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Standard M3 Date Picker Header Area
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 12.0, top: 24.0, bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PILIH RENTANG TANGGAL',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: isDarkMode
                                ? Colors.white60
                                : Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          headerText,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w400,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isInputMode
                          ? Icons.calendar_today_outlined
                          : Icons.edit_outlined,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.black.withValues(alpha: 0.6),
                    ),
                    onPressed: _toggleInputMode,
                  ),
                ],
              ),
            ),

            // Header-Body Divider
            Divider(
                height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),

            if (_isInputMode)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startInputController,
                            keyboardType: TextInputType.datetime,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tanggal Mulai',
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black54,
                                fontSize: 12.0,
                              ),
                              hintText: 'HH/BB/TTTT',
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white30
                                    : Colors.black38,
                              ),
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2.0),
                              ),
                              errorText: _startError,
                              errorStyle: const TextStyle(fontSize: 10.0),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            onChanged: _validateAndSetStartDate,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextFormField(
                            controller: _endInputController,
                            keyboardType: TextInputType.datetime,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tanggal Selesai',
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black54,
                                fontSize: 12.0,
                              ),
                              hintText: 'HH/BB/TTTT',
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white30
                                    : Colors.black38,
                              ),
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2.0),
                              ),
                              errorText: _endError,
                              errorStyle: const TextStyle(fontSize: 10.0),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            onChanged: _validateAndSetEndDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Format: HH/BB/TTTT (misal: 05/07/2026)',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month Year & Navigation Row (M3 Style)
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID')
                              .format(_currentMonth),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode
                              ? Colors.white60
                              : Colors.black.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: primaryColor),
                          onPressed: _currentMonth.isAfter(DateTime(
                                  widget.firstDate.year,
                                  widget.firstDate.month,
                                  1))
                              ? () {
                                  setState(() {
                                    _currentMonth = DateTime(_currentMonth.year,
                                        _currentMonth.month - 1, 1);
                                  });
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: primaryColor),
                          onPressed: _currentMonth.isBefore(DateTime(
                                  widget.lastDate.year,
                                  widget.lastDate.month,
                                  1))
                              ? () {
                                  setState(() {
                                    _currentMonth = DateTime(_currentMonth.year,
                                        _currentMonth.month + 1, 1);
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),

                    // Weekday Labels Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekdayLabels.map((label) {
                        return SizedBox(
                          width: 38,
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6.0),

                    // Calendar Days Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 2.0,
                        crossAxisSpacing: 0.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        if (day == null) {
                          return const SizedBox.shrink();
                        }

                        final isStart = _selectedStart != null &&
                            _isSameDay(day, _selectedStart!);
                        final isEnd = _selectedEnd != null &&
                            _isSameDay(day, _selectedEnd!);
                        final isInRange = _selectedStart != null &&
                            _selectedEnd != null &&
                            day.isAfter(_selectedStart!) &&
                            day.isBefore(_selectedEnd!);
                        final isToday = _isSameDay(day, DateTime.now());

                        Widget dayWidget = Center(
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: (isStart || isEnd)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: (isStart || isEnd)
                                  ? onPrimaryColor
                                  : (isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                          ),
                        );

                        if (isStart || isEnd) {
                          dayWidget = Stack(
                            children: [
                              // Background Range Connector
                              if (_selectedEnd != null)
                                Positioned.fill(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: isStart
                                              ? Colors.transparent
                                              : rangeHighlightColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: isEnd
                                              ? Colors.transparent
                                              : rangeHighlightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Circular Indicator
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor,
                                  ),
                                  child: dayWidget,
                                ),
                              ),
                            ],
                          );
                        } else if (isInRange) {
                          dayWidget = Container(
                            color: rangeHighlightColor,
                            child: dayWidget,
                          );
                        } else if (isToday) {
                          // Outline border for today if not selected
                          dayWidget = Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white30
                                      : Colors.black.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: dayWidget,
                            ),
                          );
                        }

                        return GestureDetector(
                          onTap: () => _onDaySelected(day),
                          behavior: HitTestBehavior.opaque,
                          child: dayWidget,
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8.0),

            // Action Buttons Row (Standard Dialog Actions Alignment)
            Padding(
              padding:
                  const EdgeInsets.only(right: 16.0, bottom: 12.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: (_selectedStart != null &&
                            _startError == null &&
                            _endError == null)
                        ? () {
                            Navigator.pop(
                              context,
                              DateTimeRange(
                                start: _selectedStart!,
                                end: _selectedEnd ?? _selectedStart!,
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      'Oke',
                      style: TextStyle(
                        color: (_selectedStart != null &&
                                _startError == null &&
                                _endError == null)
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _generateDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final list = <DateTime?>[];
    final emptyCells = firstDay.weekday % 7;
    for (int i = 0; i < emptyCells; i++) {
      list.add(null);
    }

    for (int i = 1; i <= lastDay.day; i++) {
      list.add(DateTime(month.year, month.month, i));
    }

    return list;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

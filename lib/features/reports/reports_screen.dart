import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  int? _localAccountId; // null means "Semua Akun"
  String _timeframe = 'month'; // 'day' | 'week' | 'month' | 'year'
  DateTimeRange? _selectedDateRange; // null means no custom date range
  String _allocationType = 'expense'; // 'income' | 'expense'

  final List<Color> _chartColors = [
    const Color(0xFFEF4444), // Coral Red
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF14B8A6), // Teal
    Colors.grey,
  ];

  String _formatRp(double val) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
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

  void _showAccountSelectorBottomSheet(
      BuildContext context, WidgetRef ref, List<AccountWithBalance> accounts) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pilih Dompet / Akun',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: const Text('Semua Akun', style: TextStyle(fontSize: 14.0)),
                trailing: _localAccountId == null
                    ? const Icon(Icons.check, color: Color(0xFF10B981))
                    : null,
                onTap: () {
                  setState(() {
                    _localAccountId = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ...accounts.map((acc) {
                return ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  title: Text(acc.account.name, style: const TextStyle(fontSize: 14.0)),
                  trailing: _localAccountId == acc.account.id
                      ? const Icon(Icons.check, color: Color(0xFF10B981))
                      : null,
                  onTap: () {
                    setState(() {
                      _localAccountId = acc.account.id;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () async {
              final DateTimeRange? pickedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: _selectedDateRange,
                builder: (context, child) {
                  return Theme(
                    data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
                    child: child!,
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8.0, bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDateRange != null ? null : _timeframe,
                        disabledHint: Text(
                          'Kustom (Aktif)',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                            fontSize: 12.0,
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Periode',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'day',
                            child: Text('Hari Ini',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: 'week',
                            child: Text('Minggu Ini',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: 'month',
                            child: Text('Bulan Ini',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: 'year',
                            child: Text('Tahun Ini',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                        ],
                        onChanged: _selectedDateRange != null
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() {
                                    _timeframe = val;
                                  });
                                }
                              },
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
                const SizedBox(height: 16.0),

                // 2. Data Rendering
                transactionsAsync.when(
                  data: (transactions) {
                    final categories = categoriesAsync.value ?? [];
                    final accounts = accountsAsync.value ?? [];

                    // Apply filters to transactions
                    final now = DateTime.now();
                    final filteredTxs = transactions.where((tx) {
                      final matchesAccount = _localAccountId == null ||
                          tx.accountId == _localAccountId;

                      // Filter by Date
                      bool matchesDate = false;
                      if (_selectedDateRange != null) {
                        final start = _selectedDateRange!.start;
                        final end = _selectedDateRange!.end;
                        final actualEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
                        matchesDate = tx.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
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
                        _allocationType == 'income' ? totalIncome : totalExpense;

                    final sortedAllocation = allocationByCategory.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    // Selected account name helper
                    final selectedAccName = _localAccountId == null
                        ? 'Semua Akun'
                        : accounts
                            .firstWhere((a) => a.account.id == _localAccountId,
                                orElse: () => accounts.first)
                            .account
                            .name;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: Tren Pengeluaran Harian
                        Card(
                          elevation: 0,
                          color: isDarkMode
                              ? const Color(0xFF1E222B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.black.withOpacity(0.03),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Account selector row button
                                InkWell(
                                  onTap: () => _showAccountSelectorBottomSheet(
                                      context, ref, accounts),
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white12
                                            : Colors.black12,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedAccName,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 18.0,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Totals side-by-side
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Pemasukan',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatRp(totalIncome),
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 1,
                                      color: isDarkMode
                                          ? Colors.white24
                                          : Colors.black12,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFEF4444),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Pengeluaran',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatRp(totalExpense),
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                            color: totalIncome - totalExpense >= 0
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24.0),

                                // Enlarged Bar Chart with exactly 2 comparison bars
                                SizedBox(
                                  height: 240,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceEvenly,
                                      maxY: max(totalIncome, totalExpense) == 0
                                          ? 1000.0
                                          : max(totalIncome, totalExpense) *
                                              1.15,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor: (_) => isDarkMode
                                              ? const Color(0xFF1E222B)
                                              : const Color(0xFFECEEEE),
                                          tooltipBorderRadius:
                                              BorderRadius.circular(8),
                                          getTooltipItem: (group, groupIndex,
                                              rod, rodIndex) {
                                            return BarTooltipItem(
                                              _formatRp(rod.toY),
                                              TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        leftTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (val, meta) {
                                              if (val == 0) {
                                                return const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    'Pemasukan',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              } else if (val == 1) {
                                                return const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    'Pengeluaran',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                          ),
                                        ),
                                      ),
                                      gridData: const FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: totalIncome,
                                              width: 52,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: const Color(0xFF10B981),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: totalExpense,
                                              width: 52,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Card 2: Alokasi Dana (Flexible toggling income/expense)
                        Card(
                          elevation: 0,
                          color: isDarkMode
                              ? const Color(0xFF1E222B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.black.withOpacity(0.03),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Alokasi Dana',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16.0),

                                // Toggle buttons matching Gambar 2
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => _allocationType = 'income'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          decoration: BoxDecoration(
                                            color: _allocationType == 'income'
                                                ? const Color(0xFF10B981)
                                                    .withOpacity(0.12)
                                                : (isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.04)
                                                    : Colors.black
                                                        .withOpacity(0.03)),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            border: Border.all(
                                              color: _allocationType == 'income'
                                                  ? const Color(0xFF10B981)
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            'Pemasukan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.bold,
                                              color: _allocationType == 'income'
                                                  ? const Color(0xFF10B981)
                                                  : (isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => _allocationType = 'expense'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          decoration: BoxDecoration(
                                            color: _allocationType == 'expense'
                                                ? const Color(0xFFEF4444)
                                                    .withOpacity(0.12)
                                                : (isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.04)
                                                    : Colors.black
                                                        .withOpacity(0.03)),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            border: Border.all(
                                              color: _allocationType == 'expense'
                                                  ? const Color(0xFFEF4444)
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            'Pengeluaran',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.bold,
                                              color: _allocationType ==
                                                      'expense'
                                                  ? const Color(0xFFEF4444)
                                                  : (isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),

                                // Categories list
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
                                    final index = categories.indexOf(cat) %
                                        _chartColors.length;

                                    final pct = totalForAllocation > 0
                                        ? (amt / totalForAllocation) * 100
                                        : 0.0;

                                    return InkWell(
                                      onTap: () {
                                        final catTxs = filteredTxs
                                            .where((tx) =>
                                                tx.categoryId == cat.id)
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
                                                color: _chartColors[index]
                                                    .withOpacity(0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _getCategoryIcon(cat.icon),
                                                color: _chartColors[index],
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
                                                  style: const TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
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

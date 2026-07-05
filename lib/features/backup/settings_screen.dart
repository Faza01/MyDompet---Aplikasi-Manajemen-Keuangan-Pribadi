import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/database_backup_helper.dart';
import '../accounts/accounts_provider.dart';
import '../accounts/accounts_screen.dart';
import '../budgeting/categories_provider.dart';
import '../transactions/transactions_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final accounts = accountsAsync.value ?? [];
    final int activeWalletsCount = accounts.length;
    final double totalBalance = accounts.fold(0.0, (sum, item) => sum + item.balance);

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final String formattedTotal = formatter.format(totalBalance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 8.0, bottom: 100.0),
          children: [
            // Header Summary Card
            _buildHeaderCard(
              isDarkMode: isDarkMode,
              walletCount: activeWalletsCount,
              totalBalance: formattedTotal,
            ),

            // Section 1: Accounts Management
            _buildSectionHeader('Akun & Dompet', isDarkMode),
            _buildSectionContainer(
              isDarkMode: isDarkMode,
              children: [
                _buildSettingsItemRow(
                  icon: Icons.account_balance_wallet_outlined,
                  iconBgColor: AppColors.accentTeal.withValues(alpha: 0.1),
                  iconColor: AppColors.accentTeal,
                  title: 'Kelola Dompet & Akun',
                  subtitle: 'Tambah, edit, hapus dompet, dan transfer dana',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountsScreen()),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),

            // Section 2: Backup & Restore
            _buildSectionHeader('Cadangkan & Pulihkan', isDarkMode),
            _buildSectionContainer(
              isDarkMode: isDarkMode,
              children: [
                _buildSettingsItemRow(
                  icon: Icons.upload_file_outlined,
                  iconBgColor: AppColors.accentOrange.withValues(alpha: 0.1),
                  iconColor: AppColors.accentOrange,
                  title: 'Ekspor Data (Backup)',
                  subtitle: 'Cadangkan seluruh data ke berkas JSON',
                  onTap: () async {
                    try {
                      await DatabaseBackupHelper.exportAndShare();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data berhasil diekspor!'),
                            backgroundColor: AppColors.accentTeal,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal mengekspor data: $e'),
                            backgroundColor: AppColors.semanticRed,
                          ),
                        );
                      }
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildSettingsDivider(isDarkMode),
                _buildSettingsItemRow(
                  icon: Icons.file_download_outlined,
                  iconBgColor: AppColors.accentTeal.withValues(alpha: 0.1),
                  iconColor: AppColors.accentTeal,
                  title: 'Impor Data (Restore)',
                  subtitle: 'Pulihkan data dari teks cadangan JSON',
                  onTap: () {
                    _showImportDialog(context, ref);
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),

            // Section 3: Danger Zone
            _buildSectionHeader('Zona Bahaya', isDarkMode, isDanger: true),
            _buildSectionContainer(
              isDarkMode: isDarkMode,
              isDanger: true,
              children: [
                _buildSettingsItemRow(
                  icon: Icons.delete_forever_outlined,
                  iconBgColor: AppColors.semanticRed.withValues(alpha: 0.1),
                  iconColor: AppColors.semanticRed,
                  title: 'Reset Semua Data',
                  subtitle:
                      'Hapus semua transaksi dan kembalikan ke pengaturan awal',
                  onTap: () {
                    _confirmResetData(context, ref);
                  },
                  isDarkMode: isDarkMode,
                  isDanger: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required bool isDarkMode,
    required int walletCount,
    required String totalBalance,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.accentTeal,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keuangan Anda aman',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '$walletCount Dompet Aktif • $totalBalance',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 11.0,
            decoration: BoxDecoration(
              color: isDanger ? AppColors.semanticRed : AppColors.accentTeal,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDanger
                  ? AppColors.semanticRed
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required bool isDarkMode,
    required List<Widget> children,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDanger
              ? AppColors.semanticRed.withValues(alpha: 0.15)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03)),
          width: isDanger ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildSettingsDivider(bool isDarkMode) {
    return Divider(
      height: 1.0,
      thickness: 1.0,
      color: isDarkMode
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03),
      indent: 72.0,
    );
  }

  Widget _buildSettingsItemRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDanger
                          ? AppColors.semanticRed
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18.0,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDarkMode ? AppColors.darkModal : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(
                          Icons.file_download_outlined,
                          color: AppColors.accentTeal,
                          size: 22.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Text(
                        'Impor Data JSON',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Tempelkan teks JSON cadangan Anda di bawah. Mengimpor data akan menimpa seluruh transaksi dan rekening Anda saat ini.',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: '{\n  "version": 1,\n  "accounts": [...]\n}',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        fontSize: 11.0,
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? AppColors.darkElevated
                          : const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14.0),
                    ),
                    style: TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'monospace',
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12.0),
                      ElevatedButton(
                        onPressed: () async {
                          final jsonStr = textController.text.trim();
                          if (jsonStr.isEmpty) return;

                          final success =
                              await DatabaseBackupHelper.importFromJson(jsonStr);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (success) {
                              ref.invalidate(transactionsNotifierProvider);
                              ref.invalidate(accountsNotifierProvider);
                              ref.invalidate(categoriesNotifierProvider);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Data berhasil dipulihkan (Restore Sukses)!'),
                                  backgroundColor: AppColors.income,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Format JSON tidak valid atau rusak.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.white : AppColors.primaryBlack,
                          foregroundColor: isDarkMode ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Impor',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  void _confirmResetData(BuildContext context, WidgetRef ref) {
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.semanticRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: AppColors.semanticRed,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Text(
                      'Reset Semua Data',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Apakah Anda yakin ingin menghapus seluruh data keuangan? Tindakan ini akan menghapus semua riwayat transaksi, anggaran, dan rekening Anda secara permanen.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 12.0),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(transactionsNotifierProvider.notifier).resetAllData();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Semua data berhasil direset ke kondisi awal'),
                            backgroundColor: AppColors.semanticRed,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.semanticRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

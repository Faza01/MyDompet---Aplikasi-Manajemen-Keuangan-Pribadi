import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../data/models/debt.dart';
import '../../data/models/debt_repayment.dart';
import '../accounts/accounts_provider.dart';
import '../transactions/transactions_provider.dart';

class DebtsNotifier extends AsyncNotifier<List<DebtModel>> {
  @override
  FutureOr<List<DebtModel>> build() async {
    return _fetchDebts();
  }

  Future<List<DebtModel>> _fetchDebts() async {
    final db = DatabaseHelper.instance;
    final maps = await db.getAllDebts();
    return maps.map((m) => DebtModel.fromMap(m)).toList();
  }

  Future<void> addDebt(DebtModel debt) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = DatabaseHelper.instance;
      await db.insertDebt(debt.toMap());
      
      // Invalidate related providers so balance and lists update
      ref.invalidate(accountsNotifierProvider);
      ref.invalidate(transactionsNotifierProvider);
      
      return _fetchDebts();
    });
  }

  Future<void> deleteDebt(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = DatabaseHelper.instance;
      await db.deleteDebt(id);
      
      // Invalidate related providers so balance and lists update
      ref.invalidate(accountsNotifierProvider);
      ref.invalidate(transactionsNotifierProvider);
      
      return _fetchDebts();
    });
  }

  Future<void> repayDebt({
    required int debtId,
    required double amount,
    required int accountId,
    required String contactName,
    required String type,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = DatabaseHelper.instance;
      await db.insertRepayment(debtId, amount, accountId, contactName, type);
      
      // Invalidate related providers so balance and lists update
      ref.invalidate(accountsNotifierProvider);
      ref.invalidate(transactionsNotifierProvider);
      
      return _fetchDebts();
    });
  }

  Future<List<DebtRepaymentModel>> getRepayments(int debtId) async {
    final db = DatabaseHelper.instance;
    final maps = await db.getRepaymentsForDebt(debtId);
    return maps.map((m) => DebtRepaymentModel.fromMap(m)).toList();
  }
}

final debtsNotifierProvider =
    AsyncNotifierProvider<DebtsNotifier, List<DebtModel>>(
  DebtsNotifier.new,
);

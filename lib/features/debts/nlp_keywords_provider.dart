import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../data/models/nlp_debt_keyword.dart';

class NlpKeywordsNotifier extends AsyncNotifier<List<NlpDebtKeyword>> {
  @override
  Future<List<NlpDebtKeyword>> build() async {
    final dbHelper = DatabaseHelper.instance;
    final list = await dbHelper.getNlpKeywords();
    return list.map((m) => NlpDebtKeyword.fromMap(m)).toList();
  }

  Future<void> addKeyword(String keyword, String type) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertNlpKeyword(keyword, type);
      final list = await dbHelper.getNlpKeywords();
      return list.map((m) => NlpDebtKeyword.fromMap(m)).toList();
    });
  }

  Future<void> deleteKeyword(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteNlpKeyword(id);
      final list = await dbHelper.getNlpKeywords();
      return list.map((m) => NlpDebtKeyword.fromMap(m)).toList();
    });
  }
}

final nlpKeywordsNotifierProvider =
    AsyncNotifierProvider<NlpKeywordsNotifier, List<NlpDebtKeyword>>(() {
  return NlpKeywordsNotifier();
});

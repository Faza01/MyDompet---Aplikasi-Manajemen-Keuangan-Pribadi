class NlpDebtKeyword {
  final int? id;
  final String keyword; // lowercase trigger phrase
  final String type;    // 'debt' | 'receivable'

  NlpDebtKeyword({
    this.id,
    required this.keyword,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'keyword': keyword.toLowerCase().trim(),
      'type': type,
    };
  }

  factory NlpDebtKeyword.fromMap(Map<String, dynamic> map) {
    return NlpDebtKeyword(
      id: map['id'] as int?,
      keyword: map['keyword'] as String,
      type: map['type'] as String,
    );
  }
}

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

  DebtRepaymentModel copyWith({
    int? id,
    int? debtId,
    double? amount,
    int? transactionId,
    DateTime? createdAt,
  }) {
    return DebtRepaymentModel(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
